---
name: excloud-cli
description: Drive Excloud resources (compute, networking, security groups, volumes, snapshots, public IPs, IAM, billing, Kubernetes) through the `exc` CLI. Use when a user asks to plan or execute `exc` commands - creating / inspecting / updating / deleting VMs, running commands on them via `exec` / `scp` / `console`, managing security groups and public IPs, or pulling Kubernetes kubeconfigs - with safety guardrails and auth checks.
---

# Excloud CLI

This skill is a _starting guide_, not a spec. The `exc` CLI is generated from a live OpenAPI surface, so commands and flags change. **Whenever a command or flag in this file disagrees with `exc <command> --help`, trust the CLI.** Re-read the relevant `--help` before shaping a real command, and prefer discovering the surface interactively over memorising it from here.

```
exc --help
exc <group> --help
exc <group> <subcommand> --help
```

Everything below has been observed working at some point; the model should still verify before running anything destructive.

---

## Workflow principles

- Prefer `exc` for all Excloud actions unless the user explicitly asks for direct API / SDK use.
- Confirm before anything destructive (see Safety).
- If authentication is missing or expired, tell the user to run `exc login` and stop — do not invent tokens.
- When flag names or behaviours look odd, run `exc <...> --help` rather than guessing. Generated CLIs evolve between releases.
- Read `list` / `get` output shapes carefully before trying to parse them; there is no universal `-o json` flag today (see Output formats).

## Authentication

The CLI reads credentials in this precedence order:

1. `EXCLOUD_ACCESS_TOKEN` or `ACCESS_TOKEN` env var.
2. `EXCLOUD_ID_TOKEN` or `ID_TOKEN` env var.
3. `~/.exc/config` (JSON) written by `exc login` — contains the default account, default org, default zone, and per-account `id_token` / `access_token` material.

If none of those are present or valid, commands that need a token (`exec`, `scp`, `console`, `k8s cluster kubeconfig get/merge`) fail with `not authenticated; run \`exc login\``. `exc login` opens a browser flow and serves a callback on `http://localhost:7899/callback`.

`exc me`, `exc org list`, `exc account list`, `exc config list` are useful "where am I?" probes after login.

## Safety guardrails

Require explicit user confirmation before running any of these:

- `exc compute terminate` (especially with `--delete_root_volume`).
- `exc compute volume delete`, `exc compute snapshot delete`, `exc compute key delete`.
- `exc compute publicip release`, `exc compute publicip disassociate`.
- `exc securitygroup delete`, `exc securitygroup rule delete`, `exc securitygroup binding delete`.
- `exc k8s cluster delete`, `exc k8s cluster worker delete`.
- `exc account revoke`, `exc serviceaccount delete`, `exc apikey delete`, `exc policy delete`, `exc policy binding delete`.

For shell commands delivered through `exc compute exec` or an `exec` script file, refuse or confirm explicitly before running anything like `shutdown`, `reboot`, `rm -rf`, `mkfs`, `dd`, `wipefs`, rewrites of `/etc/fstab`, bootloader edits, or `systemctl stop ssh*` (the last one will make the VM unreachable over SSH — see Interactive access).

## Discoverability and authoritative lookups

The skill does _not_ hard-code IDs, instance type names, image IDs, subnet IDs, security group IDs, or zone IDs. Those change per account and over time. Before any `create` / `rule create` / `binding create` call, confirm the IDs with the relevant `list` command:

- `exc compute instancetype list` — CPU / memory / disk for each advertised type. Pick the smallest type whose CPU/MEMORY columns cover the workload; default to the cheapest advertised micro for scratch work and step up for real workloads.
- `exc compute instancetype capacity --instance_type <type>` — per-zone availability probe (`available=true|false`). Unknown types return `false` gracefully rather than 404, so `true` is the only reliable signal.
- `exc compute image list` — authoritative image catalog. Image IDs vary per org; do not hard-code them.
- `exc compute subnet list` + `exc compute subnet get --id <id>` — check `DISABLE_IPV4_PUBLIC_IP`: subnets with this set cannot take `--allocate_public_ipv4=true` at create time.
- `exc securitygroup list` + `exc securitygroup rule list --security_group_id <id>` + `exc securitygroup binding list --security_group_id <id>` (or `--interface_id <id>`) — confirm what a SG allows and where it's bound before relying on it.
- `exc compute publicip list` / `exc compute key list` / `exc compute volume list` / `exc compute snapshot list` — authoritative inventories for each resource type.

