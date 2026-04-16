package terraform

import rego.v1

test_missing_required_output if {
    deny[msg] with input as {
        "planned_values": {
            "outputs": {
                "resource_id": {"value": "abc"},
                "resource_name": {"value": "production-platform-rds-main"}
            }
        }
    }
    msg == "Missing required output \"resource_region\""
}
