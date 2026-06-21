# 🚀 Project_Tracker — Proposal → Project in One Shot

> **One sentence to your AI agent. A full 3-month client project live in Asana in under 30 seconds.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Built with BotLearn](https://img.shields.io/badge/Built%20with-BotLearn-6C5CE7.svg)](https://botlearn.ai)
[![Powered by maton.ai](https://img.shields.io/badge/Powered%20by-maton.ai-00B894.svg)](https://maton.ai)
[![Asana REST API](https://img.shields.io/badge/Asana-REST%20API%20v1.0-F06A6A.svg)](https://developers.asana.com)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-AI%20Agent-D97757.svg)](https://claude.com/claude-code)

`Project_Tracker` is an **`asana-api` AI skill** that lets an AI agent (Claude Code) spin up an entire client engagement in Asana — projects, sections, tasks with due dates, invoices, and a kickoff comment — from a single natural-language sentence. No clicking. No templates. No 30-minute setup ritual. Just talk.

This is the hackathon build for **BotLearn**, the AI Agent University at [botlearn.ai](https://botlearn.ai).

---

## 🎬 Demo

<video src="https://github.com/kaddynator/Project_Tracker/releases/download/v1.0.0/asana-skill-demo.mp4" controls width="100%"></video>

*45-second short — watch the agent build the full Acme Corp project live. Runs against a real Asana workspace, nothing mocked.*

---

## 🔥 The Problem

Every solo entrepreneur knows the ritual. You close a client, and then you spend **25–30 minutes** setting up the exact same project scaffold you set up last time:

- Create a new project
- Add the same phases as sections
- Type out a dozen tasks
- Set due dates spread across the engagement
- Drop in invoice milestones
- Write the kickoff note

It's **100% repeatable** and **100% automatable** — yet most people do it by hand, every single time, while the meter on their actual billable work isn't running.

---

## ✨ The Solution

One sentence → AI agent → a complete project in Asana in **under 30 seconds**.

> *"Set up a 3-month engagement for Acme Corp with discovery, content, reporting, and billing phases."*

Here's what the agent does the moment you hit enter:

| Step | Agent action | Asana API call |
|---|---|---|
| 1 | Create the project | `POST /projects` |
| 2 | Add 4 sections | `POST /projects/{gid}/sections` × 4 |
| 3 | Create 12 tasks with due dates | `POST /tasks` × 12 |
| 4 | Assign each task to its section | `POST /sections/{gid}/addTask` × 12 |
| 5 | Post the kickoff comment | `POST /tasks/{gid}/stories` |

**Result:** 1 project · 4 sections · 12 tasks with due dates · 3 invoice milestones · 1 kickoff comment — all live, all linked, all in well under half a minute.

---

## 🏗️ Architecture

![Architecture](architecture/architecture.svg)

**The key move:** maton.ai handles the Asana OAuth dance. The agent never touches Asana credentials directly — one `MATON_API_KEY` gives it full access to the Asana REST surface.

---

## ⚡ Quick Start

### Prerequisites

- [maton.ai](https://maton.ai) account + API key
- `curl`, `python3`, `bash`

### Run the demo

```bash
git clone https://github.com/kaddynator/Project_Tracker
cd Project_Tracker
export MATON_API_KEY="your_maton_key_here"
bash demo/demo-script.sh
```

Then open [app.asana.com](https://app.asana.com) — the **Acme Corp** project is live, fully populated.

### Use the skill with Claude Code

1. Copy `skill/SKILL.md` into your agent's skills directory (or install from [BotLearn](https://botlearn.ai))
2. Set `MATON_API_KEY` in your environment
3. Talk to your agent in natural language — it does the rest

---

## 🧰 The Skill: `asana-api`

The heart of this repo is [`skill/SKILL.md`](skill/SKILL.md) — a 1,336-line skill definition that gives an AI agent full command of Asana. It covers:

- **Tasks** — create, update, complete, assign, due dates
- **Projects** — create, configure, archive
- **Sections** — create, reorder, assign tasks
- **Comments** (stories) — post updates and kickoff notes
- **Tags** — label and organize work
- **Webhooks** — subscribe to real-time changes
- **Custom fields** — structured metadata on tasks and projects
- **Dependencies** — block/unblock task relationships
- **Subtasks** — nested task hierarchies
- **Attachments** — link files and assets
- **Portfolios** — roll projects up into portfolios
- **Search** — typeahead and advanced search across the workspace

➡️ **Full definition:** [`skill/SKILL.md`](skill/SKILL.md)

---

## 🛠️ How It Was Built

This skill wasn't hand-coded in a vacuum — it was built through the **BotLearn AI Agent University** workflow:

1. **Enrolled** — `KarthikBot` enrolled in [BotLearn](https://botlearn.ai), the AI Agent University.
2. **Benchmarked** — ran the agent against benchmarks to identify concrete capability gaps in Asana automation.
3. **Built** — authored the `asana-api` `SKILL.md` using **Claude Code** + the **maton.ai** gateway, verified against a live Asana workspace.
4. **Published** — shipped the skill to the BotLearn skill marketplace.
5. **Iterated** — ran **5 parallel AI persona reviews** (developer, PM, freelancer, data analyst, security reviewer) and incorporated their feedback — adding custom fields, portfolio management, bulk operations, and rate-limiting guidance.
6. **Demoed** — built this hackathon demo on **real, live Asana data**: 1 project, 4 sections, 12 tasks, $4,500 in billed work.

---

## 📡 API Coverage

| Resource | GET | POST | PUT | DELETE |
|---|:---:|:---:|:---:|:---:|
| Tasks | ✅ | ✅ | ✅ | ✅ |
| Projects | ✅ | ✅ | ✅ | ✅ |
| Sections | ✅ | ✅ | ✅ | ✅ |
| Comments (Stories) | ✅ | ✅ | — | ✅ |
| Tags | ✅ | ✅ | ✅ | ✅ |
| Webhooks | ✅ | ✅ | — | ✅ |
| Custom Fields | ✅ | ✅ | ✅ | ✅ |
| Dependencies | ✅ | ✅ | — | ✅ |
| Subtasks | ✅ | ✅ | ✅ | ✅ |
| Attachments | ✅ | ✅ | — | ✅ |
| Portfolios | ✅ | ✅ | ✅ | ✅ |
| Search | ✅ | — | — | — |

---

## 🧱 Stack

[![BotLearn](https://img.shields.io/badge/BotLearn-AI%20Agent%20University-6C5CE7.svg)](https://botlearn.ai)
[![maton.ai](https://img.shields.io/badge/maton.ai-API%20Gateway-00B894.svg)](https://maton.ai)
[![Asana](https://img.shields.io/badge/Asana-REST%20API-F06A6A.svg)](https://developers.asana.com)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-AI%20Agent-D97757.svg)](https://claude.com/claude-code)
[![bash](https://img.shields.io/badge/bash-demo-4EAA25.svg)](demo/demo-script.sh)

---

## 🎤 Hackathon Presentation Notes

The full talk track, demo timing, and Q&A prep live in [`demo/HACKATHON.md`](demo/HACKATHON.md) — read it before you present.

**60-second demo flow:**
1. Show the blank Asana workspace
2. Type one sentence to the agent (or run `demo/demo-script.sh`)
3. Switch to Asana — the full project is there
4. Walk through the 4 sections and 12 tasks
5. Open the first task — show the AI kickoff comment

---

## 📁 Repo Structure

```
Project_Tracker/
├── README.md                     ← you are here
├── LICENSE                       ← MIT
│
├── skill/
│   └── SKILL.md                  ← full asana-api skill (1,336 lines)
│
├── demo/
│   ├── demo-script.sh            ← runnable bash demo
│   └── HACKATHON.md              ← presentation talk track + Q&A prep
│
├── media/
│   └── asana-skill-demo.mp4      ← 45-second demo video
│
└── architecture/
    └── architecture.excalidraw   ← source diagram (Excalidraw format)
```

---

## 📄 License

[MIT](LICENSE) © KarthikBot · Built at [BotLearn](https://botlearn.ai)
