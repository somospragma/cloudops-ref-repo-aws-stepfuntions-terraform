# **Módulo Terraform: cloudops-ref-repo-aws-stepfunctions-terraform**

## Descripción

Este módulo facilita la creación y gestión de state machines en AWS Step Functions con todas las mejores prácticas de seguridad, nomenclatura y configuración según los estándares. Permite crear múltiples state machines con cifrado KMS, logging a CloudWatch, tracing con X-Ray, y soporte para tipos STANDARD y EXPRESS.

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Características

- ✅ Creación y gestión de múltiples state machines usando mapas de objetos
- ✅ Soporte para tipos STANDARD y EXPRESS workflows
- ✅ **Definición flexible**: JSON inline o carga desde S3
- ✅ Cifrado en reposo con KMS (CUSTOMER_MANAGED_KMS_KEY o AWS_OWNED_KEY)
- ✅ Logging de ejecuciones a CloudWatch Logs (solo STANDARD)
- ✅ Tracing con AWS X-Ray para observabilidad
- ✅ Publicación de versiones de state machines
- ✅ Etiquetado consistente según estándares organizacionales
- ✅ Validaciones de entrada para prevenir configuraciones incorrectas
- ✅ Outputs detallados para facilitar la integración

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-stepfunctions-terraform/
├── sample/
│   ├── data.tf
│   ├── locals.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── README.md
│   ├── terraform.tfvars
│   └── variables.tf
├── .gitignore
├── CHANGELOG.md
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
└── versions.tf
```

- Los archivos principales del módulo (`main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Implementación y Configuración

### Requisitos Técnicos

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

### Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
# sample/providers.tf
provider "aws" {
  alias   = "principal"
  region  = var.aws_region
  profile = var.profile
  
  default_tags {
    tags = var.common_tags
  }
}

