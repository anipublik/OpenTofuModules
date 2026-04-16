package terraform

import rego.v1

module_resources(module) contains resource if {
    some resource in object.get(module, "resources", [])
}

module_resources(module) contains resource if {
    some child in object.get(module, "child_modules", [])
    some resource in module_resources(child)
}

planned_resources contains resource if {
    root := object.get(object.get(input, "planned_values", {}), "root_module", {})
    some resource in module_resources(root)
}

managed_resources contains resource if {
    some resource in planned_resources
    object.get(resource, "mode", "managed") == "managed"
}

resource_values(resource) := object.get(resource, "values", {})

resource_tags(resource) := object.get(resource_values(resource), "tags", {})

candidate_name(resource) := name if {
    values := resource_values(resource)
    some field in ["name", "identifier", "function_name", "bucket", "queue_name", "topic_name"]
    name := object.get(values, field, null)
    name != null
    name != ""
}

environment(resource) := object.get(resource_tags(resource), "environment", "")

team(resource) := object.get(resource_tags(resource), "team", "")

is_production(resource) if {
    lower(environment(resource)) == "production"
}

is_production(resource) if {
    lower(environment(resource)) == "prod"
}
