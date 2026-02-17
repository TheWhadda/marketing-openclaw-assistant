# Multi-Agent Marketing Pipeline — Architecture

## Overview

A six-phase cyclical pipeline with twelve specialized agents and six Quality Gates. Each phase produces a specific deliverable that must pass its gate before the next phase begins.

```
DISCOVERY → [QG1] → PLANNING → [QG2] → PRODUCTION → [QG3]
                                                         ↓
LEARNING ← [QG6] ← MONITORING ← [QG5] ← EXECUTION ← [QG4]
    ↺
```

---

## Phases and Agents

### Phase 1: DISCOVERY

**Goal:** Generate validated marketing hypotheses worth testing.

| Agent | Role | Inputs | Outputs |
|-------|------|--------|---------|
| **Аналитик** | Collects and structures existing data — ad account performance, CRM data, audience insights | Previous campaign data, platform APIs | Structured data report |
| **Дипресерчер** | Deep research — competitor analysis, market trends, audience signals | Data report, search tools | Research brief |
| **Гипотезатор** | Synthesizes research into testable hypotheses | Research brief | Hypothesis candidates |

**Quality Gate QG1 — Valid Hypothesis**

Criteria:
- [ ] Clear problem statement (what pain/desire to address)
- [ ] Specific target audience segment defined
- [ ] Measurable expected outcome (metric + baseline + target)
- [ ] At least one falsifiable hypothesis per audience segment
- [ ] Risk assessment completed

Output artifact: `hypothesis.json`

---

### Phase 2: PLANNING

**Goal:** Convert a hypothesis into an executable, budgeted campaign plan.

| Agent | Role | Inputs | Outputs |
|-------|------|--------|---------|
| **Гипотезатор** | Refines approved hypothesis into campaign brief | Approved hypothesis | Campaign brief |
| **Распределятор-планировщик** | Breaks brief into tasks, assigns agents, sets timeline and budget | Campaign brief | Execution plan |

**Human Approval Required** — no production work or budget commitment proceeds without sign-off.

**Quality Gate QG2 — Executable Plan**

Criteria:
- [ ] All tasks enumerated with responsible agent/person
- [ ] Timeline with milestones
- [ ] Budget allocated and approved
- [ ] Channels and platforms specified
- [ ] Human explicitly approved

Output artifact: `plan.json`

---

### Phase 3: PRODUCTION

**Goal:** Create all campaign assets and configurations.

| Agent | Role | Inputs | Outputs |
|-------|------|--------|---------|
| **Семантолог** | Keyword research, semantic clusters, negative keyword lists | Campaign brief | Semantic map |
| **Копирайтер** | Ad copy, headlines, descriptions, landing page text, email | Campaign brief, semantic map | Copy assets |
| **Иллюстратор** | Visual concepts, image prompts, creative briefs | Campaign brief, copy | Visual assets / briefs |
| **Настройщик** | Platform configuration: targeting, bidding, ad groups, placement | Plan, all assets | Platform configs |
| **Запускатор** | Assembles all assets into launch package, pre-validates | All assets + configs | Launch package |

**Quality Gate QG3 — Pre-Launch Validation**

Criteria:
- [ ] All copy assets complete and proofread
- [ ] All visuals complete or briefs approved
- [ ] Platform configurations validated (targeting, budget caps, bid limits)
- [ ] Tracking / UTM / pixel setup verified
- [ ] Legal / policy compliance checked
- [ ] Launch package assembled and signed off

Output artifact: `launch-package/`

---

### Phase 4: EXECUTION

**Goal:** Publish and verify the campaign is live and correctly configured.

| Agent | Role | Inputs | Outputs |
|-------|------|--------|---------|
| **Запускатор** | Publishes assets to platforms via APIs or guided steps | Launch package | Publication confirmations |

Post-launch verification steps:
1. Confirm ads are live and in "Active" / "Learning" state
2. Verify tracking is firing (test conversion events)
3. Check budget is not overspending in the first hour
4. Capture campaign IDs and platform references

