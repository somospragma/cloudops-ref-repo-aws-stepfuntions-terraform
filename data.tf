#######################################################
# Data Sources
#######################################################
# Los Data Sources deben estar en el Root (PC-IAC-011)
# Este archivo se mantiene para cumplir con PC-IAC-001

# Data aws_caller_identity
data "aws_caller_identity" "current" {
  provider = aws.project
}

# Data validacion region
data "aws_region" "current" {
  provider = aws.project
}

# Data source para cargar definiciones desde S3 (opcional)
# Solo se crea para state machines que usan definition_s3_bucket
data "aws_s3_object" "definition" {
  provider = aws.project
  for_each = {
    for k, v in var.state_machines_config : k => v
    if length(v.definition_s3_bucket) > 0 && length(v.definition_s3_key) > 0
  }

  bucket = each.value.definition_s3_bucket
  key    = each.value.definition_s3_key
}
