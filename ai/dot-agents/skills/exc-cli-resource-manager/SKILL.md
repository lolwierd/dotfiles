---
name: exc-cli-resource-manager
description: Manage Excloud resources using the exc CLI (compute, networking, IAM, policy, billing, volumes, snapshots, public IPs, security groups). Use when executing or planning exc CLI commands, including VM exec via exc compute exec, with safety guardrails and authentication checks.
---

# Exc CLI Resource Manager

## Workflow

- Prefer `exc` CLI for all actions unless the user explicitly asks for SDK use.
- Ask for explicit confirmation before destructive actions.
- If authentication is missing, instruct the user to run `exc login` and stop.
- Use `--help` on any command to discover arguments and flags:
  - `exc --help`
  - `exc <group> --help`
  - `exc <group> <subcommand> --help`

## Authentication

- Require an authenticated `exc` session.
- If tokens are missing or config is invalid, ask the user to run:
  - `exc login`

## Safety Guardrails

- Ask for explicit confirmation before any of:
  - delete, terminate, release, detach, revoke, or policy changes
- Block or require explicit confirmation for destructive shell commands:
  - `shutdown`, `reboot`, `rm -rf`, `mkfs`, `dd`, `wipefs`

## Default Inputs

- Default zone comes from `~/.exc/config` unless overridden by the command.
- Default SSH user for exec is `ubuntu`.
- Use `sudo` for actions that require elevated privileges, such as writing to `/var`, installing packages, or managing services.
- If the user does not specify an instance type or image, default to:
  - `instance_type`: `t1.micro`
  - `image_id`: `10`

## Common VM Lifecycle Flow

- List options:
  - `exc compute instancetype list`
  - `exc compute image list`
  - `exc compute subnet list`
- Create a VM:
  - `exc compute create --name <name> --subnet_id <id> --allocate_public_ipv4 --image_id <id> --instance_type <type> --root_volume_size_gib <size>`
- Check VM details:
  - `exc compute get --id <vm_id>`
- Start/stop/restart/terminate:
  - `exc compute start --vm_id <vm_id>`
  - `exc compute stop --vm_id <vm_id>`
  - `exc compute restart --vm_id <vm_id>`
  - `exc compute terminate --vm_id <vm_id>`

## Compute Exec

- Prefer `exc compute exec` for command execution:
  - `exc compute exec --vm-id <vm_id> --command "uname -a"`
  - `exc compute exec --vm-id <vm_id> --script-file <path>`
- If the VM has no public IPv4, explain the current limitation and ask the user to attach a public IP or use console WS (future).
- If SSH fails, check:
  - VM has public IPv4 in `exc compute get --id <vm_id>`
  - The VM interface has a security group bound:
    - `exc securitygroup binding list --interface_id <interface_id>`
    - `exc securitygroup binding create --interface_id <interface_id> --security_group_id <sg_id>`
  - The security group has ingress allow for SSH and egress allow outbound:
    - `exc securitygroup rule create --security_group_id <sg_id> --is_ingress=true --protocol TCPv4 --port_range 22 --cidr <your_ip>/32`
    - `exc securitygroup rule create --security_group_id <sg_id> --is_ingress=false --protocol IPv4 --port_range ANY --cidr 0.0.0.0/0`

## Compute SCP

- Upload files to a VM using SCP over instance-connect:
  - `exc compute scp --vm-id <vm_id> --src ./local.txt --dst /tmp/remote.txt`
  - `exc compute scp --vm-id <vm_id> --src ./dir --dst /tmp --recursive`
- If the destination requires elevated permissions, upload to `/tmp` then move with `sudo` via `exc compute exec`.

## Compute Serial Logs

- Fetch serial console logs:
  - `exc compute seriallogs --id <vm_id>`
  - `exc compute seriallogs --id <vm_id> --boot_id <boot_id>`
  - `exc compute seriallogs --id <vm_id> --offset <offset> --direction older`
- Follow newer serial log lines:
  - `exc compute seriallogs --id <vm_id> -f`
- Behavior:
  - If `--boot_id` is omitted, the API defaults to the latest boot.
  - `--offset` and `--direction` must be used together.
  - Valid `--direction` values are `older` and `newer`.
  - `--limit` must be greater than `0` when specified.
  - `-f/--follow` is implemented by polling for `direction=newer`; it is not a native server-side stream.

## User Data

- Use `--user-data-file` with a bash script only.
- Require a shebang in the script:
  - `#!/bin/bash`
  - `#!/usr/bin/env bash`
  - `#!/bin/sh`
- Example:
  - `exc compute create ... --user-data-file ./userdata.sh`

## Networking and Public IPs

- List subnets:
  - `exc compute subnet list`
  - `exc compute subnet get --id <subnet_id>`
- Manage public IPv4:
  - `exc compute publicip list`
  - `exc compute publicip reserve --zone_id <zone> --name <name>`
  - `exc compute publicip release --reservation_id <id>`
  - `exc compute publicip associate --interface_id <if_id> --reservation_id <id>`
  - `exc compute publicip disassociate --reservation_id <id>`

## Security Groups

- Create/list/get/delete:
  - `exc securitygroup create --name <name>`
  - `exc securitygroup list`
  - `exc securitygroup get --security_group_id <id>`
  - `exc securitygroup delete --security_group_id <id>`
- Rules:
  - `exc securitygroup rule create --security_group_id <id> --is_ingress=true --protocol TCPv4 --port_range 22 --cidr <cidr>`
  - `exc securitygroup rule list --security_group_id <id>`
  - `exc securitygroup rule delete --security_group_rule_id <id>`
- Bindings:
  - `exc securitygroup binding create --interface_id <if_id> --security_group_id <sg_id>`
  - `exc securitygroup binding list --interface_id <if_id>`
  - `exc securitygroup binding delete --interface_id <if_id> --security_group_id <sg_id>`

## Volumes

- Create/list/get/rename/resize/delete:
  - `exc compute volume create --name <name> --zone_id <zone> --size_gib <size> --perf_tier <tier>`
  - `exc compute volume list`
  - `exc compute volume get --id <volume_id>`
  - `exc compute volume rename --volume_id <id> --name <new_name>`
  - `exc compute volume resize --volume_id <id> --new_size_gib <size>`
  - `exc compute volume delete --volume_id <id>`

## Snapshots

- Create/list/delete:
  - `exc compute snapshot create --volume_id <id>`
  - `exc compute snapshot list`
  - `exc compute snapshot delete --snapshot_id <id>`

## IAM, Policies, and API Keys

- Orgs:
  - `exc org list`
- Accounts:
  - `exc account list`
  - `exc account invite --email <email>`
  - `exc account revoke --invite_id <id>`
- Service accounts:
  - `exc serviceaccount list`
  - `exc serviceaccount delete --service_account_id <id>`
- Policies:
  - `exc policy list`
  - `exc policy delete --policy_id <id>`
  - `exc policy binding list --policy_id <id>`
  - `exc policy binding delete --binding_id <id>`
- API keys:
  - `exc apikey list`
  - `exc apikey create`
  - `exc apikey delete --key_id <id>`

## Billing and Quota

- Billing:
  - `exc billing get`
- Quotas:
  - `exc quota`

## Misc

- Current user:
  - `exc me`
- Version:
  - `exc version`
- Config:
  - `exc config set --key <key> --value <value>`
  - `exc config list`
