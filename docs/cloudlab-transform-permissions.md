# aws-access change: `transform-demo-` deploy prefix for the Transform cohort

Target: the `aws-access` repo. The `AWSTransformAccess` permission set's inline
policy (`data "aws_iam_policy_document" "partner_demo_access"` in
`policies.tf`) already scopes every sensitive write to a variable:

```hcl
variable "demo_app_prefix" {
  type        = string
  description = "Resource name prefix for the demo application stack."
  default     = "fbctf"
}
```

It is consumed in four places — S3 (`arn:aws:s3:::${var.demo_app_prefix}-*`),
IAM role and instance-profile writes, `iam:PassRole`, and Secrets Manager. The
service-wide allows (`ec2:*`, `rds:*`, `ssm:*`, `logs:*`, …) are not
prefix-scoped and need no change.

## The change ([ADR 007](decisions/007-transform-demo-prefix.md))

Branch `chore/transform-demo-prefix` in `aws-access`:

1. `variables.tf` — `demo_app_prefix` default `"fbctf"` → `"transform-demo"`;
   the `AWSTransformAccess` description no longer says "fbctf demo app".
2. `policies.tf` — sids `Fbctf*` → `DemoStack*` and the comments that named
   fbctf. Cosmetic: the sids are not referenced anywhere else.
3. `README.md` — the variables table default.

`terraform fmt` + `validate` pass. After merge and CI apply, re-login
(`aws sso login --sso-session cloudcrafters`) and the `cloudcrafters-sandbox`
profile can create `transform-demo-*` buckets, roles, instance profiles and
secrets — and can no longer touch `fbctf-*` ones.

## What the set still cannot do (unchanged, noted during the 2026-09-14 teardown)

These list calls are denied to the set and were worked around by hand; none
blocks a deploy or destroy of the three roots:

- `tag:GetResources` (Resource Groups Tagging API)
- `secretsmanager:ListSecrets` (individual `transform-demo-*` secrets are fine)
- `dms:Describe*`, `lambda:ListFunctions`, `elasticfilesystem:Describe*`,
  `sns:ListTopics`, `sqs:ListQueues`, `discovery:DescribeAgents`
- `ec2:Describe*` outside `us-east-1` / `us-west-2` (explicit region deny)

If the team wants the cohort to audit what Transform's own jobs leave behind
(DMS instances, Aurora targets), `dms:Describe*` and `rds:Describe*` reads
would be the additions — `rds:*` is already granted, so only DMS is missing.

## Transition warning

Applying the new prefix removes the set's access to `fbctf-demo-tfstate-…` and
`fbctf-demo-artifacts-…`. Delete them first with the current set, or hand
their deletion to an account admin. All fbctf state keys are already empty.
