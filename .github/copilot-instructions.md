# Copilot Instructions for jenkinsfiles

## Project Overview
This repository contains Jenkins pipeline definitions (Groovy/Declarative) and supporting PowerShell scripts for Active Directory (AD) user management and system automation on Windows infrastructure.

**Core Purpose**: Automate temporary and permanent user access provisioning with time-based group membership (30-day windows).

## Architecture & Data Flow

### User Access Management (Primary Workflow)
1. **JSON Source** (`userAccessList.json`): Single source of truth containing user→group mappings with `StartDate`
   - Structure: `{SamAccountName, UserName, GroupName[], StartDate}`
   - Located in Jenkins workspace root and Git repository

2. **Pipeline Chain**:
   - `AD\AD_Users` (main entry): Accepts parameters, appends entries to JSON, commits to GitHub
   - `temporary_permission` / `Adding Users To Groups`: Processes JSON, adds/removes users from AD groups based on 30-day rule
   - `job_update_json`: Alternative entry point for dynamically updating JSON before triggering AD jobs

3. **30-Day Rule**: Users are group members only if `today - StartDate ≤ 30 days`
   - Enforced via PowerShell: `[datetime]::Parse($User.StartDate)` comparison
   - Automatically removes expired users via `Remove-ADGroupMember`

### Critical Patterns

**Group Distinguished Name Format** (Not flexible):
```powershell
$group = "CN=$($group.Trim()),OU=group,DC=corp,DC=local"  # Line 50+ in Adding Users To Groups
```
Update DC values to match your AD environment if modifying.

**JSON Array Handling** (Common issue):
- PowerShell must force objects into `@()` array before appending
- See `AD_Users` line ~120: `if ($existingJsonRaw -is [System.Collections.IEnumerable]) { $existingJson = @($existingJsonRaw) }`

**Environment Variables in Pipelines**:
- Groovy: `${env.WORKSPACE}`, `${params.ParamName}`, `${pwd()}`
- PowerShell: `$env:WORKSPACE`, `$env:JSON_FILE_PATH`, `$LASTEXITCODE`
- Mix requires careful escaping: `\$env:VAR` in embedded PowerShell

## Developer Workflows

### Running AD User Management
1. **Quick Test (No Git upload)**: Use `AD\ADD not upload to repo` pipeline with parameters
2. **Production**: Use `AD\AD_Users` pipeline (includes GitHub commit)
3. **Direct Script**: Execute `AD\create users and groups.ps1` locally with hardcoded `$users` array

### JSON File Management
- **Path**: `$WORKSPACE\userAccessList.json` (workspace-relative) or `C:\Scripts\userAccessList.json` (standalone scripts)
- **Validation**: Always test `Test-Path` before `Get-Content` and `ConvertFrom-Json`
- **Backup**: Git history in `Moshe832/jenkinsfiles` repo

### Git Integration
- Credentials stored as Jenkins credential ID `e081ec0d-a4eb-42cc-865b-911e79062935`
- Workflows use `git stash pop` to merge local changes with remote before push
- Branch: `main` (hardcoded in pipelines)

## Project-Specific Conventions

**PowerShell Error Handling**:
- Use `-ErrorAction Stop` to catch exceptions in try blocks
- Use `-ErrorAction SilentlyContinue` to suppress lookup failures (e.g., `Get-ADUser`)
- Always check `$isMember` existence before add/remove operations

**Pipeline Options** (Applied consistently):
- `timeout(time: X, unit: 'SECONDS')` or `timeout(time: X, unit: 'MINUTES')` on all agent pipelines
- `disableConcurrentBuilds()` when JSON file is accessed (prevents race conditions)
- `cleanWs()` in post-always block for workspace isolation

**Credentials Management**:
- Jenkins credentials referenced by ID, injected via `withCredentials` block
- Never hardcode credentials; use environment variables injected at runtime

**Parallel Stages** (Rarely used but available):
- See `multiple-agents.groovy` and `get services status` for patterns
- Use `node(label)` to bind to specific agent
- Wrap in `parallel { ... }` for concurrent execution

## File Organization

```
jenkinsfiles/
├── AD/
│   ├── AD_Users                       # Main pipeline (has Git integration)
│   ├── Adding Users To Groups         # Core processing pipeline
│   ├── AD_Users                       # Template pipeline
│   ├── create users and groups.ps1    # Standalone script with hardcoded data
│   └── # Set path to the JSON...      # Reusable PowerShell snippet
├── job_update_json                    # Alternative: update JSON dynamically
├── temporary_permission               # Testing variant (30-day logic)
├── userAccessList.json                # Source of truth
├── multiple-agents.groovy             # Multi-node execution patterns
├── react.groovy                       # Windows + Node.js example
└── [other utilities]                  # System status, DNS, SSIS, etc.
```

## Key Integration Points

**Active Directory Module**:
- Required: `Import-Module ActiveDirectory`
- Fails silently on non-domain-joined machines
- Commands: `Get-ADUser`, `Get-ADGroup`, `Add-ADGroupMember`, `Remove-ADGroupMember`, `Set-ADAccountPassword`

**Jenkins Agent Labels**:
- `label 'windows'` or `label 'dc'`: Windows agents with AD module access
- `label 'Remote Machine'`: Secondary Windows build node
- `label 'linux'`: For cross-platform testing (rarely used in AD workflows)

**GitHub Integration**:
- Repo: `Moshe832/jenkinsfiles`
- HTTPS URL with embedded credentials in PowerShell `git remote set-url origin` calls
- Commit author: `moshe.cohen` / `Moshe832@gmail.com` (hardcoded in some pipelines)

## Common Pitfalls to Avoid

1. **Group Distinguished Name**: Hardcoded to `OU=group,DC=corp,DC=local` — adjust DC values for your environment
2. **30-Day Comparison**: Use `([datetime]::Parse($User.StartDate))` for string→DateTime; avoid epoch confusion
3. **JSON Array Escaping**: PowerShell in Groovy requires `\$` escaping; test locally first
4. **Workspace Variable**: Use `${env.WORKSPACE}` in Groovy, `$env:WORKSPACE` in PowerShell — not interchangeable
5. **Credentials Leakage**: Log output may expose encoded credentials; use `returnStatus: true` where possible

## External Dependencies

- **Jenkins Plugins**: Blue Ocean, Pipeline, Git, Timestamper, Email, PowerShell, Credentials
- **Windows Components**: PowerShell 5.1+, Active Directory Module, Git CLI
- **Groovy Version**: Jenkins 2.x declarative pipeline syntax
- **PowerShell Execution**: Scripts run as Jenkins service account (typically SYSTEM on Windows agents)

## Testing & Validation

- **Local Testing**: Use `AD\create users and groups.ps1` with test OUs before pipeline execution
- **Jenkins Testing**: Create test job copying pipeline code, run with `dryRun` parameters where possible
- **JSON Validation**: Test `Get-Content $jsonPath | ConvertFrom-Json` locally before pipeline commit
- **Pester Tests**: `Hello.Tests.ps1` demonstrates Pester framework (PSUnit-style); extend for validation tests

---

**Last Updated**: January 2026 | **Maintained By**: Moshe832
