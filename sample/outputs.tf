###########################################
# Outputs del Ejemplo
###########################################

output "state_machine_arns" {
  description = "ARNs de las state machines creadas"
  value       = module.stepfunctions.state_machine_arns
}

output "state_machine_names" {
  description = "Nombres de las state machines creadas"
  value       = module.stepfunctions.state_machine_names
}

output "state_machine_status" {
  description = "Estado de las state machines creadas"
  value       = module.stepfunctions.state_machine_status
}
