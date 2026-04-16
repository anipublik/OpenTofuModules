package terraform

import rego.v1

test_missing_required_tag if {
    deny[msg] with input as {
        "planned_values": {
            "root_module": {
                "resources": [{
                    "address": "aws_s3_bucket.test",
                    "mode": "managed",
                    "values": {
                        "tags": {
                            "team": "platform",
                            "cost_center": "eng-001",
                            "managed_by": "opentofu",
                            "module": "aws/storage/s3"
                        }
                    }
                }]
            }
        }
    }
    msg == "Missing required tag \"environment\" on aws_s3_bucket.test"
}

test_invalid_managed_by_tag if {
    deny[msg] with input as {
        "planned_values": {
            "root_module": {
                "resources": [{
                    "address": "aws_s3_bucket.test",
                    "mode": "managed",
                    "values": {
                        "tags": {
                            "environment": "production",
                            "team": "platform",
                            "cost_center": "eng-001",
                            "managed_by": "terraform",
                            "module": "aws/storage/s3"
                        }
                    }
                }]
            }
        }
    }
    msg == "managed_by tag must equal \"opentofu\" on aws_s3_bucket.test"
}
