# aws-transform-demo-kit

An **AWS Transform demo kit** for the **legacy "before" state** — the estate
Transform migrates. The modernized target (Fargate, Aurora) is Transform's
output, not this repo's.

| Part | What it is | Deployed? | Cost |
|---|---|---|---|
| **The assessment inventory** (`inventory/`) | A server portfolio as data → `generate.py` → one assessment ZIP | No — data | `$0` |
| **The modernization fixtures** (`modernization/`) | Real .NET Framework, Java 8, COBOL and T-SQL code for Transform's transformation agents | No — source only | `$0` |
| **The SQL Server estate** (`environments/sqlmod`) | One EC2 SQL Server 2022 + two live apps against it — **Contoso Scoreboard** (.NET Framework 4.8 / IIS) and **Project Nami** (WordPress-on-SQL-Server / PHP) — in a 2-AZ VPC | On demand | ~$0.20/hr up, `$0` destroyed |
| **The Oracle estate** (`environments/oramod`) | One EC2 Oracle 21c XE + **Contoso Catalog** (Java 8 / Spring Boot 2.7) against it, in a 2-AZ VPC | On demand | ~$0.15/hr up, `$0` destroyed |
| **The discovery collector** (`environments/discovery-collector`) | The real AWS Transform discovery tool + a synthetic Linux fleet + a Windows/SQL Express box; peers into the sqlmod and oramod VPCs. Its last export is committed at `inventory/discovery-tool-export/` | On demand | ~$0.30/hr up, self-terminating |

Feature-by-feature coverage: [`docs/transform-feature-coverage.md`](docs/transform-feature-coverage.md).
End-to-end run order: [`docs/demo-runbook.md`](docs/demo-runbook.md).
Scope decisions: [ADR 004](docs/decisions/004-demo-scope-expansion.md), [ADR 005](docs/decisions/005-drop-the-estate.md), [ADR 006](docs/decisions/006-retire-fbctf.md).

Decisions are recorded in [`docs/decisions/`](docs/decisions/); the S3 artifact inventory in [`docs/artifacts-manifest.md`](docs/artifacts-manifest.md).

---

## Deploying

- Account `337058058699` (Sandbox), profile `cloudcrafters-sandbox` with the `AWSTransformAccess` permission set, region `us-east-1` — colocated with the AWS Transform workspace.
- **Every resource name carries the `transform-demo-` prefix** ([ADR 007](docs/decisions/007-transform-demo-prefix.md)). The permission set scopes IAM, S3 and Secrets Manager writes to that prefix through the `demo_app_prefix` variable in the `aws-access` repo; anything named otherwise hits a denial.
- No SSH to the estate hosts — SSM Session Manager (the discovery collector is the exception: it SSHes into the fleet it inventories).

### Layout

Independent roots, each with its own state key in bucket `transform-demo-tfstate-337058058699-use1` (native S3 locking, no DynamoDB):

| Root | State key | Contents |
|---|---|---|
| `environments/sqlmod` | `sqlmod/terraform.tfstate` | The SQL Server estate — on demand |
| `environments/oramod` | `oramod/terraform.tfstate` | The Oracle estate — on demand |
| `environments/discovery-collector` | `discovery-collector/terraform.tfstate` | The discovery tool + fleet — on demand, self-terminating |
| `environments/artifacts` | `artifacts/terraform.tfstate` | One persistent, versioned bucket (`transform-demo-artifacts-…`) for things that must outlive a destroy cycle |

### One-time bootstrap

The state bucket is created by hand, once per account, before the first `make init`:

```sh
export AWS_PROFILE=cloudcrafters-sandbox
B=transform-demo-tfstate-337058058699-use1
aws s3api create-bucket --bucket $B --region us-east-1
aws s3api put-bucket-versioning --bucket $B --versioning-configuration Status=Enabled
aws s3api put-bucket-encryption --bucket $B --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
aws s3api put-public-access-block --bucket $B --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
```

Then `make init ENV=<root>` / `make apply ENV=<root>`; `make destroy ENV=<root>` after every session. The Transform source-code bucket (`transform-demo-src-337058058699-use1`) is created in Phase 0 of the [runbook](docs/demo-runbook.md).

### The retired fbctf live app

