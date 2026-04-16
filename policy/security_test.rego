package terraform

import rego.v1

test_public_access_denied_in_production if {
    deny[msg] with input as {
        "planned_values": {
            "root_module": {
                "resources": [{
                    "address": "azurerm_mssql_server.test",
                    "mode": "managed",
                    "values": {
                        "public_network_access_enabled": true,
                        "tags": {
                            "environment": "production",
                            "team": "platform",
                            "cost_center": "eng-001",
                            "managed_by": "opentofu",
                            "module": "azure/storage/sql"
                        }
                    }
                }]
            }
        }
    }
    msg == "Public network access is not allowed in production: azurerm_mssql_server.test"
}

test_encryption_required if {
    deny[msg] with input as {
        "planned_values": {
            "root_module": {
                "resources": [{
                    "address": "aws_db_instance.test",
                    "mode": "managed",
                    "values": {
                        "storage_encrypted": false,
                        "tags": {
                            "environment": "staging",
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
    msg == "Encryption must be enabled on aws_db_instance.test"
}
