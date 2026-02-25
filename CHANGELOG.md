# Changelog

Todos los cambios notables en este módulo serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

## [Unreleased]

## [1.0.0] - 2025-02-25

### Added
- Versión inicial del módulo de Step Functions
- Soporte para creación de múltiples state machines usando `for_each`
- Configuración de cifrado con KMS (CUSTOMER_MANAGED_KMS_KEY)
- Configuración de logging a CloudWatch Logs
- Configuración de tracing con AWS X-Ray
- Soporte para tipos STANDARD y EXPRESS
- **Soporte para cargar definiciones desde S3** (inline o desde bucket S3)
- Validaciones de entrada para garantizar configuraciones correctas
- Nomenclatura estándar según PC-IAC-003
- Etiquetado consistente según PC-IAC-004
- Outputs granulares con ARNs e IDs
- Ejemplo funcional en directorio `sample/` con 4 escenarios
- Documentación completa en README.md
