# Project Tracker — AI-Powered Asana Automation

> **One sentence → a full client project in Asana. Under 30 seconds.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Built with BotLearn](https://img.shields.io/badge/Built%20with-BotLearn%20AI-6366f1)](https://www.botlearn.ai)
[![Powered by maton.ai](https://img.shields.io/badge/Powered%20by-maton.ai-0891b2)](https://maton.ai)
[![Asana REST API](https://img.shields.io/badge/Asana-REST%20API%20v1.0-f06a6a)](https://developers.asana.com)
[![Claude Code](https://img.shields.io/badge/Agent-Claude%20Code-4f46e5)](https://claude.ai/code)

---

## 🎬 Demo Video

**Download and watch:** [`media/asana-skill-demo.mp4`](media/asana-skill-demo.mp4) — 45-second short showing the skill in action.

> GitHub doesn't stream MP4 inline — download the file and play locally. The video was generated with [HyperFrames](https://hyperframes.heygen.com) using local TTS (Kokoro).

---

## The Problem

You're a solo consultant. You close a client. They say yes.

What happens next? **25–30 minutes of manual Asana setup:**
- Create the project
- Add sections for each workflow phase
- Copy task names from your proposal one by one
- Set due dates across 3 months
- Schedule invoices
- Write a kickoff note

This is **100% repeatable** and **100% automatable**.

---

## The Solution: Proposal → Project in One Shot

Tell your AI agent one sentence:

```
"Acme Corp said yes to the 3-month SEO retainer. Set everything up in Asana."
```

**What happens in < 30 seconds:**

| # | Agent action | Asana API call |
|---|---|---|
| 1 | Creates the project with a description | `POST /projects` |
| 2 | Adds 4 workflow sections | `POST /projects/{gid}/sections` × 4 |
| 3 | Creates 12 tasks with due dates & notes | `POST /tasks` × 12 |
| 4 | Assigns tasks to the right sections | `POST /sections/{gid}/addTask` × 12 |
| 5 | Posts an AI-written kickoff comment | `POST /tasks/{gid}/stories` |

**The result — live in your Asana workspace:**

```
📁 Client: Acme Corp — 3-Month SEO Retainer
│
├─ 🔍 Discovery & Audit
│   ├─ Technical SEO audit              due Jun 27
│   ├─ Keyword research — 50 phrases    due Jun 30
│   └─ Competitor gap analysis          due Jul 4
│
├─ 📝 Content Production
│   ├─ Blog post 1: pillar page         due Jul 11
│   ├─ Blog post 2: case study          due Jul 18
│   └─ Blog posts 3 & 4                 due Jul 25
│
├─ 📊 Reporting
│   ├─ Month 1 analytics report         due Jul 31
│   ├─ Month 2 analytics report         due Aug 31
│   └─ Final delivery report            due Sep 30
│
└─ 💰 Billing
    ├─ Invoice 1/3 — $1,500             due Jun 25
    ├─ Invoice 2/3 — $1,500             due Jul 25
    └─ Invoice 3/3 — $1,500             due Aug 25
```

25 minutes of setup. Automated to 30 seconds.

---

## Architecture

Open [`architecture/architecture.excalidraw`](architecture/architecture.excalidraw) at **[excalidraw.com](https://excalidraw.com)** for the interactive diagram.

```
👤 Solo Founder
      │
      │  "Acme Corp said yes. Set everything up in Asana."
      ▼
┌─────────────────────────────┐
│  🤖 AI Agent (Claude Code)  │ ◄── 📦 asana-api SKILL.md
│  Interprets user intent      │     (installed from BotLearn)
│  Plans the API call sequence │
└────────────┬────────────────┘
             │  structured REST calls
             ▼
┌──────────────────────────────┐
│  🌐 maton.ai Gateway         │
│  Single Bearer token         │
│  Handles Asana OAuth         │
└────────────┬─────────────────┘
             │  Asana REST API v1.0
             ▼
┌──────────────────────────────────────┐
│  ✅ Asana                             │
│  1 project · 4 sections · 12 tasks   │
│  Due dates · Notes · Kickoff comment │
└──────────────────────────────────────┘
```

**Why maton.ai?** Instead of each agent managing OAuth tokens, API refresh cycles, and Asana rate limits, maton.ai acts as a proxy gateway — the agent uses a single Bearer token and gets access to the full Asana REST surface. No server to run, no token management.

---

## Quick Start

### Prerequisites

- [maton.ai](https://maton.ai) account + API key (`MATON_API_KEY`)
- Your Asana workspace GID (find it in your Asana workspace settings)
- `curl`, `python3`, `bash`

### Run the demo

```bash
git clone https://github.com/kaddynator/Project_Tracker
cd Project_Tracker

export MATON_API_KEY="your_maton_key_here"
bash demo/demo-script.sh
```

Then open [app.asana.com](https://app.asana.com) — the full project is live.

### Use the skill with Claude Code

1. Copy `skill/SKILL.md` into your agent's skills directory (or install from BotLearn)
2. Set `MATON_API_KEY` in your environment
3. Talk to your agent in natural language:

```
"Create a new project for the Johnson account with sections for onboarding, 
delivery, and billing. Add the standard milestone tasks with due dates."
```

The agent reads the skill file, knows the API structure, and executes.

---

## The Skill: `asana-api`

**Full file:** [`skill/SKILL.md`](skill/SKILL.md) — 1,336 lines of documented API coverage.

The skill gives your AI agent complete control over Asana:

| Resource | Operations |
|---|---|
| **Tasks** | Create, read, update, delete, assign, set due dates, add followers |
| **Projects** | Create, archive, update status, add members |
| **Sections** | Create, reorder, move tasks between sections |
| **Subtasks** | Create subtask trees, set parent relationships |
| **Comments (Stories)** | Post comments, read activity feeds |
| **Custom Fields** | Read, set, and filter by custom field values |
| **Task Dependencies** | Add depends-on relationships between tasks |
| **Tags** | Create, assign to tasks, filter by tag |
| **Webhooks** | Subscribe to task/project events for real-time automation |
| **Events** | Poll-based event stream (alternative to webhooks) |
| **Attachments** | Upload files to tasks |
| **Portfolios** | Query portfolio status and constituent projects |
| **Search** | Full-text search across workspace tasks |
| **Users / Teams / Workspaces** | Discover org structure, assign by user GID |

> **Gateway base URL:** `https://gateway.maton.ai/asana/api/1.0`  
> **Auth:** `Authorization: Bearer {MATON_API_KEY}`

---

## How It Was Built

This skill was built in a single Claude Code session using the **BotLearn** platform:

```
Step 1  KarthikBot enrolled in BotLearn AI Agent University
           └─ botlearn.ai handles benchmarking & skill marketplace

Step 2  Benchmarked → capability gaps identified
           └─ BotLearn scored the agent, recommended skill categories

Step 3  Built asana-api SKILL.md
           └─ Claude Code + maton.ai gateway + live API testing
           └─ All 50+ resource types verified against real Asana workspace

Step 4  Published to BotLearn skill marketplace
           └─ Any BotLearn-enrolled agent can now install it

Step 5  Iterated with 5 parallel AI persona reviews
           └─ Developer: added pagination patterns, opt_fields reference
           └─ PM: added custom fields, project status updates
           └─ Freelancer: added invoice-task patterns, billing workflows
           └─ Data Analyst: added search, portfolio queries, bulk reads
           └─ Security Reviewer: added rate limiting, token safety notes

Step 6  Built this hackathon demo on live data
           └─ Real Asana workspace · 12 tasks created · $4,500 project value
```

---

## Repo Structure

```
Project_Tracker/
├── README.md                     ← you are here
├── LICENSE                       ← MIT
│
├── skill/
│   └── SKILL.md                  ← full asana-api skill (1,336 lines)
│
├── demo/
│   ├── demo-script.sh            ← runnable bash demo — creates Acme Corp project live
│   └── HACKATHON.md              ← presentation talk track, Q&A prep, slide notes
│
├── media/
│   └── asana-skill-demo.mp4      ← 45-second demo video (HyperFrames / Kokoro TTS)
│
└── architecture/
    └── architecture.excalidraw   ← interactive diagram (open at excalidraw.com)
```

---

## Hackathon Presentation

Full talk track, slide-by-slide notes, and Q&A prep: [`demo/HACKATHON.md`](demo/HACKATHON.md)

**The 60-second demo flow:**
1. Show the blank Asana workspace
2. Type one sentence to the agent (or run `demo-script.sh`)
3. Switch to Asana — the full project is there
4. Walk through the 4 sections and 12 tasks
5. Open the first task — show the AI kickoff comment

**Key Q&A answers baked in:**
- "Does it work with real natural language?" — Yes, the script is the agent's behavior distilled to bash
- "What's maton.ai?" — API gateway, single token, handles OAuth
- "Can it do more?" — Yes: webhooks, custom fields, portfolios, Monday reviews, invoice automation

---

## Stack

| Layer | Technology |
|---|---|
| AI Agent | [Claude Code](https://claude.ai/code) |
| Skill Platform | [BotLearn](https://www.botlearn.ai) |
| API Gateway | [maton.ai](https://maton.ai) |
| Task Management | [Asana REST API v1.0](https://developers.asana.com) |
| Demo Video | [HyperFrames](https://hyperframes.heygen.com) + Kokoro TTS |
| Diagram | [Excalidraw](https://excalidraw.com) |

---

## License

MIT — see [LICENSE](LICENSE).

Built by **KarthikBot** at the [BotLearn AI Agent Hackathon](https://www.botlearn.ai).
