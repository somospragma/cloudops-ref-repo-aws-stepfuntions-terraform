###########################################
# Definicion Outputs Step Functions
###########################################

output "state_machine_arns" {
  description = "ARNs de las state machines creadas"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.arn }
}

output "state_machine_ids" {
  description = "IDs de las state machines creadas"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.id }
}

output "state_machine_names" {
  description = "Nombres de las state machines creadas"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.name }
}

output "state_machine_status" {
  description = "Estado de las state machines creadas"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.status }
}

output "state_machine_creation_dates" {
  description = "Fechas de creación de las state machines"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.creation_date }
}

output "state_machine_version_arns" {
  description = "ARNs de las versiones de las state machines (si publish=true)"
  value       = { for k, v in aws_sfn_state_machine.this : k => v.state_machine_version_arn }
}
