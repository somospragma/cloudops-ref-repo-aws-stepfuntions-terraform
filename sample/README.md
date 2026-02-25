# Ejemplo de Uso del Módulo Step Functions

Este directorio contiene un ejemplo funcional de cómo usar el módulo de Step Functions.

## Prerrequisitos

1. Terraform >= 1.0.0 instalado
2. AWS CLI configurado con credenciales válidas
3. Rol IAM creado para Step Functions con permisos necesarios
4. CloudWatch Log Group creado (si se habilita logging)
5. KMS Key creada (si se usa cifrado con KMS)

## Estructura

```
sample/
├── README.md           # Este archivo
├── data.tf             # Data sources para obtener recursos existentes
├── locals.tf           # Transformaciones y construcción de configuración
├── main.tf             # Invocación del módulo
├── outputs.tf          # Outputs del ejemplo
├── providers.tf        # Configuración del provider
├── terraform.tfvars    # Valores de variables
└── variables.tf        # Definición de variables
```

## Flujo de Datos (PC-IAC-026)

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → ../
     (config)        (tipos)     (consulta)  (transform)  (invoca módulo)
```

## Pasos para Ejecutar

### 1. Configurar Variables

Edita `terraform.tfvars` con tus valores:

```hcl
aws_region  = "us-east-1"
profile     = "tu-perfil-aws"
client      = "pragma"
project     = "ecommerce"
environment = "dev"
```

### 2. Inicializar Terraform

```bash
terraform init
```

### 3. Validar Configuración

```bash
terraform validate
terraform fmt
```

### 4. Planificar Cambios

```bash
terraform plan
```

### 5. Aplicar Cambios

```bash
terraform apply
```

### 6. Ver Outputs

```bash
terraform output
```

## Limpieza

Para destruir los recursos creados:

```bash
terraform destroy
```

## Notas Importantes

- Este ejemplo usa configuración local para desarrollo
- Para producción, configura un backend remoto S3
- Asegúrate de que el rol IAM tenga los permisos necesarios
- El CloudWatch Log Group debe existir antes de aplicar
- La KMS Key debe existir si se usa cifrado con KMS
- **Para usar definiciones desde S3**: 
  - El bucket S3 debe existir y contener el archivo JSON
  - El rol de Terraform debe tener permisos `s3:GetObject` en el bucket
  - Ejemplo de archivo JSON: ver `sample/example-workflow.json`
