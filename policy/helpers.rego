package terraform

import rego.v1

# Collect every planned resource at any depth under planned_values.root_module
# using walk(), which avoids illegal self-recursive rules.
planned_resources contains resource if {
    root := object.get(object.get(input, "planned_values", {}), "root_module", {})
    walk(root, [_, node])
    is_object(node)
    some resource in object.get(node, "resources", [])
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
