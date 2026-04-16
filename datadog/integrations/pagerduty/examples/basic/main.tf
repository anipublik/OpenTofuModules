module "example" {
  source = "../../"

  config_file = "./config.yaml"
}

output "id" {
  value = module.example.*
}
