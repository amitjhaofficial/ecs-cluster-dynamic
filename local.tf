locals {
  
  services_map = {
    for svc in var.ecs_services : svc.name => svc
  }

 
  clusters = {
    "external-cluster" = {}
    "internal-cluster" = {}
  }


  albs = {
    "external-alb" = {
      internal = false
    }
    "int-alb" = {
      internal = true
    }
  }

  
  service_hosts = {
    for svc_key, svc in local.services_map :
    svc_key => (
      can(svc.host) && svc.host != "" ? svc.host : "${svc_key}.${var.domain_name}"
    )
  }


  ecr_image_uris = {
    for svc_key, svc_val in local.services_map :
    svc_key =>
      (
        contains(keys(data.aws_ecr_image.latest_images), svc_key) &&
        can(data.aws_ecr_image.latest_images[svc_key].image_digest)
      )
      ? "${var.aws_account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.project_name_prefix}-${svc_key}-${var.environment}@${data.aws_ecr_image.latest_images[svc_key].image_digest}"
      : svc_val.image
  }

 service_map = {
  for svc_key, svc in local.services_map :
  svc_key => merge(svc, {
    host           = try(svc.host, null),
    image          = local.ecr_image_uris[svc_key],
    container_port = svc.container_port != null ? svc.container_port : var.services_config[svc_key].port,
    cluster        = svc.cluster,
    alb            = svc.alb
  })
}
}






