#!/usr/bin/env python3
"""
Yandex Direct — campaign stats for a preset period.
Usage: python3 yd-preset.py [YESTERDAY|LAST_7_DAYS|LAST_30_DAYS|THIS_MONTH|LAST_MONTH]
Default: YESTERDAY
"""
import urllib.request, urllib.error, json, os, sys

TOKEN = os.environ.get('YANDEX_DIRECT_TOKEN', '')
if not TOKEN:
    sys.exit('ERROR: YANDEX_DIRECT_TOKEN is not set')

DATE_RANGE = sys.argv[1] if len(sys.argv) > 1 else 'YESTERDAY'
VALID = {'YESTERDAY', 'LAST_7_DAYS', 'LAST_30_DAYS', 'THIS_MONTH', 'LAST_MONTH'}
if DATE_RANGE not in VALID:
    sys.exit(f'ERROR: invalid period "{DATE_RANGE}". Valid: {", ".join(sorted(VALID))}')

params = {
    "SelectionCriteria": {},
    "FieldNames": ["CampaignId", "CampaignName", "Impressions", "Clicks", "Ctr",
                   "AvgCpc", "Cost", "Conversions", "CostPerConversion", "ConversionRate"],
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
