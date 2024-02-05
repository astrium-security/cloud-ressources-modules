# Create registry pour l'app 
module "create_ecr_registry" {
  source  = "../../../aws/standalone_resources/ecr"
  name = "${var.app_env}-${var.app_name}"
}