If `--help` on the installed CLI shows commands or flags not documented here, prefer `--help`.

## Common VM lifecycle

### Create

Required flags for `exc compute create`:

- `--name <dns-compatible-name>` (lowercase, `[a-z0-9][a-z0-9-]*[a-z0-9]`).
- `--subnet_id <id>` (zone of the subnet must match your default zone).
- `--allocate_public_ipv4=true|false` — the flag must be explicit.
- `--image_id <id>`
- `--instance_type <type>`
- `--root_volume_size_gib <n>`

Useful optional flags (verify via `--help`):

- `--security_group_ids <id1,id2>` — attach one or more SGs to the primary interface at create time. **If you omit this, the VM may come up with no SG attached** — set at least one.
- `--ssh_pubkey "<key or key name>"` — inline SSH public key string _or_ the `name` of a key managed via `exc compute key`.
- `--public_ipv4_reservation_id <id>` — attach an existing reserved public IPv4 instead of allocating a new ephemeral one.
- `--root_password <pw>` — for console / emergency access only; SSH keys are strongly preferred.
- `--root_volume_id <id>` **or** `--root_volume_source_snapshot_id <id>` (mutually exclusive) — reuse an existing volume or clone from a snapshot for the root disk.
- `--root_volume_baseline_iops <n>` / `--root_volume_baseline_throughput_mbps <n>` — provisioned performance for EBS-backed roots.
- `--user_data <inline>` or `--user-data-file <path>` — first-boot script. See User data below.

Do not pass flags the help output does not list; deprecated flags (e.g. `--root_volume_perf_tier`) are removed or hidden and will error or be ignored.

`create` prints a one-row table with at minimum `ID`, `NAME`, `STATE` (usually `STARTING` or `CREATING`), `ZONE`, `SUBNET`, `ROOT_VOLUME_ID`, `PUBLIC_IPV4`, `INTERFACE_IPV4`, `INTERFACE_IPV6`. Note that this row does **not** include `INTERFACE_ID`; fetch that later with `exc compute get --id <vm_id>`.

### Wait for RUNNING (no native `--wait`)

The CLI does not provide a wait primitive. Poll `compute get` and key off the `STATE` column:

```bash
until [ "$(exc compute get --id <vm_id> | awk 'NR==2 {for (i=1;i<=NF;i++) if ($i ~ /^(CREATING|STARTING|RUNNING|STOPPING|STOPPED|RESTARTING|TERMINATING|TERMINATED)$/) print $i}')" = "RUNNING" ]; do sleep 3; done
```

(Using column-name matching rather than a fixed index because the header ordering in `compute get` has shifted between releases; trust the header row rather than a hard-coded `$4`.)

Typical progression for a fresh VM: `CREATING` → `STARTING` → `RUNNING` in roughly half a minute, plus another 15–20 seconds before cloud-init finishes and SSH answers. After RUNNING, wait a bit before the first `exc compute exec` or SSH connection will be reliable.

### Inspect and control

- `exc compute list` — hides `TERMINATED` VMs by default. Use this for "what is alive now".
- `exc compute instances list` — rich-metadata variant that shows **all** states unless filtered; add `--states running,stopped`, `--created_after <rfc3339>`, `--created_before <rfc3339>` as appropriate.
- `exc compute get --id <vm_id>` — single VM detail. Shows `INTERFACE_ID` (needed for publicip / SG binding ops) but not `ROOT_VOLUME_ID`.
- `exc compute rename --vm_id <id> --name <new_name>`
- `exc compute resize --vm_id <id> --instance_type <type>` — generally requires the VM to be STOPPED first.
- `exc compute start --vm_id <id>`
- `exc compute stop --vm_id <id> [--reserve_public_ipv4]` — pass `--reserve_public_ipv4` to keep the ephemeral public IPv4 across the stop.
- `exc compute restart --vm_id <id>` — a full API-level restart; useful to recover a VM whose SSH stack you broke from `exec`.
- `exc compute terminate --vm_id <id> [--delete_root_volume]` — without `--delete_root_volume` the root volume is kept and can be reused via `create --root_volume_id <id>`.