fbctf (Hack/HHVM, nginx, MySQL, memcached) was the first "before" state and was
retired on 2026-09-01 ([ADR 006](docs/decisions/006-retire-fbctf.md)): no
Transform code path, MySQL-locked. Its history stays in
[`fbctf-aws-requirements.md`](fbctf-aws-requirements.md), the
[architecture brief](docs/architecture-diagram-brief.md) and diagram
(`assets/fbctf-aws-architecture.png`), ADRs 001–003 and 006, the
[artifacts manifest](docs/artifacts-manifest.md), and the unwired `modules/`
(`alb-external`, `cache`, `config`, `database`, `iam`, `nlb-internal`,
`observability`, `security`, `service-tier`, `flow-log`, `vpc-endpoints`) plus
`scripts/`. None of it deploys.

---

## The assessment inventory

`inventory/` is a 14-server portfolio — Windows/.NET, SQL Server, Java, COBOL,
self-managed services, an idle box — expressed as YAML and turned into one
assessment ZIP. It costs nothing and is never deployed.

```sh
python3 -m pip install -r inventory/requirements.txt
python3 inventory/generate.py          # -> inventory/out/transform-demo-assessment.zip
```

Details, and what each server is there to trigger: [`inventory/README.md`](inventory/README.md).

---

## The modernization fixtures

`modernization/` holds real code for Transform's transformation agents — one
fixture per capability:

| Fixture | Capability |
|---|---|
| [`dotnet-scoreboard/`](modernization/dotnet-scoreboard) | .NET Framework 4.8 → cross-platform .NET |
| [`java-catalog/`](modernization/java-catalog) | Java 8 → 17 |
| [`cobol-rollup/`](modernization/cobol-rollup) | COBOL / mainframe |
| [`sqlserver-schema/`](modernization/sqlserver-schema) | SQL Server → Aurora schema conversion |
| [`atx-task.md`](modernization/atx-task.md) | Transform Custom (`atx`) — generate the target Terraform |

Source only — nothing here is deployed. See [`modernization/README.md`](modernization/README.md).

---

## The live estate

Three real applications on two database engines, in two on-demand roots. State
keys `sqlmod/` and `oramod/` in the same bucket as above.

| Root | Database | Apps | Transform jobs it feeds |
|---|---|---|---|
| [`environments/sqlmod`](environments/sqlmod) | SQL Server 2022 (EC2, `mssql/server:2022` container) | **Contoso Scoreboard** — ASP.NET Web Forms / .NET Framework 4.8 / IIS ([source](environments/sqlmod/app)); **Project Nami** — WordPress on SQL Server / PHP | .NET → .NET 8; SQL Server → Aurora (full agentic); the "no PHP code path" close |
| [`environments/oramod`](environments/oramod) | Oracle 21c XE (EC2, `gvenzl/oracle-xe` container) | **Contoso Catalog** — Java 8 / Spring Boot 2.7 ([source](environments/oramod/app)) | Java 8 → 17 (`atx`); Oracle → Aurora PostgreSQL |

```sh
cp environments/sqlmod/terraform.tfvars.example environments/sqlmod/terraform.tfvars   # set transform_ro_password
make apply   ENV=sqlmod
make apply   ENV=oramod
make destroy ENV=sqlmod && make destroy ENV=oramod   # after the demo
```

Both app tiers are reachable on `:80` from `app_allow_cidr` / `wordpress_allow_cidr`
(default `0.0.0.0/0` — tighten to your IP for a public demo). Database ports are
VPC-internal; SSH / WinRM / Oracle Net open only to the discovery-collector CIDR.

---

## The discovery collector

`environments/discovery-collector/` runs the **actual AWS Transform discovery
tool** on an EC2 host, peers into the two estates above, and SSH/WinRM-collects
12 hosts (6 synthetic Linux roles, a Windows + SQL Express box, and the 5 live
sqlmod/oramod hosts) into `discovery_tool_export.zip`. The last export is
committed at [`inventory/discovery-tool-export/`](inventory/discovery-tool-export),
so the assessment can ingest genuine discovery data at `$0` without re-running it.

```sh
cp environments/discovery-collector/terraform.tfvars.example environments/discovery-collector/terraform.tfvars
make apply   ENV=discovery-collector
terraform -chdir=environments/discovery-collector output next_steps
make destroy ENV=discovery-collector
```

See [`environments/discovery-collector/README.md`](environments/discovery-collector/README.md).
