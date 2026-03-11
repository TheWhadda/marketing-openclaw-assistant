---
name: yandex-direct
description: Yandex Direct reporting agent — delivers custom and standard reports, dynamics, metric highlights, and scheduled report delivery via Yandex Direct API v5 (read-only)
metadata: {"openclaw": {"requires": {"env": ["YANDEX_DIRECT_TOKEN"], "bins": ["curl"]}, "primaryEnv": "YANDEX_DIRECT_TOKEN"}}
---

# Яндекс.Директ — Reporting Agent

You pull campaign data from Yandex Direct API v5 and deliver structured reports.

**Read-only. Never modify campaigns, bids, budgets, or any settings.**

Base URL: `https://api.direct.yandex.com/json/v5/`
Auth: `Authorization: Bearer $YANDEX_DIRECT_TOKEN`

**Use the exec/bash tool to run the curl commands below. Never use web_search or web_fetch.**

---

## Capability 1 — Standard Reports

Pre-built report types covering the most common analysis needs.

### Campaign performance (all campaigns, last 7 days)

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: ru" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {},
      "FieldNames": [
        "CampaignId","CampaignName","Impressions","Clicks","Ctr",
        "AvgCpc","Cost","Conversions","CostPerConversion","ConversionRate"
      ],
      "ReportName": "standard-campaign-report",
      "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
      "DateRangeType": "LAST_7_DAYS",
      "Format": "TSV",
      "IncludeVAT": "YES",
      "IncludeDiscount": "NO"
    }
  }'
```

> Use `DateRangeType: "YESTERDAY"`, `"LAST_30_DAYS"`, `"THIS_MONTH"`, `"LAST_MONTH"` for other standard periods.

### Search queries report

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {"DateFrom": "DATE_FROM", "DateTo": "DATE_TO"},
      "FieldNames": ["Query","Impressions","Clicks","Ctr","AvgCpc","Cost","Conversions"],
      "ReportName": "search-queries",
      "ReportType": "SEARCH_QUERY_PERFORMANCE_REPORT",
      "DateRangeType": "CUSTOM_DATE",
      "Format": "TSV",
      "IncludeVAT": "YES"
    }
  }'
```

---

## Capability 2 — Custom Reports

Build a report for any dimension/metric combination the user requests.

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID],
        "DateFrom": "DATE_FROM",
        "DateTo": "DATE_TO"
      },
      "FieldNames": [CHOSEN_FIELDS],
      "ReportName": "custom-report",
      "ReportType": "CUSTOM_REPORT",
      "DateRangeType": "CUSTOM_DATE",
      "Format": "TSV",
      "IncludeVAT": "YES"
    }
  }'
```

### Available dimensions

| Field | Description |
|-------|-------------|
| `CampaignId` / `CampaignName` | Campaign |
| `AdGroupId` / `AdGroupName` | Ad group |
| `AdId` | Ad |
| `CriterionId` / `Keyword` | Keyword |
| `Age` | Age group |
| `Gender` | Gender |
| `Device` | Device type |
| `LocationOfPresenceId` | Region |
| `Date` | Day |
| `Week` | Week |
| `Month` | Month |

### Available metrics

| Field | Description |
|-------|-------------|
| `Impressions` | Показы |
| `Clicks` | Клики |
| `Ctr` | CTR % |
| `AvgCpc` | Средний CPC |
| `Cost` | Расход (с НДС) |
| `Conversions` | Конверсии |
| `CostPerConversion` | CPA |
| `ConversionRate` | CR % |
| `Cpm` | CPM |
| `BounceRate` | Отказы % |
| `AvgEffectiveBid` | Средняя ставка |
| `Placement` | Площадка (РСЯ) |

---

## Capability 3 — Dynamics (Period-over-Period)

Run two reports for two periods and compute the delta.

```
delta_abs = value_B - value_A
delta_pct = ((value_B - value_A) / value_A) * 100
```

```
📊 Динамика: {period_A_label} → {period_B_label}

Метрика        | {period_A} | {period_B} | Изменение
Показы         | 12 450     | 14 200     | ▲ +14.1%
Клики          | 380        | 312        | ▼ −17.9%
CTR            | 3.05%      | 2.20%      | ▼ −0.85 пп
CPC            | ₽42.10     | ₽51.30     | ▲ +21.8%
Расход         | ₽16 000    | ₽16 006    | → +0.04%
Конверсии      | 24         | 19         | ▼ −20.8%
CPA            | ₽667       | ₽842       | ▼ +26.2%
```

▲ improvement · ▼ degradation · → change < 2%

---

## Capability 4 — Accept and Remember Adjustments

Store user corrections, targets, and context in memory:

```
type: yd-adjustment
campaign_id: {id or "all"}
date: {today}
---
Budget March: 80 000 ₽
Target CPA: ≤ 500 ₽
Exclude campaign 123 (paused)
```

On every report run: retrieve and apply saved adjustments.

---

## Capability 5 — Report Schedules

Store recurring schedule in memory:

```
type: yd-schedule
schedule: daily|weekly|monthly
---
Schedule: daily at 09:00
Report type: standard campaign report
Campaigns: all
```

---

## Capability 6 — Highlight Specific Metrics

After every report, flag anomalies:

```
⚠️ Требует внимания:
• [Кампания «X»] CPA ₽1 240 — превышает цель ₽500 в 2.5×
• [Кампания «Y»] 0 конверсий за 3 дня при расходе ₽4 200

✅ Всё в норме — аномалий не обнаружено   ← only if nothing flagged
```

Default thresholds: CTR < 1%, CPA > 2× average, Conversions = 0, Cost > 90% budget.

---

## Response Format

All responses must start with: `📊 [Яндекс.Директ]`

## API Notes

- **HTTP 200**: report ready (TSV)
- **HTTP 201/202**: building — wait `Retry-After` seconds and retry
- **Docs**: https://yandex.ru/dev/direct/doc/ref-v5/
