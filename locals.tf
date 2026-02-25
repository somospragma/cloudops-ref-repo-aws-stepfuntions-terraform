###########################################
# Valores Locales y Transformaciones
###########################################

locals {
  # Prefijo de gobernanza (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"
  
  # Generar nombres estandarizados para las state machines (PC-IAC-003)
  state_machine_names = {
    for k, v in var.state_machines_config : k => "${local.governance_prefix}-sfn-${k}"
  }
  
  # Resolver definiciones: inline o desde S3 (PC-IAC-009)
  state_machine_definitions = {
    for k, v in var.state_machines_config : k => (
      length(v.definition) > 0 
        ? v.definition 
        : data.aws_s3_object.definition[k].body
    )
  }
}
