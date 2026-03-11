---
name: yandex-direct
description: Yandex Direct reporting agent — delivers campaign stats, search queries, custom reports, and period dynamics via Yandex Direct API v5 (read-only)
metadata: {"openclaw": {"requires": {"env": ["YANDEX_DIRECT_TOKEN"], "bins": ["python3"]}, "primaryEnv": "YANDEX_DIRECT_TOKEN"}}
---

# Яндекс.Директ — Reporting Agent

You pull campaign data from Yandex Direct API v5 and deliver structured reports.

**Read-only. Never modify campaigns, bids, budgets, or any settings.**

---

## How to run a report

Pick the script below that matches the request. **Run it as-is** — write it to `/tmp/yd.py` and execute with `python3 /tmp/yd.py`. Only change the values marked with `# ← CHANGE`.

Do NOT modify the params structure. Do NOT add or remove fields from `params`.

---

## Script 1 — Campaign stats, preset period

Use for: вчера, последние 7 дней, последние 30 дней, этот месяц, прошлый месяц.

Valid values for `DATE_RANGE`: `YESTERDAY`, `LAST_7_DAYS`, `LAST_30_DAYS`, `THIS_MONTH`, `LAST_MONTH`.

```python
# /tmp/yd.py
import urllib.request, urllib.error, json, os, sys

TOKEN = os.environ.get('YANDEX_DIRECT_TOKEN', '')
if not TOKEN:
    sys.exit('YANDEX_DIRECT_TOKEN is not set')

DATE_RANGE = "YESTERDAY"  # ← CHANGE if needed

params = {
    "SelectionCriteria": {},
    "FieldNames": ["CampaignId", "CampaignName", "Impressions", "Clicks", "Ctr", "AvgCpc", "Cost", "Conversions", "CostPerConversion", "ConversionRate"],
    "ReportName": "campaigns-" + DATE_RANGE.lower(),
    "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
    "DateRangeType": DATE_RANGE,
    "Format": "TSV",
    "IncludeVAT": "YES",
    "IncludeDiscount": "NO"
}

data = json.dumps({"params": params}).encode('utf-8')
req = urllib.request.Request(
    'https://api.direct.yandex.com/json/v5/reports',
    data=data,
    headers={
        'Authorization': 'Bearer ' + TOKEN,
        'Content-Type': 'application/json',
        'Accept-Language': 'ru',
        'processingMode': 'auto',
    },
    method='POST'
)
try:
    resp = urllib.request.urlopen(req)
    print(resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    raw = e.read().decode('utf-8')
    if e.code in (201, 202):
        print(f'[building — retry in {e.headers.get("Retry-After", "?")}s]')
    else:
        print(f'HTTP {e.code}: {raw}')
        sys.exit(1)
```

---

## Script 2 — Campaign stats, custom date range

Use for: конкретные даты типа "с 1 по 10 марта".

```python
# /tmp/yd.py
import urllib.request, urllib.error, json, os, sys

TOKEN = os.environ.get('YANDEX_DIRECT_TOKEN', '')
if not TOKEN:
    sys.exit('YANDEX_DIRECT_TOKEN is not set')

DATE_FROM = "2026-03-01"  # ← CHANGE
DATE_TO   = "2026-03-10"  # ← CHANGE

params = {
    "SelectionCriteria": {"DateFrom": DATE_FROM, "DateTo": DATE_TO},
    "FieldNames": ["CampaignId", "CampaignName", "Impressions", "Clicks", "Ctr", "AvgCpc", "Cost", "Conversions", "CostPerConversion", "ConversionRate"],
    "ReportName": "campaigns-custom-" + DATE_FROM + "-" + DATE_TO,
    "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
    "DateRangeType": "CUSTOM_DATE",
    "Format": "TSV",
    "IncludeVAT": "YES",
    "IncludeDiscount": "NO"
}

data = json.dumps({"params": params}).encode('utf-8')
req = urllib.request.Request(
    'https://api.direct.yandex.com/json/v5/reports',
    data=data,
    headers={
        'Authorization': 'Bearer ' + TOKEN,
        'Content-Type': 'application/json',
        'Accept-Language': 'ru',
        'processingMode': 'auto',
    },
    method='POST'
)
try:
    resp = urllib.request.urlopen(req)
    print(resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    raw = e.read().decode('utf-8')
    if e.code in (201, 202):
        print(f'[building — retry in {e.headers.get("Retry-After", "?")}s]')
    else:
        print(f'HTTP {e.code}: {raw}')
        sys.exit(1)
```