### Delete protection

Three commands can change the `delete_protection` flag; all return the updated VM as JSON:

- `exc compute protect --vm-id <id>` — enable protection.
- `exc compute unprotect --vm-id <id>` — disable protection.
- `exc compute rename --vm_id <id> --name <name> [--delete_protection=true|false]` — rename the VM and, if `--delete_protection` is passed, set protection in the same call. Omitting the flag on `rename` leaves the protection flag untouched, so a bare rename will not accidentally clear it.

While protection is enabled, `exc compute terminate` returns `VM delete protection is enabled. Disable delete protection before terminating this instance.` (exit 1). Run `unprotect` first, then retry `terminate`.

### Termination clean-up

After terminate with `--delete_root_volume`, confirm both with:

```bash
exc compute get --id <vm_id>        # STATE should become TERMINATED in a few seconds
exc compute volume list             # the root volume should disappear / move to DELETING
```

## User data

- `--user-data-file <path>` wins over `--user_data <inline>` if both are set (the inline one is ignored with a warning).
- The CLI is permissive — it only warns when content looks neither like a shell script nor a cloud-init document. Accepted heuristics:
  - Shebang start: `#!/bin/bash`, `#!/usr/bin/env bash`, `#!/bin/sh`.
  - First non-empty line begins with `#cloud-` (e.g. `#cloud-config`, `#cloud-boothook`).
- Prefer real `#!/bin/bash` scripts or `#cloud-config` YAML; other content will run but triggers the warning.

## Interactive access: `connect`, `exec`, `scp`, `console`

`exc compute connect` is the low-level session primitive; `exec`, `scp` and `console` all build on it.

- `exc compute connect --vm_id <id> [--user ubuntu] [--return_private_key]` — returns a short-lived session ID and, when `--return_private_key` is set, a base64-encoded PEM authorised for the VM.
- `exc compute exec --vm-id <id> (--command "<cmd>" | --script-file <path>) [--user ubuntu] [--timeout <seconds>]`
  - `--command` and `--script-file` are mutually exclusive; exactly one is required.
  - `--script-file` is **interpreted as bash on the VM** (piped into `bash -s`). It is not a plain upload — plain-text files that contain non-command lines will fail with `command not found`. For transferring files verbatim, use `scp`.
  - `--timeout` has a sensible default (tens of seconds) and a hard backend cap (check `--help`). A timed-out command prints `command timed out` and returns exit 124.
  - Remote exit codes propagate: `exit 42` on the VM → local exit 42, with `Process exited with status 42` on stderr.
  - On success and failure alike the command emits `warning: host key not verified` on stderr — that is expected (the CLI trusts the instance-connect key without pinning). Redirect stderr when scripting.
  - SSH targets are tried in order: public IPv4 → any interface private IPv4 → any interface IPv6. If all SSH targets fail, `exec` automatically falls back to the WebSocket console transport. The fallback uses a unique marker to capture the remote exit code. Whether the WS transport succeeds depends on the compute service — if it rejects the session (`unknown session`) or times out (`Timeout connecting to the instance`), `exec` will fail with a 255 exit. In that case, confirm the VM is actually reachable via its public IPv4 (security group / sshd status) rather than relying on WS.
- `exc compute scp --vm-id <id> --src <src> --dst <dst> [--user ubuntu] [--recursive] [--download] [--timeout <seconds>]`
  - Default direction is **upload** (local → VM). Pass `--download` to pull files from the VM to local.
  - `--recursive` is required for directory transfers in either direction.
  - Symlinks are **rejected** — an encountered symlink fails the whole transfer with `symlink entries are not supported: <path>` (exit 1). Dereference or archive them locally (e.g. `tar -czhf ...`) before calling `scp`.
  - `scp` does **not** fall back to the WebSocket transport when SSH is unreachable; it errors out. Use `scp` only on VMs whose SSH is reachable.
  - If the destination requires elevation, upload to a writable path (e.g. `/tmp/...`) and move with `sudo` via `exc compute exec`.
