#######################################################
# Transformaciones y Configuración
#######################################################

locals {
  # Prefijo de gobernanza (PC-IAC-025)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"
  
  # Transformar configuración inyectando IDs dinámicos desde data sources (PC-IAC-026)
  state_machines_config_transformed = {
    for key, config in var.state_machines_config : key => merge(config, {
      # Inyectar role_arn desde data source si está vacío (PC-IAC-009)
      role_arn = length(config.role_arn) > 0 ? config.role_arn : data.aws_iam_role.stepfunctions.arn
      
      # Inyectar log_destination desde data source si está vacío
      log_destination = length(config.log_destination) > 0 ? config.log_destination : "${data.aws_cloudwatch_log_group.stepfunctions.arn}:*"
      
      # Inyectar kms_key_id desde data source si está vacío
      kms_key_id = length(config.kms_key_id) > 0 ? config.kms_key_id : data.aws_kms_key.stepfunctions.arn
    })
  }
}
