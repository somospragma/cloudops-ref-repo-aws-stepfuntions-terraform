#######################################################
# Data Sources
#######################################################

# Data aws_caller_identity
data "aws_caller_identity" "current" {
  provider = aws.principal
}

# Data validacion region
data "aws_region" "current" {
  provider = aws.principal
}

# Obtener rol IAM para Step Functions por nomenclatura estándar
data "aws_iam_role" "stepfunctions" {
  provider = aws.principal
  name     = "${var.client}-${var.project}-${var.environment}-role-stepfunctions"
}

# Obtener CloudWatch Log Group por nomenclatura estándar
data "aws_cloudwatch_log_group" "stepfunctions" {
  provider = aws.principal
  name     = "/aws/stepfunctions/${var.client}-${var.project}-${var.environment}"
}

# Obtener KMS Key por alias
data "aws_kms_key" "stepfunctions" {
  provider = aws.principal
  key_id   = "alias/${var.client}-${var.project}-${var.environment}-kms-stepfunctions"
}
