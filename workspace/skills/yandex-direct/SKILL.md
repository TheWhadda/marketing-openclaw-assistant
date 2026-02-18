---
name: yandex-direct
description: Manage Yandex Direct ad campaigns — read stats, campaigns, ad groups, ads, keywords and bids via the JSON API v5
metadata: {"openclaw": {"requires": {"env": ["YANDEX_DIRECT_TOKEN"], "bins": ["curl"]}, "primaryEnv": "YANDEX_DIRECT_TOKEN"}}
---

# Yandex Direct API v5

Base URL: `https://api.direct.yandex.com/json/v5/`

All requests are `POST` with JSON body and Bearer auth.

## Auth header

```bash
AUTH="Authorization: Bearer $YANDEX_DIRECT_TOKEN"
```

Get a token at: https://oauth.yandex.ru — create an app with Yandex Direct permissions,
then obtain the token via OAuth 2.0 or the sandbox at https://direct.yandex.ru/api/v5.

---

## Campaigns

### List campaigns

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/campaigns" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {},
      "FieldNames": ["Id","Name","State","Status","StartDate","DailyBudget"]
    }
  }'
```

### Pause a campaign

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/campaigns" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"method": "suspend", "params": {"SelectionCriteria": {"Ids": [CAMPAIGN_ID]}}}'
```

### Resume a campaign

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/campaigns" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{"method": "resume", "params": {"SelectionCriteria": {"Ids": [CAMPAIGN_ID]}}}'
```

---

## Ad groups

### List ad groups for a campaign

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/adgroups" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {"CampaignIds": [CAMPAIGN_ID]},
      "FieldNames": ["Id","Name","CampaignId","Status","RegionIds"]
    }
  }'
```

---

## Ads

### List ads

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/ads" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {"CampaignIds": [CAMPAIGN_ID]},
      "FieldNames": ["Id","AdGroupId","State","Status"],
      "TextAdFieldNames": ["Title","Title2","Text","Href","DisplayUrlPath"]
    }
  }'
```

---

## Keywords

### List keywords

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/keywords" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {"CampaignIds": [CAMPAIGN_ID]},
      "FieldNames": ["Id","Keyword","Bid","ContextBid","State","Status","QualityScore"]
    }
  }'
```

### Set keyword bids

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/keywords" \
  -H "$AUTH" -H "Content-Type: application/json" \
  -d '{
    "method": "setBids",
    "params": {
      "Bids": [{"KeywordId": KEYWORD_ID, "Bid": 3000000}]
    }
  }'
```

> Bids are in micros (1 RUB = 1 000 000 micros). Min bid is typically 300 000 (0.30 RUB).

---

## Statistics (Reports)

### Request a stats report

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "$AUTH" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: ru" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {
        "DateFrom": "2026-02-01",
        "DateTo": "2026-02-18"
      },
      "FieldNames": ["CampaignId","CampaignName","Impressions","Clicks","Ctr","AvgCpc","Cost"],
      "ReportName": "campaign-stats",
      "ReportType": "CAMPAIGN_PERFORMANCE_REPORT",
      "DateRangeType": "CUSTOM_DATE",
      "Format": "TSV",
      "IncludeVAT": "YES",
      "IncludeDiscount": "NO"
    }
  }'
```

> Response is TSV. HTTP 200 = ready, HTTP 201/202 = processing (retry after `Retry-After` header seconds).

---

## Useful tips

- **Sandbox**: replace host with `https://api-sandbox.direct.yandex.ru` for testing
- **Client login**: add header `Client-Login: <login>` when acting on behalf of a client (agency accounts)
- **Pagination**: use `Page: {"Limit": 10000, "Offset": 0}` in params
- **Docs**: https://yandex.ru/dev/direct/doc/ref-v5/

---

## Setup

1. Create a Yandex OAuth app at https://oauth.yandex.ru with **Yandex Direct** permissions
2. Obtain a token (standard OAuth flow or direct.yandex.ru sandbox)
3. Add to Railway/Render variables: `YANDEX_DIRECT_TOKEN=<your_token>`
