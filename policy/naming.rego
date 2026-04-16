package terraform

import rego.v1

deny contains msg if {
    some resource in managed_resources
    name := candidate_name(resource)
    env := environment(resource)
    team_name := team(resource)
    env != ""
    team_name != ""
    expected_prefix := sprintf("%s-%s-", [env, team_name])
    not startswith(lower(name), lower(expected_prefix))
    msg := sprintf("Resource %s name %q must start with %q", [resource.address, name, expected_prefix])
}
