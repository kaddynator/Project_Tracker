# Presentation Guide: "Proposal → Project in One Shot"

---

## Stage 1 — THE HOOK (30 seconds)
*Open with this — before showing anything on screen.*

> "How many of you here are freelancers, consultants, or solo founders?"

Wait for hands.

> "Every time you close a client — you spend the next 30 minutes doing the exact same thing. Create a project. Add sections. Type out tasks from your proposal. Set due dates. Schedule invoices. Write a kickoff note. Every. Single. Time."

**The pause that lands:**
> "That's not consulting work. That's admin. And it's 100% repeatable — which means it's 100% automatable."

---

## Stage 2 — THE PROBLEM (45 seconds)
*Three specific pains — say them slowly:*

- **Time cost:** 25–30 minutes of setup per client, zero billable value
- **Cognitive cost:** You switch from "I just closed a deal" energy straight into data-entry mode
- **Scale wall:** The more clients you close, the more setup you drown in — the thing that should feel like success becomes the bottleneck

**One line to remember:**
> "The moment a client says yes, you should be thinking about delivery — not clicking around in Asana."

---

## Stage 3 — THE SOLUTION STATEMENT (20 seconds)
*Say this before the demo — give them the punchline first so they know what to watch for.*

> "I built an AI skill that lets your agent set up an entire client project from one sentence. Watch what happens when I say: 'Acme Corp said yes to the 3-month SEO retainer. Set everything up in Asana.'"

---

## Stage 4 — THE LIVE DEMO (60–90 seconds)
*What to show, in order:*

1. **Show the blank Asana workspace** — nothing there, completely empty
2. **Run the demo** — type the sentence to Claude Code, or run in terminal:
   ```bash
   export MATON_API_KEY="your_key"
   bash demo/demo-script.sh
   ```
   Let the output scroll — it reads well as it prints each step.
3. **Switch to Asana** — refresh the workspace
4. **Walk through what appeared:**
   - Point to the project name
   - Click into each section — "Discovery, Content, Reporting, Billing — four phases, already structured"
   - Open a task — "Due date set, notes pre-filled, assigned to me"
   - Open the first task — "And here's the AI-written kickoff comment, already posted"
5. **Say the time:**
   > "That took 22 seconds. Manual would have been 30 minutes."

> **Tip:** The moment you switch from terminal to Asana and the project is already there — that's the "wow" beat. Pause for two seconds before walking through it. Let the audience see it before you explain it.

---

## Stage 5 — HOW IT WORKS (45 seconds)
*Point to the architecture diagram in the GitHub README.*

Three layers — keep it simple:

- **BotLearn** — the AI Agent University where the skill was published. Think of it like an app store for agent abilities.
- **The `asana-api` skill** — a 1,300-line instruction file that teaches the agent exactly how to talk to Asana. Built it, benchmarked it, published it.
- **maton.ai** — the bridge. Instead of dealing with Asana OAuth, the agent uses one API key and maton handles the rest.

> "The agent reads the skill, understands the intent, and fires the right sequence of API calls. No code written by the user. Just a sentence."

---

## Stage 6 — WHAT ELSE IT CAN DO (30 seconds)
*Expand the vision beyond the demo:*

- **Monday morning review** — "What's overdue, what's due this week, reprioritize by revenue impact"
- **End of month** — Query all tasks across projects, draft the client report, schedule the invoice
- **Webhooks** — Agent gets notified when tasks are completed or deadlines slip, and reacts automatically

> "Today I showed you the intake flow. But the same skill covers the entire engagement lifecycle."

---

## Stage 7 — THE CLOSER (20 seconds)

> "Solo founders don't have a PM, an ops person, or an EA. Their AI agent is all three. This skill is what gives the agent hands inside Asana."

**Final line:**
> "Built in one Claude Code session. Published to BotLearn. Iterated by five AI personas in parallel. And this demo runs on a real live workspace — nothing is mocked."

---

## Likely Questions — Your Answers

| Question | Your answer |
|---|---|
| "Is this real data?" | Yes — live Asana workspace, real API calls, the project is there right now |
| "What's maton.ai?" | API gateway — the agent uses one token, maton handles Asana auth. No OAuth setup needed |
| "Can it handle different project types?" | Yes — the agent interprets natural language, not a template. "3-month SEO retainer" vs "app MVP sprint" produce different structures |
| "What's BotLearn?" | AI Agent University — agents get benchmarked, install skills, and keep improving. Like GitHub Marketplace but for agent capabilities |
| "How long did this take to build?" | One Claude Code session for the skill, then 5 parallel AI persona reviews to fill gaps. A few hours total |
| "What's the 45-second video?" | A HyperFrames video short generated with local TTS — automated video production for the skill |

---

## Timing Guide (5-minute slot)

| Stage | Time |
|---|---|
| Hook + Problem | 0:00 – 1:15 |
| Solution statement | 1:15 – 1:35 |
| Live demo | 1:35 – 3:00 |
| How it works | 3:00 – 3:45 |
| What else it can do | 3:45 – 4:15 |
| Closer | 4:15 – 4:35 |
| Questions | 4:35 – 5:00 |
