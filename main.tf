###########################################
# Recursos Step Functions State Machine
###########################################
resource "aws_sfn_state_machine" "this" {
  provider = aws.project
  for_each = var.state_machines_config

  name       = local.state_machine_names[each.key]
  role_arn   = each.value.role_arn
  definition = local.state_machine_definitions[each.key]
  type       = each.value.type
  publish    = each.value.publish

  # Encryption configuration (PC-IAC-020: Cifrado en reposo obligatorio)
  dynamic "encryption_configuration" {
    for_each = each.value.enable_encryption ? [1] : []
    
    content {
      type                              = length(each.value.kms_key_id) > 0 ? "CUSTOMER_MANAGED_KMS_KEY" : "AWS_OWNED_KEY"
      kms_key_id                        = length(each.value.kms_key_id) > 0 ? each.value.kms_key_id : null
      kms_data_key_reuse_period_seconds = length(each.value.kms_key_id) > 0 ? each.value.kms_data_key_reuse_period : null
    }
  }

  # Logging configuration (PC-IAC-020: Observabilidad)
  dynamic "logging_configuration" {
    for_each = each.value.enable_logging && each.value.type == "STANDARD" ? [1] : []
    
    content {
      log_destination        = each.value.log_destination
      include_execution_data = each.value.include_execution_data
      level                  = each.value.log_level
    }
  }

  # Tracing configuration (PC-IAC-020: Observabilidad con X-Ray)
  dynamic "tracing_configuration" {
    for_each = each.value.enable_tracing ? [1] : []
    
    content {
      enabled = true
    }
  }

  # Lifecycle para prevenir destrucción accidental (PC-IAC-010)
  lifecycle {
    create_before_destroy = true
  }

  # Tags (PC-IAC-004)
  tags = merge(
    {
      Name = local.state_machine_names[each.key]
    },
    each.value.additional_tags
  )
}
