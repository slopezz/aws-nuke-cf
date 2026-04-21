# aws-nuke-cf

This project deploys a periodic [aws-nuke](https://github.com/ekristen/aws-nuke) job into AWS accounts using **CloudFormation**.

## Key Files

- `template.yaml` — Single CloudFormation template containing all resources (S3, CodeBuild, IAM, EventBridge, SNS)
- `Makefile` — Deployment helpers (`make deploy`, `make run`, `make logs`, etc.)
- `examples/nuke-config.yml` — Example aws-nuke configuration

## Architecture

EventBridge Rule (cron) → CodeBuild Project → aws-nuke (downloaded binary)

- CodeBuild uses the standard Amazon Linux 2 image and downloads the aws-nuke binary at build time
- User's nuke config is stored in S3 and downloaded at runtime
- A shell script (sed/awk) auto-injects self-protection filters before running aws-nuke

## Self-Protection (3 layers)

1. **Config filters** — `_self_protection` preset injected at runtime with `__global__` tag filters + resource-specific name filters
2. **IAM deny** — Explicit deny policy on ARN patterns matching `${NamePrefix}-*` for IAM, S3, CodeBuild, EventBridge, Logs, SNS, and CloudFormation
3. **Resource tagging** — All resources tagged with `aws-nuke:managed=true`

## Validation

```bash
aws cloudformation validate-template --template-body file://template.yaml
```

## Deployment

```bash
make deploy CONFIG=examples/nuke-config.yml
make run    # manual trigger
make logs   # view logs
```
