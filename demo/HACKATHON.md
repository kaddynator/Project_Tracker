# Hackathon Presentation: "Proposal → Project in One Shot"

## The skill: `asana-api` on BotLearn

Built and published by KarthikBot on BotLearn.ai — the AI Agent University.

---

## The Hook (15 seconds)

> "You close a client. They say yes. What happens next?"
>
> If you're a solo founder: you spend the next 30 minutes creating a project in Asana, adding sections, copying task names from your proposal, setting due dates one by one, and scheduling invoices.
>
> **What if your AI agent did all of that from one sentence?**

---

## The Demo (live — 60 seconds)

**Say this to your agent:**

> "Acme Corp said yes to the 3-month SEO retainer. Set everything up in Asana."

**What happens in under 30 seconds:**

| # | What the agent does | Asana API call |
|---|---|---|
| 1 | Creates the project with a description | `POST /projects` |
| 2 | Sets up 4 workflow sections | `POST /projects/{gid}/sections` × 4 |
| 3 | Creates 12 tasks with due dates & notes | `POST /tasks` × 12 |
| 4 | Places each task in the right section | `POST /sections/{gid}/addTask` × 12 |
| 5 | Posts a kickoff comment | `POST /tasks/{gid}/stories` |

**Show live in Asana:**
- Project `Client: Acme Corp — 3-Month SEO Retainer` is there
- 4 sections: Discovery, Content, Reporting, Billing
- 12 tasks, all with due dates cascading across 3 months
- First task has an AI-written kickoff note

**The punchline:** This would have taken 25–30 minutes manually. The agent did it in one shot.

---

## What Makes This Possible

### BotLearn — the AI Agent University

BotLearn is a platform where AI agents go to learn capabilities and earn skills.

- Agents are **benchmarked** to find gaps
- **Skills are installed** — like an app store for agent abilities
- A **community** of agents and builders share what works

KarthikBot (the demo agent) installed the `asana-api` skill from the BotLearn marketplace.

### The `asana-api` Skill

- Built on top of **maton.ai** — a gateway that connects AI agents to Asana's REST API
- Covers the full CRUD surface: tasks, projects, sections, comments, tags, webhooks, custom fields
- Works from **natural language** — no code required by the end user

### maton.ai — the Bridge

maton.ai acts as the secure API gateway between the agent and Asana. One API key, one gateway URL, full Asana access. No OAuth dance, no server to run.

```
AI Agent ──natural language──► Claude Code
Claude Code ──Asana API skill──► maton.ai gateway
maton.ai ──REST calls──► Asana
```

---

## The Bigger Picture: Solo Entrepreneur AI Stack

For a solo founder, the key constraint isn't ability — it's **time and context switching**.

Every closed deal triggers the same project setup ritual. Every month triggers the same invoice and report. These are 100% repeatable, 100% automatable.

With this stack:
- **Close a deal** → agent sets up the project (this demo)
- **End of month** → agent queries overdue tasks, drafts the client report, schedules the invoice
- **Monday morning** → agent surfaces what's urgent, reassigns what's slipped, flags what's at risk

The `asana-api` skill is the **action layer** — the agent's hands inside Asana. BotLearn is where it learned to use them.

---

## Q&A Prep

**"Can it work with a real natural language prompt, not a script?"**
Yes. The demo script is the *agent's behavior* distilled into bash for a hackathon demo. In a real Claude Code session, the user types the sentence and the agent runs the exact same API calls — the skill file tells it what parameters to use.

**"What's maton.ai?"**
An API gateway that exposes 50+ Asana resource types through a single Bearer token. Instead of each agent managing OAuth tokens, maton.ai handles auth and routes calls.

**"Can the skill do more than create tasks?"**
Yes — it covers updates, queries, webhooks, custom fields, dependencies, attachments, portfolio management. Today's demo is project creation; next session could be a full Monday morning review workflow.

**"How long did it take to build the skill?"**
The `asana-api` skill was built in one Claude Code session — SKILL.md written, API coverage verified, published to BotLearn, then iterated with 5 parallel persona reviews to add coverage gaps (custom fields, portfolio management, bulk operations).

**"Where is the skill?"**
Live on BotLearn: `asana-api` by KarthikBot. Any agent enrolled in BotLearn can install and use it.

---

## Live Links

- BotLearn: https://www.botlearn.ai
- maton.ai: https://maton.ai
- Asana project (demo): see app.asana.com → workspace "ssdi" → "Client: Acme Corp — 3-Month SEO Retainer"
- Demo script: `skills/asana-api/demo/demo-script.sh`

---

## What Was Built This Session

1. `asana-api` skill — full SKILL.md covering all major Asana resource types via maton.ai
2. Published to BotLearn by KarthikBot
3. Iterated with 5 parallel agent personas (developer, PM, freelancer, data analyst, security reviewer)
4. Demo project built live in Asana: 1 project, 4 sections, 12 tasks, 1 kickoff comment
5. Demo script (`demo-script.sh`) — reproducible in any future hackathon presentation
6. HyperFrames video short (`asana-api-skill-manage-asana-tasks-projects`) — 45s preview available
