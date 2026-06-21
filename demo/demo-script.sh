#!/usr/bin/env bash
# =============================================================================
# DEMO: "Proposal → Project in One Shot"
# Hackathon demo for the Asana API skill built with BotLearn + maton.ai
#
# SCENARIO:  You're a solo consultant. Acme Corp just said yes to your
#            3-month SEO retainer proposal. One message to your AI agent
#            sets up the entire project: sections, 12 tasks with due dates,
#            invoices, and a kickoff comment — all in under 30 seconds.
#
# LIVE URL:  After running, open Asana and show the project live on screen.
#
# USAGE:
#   export MATON_API_KEY="your_key_here"
#   bash demo-script.sh
# =============================================================================

set -euo pipefail

MATON_API_KEY="${MATON_API_KEY:?Set MATON_API_KEY before running}"
BASE="https://gateway.maton.ai/asana/api/1.0"
WORKSPACE="596034346419711"   # "ssdi" workspace
ME="596034346419708"          # Karthik Ravi

H() { echo -e "\n\033[1;36m$*\033[0m"; }
OK() { echo -e "  \033[0;32m✓ $*\033[0m"; }

# --------------------------------------------------------------------------- #
# STEP 1 — Create the project
# --------------------------------------------------------------------------- #
H "Step 1 › Creating project: Client: Acme Corp — 3-Month SEO Retainer"

PROJECT_RESP=$(curl -s -X POST "$BASE/projects" \
  -H "Authorization: Bearer $MATON_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "name": "Client: Acme Corp — 3-Month SEO Retainer",
      "workspace": "'"$WORKSPACE"'",
      "notes": "Auto-created by AI agent from proposal approval.\nStart: June 2026 | Value: $4,500 | Deliverables: SEO audit, 4 posts/month, monthly analytics report."
    }
  }')

PROJECT_GID=$(echo "$PROJECT_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['gid'])")
OK "Project GID: $PROJECT_GID"

# --------------------------------------------------------------------------- #
# STEP 2 — Create 4 sections
# --------------------------------------------------------------------------- #
H "Step 2 › Setting up workflow sections"

make_section() {
  curl -s -X POST "$BASE/projects/$PROJECT_GID/sections" \
    -H "Authorization: Bearer $MATON_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"data\":{\"name\":\"$1\"}}" | python3 -c "import sys,json; print(json.load(sys.stdin)['data']['gid'])"
}

S_DISCOVERY=$(make_section "🔍 Discovery & Audit");   OK "Section: Discovery & Audit"
S_CONTENT=$(make_section "📝 Content Production");    OK "Section: Content Production"
S_REPORTING=$(make_section "📊 Reporting");            OK "Section: Reporting"
S_BILLING=$(make_section "💰 Billing");                OK "Section: Billing"

# --------------------------------------------------------------------------- #
# STEP 3 — Create tasks and assign to sections
# --------------------------------------------------------------------------- #
H "Step 3 › Creating 12 tasks with due dates"

make_task() {
  local name="$1" notes="$2" due="$3" section="$4"
  local gid
  gid=$(curl -s -X POST "$BASE/tasks" \
    -H "Authorization: Bearer $MATON_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"data\":{\"name\":\"$name\",\"notes\":\"$notes\",\"due_on\":\"$due\",\"assignee\":\"$ME\",\"projects\":[\"$PROJECT_GID\"]}}" | \
    python3 -c "import sys,json; print(json.load(sys.stdin)['data']['gid'])")
  curl -s -X POST "$BASE/sections/$section/addTask" \
    -H "Authorization: Bearer $MATON_API_KEY" \
    -H "Content-Type: application/json" \
    -d "{\"data\":{\"task\":\"$gid\"}}" > /dev/null
  echo "$gid"
}

# Discovery
T1=$(make_task \
  "Technical SEO audit — crawl & site structure" \
  "Crawl Acme website; identify indexing issues, page speed, canonical errors, broken links." \
  "2026-06-27" "$S_DISCOVERY")
OK "Task: Technical SEO audit (due Jun 27)"

T2=$(make_task \
  "Keyword research — 50 target phrases" \
  "Identify high-intent, low-competition keywords. Prioritize by commercial value." \
  "2026-06-30" "$S_DISCOVERY")