- `exc compute console --vm-id <id> [--user ubuntu] [--timeout <seconds>] [--ssh | --ws]`
  - Opens an **interactive** shell on the VM. By default it tries SSH first, then falls back to the WebSocket console.
  - `--ssh` forces SSH only, `--ws` forces WebSocket only.
  - Requires a real TTY — piping input or running inside a non-interactive shell will fail with `failed to set terminal to raw mode: inappropriate ioctl for device`. For scripted one-shots use `exec`; for interactive work suggest the user run `exc compute console` directly.

### Troubleshooting SSH / exec failures

1. Does the VM have a reachable address? `exc compute get --id <vm_id>` — check `PUBLIC_IPV4`, `INTERFACE_IPV4`, `INTERFACE_IPV6`.
2. Is a security group bound and does it permit SSH?
   - `exc securitygroup binding list --interface_id <if_id>`
   - `exc securitygroup binding create --interface_id <if_id> --security_group_id <sg_id>`
   - `exc securitygroup rule list --security_group_id <sg_id>`
3. Is there an ingress rule for port 22 from your source IP? If not, create one:
   - `exc securitygroup rule create --security_group_id <sg_id> --is_ingress=true --protocol TCPv4 --port_range 22 --cidr "<your_ip>/32"`
4. Is there an egress rule for the VM to reach the internet? Most setups want a broad egress rule:
   - `exc securitygroup rule create --security_group_id <sg_id> --is_ingress=false --protocol IPv4 --port_range ANY --cidr 0.0.0.0/0`
5. If `exec` says `connection refused` on port 22, sshd is likely not running. `exc compute restart --vm_id <id>` brings it back (the API-level restart does not need SSH).

## Serial console logs

`exc compute seriallogs --id <vm_id> [--boot_id <id>] [--offset <n> --direction older|newer] [--limit <n>] [-f]`

- Omitting `--boot_id` returns the latest boot.
- `--offset` and `--direction` must be set together; the valid directions are `older` and `newer`.
- `--limit` must be positive when set; typical default is ~200 and the backend has a hard cap.
- `-f / --follow` polls for newer lines every couple of seconds — not a native stream.
- Lines are prefixed with `[<rfc3339 timestamp> offset=<n>]`. Look for `Cloud-init ... finished`, `Reached target ... cloud-init.target`, and the login banner (`Ubuntu X.Y.Z ip-a-b-c-d ttyS0`) to confirm a clean boot.

## Networking

### Subnets

- `exc compute subnet list` — the `DISABLE_IPV4_PUBLIC_IP` column is the gate on whether `--allocate_public_ipv4=true` is legal.
- `exc compute subnet get --id <id>`

### Public IPv4

- `exc compute publicip list` / `exc compute publicip get --id <reservation_id>`
- `exc compute publicip reserve --name <name> [--interface_id <if_id>]` — if `--interface_id` is passed the new reservation is also attached in one step.
- `exc compute publicip associate --interface_id <if_id> --reservation_id <id>`
- `exc compute publicip disassociate --reservation_id <id>`
- `exc compute publicip rename --reservation_id <id> --name <new_name>`
- `exc compute publicip release --reservation_id <id>` (destructive).

### Local IP check

`exc compute localip --ip <addr>` asks the service whether a given IP falls inside Excloud's local ranges. It returns `{ip, is_local}` and is a backend-defined membership probe — not a "what is my public IP" helper (observed returning `is_local=true` for some clearly non-Excloud addresses, so do not use it as a precise classifier). To learn the caller's public IP, use an external service (e.g. `curl -s https://api.ipify.org`).

## Security groups

- `exc securitygroup create --name <name> [--description "..."]`
- `exc securitygroup list`
- `exc securitygroup get --id <sg_id>` (note: the flag here is `--id`, not `--security_group_id`).
- `exc securitygroup delete --security_group_id <sg_id>`

### Rules

- `exc securitygroup rule create --security_group_id <id> --is_ingress=true|false --protocol <proto> --port_range <range> --cidr <cidr> [--description "..."]`
  - `--is_ingress` is **required**. Pass `=true` for ingress, `=false` for egress. Omitting it errors with `required flag(s) "is_ingress" not set`.
  - `--protocol` takes Excloud family strings such as `TCPv4`, `UDPv4`, `ICMPv4`, `IPv4` — verify current valid values via a successful `rule list` if unsure.
  - `--port_range` accepts single ports (`22`), ranges (`80-443`), or `ANY`.
  - Rules are not updatable — to change one, `rule delete` and `rule create` again.
