package terraform

import rego.v1

test_name_must_start_with_environment_and_team if {
    deny[msg] with input as {
        "planned_values": {
            "root_module": {
                "resources": [{
                    "address": "aws_db_instance.test",
                    "mode": "managed",
                    "values": {
                        "identifier": "db-prod-main",
                        "tags": {
                            "environment": "production",
                            "team": "platform",
                            "cost_center": "eng-001",
                            "managed_by": "opentofu",
                            "module": "aws/storage/rds"
                        }
                    }
                }]
            }
        }
    }
    msg == "Resource aws_db_instance.test name \"db-prod-main\" must start with \"production-platform-\""
}