OK "Task: Keyword research (due Jun 30)"

T3=$(make_task \
  "Competitor gap analysis" \
  "Compare Acme vs 3 main competitors on DA, top-ranking pages, backlink profile." \
  "2026-07-04" "$S_DISCOVERY")
OK "Task: Competitor gap analysis (due Jul 4)"

# Content
T4=$(make_task \
  "Blog post 1: pillar page — primary keyword target" \
  "2,000-word pillar post. Include FAQ schema markup. Target primary keyword cluster." \
  "2026-07-11" "$S_CONTENT")
OK "Task: Blog post 1 (due Jul 11)"

T5=$(make_task \
  "Blog post 2: client case study format" \
  "1,200 words, 3 testimonial quotes, results-led headline." \
  "2026-07-18" "$S_CONTENT")
OK "Task: Blog post 2 (due Jul 18)"

T6=$(make_task \
  "Blog posts 3 & 4 — complete Month 1 quota" \
  "Remaining 2 posts to hit 4 posts/month deliverable." \
  "2026-07-25" "$S_CONTENT")
OK "Task: Blog posts 3 & 4 (due Jul 25)"

# Reporting
T7=$(make_task \
  "Month 1 analytics report" \
  "GA4 + Search Console data: organic sessions, ranking changes, CTR vs prior period." \
  "2026-07-31" "$S_REPORTING")
OK "Task: Month 1 report (due Jul 31)"

T8=$(make_task \
  "Month 2 analytics report" \
  "Month 2 snapshot — compare vs Month 1 baseline and flag trend changes." \
  "2026-08-31" "$S_REPORTING")
OK "Task: Month 2 report (due Aug 31)"

T9=$(make_task \
  "Final delivery report — Month 3" \
  "3-month summary: total traffic lift, ranking wins, content inventory, Q2 recommendations." \
  "2026-09-30" "$S_REPORTING")
OK "Task: Final delivery report (due Sep 30)"

# Billing
T10=$(make_task \
  "Invoice 1/3 — June retainer (\$1,500)" \
  "Send invoice for Month 1. Net 14 payment terms. CC Acme CFO." \
  "2026-06-25" "$S_BILLING")
OK "Task: Invoice 1 (due Jun 25)"

T11=$(make_task \
  "Invoice 2/3 — July retainer (\$1,500)" \
  "Send invoice for Month 2." \
  "2026-07-25" "$S_BILLING")
OK "Task: Invoice 2 (due Jul 25)"

T12=$(make_task \
  "Invoice 3/3 — August retainer (\$1,500)" \
  "Send invoice for Month 3. Include Q2 retainer upsell offer." \
  "2026-08-25" "$S_BILLING")
OK "Task: Invoice 3 (due Aug 25)"

# --------------------------------------------------------------------------- #
# STEP 4 — Post kickoff comment on first task
# --------------------------------------------------------------------------- #
H "Step 4 › Posting AI-generated kickoff note"

curl -s -X POST "$BASE/tasks/$T1/stories" \
  -H "Authorization: Bearer $MATON_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "data": {
      "text": "🤖 Auto-created by AI agent on proposal acceptance.\n\nAcme Corp confirmed the 3-month SEO retainer at $1,500/month ($4,500 total).\n\nProject structure set up in one shot:\n• 4 workflow sections\n• 12 tasks with due dates across the full engagement\n• All 3 invoices pre-scheduled\n\nStart date: June 25, 2026.\n\nNext action: send kickoff email and schedule discovery call."
    }
  }' | python3 -c "import sys,json; print('Comment GID:', json.load(sys.stdin)['data']['gid'])"
OK "Kickoff comment posted on task T1"

# --------------------------------------------------------------------------- #
# SUMMARY
# --------------------------------------------------------------------------- #
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  DEMO COMPLETE"
echo "  Project:  Client: Acme Corp — 3-Month SEO Retainer"
echo "  GID:      $PROJECT_GID"
echo "  Tasks:    12 (across 4 sections)"
echo "  Value:    \$4,500 retainer"
echo "  Time:     ~20 seconds from one natural language command"
echo ""
echo "  Open Asana and show the project live  →  app.asana.com"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
