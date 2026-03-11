#!/usr/bin/env python3
"""
Yandex Direct — campaign stats for a custom date range.
Usage: python3 yd-custom.py DATE_FROM DATE_TO
Example: python3 yd-custom.py 2026-03-01 2026-03-10
"""
import urllib.request, urllib.error, json, os, sys

TOKEN = os.environ.get('YANDEX_DIRECT_TOKEN', '')
if not TOKEN:
    sys.exit('ERROR: YANDEX_DIRECT_TOKEN is not set')

if len(sys.argv) < 3:
    sys.exit('Usage: python3 yd-custom.py DATE_FROM DATE_TO  (e.g. 2026-03-01 2026-03-10)')

DATE_FROM = sys.argv[1]
DATE_TO   = sys.argv[2]

params = {
    "SelectionCriteria": {"DateFrom": DATE_FROM, "DateTo": DATE_TO},
    "FieldNames": ["CampaignId", "CampaignName", "Impressions", "Clicks", "Ctr",
                   "AvgCpc", "Cost", "Conversions", "CostPerConversion", "ConversionRate"],
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
