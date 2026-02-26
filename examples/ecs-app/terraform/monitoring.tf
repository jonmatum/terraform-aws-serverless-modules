module "waf" {
  count  = var.enable_waf ? 1 : 0
  source = "../../../modules/waf"

  name                    = "${var.app_name}-waf"
  scope                   = "REGIONAL"
  enable_rate_limiting    = true
  rate_limit              = var.waf_rate_limit
  enable_ip_reputation    = true
  enable_known_bad_inputs = true

  tags = var.tags

  depends_on = [module.alb]
}

resource "aws_wafv2_web_acl_association" "alb" {
  count        = var.enable_waf ? 1 : 0
  resource_arn = module.alb.alb_arn
  web_acl_arn  = module.waf[0].web_acl_arn

  depends_on = [module.waf]
}

module "cloudwatch_alarms" {
  count  = var.enable_alarms ? 1 : 0
  source = "../../../modules/cloudwatch-alarms"

  cluster_name            = module.ecs.cluster_name
  service_name            = module.ecs.service_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix
  sns_topic_arn           = var.alarm_sns_topic_arn
  cpu_threshold           = 80
  memory_threshold        = 80
  target_response_time    = 1

  tags = var.tags
}
