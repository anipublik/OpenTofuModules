package terraform

import rego.v1

required_tag_keys := {"environment", "team", "cost_center", "managed_by", "module"}
allowed_environments := {"dev", "development", "staging", "stage", "prod", "production"}

deny contains msg if {
    some resource in managed_resources
    tags := resource_tags(resource)
    some key in required_tag_keys
    object.get(tags, key, "") == ""
    msg := sprintf("Missing required tag %q on %s", [key, resource.address])
}

deny contains msg if {
    some resource in managed_resources
    lower(object.get(resource_tags(resource), "managed_by", "")) != "opentofu"
    msg := sprintf("managed_by tag must equal \"opentofu\" on %s", [resource.address])
}

deny contains msg if {
    some resource in managed_resources
    env := lower(environment(resource))
    env != ""
    not allowed_environments[env]
    msg := sprintf("Invalid environment tag %q on %s", [env, resource.address])
}
