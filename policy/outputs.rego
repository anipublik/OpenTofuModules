package terraform

import rego.v1

required_output_keys := {"resource_id", "resource_name", "resource_region"}

deny contains msg if {
    outputs := object.get(object.get(input, "planned_values", {}), "outputs", {})
    count(outputs) > 0
    some key in required_output_keys
    object.get(outputs, key, null) == null
    msg := sprintf("Missing required output %q", [key])
}
