###########################################
# Variables Globales
###########################################

variable "client" {
  description = "Identificador del cliente"
  type        = string
  
  validation {
    condition     = length(var.client) > 0
    error_message = "El valor de client no puede estar vacío."
  }
}

variable "project" {
  description = "Nombre del proyecto asociado a las state machines"
  type        = string
  
  validation {
    condition     = length(var.project) > 0
    error_message = "El valor de project no puede estar vacío."
  }
}

variable "environment" {
  description = "Entorno en el que se desplegarán las state machines (dev, qa, pdn)"
  type        = string
  
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn."
  }
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
    
    # Encryption configuration
    enable_encryption         = optional(bool, true)
    kms_key_id                = optional(string, "")
    kms_data_key_reuse_period = optional(number, 900)
    
    # Logging configuration
    enable_logging            = optional(bool, true)
    log_destination           = optional(string, "")
    include_execution_data    = optional(bool, true)
    log_level                 = optional(string, "ERROR")
    
    # Tracing configuration
    enable_tracing            = optional(bool, true)
    
    # Tags
    additional_tags           = optional(map(string), {})
  }))
  
  validation {
    condition = alltrue([
      for k, v in var.state_machines_config : 
      contains(["STANDARD", "EXPRESS"], v.type)
    ])
    error_message = "El tipo de state machine debe ser 'STANDARD' o 'EXPRESS'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.state_machines_config : 
      contains(["ALL", "ERROR", "FATAL", "OFF"], v.log_level)
    ])
    error_message = "El nivel de log debe ser uno de: 'ALL', 'ERROR', 'FATAL', 'OFF'."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.state_machines_config : 
      length(v.role_arn) > 0
    ])
    error_message = "El role_arn es obligatorio para cada state machine."
  }
  
  validation {
    condition = alltrue([
      for k, v in var.state_machines_config : 
      (length(v.definition) > 0 && length(v.definition_s3_bucket) == 0 && length(v.definition_s3_key) == 0) ||
      (length(v.definition) == 0 && length(v.definition_s3_bucket) > 0 && length(v.definition_s3_key) > 0)
    ])
    error_message = "Debe proporcionar 'definition' (inline) O 'definition_s3_bucket' + 'definition_s3_key' (desde S3), pero no ambos."
  }
}
