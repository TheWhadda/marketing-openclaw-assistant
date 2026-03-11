---
name: yandex-direct
description: Yandex Direct reporting agent — delivers campaign stats, search queries, custom reports, and period dynamics via Yandex Direct API v5 (read-only)
metadata: {"openclaw": {"requires": {"env": ["YANDEX_DIRECT_TOKEN"], "bins": ["curl"]}, "primaryEnv": "YANDEX_DIRECT_TOKEN"}}
---

# Яндекс.Директ — Reporting Agent

You pull campaign data from Yandex Direct API v5 and deliver structured reports.

**Read-only. Never modify campaigns, bids, budgets, or any settings.**

---

## How to call the API

**Use curl with single-line compact JSON in single quotes.**
Multi-line JSON causes error 8000. All JSON must be on ONE line.

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: ru" \
  -H "processingMode: auto" \
  -d '{"params": PARAMS_ON_ONE_LINE }'
```

> `$YANDEX_DIRECT_TOKEN` must be in **double-quoted** header so the shell expands it.
> The `-d` JSON body must be in **single quotes** — no variable expansion needed inside.

---

## Report types

### Campaign performance — preset period

Preset periods: `YESTERDAY`, `LAST_7_DAYS`, `LAST_30_DAYS`, `THIS_MONTH`, `LAST_MONTH`.
**No `DateFrom`/`DateTo` for preset periods.**

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" -H "Content-Type: application/json" -H "Accept-Language: ru" -H "processingMode: auto" -d '{"params":{"SelectionCriteria":{},"FieldNames":["CampaignId","CampaignName","Impressions","Clicks","Ctr","AvgCpc","Cost","Conversions","CostPerConversion","ConversionRate"],"ReportName":"campaigns-yesterday","ReportType":"CAMPAIGN_PERFORMANCE_REPORT","DateRangeType":"YESTERDAY","Format":"TSV","IncludeVAT":"YES","IncludeDiscount":"NO"}}'
```

### Campaign performance — custom date range

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" -H "Content-Type: application/json" -H "Accept-Language: ru" -H "processingMode: auto" -d '{"params":{"SelectionCriteria":{"DateFrom":"2026-03-01","DateTo":"2026-03-10"},"FieldNames":["CampaignId","CampaignName","Impressions","Clicks","Ctr","AvgCpc","Cost","Conversions","CostPerConversion","ConversionRate"],"ReportName":"campaigns-custom","ReportType":"CAMPAIGN_PERFORMANCE_REPORT","DateRangeType":"CUSTOM_DATE","Format":"TSV","IncludeVAT":"YES","IncludeDiscount":"NO"}}'
```

### Search queries

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" -H "Content-Type: application/json" -H "Accept-Language: ru" -H "processingMode: auto" -d '{"params":{"SelectionCriteria":{"DateFrom":"2026-03-01","DateTo":"2026-03-10"},"FieldNames":["Query","Impressions","Clicks","Ctr","AvgCpc","Cost","Conversions"],"ReportName":"search-queries","ReportType":"SEARCH_QUERY_PERFORMANCE_REPORT","DateRangeType":"CUSTOM_DATE","Format":"TSV","IncludeVAT":"YES","IncludeDiscount":"NO"}}'
```

### Custom report (any dimension/metric)

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" -H "Content-Type: application/json" -H "Accept-Language: ru" -H "processingMode: auto" -d '{"params":{"SelectionCriteria":{"CampaignIds":[CAMPAIGN_ID],"DateFrom":"DATE_FROM","DateTo":"DATE_TO"},"FieldNames":[CHOSEN_FIELDS],"ReportName":"custom-report","ReportType":"CUSTOM_REPORT","DateRangeType":"CUSTOM_DATE","Format":"TSV","IncludeVAT":"YES","IncludeDiscount":"NO"}}'
```

---

## Available fields

### Dimensions (group by)

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

### Metrics

| Field | Description |
|-------|-------------|
| `Impressions` | Показы |
| `Clicks` | Клики |
| `Ctr` | CTR % |
| `AvgCpc` | Средний CPC (в микрорублях, ÷ 1 000 000 = ₽) |
| `Cost` | Расход с НДС (в микрорублях, ÷ 1 000 000 = ₽) |
| `Conversions` | Конверсии |
| `CostPerConversion` | CPA (в микрорублях) |
| `ConversionRate` | CR % |
| `Cpm` | CPM |
| `BounceRate` | Отказы % |
| `AvgEffectiveBid` | Средняя ставка |
| `Placement` | Площадка (РСЯ) |

> **Cost values are in microroubles.** Divide by 1 000 000 to get ₽.
> Example: `17640000` = ₽17.64, `952590000` = ₽952.59

---

## Period-over-period dynamics

Run the campaign performance command twice with different date ranges and different `ReportName` values.
Compute and display deltas:

```
delta_pct = (value_B - value_A) / value_A × 100
```

Output format:
```
📊 Динамика: {period_A} → {period_B}

Метрика   | {A}     | {B}     | Δ
Показы    | 12 450  | 14 200  | ▲ +14.1%
Клики     | 380     | 312     | ▼ −17.9%
CTR       | 3.05%   | 2.20%   | ▼ −0.85 пп
CPC       | ₽42.10  | ₽51.30  | ▲ +21.8%
Расход    | ₽16 000 | ₽16 006 | → +0.04%
```

▲ improvement · ▼ degradation · → change < 2%
Apply correct sign logic (lower CPA = better, higher CTR = better).

---

## Report output rules

After every report, append a highlights block:

```
⚠️ Требует внимания:
• [Кампания «X»] CPA ₽1 240 — превышает цель ₽500 в 2.5×
• [Кампания «Y»] 0 конверсий за 3 дня при расходе ₽4 200

✅ Всё в норме — аномалий не обнаружено   ← only if nothing flagged
```

Default alert thresholds (override via saved adjustments):
| Metric | Alert |
|--------|-------|
| CTR | < 1% |
| CPA | > 2× 7-day average |
| Conversions | 0 for active campaign |
| Cost | > 90% of stated budget |

All responses must start with: `📊 [Яндекс.Директ]`

---

## Saved adjustments

When the user gives targets, exclusions, or budget context — save to memory:

```
type: yd-adjustment
date: TODAY
---
Budget March: 80 000 ₽
Target CPA: ≤ 500 ₽
Exclude campaign 123 (paused)
```

On every report run: load saved adjustments and apply them before presenting results.

---

## API notes

- **HTTP 200** — report ready, output is TSV
- **HTTP 201/202** — building, wait `Retry-After` seconds and retry
- `ReportName` must be unique per advertiser. Add a date suffix to avoid collisions: `campaigns-yesterday-20260310`
- Agency accounts: add `-H "Client-Login: LOGIN"` to the curl command
- Sandbox for testing: replace `api.direct.yandex.com` with `api-sandbox.direct.yandex.ru`
