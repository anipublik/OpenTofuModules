resource "aws_vpc" "this" {
  cidr_block           = local.config.network.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.tags, {
    Name = local.vpc_name
  })
}

# Public subnets
resource "aws_subnet" "public" {
  count = length(local.config.network.availability_zones)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(local.config.network.cidr_block, 4, count.index)
  availability_zone       = local.config.network.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-public-${local.config.network.availability_zones[count.index]}"
    Type = "public"
  })
}

# Private subnets
resource "aws_subnet" "private" {
  count = length(local.config.network.availability_zones)

  vpc_id            = aws_vpc.this.id
  cidr_block        = cidrsubnet(local.config.network.cidr_block, 4, count.index + length(local.config.network.availability_zones))
  availability_zone = local.config.network.availability_zones[count.index]

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-private-${local.config.network.availability_zones[count.index]}"
    Type = "private"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-igw"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(local.config.network.availability_zones)

  domain = "vpc"

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-nat-${local.config.network.availability_zones[count.index]}"
  })

  depends_on = [aws_internet_gateway.this]
}

# NAT Gateways
resource "aws_nat_gateway" "this" {
  count = length(local.config.network.availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-nat-${local.config.network.availability_zones[count.index]}"
  })

  depends_on = [aws_internet_gateway.this]
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private route tables
resource "aws_route_table" "private" {
  count = length(local.config.network.availability_zones)

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[count.index].id
  }

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-private-rt-${local.config.network.availability_zones[count.index]}"
  })
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPC Flow Logs
resource "aws_flow_log" "this" {
  count = local.config.security.flow_logs_enabled ? 1 : 0

  iam_role_arn    = aws_iam_role.flow_logs[0].arn
  log_destination = aws_cloudwatch_log_group.flow_logs[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-flow-logs"
  })
}

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = local.config.security.flow_logs_enabled ? 1 : 0

  name              = "/aws/vpc/${local.vpc_name}"
  retention_in_days = 90

  tags = local.tags
}

resource "aws_iam_role" "flow_logs" {
  count = local.config.security.flow_logs_enabled ? 1 : 0

  name = "${local.vpc_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "vpc-flow-logs.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "flow_logs" {
  count = local.config.security.flow_logs_enabled ? 1 : 0

  name = "${local.vpc_name}-flow-logs-policy"
  role = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${local.config.meta.region}.s3"

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-s3-endpoint"
  })
}

resource "aws_vpc_endpoint_route_table_association" "s3_private" {
  count = length(aws_route_table.private)

  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.${local.config.meta.region}.dynamodb"

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-dynamodb-endpoint"
  })
}

resource "aws_vpc_endpoint_route_table_association" "dynamodb_private" {
  count = length(aws_route_table.private)

  route_table_id  = aws_route_table.private[count.index].id
  vpc_endpoint_id = aws_vpc_endpoint.dynamodb.id
}

# Interface endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${local.vpc_name}-vpce-"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.config.network.cidr_block]
    description = "Allow HTTPS from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-vpce-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${local.config.meta.region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-ecr-api-endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${local.config.meta.region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.private[*].id
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(local.tags, {
    Name = "${local.vpc_name}-ecr-dkr-endpoint"
  })
}