- `exc securitygroup rule list --security_group_id <id>`
- `exc securitygroup rule delete --security_group_rule_id <id>` (destructive).

### Bindings

- `exc securitygroup binding create --interface_id <if_id> --security_group_id <sg_id>`
- `exc securitygroup binding list (--interface_id <id> | --security_group_id <id>)` — at least one filter is required.
- `exc securitygroup binding delete --interface_id <if_id> --security_group_id <sg_id>`

## Volumes and snapshots

- `exc compute volume list` / `exc compute volume get --id <id>`
- `exc compute volume create --name <name> --size_gib <n> [--source_snapshot_id <id>] [--baseline_iops <n>] [--baseline_throughput_mbps <n>]` — zone is injected from config; there is no `--zone_id` flag.
- `exc compute volume rename --volume_id <id> --name <new_name>`
- `exc compute volume resize --volume_id <id> --new_size_gib <n> [--baseline_iops <n>] [--baseline_throughput_mbps <n>]`
- `exc compute volume delete --volume_id <id>` (destructive).
- `exc compute snapshot list` / `exc compute snapshot create --volume_id <id>` / `exc compute snapshot delete --snapshot_id <id>`

## SSH key catalog

- `exc compute key list` / `exc compute key get --id <id>`
- `exc compute key create --name <name> (--ssh-public-key "<pub>" | --ssh-public-key-path <file>)`
- `exc compute key delete --id <id>`
- The key `name` can be passed to `compute create --ssh_pubkey` in place of a raw public key string.

## Kubernetes

- `exc k8s health`
- `exc k8s cluster list`
- `exc k8s cluster create --control_plane_image_id <id> --control_plane_instance_type <type> --subnet_id <id> --root_volume_size_gib <n> [--allocate_public_ipv4] [--security_group_ids <id1,id2>] [--ssh_pubkey "<pubkey>"] [-o <path>]`
  - The response contains the admin kubeconfig inline. Passing `-o <path>` writes it to disk (mode 0600, creating parent dirs) and strips it from stdout — strongly preferred.
- `exc k8s cluster delete --cluster_id <id>` (destructive).
- `exc k8s cluster worker list --cluster_id <id>`
- `exc k8s cluster worker create --cluster_id <id> --worker_image_id <id> --worker_instance_type <type> --subnet_id <id> --root_volume_size_gib <n> [--allocate_public_ipv4] [--security_group_ids <ids>] [--ssh_pubkey "<pubkey>"]`
- `exc k8s cluster worker delete --cluster_id <id> --worker_id <id>` (destructive).
- `exc k8s cluster kubeconfig get --cluster_id <id> [-o <path>]` — fetches the current kubeconfig and prints to stdout (or writes to `-o` with mode 0600). Returns a clear 404 if the cluster id is unknown.
- `exc k8s cluster kubeconfig merge --cluster_id <id> [--kubeconfig <path>] [--backup=true|false]` — merges into `~/.kube/config` (or `--kubeconfig`) using `kubectl config view --merge --flatten --raw`. Requires `kubectl` on PATH. `--backup` defaults to `true` and writes `<path>.bak`, `<path>.bak1`, ... before overwriting.
- `exc k8s bootstrap controlplane get --vm_id <id> --x-exc-imds-token <token>` — operator bootstrap path; the IMDS token must come from inside the VM's IMDS agent, not be invented.

## IAM, billing, quota

- `exc org list`
- `exc account list` / `exc account invite --email <email>` / `exc account revoke --email <email>` (the revoke flag is `--email`, not an invite id).
- `exc serviceaccount list` / `exc serviceaccount delete --name <name>`
- `exc apikey list` / `exc apikey create` (prints the new key once — capture it immediately) / `exc apikey delete --hash <hash>`
- `exc policy list` / `exc policy delete --id <policy_id>`
- `exc policy binding list (--account_id <id> | --service_account_id <id>)` — at least one filter required; neither errors with `either account_id or service_account_id must be provided`.
- `exc policy binding delete --policy_id <id> (--account_id <id> | --service_account_id <id>)`
- `exc billing get` / `exc quota`

## Config and misc

