data "aws_ecr_image" "latest_images" {
  for_each = {
    for svc in var.ecs_services :
    svc.name => svc
    if svc.image == null || can(regex("^${var.aws_account_id}\\.dkr\\.ecr\\.", svc.image))
  }

  repository_name = "${var.project_name_prefix}-${each.key}-${var.environment}"
  most_recent     = true
}