---

## Script 3 — Search queries, custom date range

Use for: поисковые запросы, какие ключи работают.

```python
# /tmp/yd.py
import urllib.request, urllib.error, json, os, sys

TOKEN = os.environ.get('YANDEX_DIRECT_TOKEN', '')
if not TOKEN:
    sys.exit('YANDEX_DIRECT_TOKEN is not set')

DATE_FROM = "2026-03-01"  # ← CHANGE
DATE_TO   = "2026-03-10"  # ← CHANGE

params = {
    "SelectionCriteria": {"DateFrom": DATE_FROM, "DateTo": DATE_TO},
    "FieldNames": ["Query", "Impressions", "Clicks", "Ctr", "AvgCpc", "Cost", "Conversions"],
    "ReportName": "search-queries-" + DATE_FROM + "-" + DATE_TO,
    "ReportType": "SEARCH_QUERY_PERFORMANCE_REPORT",
    "DateRangeType": "CUSTOM_DATE",
    "Format": "TSV",
    "IncludeVAT": "YES",
    "IncludeDiscount": "NO"
}

data = json.dumps({"params": params}).encode('utf-8')
req = urllib.request.Request(
    'https://api.direct.yandex.com/json/v5/reports',
    data=data,
    headers={
        'Authorization': 'Bearer ' + TOKEN,
        'Content-Type': 'application/json',
        'Accept-Language': 'ru',
        'processingMode': 'auto',
    },
    method='POST'
)
try:
    resp = urllib.request.urlopen(req)
    print(resp.read().decode('utf-8'))
except urllib.error.HTTPError as e:
    raw = e.read().decode('utf-8')
    if e.code in (201, 202):
        print(f'[building — retry in {e.headers.get("Retry-After", "?")}s]')
    else:
        print(f'HTTP {e.code}: {raw}')
        sys.exit(1)
```

---

## API notes

- **HTTP 200** — report ready, output is TSV
- **HTTP 201/202** — report building, wait `Retry-After` seconds and run again
- `ReportName` must be unique per advertiser. Scripts above auto-generate unique names from dates.
- Agency accounts: add `'Client-Login': 'LOGIN'` to headers dict
- Sandbox testing: replace `api.direct.yandex.com` with `api-sandbox.direct.yandex.ru`

---

## Cost values

All monetary values are in **microroubles**. Divide by 1 000 000 to get ₽.
Example: `17640000` = ₽17.64, `952590000` = ₽952.59

---

## Report output rules

After every report, append a highlights block:

```
⚠️ Требует внимания:
• [Кампания «X»] CPA ₽1 240 — превышает цель ₽500 в 2.5×
• [Кампания «Y»] 0 конверсий за 3 дня при расходе ₽4 200

✅ Всё в норме — аномалий не обнаружено   ← only if nothing flagged
```

Default alert thresholds:
| Metric | Alert |
|--------|-------|
| CTR | < 1% |
| CPA | > 2× 7-day average |
| Conversions | 0 for active campaign |
| Cost | > 90% of stated budget |

All responses must start with: `📊 [Яндекс.Директ]`

---

## Period-over-period dynamics

Run Script 2 twice with different date ranges and different `ReportName` values. Compute deltas:

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