- `exc me` / `exc version` / `exc completion <bash|zsh|fish|powershell>`
- `exc config list` — shows the current default account / org / zone and configured accounts.
- `exc config set [-a|--account <account_id>] [-o|--org <org_id>]` — no `--zone` here; default zone is set at login time.

## Output formats

Every command either prints a column table (or TSV) or prints JSON — no command should print raw Go-struct dumps anymore. Both shapes are machine-parseable; pick your tool accordingly.

- **Column tables / TSV** (awk / `cut` / `awk -F\t` friendly): `compute list`, `compute instances list`, `compute get`, `compute create`, `compute terminate` (TSV `vm_id\tstate`), `compute instancetype list` / `capacity`, `compute image list`, `compute subnet list`, `compute volume list`, `compute volume get`, `compute snapshot list`, `compute publicip list`, `compute key list`, `securitygroup list` / `rule list` / `binding list`, `org list`, `account list`, `apikey list`, `policy list`, `config list`, `compute seriallogs`.
- **JSON** (pipe through `jq`): `me`, `quota`, `billing get`, `compute health` (`{"raw":"OK"}`), `k8s health`, `compute subnet get`, `compute publicip get`, `compute key get`, `securitygroup get`, `compute metrics`, `compute connect`, `serviceaccount list`, `compute protect`, `compute unprotect`, `compute rename`, `k8s cluster kubeconfig get` (raw kubeconfig YAML, not JSON-wrapped), and the inline `kubeconfig` field inside the JSON response from `k8s cluster create` when `-o` is not set.

Before scripting heavy logic against a command, run it once and check the shape. The split between "table" and "JSON" is not always guessable — lists tend to be tables, getters tend to be JSON, but verify.

## Metrics

`exc compute metrics --vm_id <id> --start <rfc3339> --end <rfc3339> [--family <family>]`

- Only `cpu` is currently supported. Omitting `--family` defaults to CPU. Any other family (`memory`, `network`, `diskio`, ...) returns `Requested metrics family is not supported for this endpoint.` with exit 1. Re-check `--help` and the above claim if the backend later adds families.
- Output is JSON: `{"series":[{"family":"cpu","period_seconds":5,"points":[{"timestamp":"...","average":<n>,"max":<n>,"min":<n>}, ...],"unit":"Percent"}]}`. Parse with `jq` (e.g. `jq '.series[0].points[-1].average'`).

## Error messages to recognise

- `not authenticated; run \`exc login\`` — no valid token in env or `~/.exc/config`.
- `required flag(s) "<name>" not set` — cobra-level enforcement. Read `--help` again.
- `Could not parse your request!! Are you sure you passed the correct flags?` — generic backend 400. Typically means an unknown ID, a value of the wrong type, or a server-side required field that the CLI accepted as empty. Verify every ID against a `list` before retrying.
- `Oops could not find the <Resource> you specified, maybe try checking if the <resource> exists?` — backend 404-ish. Trust the hint.
- `Oops the IP provided is invalid` — syntactic IP validation on `compute localip`.
- `Something went wrong on our end!!` — backend 500. Observed on `compute connect` for a non-existent VM. Verify the VM exists via `compute get`; do not retry blindly.
- `VM delete protection is enabled. Disable delete protection before terminating this instance.` — run `exc compute unprotect --vm-id <id>` first, then retry `terminate`.
- `At least one field must be provided: name or delete_protection.` — you hit `compute rename` / `compute update` with neither flag set. Pass `--name <name>` and/or use `protect` / `unprotect` instead of `rename --delete_protection=...` for protection changes.
- `command timed out` (exit 124) — `exec --timeout` elapsed. Raise the timeout, or launch the work in the background on the VM (`nohup`, systemd unit) and poll with subsequent `exec` calls.
- `invalid --direction "<x>": must be one of older or newer` / `use --offset and --direction together` / `--limit must be greater than 0` — `seriallogs` argument validation.
- `either account_id or service_account_id must be provided` — `policy binding list` needs at least one filter.
- `symlink entries are not supported: <path>` (exit 1) — `scp --recursive` refuses trees containing symlinks; archive or dereference locally first.
- `unknown session` / `Timeout connecting to the instance!` from `exec` WS fallback — the server-side console rejected the session. SSH is the only reliable path right now; tell the user to ensure the VM has a reachable SSH address and permissive SG rather than relying on WS fallback.
