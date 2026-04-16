module "apm_monitor" {
  source = "../../"

  config_file = "./config.yaml"
}

output "monitor_id" {
  value = module.apm_monitor.monitor_id
}
