# Instrucciones de Instalación y Configuración de Infraestructura

## Requisitos Previos
- Terraform 1.0 o superior
- AWS CLI configurado
- Git

## Configuración de Terraform

1. Instalar Terraform:
   - Windows (usando Chocolatey):
   ```bash
   choco install terraform
   ```
   - MacOS (usando Homebrew):
   ```bash
   brew install terraform
   ```
   - Linux:
   ```bash
   wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   sudo apt update && sudo apt install terraform
   ```

2. Configurar credenciales AWS:
   ```bash
   aws configure
   ```
   Ingresar:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name (ej: us-east-1)
   - Default output format (json)

3. Clonar y preparar el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/meli-inventory-solution.git
   cd meli-inventory-solution/terraform
   ```

4. Inicializar Terraform:
   ```bash
   terraform init
   ```

5. Revisar plan de infraestructura:
   ```bash
   terraform plan
   ```

6. Aplicar la infraestructura:
   ```bash
   terraform apply
   ```

## Destruir Infraestructura

Cuando necesites eliminar la infraestructura:
```bash
cd terraform
terraform destroy
```

## Notas Importantes
- Asegúrate de tener suficientes permisos en tu cuenta AWS
- Revisa los costos asociados antes de aplicar la infraestructura
- Mantén tus credenciales seguras y nunca las compartas
- Ejecuta `terraform destroy` cuando ya no necesites la infraestructura para evitar costos innecesarios
