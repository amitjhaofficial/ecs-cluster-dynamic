output "ecs_clusters" {
  value = {
    for k, cluster in aws_ecs_cluster.ecs_clusters :
    k => cluster.name
  }
}


output "alb_dns_names" {
  value = {
    for k, alb in aws_lb.albs :
    k => alb.dns_name
  }
}

output "ecs_services" {
  value = {
    for k, svc in aws_ecs_service.nginx_service :
    k => svc.name
  }
}

output "alb_listeners" {
  value = {
    for k, listener in aws_lb_listener.http :
    k => listener.arn
  }
}