**Quality Gate QG4 — Launch Verification**

Criteria:
- [ ] All ads confirmed active on all platforms
- [ ] Tracking events verified (at least one test conversion)
- [ ] No policy violations flagged
- [ ] Budget pacing is within expected range
- [ ] Campaign IDs documented

Output artifact: `launch-report.json`

---

### Phase 5: MONITORING

**Goal:** Continuous performance tracking and safety monitoring.

| Agent | Role | Inputs | Outputs |
|-------|------|--------|---------|
| **Контролер** | Real-time monitoring of spend, CTR, CPA, ROAS, anomalies | Platform APIs, campaign IDs | Alerts, status reports |
| **Аналитик** | Periodic performance analysis, trend identification | Контролер reports | Performance reports |

Monitoring checks:
- Budget burn rate vs plan
- CTR vs baseline hypothesis
- Conversion rate vs expected
- ROAS / CPA vs targets
- Audience quality signals (bounce rate, time on site)
- Anomaly detection (sudden drops or spikes)

**Quality Gate QG5 — Safety**

Criteria:
- [ ] No budget overrun (>110% of daily plan)
- [ ] No policy violations
- [ ] Performance not in freefall (CTR < 20% of baseline triggers review)
- [ ] No data/tracking anomalies
- [ ] Human notified of any critical alerts

Output: Ongoing. Critical failures trigger immediate escalation to human.

---

### Phase 6: LEARNING

**Goal:** Extract learnings, decide next steps, update knowledge base.

| Agent | Role | Inputs | Outputs |
|-------|------|--------|---------|
| **Оценщик** | Evaluates campaign results vs hypothesis — did it work? why/why not? | All phase data | Evaluation report |
| **Масштабировщик** | Decides: scale / pause / kill / iterate. Identifies winning patterns | Evaluation report | Decision + scale plan |

Knowledge base update:
- Save winning ad formats, audiences, messages
- Save negative learnings (what didn't work and why)
- Update audience segments with new signals
- Record validated hypotheses for future DISCOVERY

**Quality Gate QG6 — Knowledge Update**

Criteria:
- [ ] Evaluation report complete (results vs hypothesis)
- [ ] Scale/pause/kill decision documented
- [ ] At least 3 learnings written to knowledge base
- [ ] Next hypothesis candidates generated (if scaling or iterating)
- [ ] Knowledge base committed and versioned

→ Returns to DISCOVERY with enriched knowledge base.

---

## Data Flow

```
hypothesis.json
    → plan.json
        → launch-package/
            → launch-report.json
                → monitoring-reports/
                    → evaluation-report.json
                        → knowledge-base/ → (next hypothesis)
```

## Agent Interaction Model

All agents in the same phase can run in parallel where dependencies allow.
Cross-phase dependencies are strictly sequential (enforced by Quality Gates).

```
PRODUCTION (parallel where possible):
  Семантолог ──┐
  Копирайтер ──┤ (Копирайтер waits for Семантолог)
  Иллюстратор ─┤ (can run in parallel with Копирайтер)
  Настройщик ──┘ (waits for all above)
       ↓
  Запускатор (assembles, always last)
```

## Implementation Status

| Phase | Status |
|-------|--------|
| DISCOVERY | Planned |
| PLANNING | Planned |
| PRODUCTION | Planned |
| EXECUTION | Planned |
| MONITORING | Planned |
| LEARNING | Planned |

**Current:** Foundation / project structure only. Single general-purpose agent handles all requests until specialized agents are built.

## Technology Stack

- **Gateway:** [OpenClaw](https://openclaw.ai) — multi-channel AI gateway
- **Agent runtime:** Claude Agent SDK (Pi agent in RPC mode)
- **Model:** claude-opus-4-6 (primary), claude-sonnet-4-5 (fallback)
- **Channels:** TBD (configured via OpenClaw)
- **Storage:** OpenClaw workspace memory + future structured storage
