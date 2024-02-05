module "create_kms_key_registry" {
  source  = "../kms"
  description = "key-${var.name}-registry"
  deletion_window_in_days = 7
}

# ECR Repository
resource "aws_ecr_repository" "this" {
  name                 = "${var.name}" # Name your repository
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
  force_delete = true
  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = module.create_kms_key_registry.key_arn
  }
}
