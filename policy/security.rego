package terraform

import rego.v1

deny contains msg if {
    some resource in managed_resources
    is_production(resource)
    object.get(resource_values(resource), "public_access", false) == true
    msg := sprintf("Public access is not allowed in production: %s", [resource.address])
}

deny contains msg if {
    some resource in managed_resources
    is_production(resource)
    object.get(resource_values(resource), "publicly_accessible", false) == true
    msg := sprintf("Public accessibility is not allowed in production: %s", [resource.address])
}

deny contains msg if {
    some resource in managed_resources
    is_production(resource)
    object.get(resource_values(resource), "public_network_access_enabled", false) == true
    msg := sprintf("Public network access is not allowed in production: %s", [resource.address])
}

deny contains msg if {
    some resource in managed_resources
    object.get(resource_values(resource), "storage_encrypted", true) == false
    msg := sprintf("Encryption must be enabled on %s", [resource.address])
}

deny contains msg if {
    some resource in managed_resources
    object.get(resource_values(resource), "encrypted", true) == false
    msg := sprintf("Encryption must be enabled on %s", [resource.address])
}

deny contains msg if {
    some resource in managed_resources
    is_production(resource)
    object.get(resource_values(resource), "deletion_protection", true) == false
    msg := sprintf("Deletion protection must be enabled in production: %s", [resource.address])
}