# sample/main.tf
module "stepfunctions" {
  source = "../"
  providers = {
    aws.project = aws.principal
  }
  # ... resto de la configuración
}
```

### Configuración del Backend

> **Recomendación importante**: Para entornos de producción y colaboración en equipo, se recomienda configurar un backend remoto para almacenar el estado de Terraform (tfstate). Esto proporciona:
>
> - Bloqueo de estado para prevenir operaciones concurrentes
> - Respaldo y versionado del estado
> - Almacenamiento seguro de información sensible
> - Colaboración en equipo
>
> Ejemplo de configuración con S3 y DynamoDB:
>
> ```hcl
> terraform {
>   backend "s3" {
>     bucket         = "pragma-terraform-states"
>     key            = "stepfunctions/terraform.tfstate"
>     region         = "us-east-1"
>     encrypt        = true
>     dynamodb_table = "terraform-locks"
>   }
> }
> ```
>
> Asegúrese de que el bucket S3 tenga el versionado habilitado y que la tabla DynamoDB tenga una clave primaria llamada `LockID`.

### Convenciones de nomenclatura

El módulo sigue un estándar de nomenclatura para las state machines:

```
{client}-{project}-{environment}-sfn-{state_machine_name}
```

Por ejemplo:
- `pragma-ecommerce-dev-sfn-order-processing`
- `pragma-ecommerce-pdn-sfn-payment-workflow`

### Estrategia de Etiquetado

El módulo maneja el etiquetado de la siguiente manera:

1. **Etiquetas obligatorias**: Se aplican a través del provider AWS usando `default_tags` en la configuración del provider.
   ```hcl
   provider "aws" {
     default_tags {
       tags = {
         environment = "dev"
         project = "ecommerce"
         owner = "cloudops"
         area = "infrastructure"
         provisioned = "terraform"
         datatype = "operational"
       }
     }
   }
   ```

2. **Etiqueta Name**: Se genera automáticamente siguiendo el estándar de nomenclatura para cada state machine.

3. **Etiquetas adicionales por recurso**: Se pueden especificar etiquetas adicionales para cada state machine individualmente mediante el atributo `additional_tags` en la configuración de cada state machine.

### Recursos Gestionados

| Name | Type |
|------|------|
| [aws_sfn_state_machine.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sfn_state_machine) | recurso |

### Parámetros de Entrada

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="client"></a> [client](#input\client) | Identificador del cliente | `string` | n/a | yes |
| <a name="project"></a> [project](#input\project) | Nombre del proyecto asociado a las state machines | `string` | n/a | yes |
| <a name="environment"></a> [environment](#input\environment) | Entorno de despliegue (dev, qa, pdn) | `string` | n/a | yes |
| <a name="state_machines_config"></a> [state_machines_config](#input\state_machines_config) | Configuración de state machines en AWS Step Functions | `map(object)` | n/a | yes |

### Estructura de Configuración

```hcl
variable "state_machines_config" {
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
```

> **Nota sobre la definición**: Debe proporcionar **una** de las siguientes opciones:
> - `definition`: JSON inline (recomendado para definiciones pequeñas)
> - `definition_s3_bucket` + `definition_s3_key`: Cargar JSON desde S3 (recomendado para definiciones grandes o gestionadas externamente)

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="definition"></a> [definition](#input\definition) | Definición de la state machine en Amazon States Language (JSON inline) | `string` | `""` | no* |
| <a name="definition_s3_bucket"></a> [definition_s3_bucket](#input\definition_s3_bucket) | Bucket S3 donde se encuentra el archivo JSON de definición | `string` | `""` | no* |
| <a name="definition_s3_key"></a> [definition_s3_key](#input\definition_s3_key) | Key (ruta) del archivo JSON en S3 | `string` | `""` | no* |
| <a name="role_arn"></a> [role_arn](#input\role_arn) | ARN del rol IAM para la state machine | `string` | n/a | yes |
| <a name="type"></a> [type](#input\type) | Tipo de state machine ("STANDARD" o "EXPRESS") | `string` | `"STANDARD"` | no |
| <a name="publish"></a> [publish](#input\publish) | Publicar versión de la state machine | `bool` | `false` | no |
| <a name="enable_encryption"></a> [enable_encryption](#input\enable_encryption) | Habilitar cifrado | `bool` | `true` | no |
| <a name="kms_key_id"></a> [kms_key_id](#input\kms_key_id) | ID o ARN de la clave KMS (vacío usa AWS_OWNED_KEY) | `string` | `""` | no |
| <a name="kms_data_key_reuse_period"></a> [kms_data_key_reuse_period](#input\kms_data_key_reuse_period) | Período de reutilización de data key en segundos | `number` | `900` | no |
| <a name="enable_logging"></a> [enable_logging](#input\enable_logging) | Habilitar logging (solo STANDARD) | `bool` | `true` | no |
| <a name="log_destination"></a> [log_destination](#input\log_destination) | ARN del CloudWatch Log Group (debe terminar en :*) | `string` | `""` | no |
| <a name="include_execution_data"></a> [include_execution_data](#input\include_execution_data) | Incluir datos de ejecución en logs | `bool` | `true` | no |
| <a name="log_level"></a> [log_level](#input\log_level) | Nivel de logging ("ALL", "ERROR", "FATAL", "OFF") | `string` | `"ERROR"` | no |
| <a name="enable_tracing"></a> [enable_tracing](#input\enable_tracing) | Habilitar AWS X-Ray tracing | `bool` | `true` | no |
| <a name="additional_tags"></a> [additional_tags](#input\additional_tags) | Etiquetas adicionales para la state machine | `map(string)` | `{}` | no |

### Valores de Salida

| Name | Description |
|------|-------------|
| <a name="state_machine_arns"></a> [state_machine_arns](#output\state_machine_arns) | ARNs de las state machines creadas |
| <a name="state_machine_ids"></a> [state_machine_ids](#output\state_machine_ids) | IDs de las state machines creadas |
| <a name="state_machine_names"></a> [state_machine_names](#output\state_machine_names) | Nombres de las state machines creadas |
| <a name="state_machine_status"></a> [state_machine_status](#output\state_machine_status) | Estado de las state machines creadas |
| <a name="state_machine_creation_dates"></a> [state_machine_creation_dates](#output\state_machine_creation_dates) | Fechas de creación de las state machines |
| <a name="state_machine_version_arns"></a> [state_machine_version_arns](#output\state_machine_version_arns) | ARNs de las versiones de las state machines (si publish=true) |

### Ejemplos de Uso

#### Ejemplo 1: Definición Inline (JSON embebido)

```hcl
module "stepfunctions" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-stepfunctions-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  # Configuración común
  client      = "pragma"
  project     = "ecommerce"
  environment = "dev"

  # Configuración de state machines con definición inline
  state_machines_config = {
    "order-processing" = {
      definition = jsonencode({
        Comment = "Order processing workflow"
        StartAt = "ValidateOrder"
        States = {
          ValidateOrder = {
            Type     = "Task"
            Resource = "arn:aws:lambda:us-east-1:123456789012:function:validate-order"
            Next     = "ProcessPayment"
          }
          ProcessPayment = {
            Type     = "Task"
            Resource = "arn:aws:lambda:us-east-1:123456789012:function:process-payment"
            End      = true
          }
        }
      })
      role_arn           = "arn:aws:iam::123456789012:role/StepFunctionsRole"
      type               = "STANDARD"
      kms_key_id         = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      log_destination    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/order-processing:*"
      additional_tags = {
        application = "order-management"
      }
    }
  }
}
```

#### Ejemplo 2: Definición desde S3

```hcl
module "stepfunctions" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-stepfunctions-terraform.git?ref=v1.0.0"
  
  providers = {
    aws.project = aws.principal
  }

  # Configuración común
  client      = "pragma"
  project     = "ecommerce"
  environment = "dev"

  # Configuración de state machines cargando definición desde S3
  state_machines_config = {
    "complex-workflow" = {
      # Cargar definición desde S3 (ideal para workflows grandes)
      definition_s3_bucket = "pragma-stepfunctions-definitions"
      definition_s3_key    = "workflows/complex-workflow.json"
      
      role_arn           = "arn:aws:iam::123456789012:role/StepFunctionsRole"
      type               = "STANDARD"
      kms_key_id         = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
      log_destination    = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/stepfunctions/complex-workflow:*"
      additional_tags = {
        application = "complex-processing"
        source      = "s3"
      }
    }
  }
}
```

## Consideraciones Operativas

### Definición de Workflows

El módulo soporta dos formas de proporcionar la definición de la state machine:

1. **Inline (JSON embebido)**: Ideal para definiciones pequeñas y simples
   - Usa el parámetro `definition`
   - Permite versionamiento junto con el código Terraform
   - Fácil de revisar en pull requests

2. **Desde S3**: Ideal para definiciones grandes o gestionadas externamente
   - Usa los parámetros `definition_s3_bucket` y `definition_s3_key`
   - Permite gestionar workflows complejos en archivos separados
   - Facilita la colaboración con equipos que no usan Terraform
   - El rol IAM de Terraform debe tener permisos de lectura en el bucket S3

**Ejemplo de archivo JSON en S3:**
```json
{
  "Comment": "Complex workflow managed in S3",
  "StartAt": "Step1",
  "States": {
    "Step1": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:step1",
      "Next": "Step2"
    },
    "Step2": {
      "Type": "Task",
      "Resource": "arn:aws:lambda:us-east-1:123456789012:function:step2",
      "End": true
    }
  }
}
```

### Tipos de Workflows

AWS Step Functions ofrece dos tipos de workflows:

1. **STANDARD**: Para workflows de larga duración (hasta 1 año), con garantía de ejecución exactamente una vez y auditoría completa.
2. **EXPRESS**: Para workflows de alta velocidad (hasta 5 minutos), con ejecución al menos una vez y menor costo.

### Cifrado y Seguridad

- **Cifrado en reposo**: Por defecto habilitado. Usa AWS_OWNED_KEY si no se especifica KMS key.
- **Cifrado con KMS**: Proporciona `kms_key_id` para usar CUSTOMER_MANAGED_KMS_KEY.
- **Roles IAM**: El rol debe tener permisos para invocar los servicios integrados (Lambda, SNS, SQS, etc.).

### Logging

- Solo disponible para workflows STANDARD
- El CloudWatch Log Group debe existir previamente
- El ARN del log group debe terminar con `:*`
- El rol IAM debe tener permisos para escribir en CloudWatch Logs

### Tracing

- AWS X-Ray proporciona visibilidad end-to-end de las ejecuciones
- El rol IAM debe tener permisos para X-Ray
- Útil para debugging y optimización de performance

### Limitaciones y Restricciones

- El tipo de workflow (STANDARD/EXPRESS) no puede cambiarse después de la creación
- Los workflows EXPRESS no soportan logging configuration
- Límite de 10,000 state machines por cuenta (puede aumentarse)
- Tamaño máximo de definición: 1 MB

## Seguridad y Cumplimiento

### Consideraciones de seguridad

- **Cifrado**: Habilitado por defecto. Usa KMS para mayor control.
- **Roles IAM**: Sigue el principio de mínimo privilegio.
- **Logging**: Habilita logging para auditoría y troubleshooting.
- **Tracing**: Usa X-Ray para visibilidad de ejecuciones.

### Cumplimiento de Reglas PC-IAC

Este módulo cumple con las siguientes reglas de gobernanza:

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de Módulo | 18 archivos obligatorios (10 raíz + 8 sample/) |
| PC-IAC-002 | Variables | Tipificación explícita, validaciones, uso de `map(object)` |
| PC-IAC-003 | Nomenclatura | `{client}-{project}-{environment}-sfn-{key}` |
| PC-IAC-004 | Etiquetas | `default_tags` + etiqueta `Name` + `additional_tags` |
| PC-IAC-005 | Providers | Alias `aws.project` consumido desde Root |
| PC-IAC-006 | Versiones | `required_version >= 1.0.0`, `aws >= 4.31.0` |
| PC-IAC-007 | Outputs | Outputs granulares (ARNs, IDs) con descripciones |
| PC-IAC-009 | Tipos de Datos | Conversiones en `locals.tf`, uso de `optional()` |
| PC-IAC-010 | For_Each | Uso de `for_each` con `map(object)`, `create_before_destroy` |
| PC-IAC-011 | Data Sources | Data sources solo en Root, no en módulo |
| PC-IAC-014 | Bloques Dinámicos | `dynamic` para encryption, logging, tracing |
| PC-IAC-020 | Seguridad | Cifrado habilitado, logging, tracing, mínimo privilegio |
| PC-IAC-023 | Responsabilidad Única | Solo crea state machines, roles vienen como input |
| PC-IAC-026 | Patrón sample/ | `terraform.tfvars → locals.tf → main.tf` |

### Decisiones de Diseño

1. **Cifrado por defecto**: `enable_encryption = true` para cumplir PC-IAC-020
2. **Logging habilitado**: `enable_logging = true` para observabilidad
3. **Tracing habilitado**: `enable_tracing = true` para debugging
4. **Roles como input**: El módulo no crea roles IAM (PC-IAC-023)
5. **KMS opcional**: Permite AWS_OWNED_KEY o CUSTOMER_MANAGED_KMS_KEY
6. **Validaciones estrictas**: Previene configuraciones incorrectas
7. **Bloques dinámicos**: Configuración condicional de encryption, logging, tracing
8. **Lifecycle**: `create_before_destroy = true` para actualizaciones sin downtime
9. **Definición flexible**: Soporta JSON inline o carga desde S3
10. **Data source S3**: Solo se crea para state machines que usan S3 (optimización)

## Observaciones

- Este módulo está diseñado para ser flexible y adaptarse a diferentes escenarios de workflows.
- Los workflows STANDARD son recomendados para procesos críticos que requieren auditoría completa.
- Los workflows EXPRESS son ideales para procesamiento de eventos de alta velocidad.
- El rol IAM debe tener permisos para todos los servicios que la state machine invocará.
- El logging solo está disponible para workflows STANDARD.
- Considera usar versiones (`publish = true`) para despliegues controlados.
