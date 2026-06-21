---
name: asana-api
displayName: Asana API
description: Full Asana REST API integration via maton.ai — manage tasks, projects, webhooks, custom fields, dependencies, and more through natural language.

categories: [automation, planning]
roles:      [developer, project-manager, product-manager, operator]
outputs:    [structured-data, action-plan]
scenarios:  [project-execution, workplace-productivity, coding-dev]
runtimes:   [chat, workspace, api]
platforms:  [claude-code, openclaw, cursor]

tags: [asana, project-management, tasks, api, maton, automation, webhooks, custom-fields]
version: 0.3.0
author: KarthikBot
---

# Asana API Skill

Interact with Asana's REST API v1.0 through the maton.ai gateway. Full CRUD for tasks, projects, sections, comments, tags, webhooks, custom fields, task dependencies, attachments, and project status updates — all from natural language or shell scripts.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Gateway](#gateway)
3. [Setup](#setup)
4. [Core Concepts](#core-concepts)
5. [API Reference](#api-reference)
   - [Users](#users)
   - [Workspaces](#workspaces)
   - [Teams](#teams)
   - [Projects](#projects)
   - [Project Status Updates](#project-status-updates)
   - [Sections](#sections)
   - [Tasks](#tasks)
   - [Task Dependencies](#task-dependencies)
   - [Subtasks](#subtasks)
   - [Comments (Stories)](#comments-stories)
   - [Attachments](#attachments)
   - [Tags](#tags)
   - [Custom Fields](#custom-fields)
   - [Webhooks](#webhooks)
   - [Events (poll-based alternative)](#events)
   - [Search](#search)
   - [Followers](#followers)
   - [Project Members](#project-members)
   - [Portfolios](#portfolios)
6. [Pagination](#pagination)
7. [opt_fields — Controlling Response Size](#opt_fields)
8. [Common Patterns](#common-patterns)
9. [Shell Scripting Guide](#shell-scripting-guide)
10. [Error Handling](#error-handling)
11. [Rate Limits](#rate-limits)
12. [Security Notes](#security-notes)
13. [Troubleshooting](#troubleshooting)
14. [Limitations](#limitations)
15. [Related](#related)

---

## Quick Start

Create your first task in 3 commands:

```bash
# 1. Set your key
export MATON_API_KEY="v2.your_key_here"

# 2. Find your workspace GID
curl -s "https://gateway.maton.ai/asana/api/1.0/workspaces" \
  -H "Authorization: Bearer $MATON_API_KEY" | python3 -m json.tool
# → note the "gid" value, e.g. "123456789"

# 3. Create a task
curl -s -X POST "https://gateway.maton.ai/asana/api/1.0/tasks" \
  -H "Authorization: Bearer $MATON_API_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"data\":{\"name\":\"My first task\",\"workspace\":\"YOUR_WORKSPACE_GID\",\"assignee\":\"me\"}}" \
  | python3 -m json.tool
```

> Replace `YOUR_WORKSPACE_GID` with the `gid` from step 2. All other examples in this skill use `$WORKSPACE_GID` — set it once: `export WORKSPACE_GID="YOUR_WORKSPACE_GID"`.

---

## Gateway

All requests route through maton.ai:

```
Base URL: https://gateway.maton.ai/asana/api/1.0
Auth:     Authorization: Bearer {MATON_API_KEY}
API Ver:  Asana REST API v1.0 (stable; no newer version in production as of 2026)
```

The maton.ai key handles Asana OAuth transparently — no separate Asana token is needed.

> **Gateway caveat for webhooks and events:** maton.ai proxies REST calls, but webhook deliveries (Asana → your server) and the `/events` sync stream require your endpoint to be publicly reachable. Verify with maton.ai support whether outbound webhook delivery is forwarded through the gateway before relying on it.

---

## Setup

### 1. Obtain a maton.ai API key

Sign in at https://maton.ai, open **Settings → API Keys**, and copy your key.

Store it securely (avoid shell history — see [Security Notes](#security-notes)):

```bash
# Recommended: read from file, not inline
export MATON_API_KEY=$(cat ~/.secrets/maton_api_key)

# Or add to .botlearn/credentials.json under key "maton_api_key"
```

### 2. Connect Asana on maton.ai

In the maton.ai dashboard under **Connections**, authorize Asana with your account. The OAuth connection grants the scopes you approve — typically `default` (read/write tasks and projects).

Confirm the connection is active:

```bash
curl -s "https://ctrl.maton.ai/connections" \
  -H "Authorization: Bearer $MATON_API_KEY" | python3 -m json.tool
# Look for: "app": "asana", "status": "active"
```

### 3. Discover your IDs and export variables

```bash
BASE="https://gateway.maton.ai/asana/api/1.0"
AUTH="Authorization: Bearer $MATON_API_KEY"

# Get workspace GID
curl -s "$BASE/workspaces" -H "$AUTH"
# → {"data": [{"gid": "111222333", "name": "My Workspace"}]}

export WORKSPACE_GID="111222333"   # ← your actual value

# Get your user GID
curl -s "$BASE/users/me" -H "$AUTH"
# → {"data": {"gid": "444555666", "name": "You", "email": "you@example.com"}}

export USER_GID="444555666"        # ← your actual value
```

> All examples below use `$WORKSPACE_GID`, `$USER_GID`, `$PROJECT_GID`, etc. Set these from the responses above — do not copy the placeholder strings literally.

### 4. Validate environment

Add this guard to any script before making API calls:

```bash
: "${MATON_API_KEY:?MATON_API_KEY is not set. Run: export MATON_API_KEY=\$(cat ~/.secrets/maton_api_key)}"
: "${WORKSPACE_GID:?WORKSPACE_GID is not set. Run: export WORKSPACE_GID=your_gid}"
```

---

## Core Concepts

| Concept | Description |
|---------|-------------|
| `workspace` | Top-level container. All projects and tasks belong to a workspace. |
| `project` | A collection of tasks, organized in sections/columns. |
| `section` | A column or grouping within a project (Kanban column or list section). |
| `task` | The atomic unit of work. Has assignee, due date, notes, tags, custom fields. |
| `story` | A comment or system event on a task (Asana's internal term for activity feed entries). |
| `tag` | A label applied to tasks for filtering and cross-project views. |
| `team` | A group of users within a workspace (used in organizations). |
| `custom_field` | Workspace-level field definition (text, number, enum, date) applied to tasks/projects. |
| `webhook` | A push notification from Asana to your endpoint when resources change. |
| `portfolio` | A container for grouping and tracking multiple projects (organizations only). |
| `project_status` | A weekly on-track/at-risk/off-track update posted to a project. |

---

## API Reference

Set these once before running any examples:

```bash
export MATON_API_KEY="v2.your_key_here"
export WORKSPACE_GID="YOUR_WORKSPACE_GID"
export BASE="https://gateway.maton.ai/asana/api/1.0"
export AUTH="Authorization: Bearer $MATON_API_KEY"
```

---

### Users

#### Get current user
```bash
curl -s "$BASE/users/me" -H "$AUTH"
```
Response:
```json
{"data": {"gid": "444555666", "email": "you@example.com", "name": "You",
           "workspaces": [{"gid": "111222333", "name": "My Workspace"}]}}
```

#### List workspace users
```bash
curl -s "$BASE/workspaces/$WORKSPACE_GID/users?opt_fields=gid,name,email" -H "$AUTH"
```
> Note: Result includes guest users who may have restricted project access. Do not assume all listed users have full workspace visibility.

---

### Workspaces

#### List workspaces
```bash
curl -s "$BASE/workspaces" -H "$AUTH"
```

---

### Teams

#### List teams in workspace
```bash
curl -s "$BASE/organizations/$WORKSPACE_GID/teams?limit=50" -H "$AUTH"
```
Response: `{"data": [{"gid": "777888999", "name": "Engineering"}]}`

---

### Projects

#### List projects in workspace
```bash
curl -s "$BASE/projects?workspace=$WORKSPACE_GID&limit=50&opt_fields=gid,name,archived,due_date,color" -H "$AUTH"
```

Useful filters:
- `team=$TEAM_GID` — narrow to one team
- `archived=false` — active projects only

#### Get project detail
```bash
curl -s "$BASE/projects/$PROJECT_GID?opt_fields=gid,name,notes,color,layout,permalink_url,members,current_status" -H "$AUTH"
```

#### Create project
```bash
curl -s -X POST "$BASE/projects" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg ws "$WORKSPACE_GID" '{
    data: {
      name: "Q3 Launch",
      workspace: $ws,
      notes: "Main launch tracker",
      color: "dark-blue",
      layout: "board"
    }
  }')"
```

Color options: `dark-pink`, `dark-green`, `dark-blue`, `dark-red`, `dark-teal`, `dark-brown`,
`dark-orange`, `dark-purple`, `dark-warm-gray`, `light-pink`, `light-green`, `light-blue`,
`light-red`, `light-teal`, `light-brown`, `light-orange`, `light-purple`, `light-warm-gray`.

Layout: `list` or `board`.

#### Update project
```bash
curl -s -X PUT "$BASE/projects/$PROJECT_GID" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"data": {"name": "Renamed project", "notes": "Updated"}}'
```

#### Delete project
```bash
# ⚠️  WARNING: Deletion is permanent for users without admin access.
# Asana soft-deletes projects but recovery requires workspace admin intervention.
# Always confirm before running this in scripts.
curl -s -X DELETE "$BASE/projects/$PROJECT_GID" -H "$AUTH"
```

#### Duplicate project (as template)
```bash
curl -s -X POST "$BASE/projects/$PROJECT_GID/duplicate" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{
    "data": {
      "name": "Q4 Launch (copy)",
      "include": ["members","notes","task_notes","task_assignee","task_subtasks","task_tags","task_dates"]
    }
  }'
```
Use `include` to control what gets copied. Response contains the new project GID.

---

### Project Status Updates

Post weekly health updates (on-track / at-risk / off-track) visible on the project timeline.

> **API note:** The modern endpoint is `POST /status_updates` (not `/project_statuses`). The legacy `/project_statuses` endpoints still work but `/status_updates` is preferred for new integrations.

#### List status updates for a project
```bash
# Modern endpoint
curl -s "$BASE/status_updates?parent=$PROJECT_GID&opt_fields=gid,title,text,status_type,created_at,created_by.name" -H "$AUTH"

# Legacy endpoint (also works)
curl -s "$BASE/projects/$PROJECT_GID/project_statuses?opt_fields=gid,title,text,color,created_at,created_by" -H "$AUTH"
```

#### Create a status update (modern)
```bash
curl -s -X POST "$BASE/status_updates" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg prj "$PROJECT_GID" '{
    data: {
      parent: $prj,
      title: "Week 25 Update",
      text: "On track. Auth module shipped. Payments in review.",
      status_type: "on_track"
    }
  }')"
```
`status_type` options: `on_track`, `at_risk`, `off_track`, `on_hold`.

#### Create a status update (legacy)
```bash
curl -s -X POST "$BASE/project_statuses" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg prj "$PROJECT_GID" '{
    data: {
      project: $prj,
      title: "Week 25 Update",
      text: "On track. Auth module shipped. Payments in review.",
      color: "green"
    }
  }')"
```
Legacy `color` options: `green` (on track), `yellow` (at risk), `red` (off track).

#### Delete a status update
```bash
curl -s -X DELETE "$BASE/project_statuses/$STATUS_GID" -H "$AUTH"
```

---

### Sections

#### List sections in a project
```bash
curl -s "$BASE/projects/$PROJECT_GID/sections" -H "$AUTH"
```
Response: `{"data": [{"gid": "...", "name": "In Progress"}]}`

#### Create section
```bash
curl -s -X POST "$BASE/projects/$PROJECT_GID/sections" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"data": {"name": "In Review"}}'
```

#### Move task to section
```bash
curl -s -X POST "$BASE/sections/$SECTION_GID/addTask" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg t "$TASK_GID" '{data: {task: $t}}')"
```

---

### Tasks

#### List tasks assigned to me
```bash
curl -s "$BASE/tasks?assignee=me&workspace=$WORKSPACE_GID&limit=50&opt_fields=gid,name,completed,due_on,projects" -H "$AUTH"
```

#### List tasks in a project
```bash
curl -s "$BASE/projects/$PROJECT_GID/tasks?limit=50&opt_fields=gid,name,completed,due_on,assignee,tags,custom_fields" -H "$AUTH"
```

#### List tasks modified since a timestamp (standup prep)
```bash
# ISO 8601 timestamp — get everything changed in last 24 hours
SINCE=$(date -u -v-24H +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "24 hours ago" +"%Y-%m-%dT%H:%M:%SZ")
curl -s "$BASE/projects/$PROJECT_GID/tasks?modified_since=$SINCE&opt_fields=gid,name,completed,modified_at,assignee.name" -H "$AUTH"
```

#### Get task detail
```bash
curl -s "$BASE/tasks/$TASK_GID?opt_fields=gid,name,completed,due_on,start_on,notes,assignee,projects,tags,followers,parent,custom_fields,dependencies,dependents" -H "$AUTH"
```

#### Create task
```bash
curl -s -X POST "$BASE/tasks" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg ws "$WORKSPACE_GID" \
    --arg prj "$PROJECT_GID" \
    --arg name "Fix the login bug" \
    --arg notes "Steps to reproduce: ..." \
    '{data: {name: $name, workspace: $ws, assignee: "me",
              due_on: "2026-06-30", notes: $notes, projects: [$prj]}}')"
```

Key fields:
- `assignee`: user GID or `"me"` — `"me"` resolves to the authenticated user anywhere a user GID is accepted
- `due_on`: ISO date `YYYY-MM-DD` — mutually exclusive with `due_at`
- `due_at`: ISO datetime with time (for time-specific due dates) — mutually exclusive with `due_on`
- `start_on`: ISO date for start date — must be ≤ `due_on` when both are set
- `notes`: plain-text description — mutually exclusive with `html_notes`
- `html_notes`: HTML-formatted description (subset of HTML; see Asana docs for allowed tags)
- `projects`: array of project GIDs
- `tags`: array of tag GIDs
- `followers`: array of user GIDs to add as followers on create
- `parent`: GID of parent task (creates a subtask)
- `assignee_section`: GID of section within the assignee's My Tasks to place the task
- `resource_subtype`: `"default_task"`, `"milestone"`, or `"approval"`
- `custom_fields`: map of `{field_gid: value}` — see [Custom Fields](#custom-fields)

> **`GET /tasks` requires a scope filter.** You cannot query tasks with only `workspace`. At least one of: `project`, `section`, `tag`, `user_task_list`, or (`assignee` + `workspace`) is required, otherwise the API returns 400. Use `GET /projects/{gid}/tasks` for project-level lists.
>
> **`completed_since=now`** is the standard idiom to exclude completed tasks without knowing a cutoff date:

```bash
# Only open tasks (preferred over filtering locally)
curl -s "$BASE/projects/$PROJECT_GID/tasks?completed_since=now&opt_fields=gid,name,due_on" -H "$AUTH"
```

#### Create approval task
```bash
curl -s -X POST "$BASE/tasks" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg ws "$WORKSPACE_GID" '{
    data: {
      name: "Approve Q3 budget",
      workspace: $ws,
      assignee: "me",
      resource_subtype: "approval"
    }
  }')"
```

> Approval tasks are completed by setting `approval_status` to `"approved"`, `"rejected"`, or `"changes_requested"` — not `completed: true`.

```bash
# Approve a task
curl -s -X PUT "$BASE/tasks/$TASK_GID" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"data": {"approval_status": "approved"}}'
```

#### Update task
```bash
curl -s -X PUT "$BASE/tasks/$TASK_GID" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"data": {"due_on": "2026-07-01", "notes": "Updated description"}}'
```

#### Complete task
```bash
curl -s -X PUT "$BASE/tasks/$TASK_GID" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"data": {"completed": true}}'
```

#### Delete task
```bash
# ⚠️  WARNING: Tasks are soft-deleted and can only be recovered by workspace admins.
curl -s -X DELETE "$BASE/tasks/$TASK_GID" -H "$AUTH"
```

---

### Task Dependencies

Mark a task as blocked by another task.

#### Add dependencies (this task is blocked by others)
```bash
curl -s -X POST "$BASE/tasks/$TASK_GID/addDependencies" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --argjson deps '["DEP_TASK_GID_1","DEP_TASK_GID_2"]' '{data: {dependencies: $deps}}')"
```

#### Remove dependencies
```bash
curl -s -X POST "$BASE/tasks/$TASK_GID/removeDependencies" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"data": {"dependencies": ["DEP_TASK_GID_1"]}}'
```

#### Add dependents (other tasks blocked by this one)
```bash
curl -s -X POST "$BASE/tasks/$TASK_GID/addDependents" -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"data": {"dependents": ["DEPENDENT_TASK_GID"]}}'
```

#### Get dependencies for a task
```bash
curl -s "$BASE/tasks/$TASK_GID/dependencies" -H "$AUTH"
```

---

### Subtasks

#### Create subtask
```bash
curl -s -X POST "$BASE/tasks" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg p "$PARENT_TASK_GID" '{data: {name: "Write unit tests", parent: $p, assignee: "me"}}')"
```

#### List subtasks
```bash
curl -s "$BASE/tasks/$TASK_GID/subtasks" -H "$AUTH"
```

---

### Comments (Stories)

> **Terminology note:** Asana calls all task activity "stories". This includes both user-written comments (`type: "comment"`) and system events like assignment changes (`type: "system"`). Filter by `type` to show only comments.

#### List comments on a task
```bash
curl -s "$BASE/tasks/$TASK_GID/stories?limit=50" -H "$AUTH" | \
  python3 -c "
import sys, json
stories = json.load(sys.stdin)['data']
comments = [s for s in stories if s['type'] == 'comment']
for c in comments:
    print(c['created_at'][:10], c.get('created_by',{}).get('name','?'), ':', c['text'])
"
```

#### Add comment to task
```bash
curl -s -X POST "$BASE/tasks/$TASK_GID/stories" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg t "Blocked by the auth redesign — ETA next Friday." '{data: {text: $t}}')"
```

---

### Attachments

#### Upload attachment to a task
```bash
# Multipart upload — file from disk
curl -s -X POST "$BASE/tasks/$TASK_GID/attachments" \
  -H "$AUTH" \
  -F "file=@/path/to/report.pdf;type=application/pdf" \
  -F "name=Q3_Report.pdf"
```

#### List attachments on a task
```bash
curl -s "$BASE/tasks/$TASK_GID/attachments" -H "$AUTH"
```

#### Get attachment metadata
```bash
curl -s "$BASE/attachments/$ATTACHMENT_GID" -H "$AUTH"
```
Returns `download_url` for direct download (time-limited signed URL).

---

### Tags

#### List tags in workspace
```bash
curl -s "$BASE/workspaces/$WORKSPACE_GID/tags?limit=50" -H "$AUTH"
```

#### Create tag
```bash
curl -s -X POST "$BASE/tags" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg ws "$WORKSPACE_GID" '{data: {name: "bug", workspace: $ws, color: "red"}}')"
```

#### Add tag to task
```bash
curl -s -X POST "$BASE/tasks/$TASK_GID/addTag" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg t "$TAG_GID" '{data: {tag: $t}}')"
```

#### Remove tag from task
```bash
curl -s -X POST "$BASE/tasks/$TASK_GID/removeTag" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg t "$TAG_GID" '{data: {tag: $t}}')"
```

---

### Custom Fields

Custom fields are workspace-level definitions (text, number, enum, date) applied to tasks and projects via custom field settings.

#### List custom fields in workspace
```bash
curl -s "$BASE/workspaces/$WORKSPACE_GID/custom_fields?opt_fields=gid,name,type,enum_options" -H "$AUTH"
```

#### Get a custom field definition
```bash
curl -s "$BASE/custom_fields/$CUSTOM_FIELD_GID" -H "$AUTH"
```
Returns `type` (`text`, `number`, `enum`, `date`, `multi_enum`), `enum_options[]`, and `precision` for number fields.

#### Read custom field values on a task
```bash
curl -s "$BASE/tasks/$TASK_GID?opt_fields=custom_fields" -H "$AUTH" | \
  python3 -c "
import sys, json
cfs = json.load(sys.stdin)['data'].get('custom_fields', [])
for cf in cfs:
    name = cf.get('name', '?')
    val = cf.get('display_value') or cf.get('text_value') or cf.get('number_value') or cf.get('enum_value',{}).get('name','')
    print(f'{name}: {val}')
"
```

#### Set a custom field value on a task
```bash
# Enum field — pass enum option GID
curl -s -X PUT "$BASE/tasks/$TASK_GID" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg cfgid "$CUSTOM_FIELD_GID" \
    --arg optgid "$ENUM_OPTION_GID" \
    '{data: {custom_fields: {($cfgid): $optgid}}}')"

# Text field
curl -s -X PUT "$BASE/tasks/$TASK_GID" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg cfgid "$CUSTOM_FIELD_GID" '{data: {custom_fields: {($cfgid): "High priority"}}}')"

# Number field
curl -s -X PUT "$BASE/tasks/$TASK_GID" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg cfgid "$CUSTOM_FIELD_GID" --argjson val 8 '{data: {custom_fields: {($cfgid): $val}}}')"
```

---

### Webhooks

Webhooks push real-time events to your endpoint when Asana resources change — no polling needed.

> **Security:** Validate the `X-Hook-Signature` header on every webhook delivery. Asana signs the payload with HMAC-SHA256 using the secret returned at webhook creation. Reject any delivery where the signature doesn't match.

#### Create a webhook
```bash
WEBHOOK=$(curl -s -X POST "$BASE/webhooks" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg resource "$PROJECT_GID" \
    --arg target "https://your-server.example.com/asana-webhook" \
    '{data: {resource: $resource, target: $target}}')")
echo "$WEBHOOK" | python3 -m json.tool
# Save the returned "secret" — you need it to validate signatures
WEBHOOK_GID=$(echo "$WEBHOOK" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['gid'])")
WEBHOOK_SECRET=$(echo "$WEBHOOK" | python3 -c "import sys,json; print(json.load(sys.stdin)['data'].get('secret',''))")
```

Asana sends a handshake request first — your endpoint must return HTTP 200 with the `X-Hook-Secret` header echoed back.

#### Validate incoming webhook signature (Python)
```python
import hmac, hashlib, base64

def verify_asana_webhook(payload_bytes: bytes, signature_header: str, secret: str) -> bool:
    expected = hmac.new(secret.encode(), payload_bytes, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, signature_header)
```

#### List webhooks
```bash
curl -s "$BASE/webhooks?workspace=$WORKSPACE_GID" -H "$AUTH"
```

#### Delete webhook
```bash
curl -s -X DELETE "$BASE/webhooks/$WEBHOOK_GID" -H "$AUTH"
```

#### Common webhook event types
| `action` | `type` | Trigger |
|---|---|---|
| `added` | `task` | Task created in project |
| `changed` | `task` | Task field updated |
| `removed` | `task` | Task removed from project |
| `added` | `story` | Comment or system event added |
| `changed` | `project` | Project updated |
| `deleted` | `task` | Task deleted |

---

### Search

#### Typeahead (autocomplete) search
```bash
curl -s "$BASE/workspaces/$WORKSPACE_GID/typeahead?resource_type=task&query=auth&count=10&opt_fields=gid,name" -H "$AUTH"
```
`resource_type` options: `task`, `project`, `tag`, `user`, `portfolio`.

#### Advanced task search
```bash
# Find incomplete tasks assigned to me, due before a date, in a project
curl -s -X POST "$BASE/workspaces/$WORKSPACE_GID/tasks/search" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg prj "$PROJECT_GID" \
    '{data: {
      assignee: "me",
      completed: false,
      projects_any: [$prj],
      due_on_before: "2026-07-01",
      sort_by: "due_on",
      opt_fields: "gid,name,due_on,assignee.name"
    }}')"
```

---

### Followers

#### Add followers to a task
```bash
curl -s -X POST "$BASE/tasks/$TASK_GID/addFollowers" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --argjson followers '["USER_GID_1","USER_GID_2"]' '{data: {followers: $followers}}')"
```

#### Remove followers from a task
```bash
curl -s -X POST "$BASE/tasks/$TASK_GID/removeFollowers" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --argjson followers '["USER_GID_1"]' '{data: {followers: $followers}}')"
```

---

### Project Members

#### Add members to a project
```bash
curl -s -X POST "$BASE/projects/$PROJECT_GID/addMembers" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --argjson members '["USER_GID_1","USER_GID_2"]' '{data: {members: $members}}')"
```

#### Remove members from a project
```bash
curl -s -X POST "$BASE/projects/$PROJECT_GID/removeMembers" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --argjson members '["USER_GID_1"]' '{data: {members: $members}}')"
```

> Adding members grants them project visibility. Adding a guest user (external collaborator) as a member will expose all project tasks and comments to that external party.

---

### Portfolios

Portfolios group multiple projects for exec-level tracking. Available on **Asana Business and Enterprise plans only** — these endpoints return 402 on free/premium workspaces.

#### List portfolios you own or are a member of
```bash
curl -s "$BASE/portfolios?workspace=$WORKSPACE_GID&owner=me&opt_fields=gid,name,color" -H "$AUTH"
```

#### Get portfolio detail
```bash
curl -s "$BASE/portfolios/$PORTFOLIO_GID?opt_fields=gid,name,members,custom_fields,current_status_update" -H "$AUTH"
```

#### List projects in a portfolio
```bash
curl -s "$BASE/portfolios/$PORTFOLIO_GID/items?opt_fields=gid,name,archived,current_status" -H "$AUTH"
```

#### Add project to portfolio
```bash
curl -s -X POST "$BASE/portfolios/$PORTFOLIO_GID/addItem" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg prj "$PROJECT_GID" '{data: {item: $prj}}')"
```

#### Remove project from portfolio
```bash
curl -s -X POST "$BASE/portfolios/$PORTFOLIO_GID/removeItem" -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n --arg prj "$PROJECT_GID" '{data: {item: $prj}}')"
```

---

### Events (poll-based alternative to webhooks)

Use the `/events` endpoint to poll for changes when your server can't receive inbound webhook deliveries (e.g., local dev, gateway restrictions).

```bash
# First call — no sync token yet. Returns 412 with a fresh sync token.
RESP=$(curl -s -o /dev/null -D - "$BASE/events?resource=$PROJECT_GID" -H "$AUTH")
SYNC=$(echo "$RESP" | grep -i "^x-sync:" | tr -d '\r' | awk '{print $2}')
echo "Initial sync token: $SYNC"

# Subsequent calls — pass the sync token to get events since last poll
curl -s "$BASE/events?resource=$PROJECT_GID&sync=$SYNC" -H "$AUTH" | python3 -m json.tool
# Response: {"data": [...events...], "sync": "<new_token>"}
# Use the new "sync" value in the next call.
```

> The first call always returns HTTP 412 (Precondition Failed) with the initial sync token in the `X-Sync` response header — this is expected behavior, not an error. Store the token and use it on subsequent polls.

Large result sets return a `next_page` object:

```json
{
  "data": [...],
  "next_page": {
    "offset": "eyJ0...",
    "uri": "https://gateway.maton.ai/asana/api/1.0/tasks?offset=eyJ0..."
  }
}
```

Pass `?offset=<token>` to fetch the next page. `next_page: null` means all results returned.

```bash
# Paginate all tasks in a project
fetch_all_tasks() {
  local project_gid="$1"
  local offset=""
  while true; do
    local url="$BASE/projects/$project_gid/tasks?limit=100&opt_fields=gid,name,completed"
    [ -n "$offset" ] && url="$url&offset=$offset"
    local resp
    resp=$(curl -s "$url" -H "$AUTH")
    echo "$resp" | python3 -c "import sys,json; [print(t['gid'], t['name']) for t in json.load(sys.stdin)['data']]"
    offset=$(echo "$resp" | python3 -c "
import sys,json
d=json.load(sys.stdin)
np=d.get('next_page')
print(np['offset'] if np else '')
" 2>/dev/null)
    [ -z "$offset" ] && break
  done
}
fetch_all_tasks "$PROJECT_GID"
```

---

## opt_fields — Controlling Response Size

Request only the fields you need. This reduces payload size and speeds up responses.

| Use case | opt_fields value |
|----------|-----------------|
| Task list view | `gid,name,completed,due_on,assignee.name` |
| Task detail | `gid,name,completed,due_on,start_on,notes,assignee,projects,tags,followers,custom_fields` |
| Project list | `gid,name,archived,color,permalink_url` |
| User list | `gid,name,email` |
| Standup digest | `gid,name,completed,modified_at,assignee.name,projects.name` |

Dot-notation traverses nested objects: `assignee.name`, `projects.name`, `enum_value.name`.

---

## Common Patterns

### Quick digest: tasks due this week
```bash
TODAY=$(date +%Y-%m-%d)
WEEK_END=$(date -v+7d +%Y-%m-%d 2>/dev/null || date -d "+7 days" +%Y-%m-%d)
curl -s -X POST "$BASE/workspaces/$WORKSPACE_GID/tasks/search" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d "$(jq -n \
    --arg start "$TODAY" \
    --arg end "$WEEK_END" \
    '{data: {assignee: "me", completed: false,
              due_on_after: $start, due_on_before: $end,
              opt_fields: "gid,name,due_on,projects.name"}}')" | \
  python3 -c "
import sys, json
tasks = json.load(sys.stdin)['data']
for t in sorted(tasks, key=lambda x: x.get('due_on','')):
    prj = t.get('projects',[{}])[0].get('name','no project') if t.get('projects') else 'no project'
    print(t.get('due_on','?'), f'[{prj}]', t['name'])
"
```

### Standup prep: what changed in last 24h
```bash
SINCE=$(date -u -v-24H +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u -d "24 hours ago" +"%Y-%m-%dT%H:%M:%SZ")
curl -s "$BASE/projects/$PROJECT_GID/tasks?modified_since=$SINCE&opt_fields=gid,name,completed,modified_at,assignee.name" \
  -H "$AUTH" | \
  python3 -c "
import sys, json
tasks = json.load(sys.stdin)['data']
for t in sorted(tasks, key=lambda x: x.get('modified_at','')):
    status = 'DONE' if t['completed'] else 'open'
    who = t.get('assignee',{}).get('name','unassigned') if t.get('assignee') else 'unassigned'
    print(f'[{status}] {t[\"name\"]} ({who})')
"
```

### Workload view: tasks per team member
```bash
curl -s "$BASE/projects/$PROJECT_GID/tasks?limit=100&opt_fields=gid,name,completed,assignee.name" -H "$AUTH" | \
  python3 -c "
import sys, json
from collections import defaultdict
tasks = json.load(sys.stdin)['data']
counts = defaultdict(list)
for t in tasks:
    if not t['completed']:
        who = t.get('assignee',{}).get('name','unassigned') if t.get('assignee') else 'unassigned'
        counts[who].append(t['name'])
for who, tasks in sorted(counts.items(), key=lambda x: -len(x[1])):
    print(f'{who}: {len(tasks)} open tasks')
"
```

### Find all overdue tasks
```bash
curl -s "$BASE/tasks?assignee=me&workspace=$WORKSPACE_GID&opt_fields=gid,name,due_on,completed" -H "$AUTH" | \
  python3 -c "
import sys, json
from datetime import date
tasks = json.load(sys.stdin)['data']
today = date.today().isoformat()
overdue = [t for t in tasks if t.get('due_on') and t['due_on'] < today and not t['completed']]
for t in sorted(overdue, key=lambda x: x['due_on']):
    print(t['due_on'], t['name'])
"
```

### Find-or-create (idempotent task creation)
```bash
# Use this in CI pipelines to avoid duplicate tasks on retries
find_or_create_task() {
  local name="$1"
  # Search for existing task by name
  local existing
  existing=$(curl -s -X POST "$BASE/workspaces/$WORKSPACE_GID/tasks/search" \
    -H "$AUTH" -H "Content-Type: application/json" \
    -d "$(jq -n --arg n "$name" --arg prj "$PROJECT_GID" \
        '{data: {text: $n, projects_any: [$prj], completed: false, opt_fields: "gid,name"}}')" | \
    python3 -c "import sys,json; d=json.load(sys.stdin)['data']; print(d[0]['gid'] if d else '')" 2>/dev/null)

  if [ -n "$existing" ]; then
    echo "EXISTS:$existing"
  else
    local new
    new=$(curl -s -X POST "$BASE/tasks" -H "$AUTH" -H "Content-Type: application/json" \
      -d "$(jq -n --arg n "$name" --arg ws "$WORKSPACE_GID" --arg prj "$PROJECT_GID" \
          '{data: {name: $n, workspace: $ws, projects: [$prj]}}')" | \
      python3 -c "import sys,json; print(json.load(sys.stdin)['data']['gid'])")
    echo "CREATED:$new"
  fi
}
RESULT=$(find_or_create_task "Deploy v2.3.0 to production")
echo "$RESULT"
```

### CI/CD: create task on deploy failure
```bash
# In your CI pipeline (GitHub Actions, Jenkins, etc.)
create_deploy_failure_task() {
  local env="$1"
  local commit="$2"
  local run_url="$3"
  curl -s -X POST "$BASE/tasks" -H "$AUTH" -H "Content-Type: application/json" \
    -d "$(jq -n \
      --arg env "$env" \
      --arg commit "$commit" \
      --arg url "$run_url" \
      --arg ws "$WORKSPACE_GID" \
      --arg prj "$PROJECT_GID" \
      '{data: {
        name: ("Deploy FAILED: " + $env + " @ " + $commit[0:8]),
        workspace: $ws,
        assignee: "me",
        projects: [$prj],
        notes: ("CI run: " + $url + "\nCommit: " + $commit + "\nEnvironment: " + $env)
      }}')" | python3 -c "import sys,json; d=json.load(sys.stdin)['data']; print('Task:', d['gid'], d['permalink_url'])"
}
# Usage:
create_deploy_failure_task "production" "$GITHUB_SHA" "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY/actions/runs/$GITHUB_RUN_ID"
```

### Bulk create tasks from a list (safe quoting)
```bash
# Use jq --arg to safely handle task names with special characters
TASK_NAMES=("Design mockups" "Write unit tests" "Update \"config\" file" "Deploy to staging")
for NAME in "${TASK_NAMES[@]}"; do
  curl -s -X POST "$BASE/tasks" -H "$AUTH" -H "Content-Type: application/json" \
    -d "$(jq -n --arg n "$NAME" --arg ws "$WORKSPACE_GID" --arg prj "$PROJECT_GID" \
        '{data: {name: $n, workspace: $ws, projects: [$prj]}}')"
  sleep 0.5
done
```

### Move all tasks from one section to another
```bash
TASKS=$(curl -s "$BASE/sections/$SECTION_GID/tasks" -H "$AUTH" | \
  python3 -c "import sys,json; [print(t['gid']) for t in json.load(sys.stdin)['data']]")
for T in $TASKS; do
  curl -s -X POST "$BASE/sections/$TARGET_SECTION_GID/addTask" -H "$AUTH" -H "Content-Type: application/json" \
    -d "$(jq -n --arg t "$T" '{data: {task: $t}}')"
  sleep 0.5
done
```

### Sprint status report
```bash
python3 - <<'EOF'
import subprocess, json, os
base = os.environ['BASE']
auth = f"Authorization: Bearer {os.environ['MATON_API_KEY']}"
project_gid = os.environ['PROJECT_GID']

# Fetch all sections and their tasks
sections = json.loads(subprocess.check_output(
    ['curl', '-s', f'{base}/projects/{project_gid}/sections', '-H', auth]))['data']

for sec in sections:
    tasks = json.loads(subprocess.check_output(
        ['curl', '-s', f'{base}/projects/{project_gid}/tasks?section={sec["gid"]}&opt_fields=gid,name,completed', '-H', auth]))['data']
    total = len(tasks)
    done = sum(1 for t in tasks if t['completed'])
    pct = int(done/total*100) if total else 0
    print(f'{sec["name"]}: {done}/{total} complete ({pct}%)')
EOF
```

---

## Shell Scripting Guide

### Use jq for safe JSON construction

Never interpolate shell variables directly into JSON strings — it breaks on special characters and can corrupt JSON:

```bash
# UNSAFE — breaks if NAME contains quotes, backslashes, or newlines
curl -s -X POST "$BASE/tasks" -d "{\"data\":{\"name\":\"$NAME\"}}"

# SAFE — jq handles all escaping
curl -s -X POST "$BASE/tasks" \
  -d "$(jq -n --arg n "$NAME" '{data: {name: $n}}')"
```

### Retry with exponential backoff
```bash
asana_request() {
  local max_attempts=4
  local attempt=1
  local delay=1
  while [ $attempt -le $max_attempts ]; do
    local resp http_code
    resp=$(curl -s -w "\n%{http_code}" "$@")
    http_code=$(echo "$resp" | tail -n1)
    body=$(echo "$resp" | head -n-1)
    if [ "$http_code" = "429" ]; then
      retry_after=$(echo "$body" | python3 -c "import sys,json; print(json.load(sys.stdin).get('retry_after',${delay}))" 2>/dev/null || echo $delay)
      echo "Rate limited. Waiting ${retry_after}s..." >&2
      sleep "$retry_after"
      delay=$((delay * 2))
      attempt=$((attempt + 1))
    elif [ "$http_code" -ge 500 ] 2>/dev/null; then
      echo "Server error ($http_code), retrying in ${delay}s..." >&2
      sleep "$delay"
      delay=$((delay * 2))
      attempt=$((attempt + 1))
    else
      echo "$body"
      return 0
    fi
  done
  echo "Max retries exceeded" >&2
  return 1
}

# Usage — same as curl
asana_request "$BASE/tasks/$TASK_GID" -H "$AUTH"
```

### jq alternatives to python3

If python3 is unavailable (minimal containers), use jq:

```bash
# Extract GID from create response
TASK_GID=$(curl -s ... | jq -r '.data.gid')

# List task names
curl -s "$BASE/projects/$PROJECT_GID/tasks" -H "$AUTH" | jq -r '.data[].name'

# Filter incomplete tasks
curl -s "$BASE/tasks?assignee=me&workspace=$WORKSPACE_GID" -H "$AUTH" | \
  jq -r '.data[] | select(.completed == false) | [.due_on, .name] | @tsv'

# Extract offset for pagination
OFFSET=$(curl -s "$BASE/projects/$PROJECT_GID/tasks?limit=100" -H "$AUTH" | \
  jq -r '.next_page.offset // empty')
```

### Load .env file in scripts

```bash
# Load .env file (skip comment lines and empty lines)
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
fi
# Now MATON_API_KEY and WORKSPACE_GID are available
```

### Script preamble for reliability

```bash
#!/usr/bin/env bash
set -euo pipefail   # exit on error, undefined var, or pipe failure

# Validate required env vars
: "${MATON_API_KEY:?Set MATON_API_KEY}"
: "${WORKSPACE_GID:?Set WORKSPACE_GID}"

BASE="https://gateway.maton.ai/asana/api/1.0"
AUTH="Authorization: Bearer $MATON_API_KEY"
```

> **Note:** The bulk-task loop uses bash array syntax (`TASKS=(...)`) which requires bash, not POSIX sh. Use `#!/usr/bin/env bash` at the top of scripts that use this syntax.

---

## Error Handling

| HTTP | Meaning | Fix |
|------|---------|-----|
| 400 | Bad request — invalid field or missing required param | Check `errors[].message` in response body |
| 401 | Unauthorized | Verify `MATON_API_KEY` is set and not expired |
| 402 | Payment Required | Feature requires a paid Asana plan (Business/Enterprise) — portfolios, advanced search on free workspaces |
| 403 | Forbidden | Asana OAuth not connected, or insufficient scope, or no access to resource |
| 404 | Not found | Verify GID is correct; resource may have been deleted |
| 409 | Conflict | Resource already exists or concurrent edit conflict |
| 412 | Precondition Failed | Expected from first `/events` call — read `X-Sync` header for the initial token |
| 429 | Rate limited | Wait `Retry-After` seconds; use the retry wrapper above |
| 451 | Unavailable For Legal Reasons | Content blocked by Asana compliance policy |
| 500 | Server error | Retry once; check maton.ai status page if persistent |

> **Debugging tip:** every Asana API response includes an `Asana-Request-Id` header. Quote this value when filing bug reports with maton.ai support — it uniquely identifies the gateway call on their end.

Error response shape:
```json
{
  "errors": [
    {
      "message": "task: Not a recognized ID: 999",
      "help": "https://developers.asana.com/docs/errors"
    }
  ]
}
```

Check for errors in scripts:

```bash
RESP=$(curl -s "$BASE/tasks/$TASK_GID" -H "$AUTH")
if echo "$RESP" | python3 -c "import sys,json; sys.exit(0 if 'errors' not in json.load(sys.stdin) else 1)"; then
  echo "Success"
else
  echo "Error:" $(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['errors'][0]['message'])")
  exit 1
fi
```

---

## Rate Limits

Asana enforces **150 requests per minute** per user. The maton.ai gateway forwards these limits.

- For bulk operations: add `sleep 0.5` between requests (~120 req/min)
- On 429: read the `Retry-After` header/body and wait — use the retry wrapper in [Shell Scripting Guide](#shell-scripting-guide)
- Rate limits are per user — multiple agents using the same Asana account share the same limit

---

## Security Notes

### Never put API keys in shell history

```bash
# BAD — key appears in ~/.bash_history
export MATON_API_KEY="v2.abc123..."

# GOOD — read from file (not logged)
export MATON_API_KEY=$(cat ~/.secrets/maton_api_key)

# GOOD — prompt without echo (interactive use)
read -rs MATON_API_KEY < /dev/tty
export MATON_API_KEY
```

### Avoid exposing the bearer token in debug output

Never use `curl -v` or `curl -i` in shared/transcribed sessions — these flags print all request headers, including `Authorization: Bearer ...`, to stderr.

Similarly, avoid `set -x` in scripts that reference `$AUTH`:

```bash
# BAD — prints the full bearer token to the terminal/log
set -x
curl -s "$BASE/tasks" -H "$AUTH"

# GOOD — debug non-sensitive parts separately, unset AUTH before -x tracing
set +x
curl -s "$BASE/tasks" -H "$AUTH"
```

### Safe JSON construction

Use `jq --arg` to prevent command injection when task/project names come from user input or external systems (filenames, PR titles, deploy tags):

```bash
# UNSAFE — NAME="evil" ; rm -rf /" would break the JSON and expose the shell
curl -s -X POST "$BASE/tasks" -d "{\"data\":{\"name\":\"$NAME\"}}"

# SAFE — jq escapes all special characters
curl -s -X POST "$BASE/tasks" \
  -d "$(jq -n --arg n "$NAME" '{data: {name: $n}}')"
```

### Validate webhook signatures

Always verify `X-Hook-Signature` before processing webhook events:

```python
import hmac, hashlib
def verify(payload: bytes, sig_header: str, secret: str) -> bool:
    expected = hmac.new(secret.encode(), payload, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, sig_header)
```

### Confirm before destructive operations

```bash
delete_task() {
  local gid="$1"
  local name
  name=$(curl -s "$BASE/tasks/$gid?opt_fields=name" -H "$AUTH" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['name'])")
  read -rp "Delete task '$name' ($gid)? [y/N] " confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || { echo "Cancelled."; return 1; }
  curl -s -X DELETE "$BASE/tasks/$gid" -H "$AUTH"
}
```

### Key rotation schedule

Rotate your maton.ai API key:
- **After** any personnel change (offboarding a team member who had access)
- **After** any suspected exposure (key appears in logs, Git history, or chat)
- **Proactively** every 90 days as part of credential hygiene

Rotate at: https://maton.ai/settings → API Keys → Revoke + Create New

### Workspace isolation

If your maton.ai account is connected to multiple Asana workspaces, always pass an explicit `workspace` parameter in requests to prevent operations from defaulting to the wrong workspace.

### Data sensitivity

Asana task notes often contain PII, internal roadmaps, or credentials. When logging API responses:
- Use `opt_fields` to omit `notes` from list responses
- Avoid logging full task payloads to shared log systems
- Treat task content as potentially sensitive

### Audit logging

For automation scripts that modify Asana data on behalf of users, log what was done:

```bash
log_action() {
  local action="$1" resource="$2" gid="$3"
  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) [asana-api] $action $resource $gid" >> ~/.botlearn/asana-audit.log
}
log_action "DELETE" "task" "$TASK_GID"
```

---

## Troubleshooting

### 401 Unauthorized
- Is `MATON_API_KEY` exported? Run `echo $MATON_API_KEY` — should show the key.
- Has the key been rotated? Generate a new one at maton.ai/settings.

### 403 Forbidden
- Is the Asana OAuth connection active? Check: `curl -s "https://ctrl.maton.ai/connections" -H "$AUTH"`
- Does the connection have the right scopes? Re-authorize at maton.ai/connections if unsure.
- Are you accessing a resource in a different workspace than the one connected?

### 404 Not Found
- Copy the GID directly from Asana's URL bar or API response — do not use placeholder values from this doc.
- Tasks and projects can be "deleted" (soft-deleted) — only admins can see and recover them.

### Tasks not appearing in list
- Completed tasks are filtered out by default. Add `?completed_since=now` to see all, or `?completed=false` to explicitly exclude.
- `GET /tasks?assignee=me` only returns tasks in your "My Tasks". Use `GET /projects/{gid}/tasks` for project-level lists.

### Pagination not returning all results
- Check `next_page` in the response — if it's not `null`, there are more pages.
- Default `limit` is 20. Set `limit=100` for larger pages (max 100 per request).

### Webhook not firing
- Check the target URL is publicly reachable (not localhost). Use a tunnel like ngrok for local testing.
- Asana sends a handshake on creation — your endpoint must echo back the `X-Hook-Secret` header within 10 seconds.
- Webhooks expire if they fail to deliver for an extended period — check their status with `GET /webhooks`.

### `python3` not available
- Use `jq` as an alternative — see the jq alternatives in [Shell Scripting Guide](#shell-scripting-guide).
- On macOS: `brew install jq`. On Debian/Ubuntu: `apt-get install jq`.

---

## Limitations

This skill does not cover:

- **Asana automation rules** — Asana's no-code automation rules (IF task moves to Done, THEN assign to X) cannot be created or modified via the API. Manage them through the Asana UI.
- **Asana Goals** — Goals API (`/goals`) is available in the Asana REST API but not documented in this skill.
- **Rich text in task notes** — Asana supports rich text in the UI; the API `notes` field is plain text. Use `html_notes` for a limited HTML subset (see Asana docs for allowed tags).
- **File preview / rendering** — Attachment `download_url` values are time-limited signed URLs; this skill does not handle rendering or previewing file content.
- **Asana UI automation** — This skill covers only the REST API. It cannot click buttons, navigate the Asana UI, or trigger UI-only features.
- **Real-time presence** — Who is currently viewing a task is not exposed by the API.
- **Inbox notifications / user task lists** — `/inbox` and `/user_task_lists` are separate resources not covered here.
- **Advanced search on free plans** — `POST /workspaces/{gid}/tasks/search` requires a premium workspace; returns 402 on free plans. Fall back to `GET /projects/{gid}/tasks` with local filtering.
- **Portfolios on free/premium plans** — Portfolio endpoints are available only on Asana Business and Enterprise. Covered in the [Portfolios](#portfolios) section with a 402 note.

---

## Related

- [Asana REST API docs](https://developers.asana.com/docs)
- [maton.ai gateway docs](https://maton.ai/docs)
- Connect more apps at [maton.ai/connections](https://maton.ai/connections)
- Rotate your maton.ai key at [maton.ai/settings](https://maton.ai/settings)
