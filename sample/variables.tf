###########################################
# Variables Globales
###########################################
variable "aws_region" {
  description = "Región de AWS donde se desplegarán los recursos"
  type        = string
}

# Opcional para ejecutar el modulo localmente - Validar providers.tf 
variable "profile" {
  description = "Perfil de AWS a utilizar"
  type        = string
  default     = "default"
}

variable "client" {
  description = "Identificador del cliente"
  type        = string
}

variable "project" {
  description = "Nombre del proyecto asociado a las state machines"
  type        = string
}

variable "environment" {
  description = "Entorno en el que se desplegarán las state machines (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags to be applied to the resources"
}

###########################################
# Variables Modulo Step Functions
###########################################
variable "state_machines_config" {
  description = "Configuración de state machines en AWS Step Functions"
  type = map(object({
    definition                = optional(string, "")
    definition_s3_bucket      = optional(string, "")
    definition_s3_key         = optional(string, "")
    role_arn                  = string
    type                      = optional(string, "STANDARD")
    publish                   = optional(bool, false)
    enable_encryption         = optional(bool, true)
    kms_key_id                = optional(string, "")
    kms_data_key_reuse_period = optional(number, 900)
    enable_logging            = optional(bool, true)
    log_destination           = optional(string, "")
    include_execution_data    = optional(bool, true)
    log_level                 = optional(string, "ERROR")
    enable_tracing            = optional(bool, true)
    additional_tags           = optional(map(string), {})
  }))
}
