# Non-secret runtime configuration under /transform-demo/* — read by both tiers'
# user-data (the instance roles allow ssm:GetParameter on /transform-demo/*).
# /transform-demo/nlb_dns is added by the NLB module in Phase 5.

resource "aws_ssm_parameter" "this" {
  for_each = var.parameters

  name  = "/transform-demo/${each.key}"
  type  = "String"
  value = each.value
}
