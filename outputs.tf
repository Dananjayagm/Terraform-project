output "vpc_id" {
  value = module.vpc.vpc_id
}

output "ecs_cluster_id" {
  value = module.ecs_cluster.ecs_cluster_id
}

output "alb_dns_name" {
  value = module.alb.this_lb_dns_name
}

output "web_acl_id" {
  value = aws_waf_web_acl.web_acl.id
}
