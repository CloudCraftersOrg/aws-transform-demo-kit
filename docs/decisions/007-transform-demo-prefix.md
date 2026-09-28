# 007 — `transform-demo-` replaces `fbctf-` as the resource prefix

**Status:** accepted, 2026-09-14. Follows [ADR 006](006-retire-fbctf.md).

## Context

Every AWS resource this repo creates carried the `fbctf-` prefix because the
`AWSTransformAccess` permission set (defined in the `aws-access` repo,
`demo_app_prefix = "fbctf"`) scopes IAM, S3 and Secrets Manager writes to that
prefix. fbctf itself was retired in ADR 006 and the repo was renamed to
`aws-transform-demo-kit`; the prefix was the last thing still named after an
app the kit no longer deploys. The demos concluded on 2026-09-14 and all three
on-demand roots were destroyed, so there is no live estate to migrate.

## Decision

The prefix is **`transform-demo-`**. Concretely:

| Was | Is |
|---|---|
| tag `Project = fbctf-demo` | `Project = transform-demo` |
| state bucket `fbctf-demo-tfstate-<acct>-use1`, keys `fbctf-<root>/` | `transform-demo-tfstate-<acct>-use1`, keys `<root>/terraform.tfstate` |
| `fbctf-sqlmod*`, `fbctf-oramod*`, `fbctf-discovery*` (VPCs, hosts, SGs, roles, secrets, key pair) | `transform-demo-sqlmod*`, `transform-demo-oramod*`, `transform-demo-discovery*` |
| buckets `fbctf-sqlmod-schema-…`, `fbctf-oramod-artifacts-…`, `fbctf-discovery-export-…` | `transform-demo-sqlmod-schema-…`, `transform-demo-oramod-artifacts-…`, `transform-demo-discovery-export-…` |
| hand-made source bucket `fbctf-transform-src-…` | `transform-demo-src-…` |
| persistent bucket `fbctf-demo-artifacts-…` | `transform-demo-artifacts-…` (fresh; the old bucket holds fbctf-only content) |
| `inventory/out/fbctf-assessment.zip`, `fbctf-vmware-import.zip` | `transform-demo-assessment.zip`, `transform-demo-vmware-import.zip` |
| `atx` custom definition `fbctf-after-terraform` | `transform-demo-after-terraform` |

The unwired fbctf modules keep their `startswith(var.name, "transform-demo-")`
validations so they stay consistent with the permission set if ever reused;
their app-specific content (HHVM user-data, `db_name = "fbctf"`) is untouched
because it *is* the retired app. History documents (ADRs 001–006,
`fbctf-aws-requirements.md`, the architecture brief, the artifacts manifest,
the committed discovery export) keep the names they were written with.

## Sequencing — the permission set gates everything

Nothing under the new prefix can be created until `aws-access` is applied with
`demo_app_prefix = "transform-demo"`, and once it is, the role loses access to
the old `fbctf-*` buckets. So:

1. **Before** merging the `aws-access` change, an operator with the current set
   empties and deletes `fbctf-demo-tfstate-…` (all state keys are empty) and
   `fbctf-demo-artifacts-…` (fbctf-only content, see the manifest), or the team
   accepts that an account admin will remove them later.
2. Merge `aws-access` (`chore/transform-demo-prefix`): variable default, the
   `Fbctf*` → `DemoStack*` sids, the set description. CI applies it.
3. `aws sso login --sso-session cloudcrafters`, then the one-time bootstrap in
   the README (state bucket) and Phase 0 of the runbook (source bucket).
4. `make init ENV=<root>` works again; `make apply` as before.

## Consequences

- `docs/cloudlab-transform-permissions.md` now describes the prefix variable
  change instead of the original fbctf statements.
- `inventory/fleet.yaml` still carries the two fbctf `i-*` rows and
  `inventory/ASSESSMENT_INTENT.md` still narrates the fbctf assessment — both
  are input data for the MPA import and are a separate refresh.
- The local clone directory may still be called `fbctf-aws`; nothing in the
  repo depends on that path.
