###########################################
# Definicion modulo Step Functions
###########################################

module "stepfunctions" {
  source = "../"
  
  providers = {
    aws.project = aws.principal
  }

  # Definicion variables Globales
  client      = var.client
  project     = var.project
  environment = var.environment

  # Definicion state_machines_config transformada (PC-IAC-026)
  state_machines_config = local.state_machines_config_transformed
}
