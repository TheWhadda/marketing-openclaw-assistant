---
name: yandex-direct
description: Yandex Direct agent — read-only access to campaigns, ad groups, ads, keywords, bids, targeting, analytics, wordstat, account data, and reports via Yandex Direct API v5
metadata: {"openclaw": {"requires": {"env": ["YANDEX_DIRECT_TOKEN"], "bins": ["curl"]}, "primaryEnv": "YANDEX_DIRECT_TOKEN"}}
---

# Яндекс.Директ — Read-Only Agent

You retrieve and report data from Yandex Direct API v5.

**Read-only. NEVER call any write, add, update, set, delete, manage, or archive operation.**
Write operations are listed in the LOCKED section at the bottom — they exist for reference only and must never be executed.

Base URL: `https://api.direct.yandex.com/json/v5/`
Auth: `Authorization: Bearer $YANDEX_DIRECT_TOKEN`
Agency accounts: add header `Client-Login: <login>` to act on behalf of a client.

All requests use `POST`. For reads, `"method": "get"`.

---

## Capability 1 — Campaigns

### List campaigns

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/campaigns" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {},
      "FieldNames": [
        "Id","Name","State","Status","StatusPayment","StatusClarification",
        "Type","StartDate","EndDate","DailyBudget","Funds"
      ],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

Filter by IDs: `"SelectionCriteria": {"Ids": [123, 456]}`
Filter by states: `"SelectionCriteria": {"States": ["ON","SUSPENDED","ARCHIVED"]}`
Filter by statuses: `"SelectionCriteria": {"Statuses": ["ACCEPTED","DRAFT"]}`

Optional extra fields: `"TextCampaignFieldNames"`, `"DynamicTextCampaignFieldNames"`, `"SmartCampaignFieldNames"`

---

## Capability 2 — Ad Groups

### List ad groups

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/adgroups" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID]
      },
      "FieldNames": [
        "Id","Name","CampaignId","Type","Status","ServingStatus",
        "RegionIds","NegativeKeywords","TrackingParams"
      ],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

Filter options: `"Ids"`, `"CampaignIds"`, `"Types"` (`TEXT_AD_GROUP`, `DYNAMIC_TEXT_AD_GROUP`, `SMART_AD_GROUP`)

---

## Capability 3 — Ads

### List ads

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/ads" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID]
      },
      "FieldNames": [
        "Id","AdGroupId","CampaignId","State","Status","StatusClarification","Type"
      ],
      "TextAdFieldNames": [
        "Title","Title2","Text","Href","Mobile","DisplayUrlPath","SitelinkSetId","AdImageHash","VCardId"
      ],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

Filter options: `"Ids"`, `"AdGroupIds"`, `"CampaignIds"`, `"Types"`, `"States"`, `"Statuses"`, `"Mobile"`

---

## Capability 4 — Keywords

### List keywords

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/keywords" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID]
      },
      "FieldNames": [
        "Id","AdGroupId","CampaignId","Keyword","State","Status",
        "StatusClarification","Bid","ContextBid","StrategyPriority","ServingStatus","QualityScore"
      ],
      "Page": {"Limit": 10000, "Offset": 0}
    }
  }'
```

Filter options: `"Ids"`, `"AdGroupIds"`, `"CampaignIds"`, `"States"`, `"Statuses"`, `"ServingStatuses"`

---

## Capability 5 — Keyword Bids

### Get bids

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/keywordbids" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "KeywordIds": [KEYWORD_ID]
      },
      "FieldNames": ["KeywordId","CampaignId","AdGroupId","Bid","ContextBid","ServingStatus"]
    }
  }'
```

Filter by: `"KeywordIds"`, `"AdGroupIds"`, `"CampaignIds"`

---

## Capability 6 — Bid Modifiers

### Get bid modifiers (by device, demographics, regions)

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/bidmodifiers" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID]
      },
      "FieldNames": ["Id","CampaignId","AdGroupId","Level","Type","BidModifier","Enabled"],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

Types: `DESKTOP_ADJUSTMENT`, `MOBILE_ADJUSTMENT`, `TABLET_ADJUSTMENT`, `DEMOGRAPHICS_ADJUSTMENT`, `REGIONAL_ADJUSTMENT`, `VIDEO_ADJUSTMENT`, `SMARTTV_ADJUSTMENT`

---

## Capability 7 — Autotargeting

### Get autotargeting conditions

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/audiencetargets" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID]
      },
      "FieldNames": ["Id","AdGroupId","CampaignId","RetargetingListId","InterestId","State","Status","ContextBid","StrategyPriority"]
    }
  }'
```

---

## Capability 8 — Retargeting Lists

### Get retargeting lists (remarketing audiences)

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/retargetinglists" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {},
      "FieldNames": ["Id","Name","Description","Rules","RetargetingListType","IsAvailable"],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

---

## Capability 9 — Dynamic Ad Targets

### Get dynamic ad targeting conditions

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/dynamicadtargets" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID]
      },
      "FieldNames": ["Id","AdGroupId","CampaignId","Bid","ContextBid","StrategyPriority","State","Status","Conditions","ConditionName","ConditionType"]
    }
  }'
```

---

## Capability 10 — Smart Ad Targets

### Get smart banner filters

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/smartadtargets" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID]
      },
      "FieldNames": ["Id","AdGroupId","CampaignId","Name","Bid","ContextBid","StrategyPriority","State","Status","Conditions","AvailableFiltersCount"]
    }
  }'
```

---

## Capability 11 — Feeds (Product Data Sources)

### Get feeds

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/feeds" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {},
      "FieldNames": ["Id","Name","BusinessType","SourceType","Status","UpdatedAt","OffersCount","CampaignIds"],
      "Page": {"Limit": 100, "Offset": 0}
    }
  }'
```

BusinessTypes: `RETAIL`, `HOTELS`, `REALTY`, `AUTO`, `FLIGHTS`, `JOBS`

---

## Capability 12 — Sitelinks

### Get sitelink sets

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/sitelinks" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {},
      "FieldNames": ["Id","Sitelinks"],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

---

## Capability 13 — Ad Extensions (Callouts)

### Get ad extensions

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/adextensions" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "Types": ["CALLOUT"]
      },
      "FieldNames": ["Id","Type","CalloutFieldNames"],
      "CalloutFieldNames": ["CalloutText","Status"],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

---

## Capability 14 — VCards (Business Cards)

### Get vcards

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/vcards" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "CampaignIds": [CAMPAIGN_ID]
      },
      "FieldNames": ["Id","CampaignId","CompanyName","WorkTime","Phone","Street","City","Country","Description1","Description2"],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

---

## Capability 15 — Ad Images

### Get ad images

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/adimages" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {},
      "FieldNames": ["AdImageHash","OriginalUrl","PreviewUrl","Name","Type","SubType","Status","IsAssociated"],
      "Page": {"Limit": 1000, "Offset": 0}
    }
  }'
```

---

## Capability 16 — Creatives (Video)

### Get video creatives

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/creatives" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "Types": ["VIDEO_EXTENSION_CREATIVE","CPC_VIDEO_CREATIVE","CPM_VIDEO_CREATIVE"]
      },
      "FieldNames": ["CreativeId","Name","Type","Status","PreviewUrl","Duration"]
    }
  }'
```

---

## Capability 17 — Account Info

### Get client info

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/clients" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "FieldNames": [
        "Login","ClientId","ClientInfo","Currency","Type","Status",
        "AccountQuality","Bonuses","Settings","Notification","OverdraftSumAvailable"
      ]
    }
  }'
```

### Get agency clients

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/agencyclients" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "Archived": "NO"
      },
      "FieldNames": ["Login","ClientId","ClientInfo","Currency","Type","AccountQuality","Bonuses","OverdraftSumAvailable"],
      "Page": {"Limit": 500, "Offset": 0}
    }
  }'
```

---

## Capability 18 — Dictionaries

### Get reference data

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/dictionaries" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "DictionaryNames": ["GeoRegions","Currencies","MetroStations","TimeZones","AudienceCriteriaTypes","AudienceDemographicProfiles","ProductivityGoals","Interests"]
    }
  }'
```

Available dictionaries: `GeoRegions`, `Currencies`, `MetroStations`, `TimeZones`, `AdCategories`, `OperationSystemVersions`, `ProductivityGoals`, `Interests`, `AudienceCriteriaTypes`, `AudienceDemographicProfiles`, `SupplySidePlatforms`

---

## Capability 19 — Changes Tracking

### Check what changed since a timestamp

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/changes" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "checkDictionaries",
    "params": {
      "Timestamp": "2024-01-01 00:00:00"
    }
  }'
```

Check campaign changes:
```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/changes" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "checkCampaigns",
    "params": {
      "Timestamp": "2024-01-01 00:00:00",
      "FieldNames": ["CampaignIds","AdGroupIds","AdIds"],
      "CampaignIds": [CAMPAIGN_ID]
    }
  }'
```

---

## Capability 20 — Tasks

### Get tasks

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/tasks" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "SelectionCriteria": {
        "Statuses": ["OPEN","IN_PROGRESS"]
      },
      "FieldNames": ["Id","Name","Description","Status","AssignedTo","Deadline","CampaignIds"],
      "Page": {"Limit": 100, "Offset": 0}
    }
  }'
```

---

## Capability 21 — Standard Reports

### Campaign performance (last 7 days)

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept-Language: ru" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {
        "DateFrom": "LAST_7_DAYS_START",
        "DateTo": "LAST_7_DAYS_END"
      },
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

Standard date ranges: `YESTERDAY`, `LAST_7_DAYS`, `LAST_30_DAYS`, `THIS_MONTH`, `LAST_MONTH`, `ALL_TIME`

### Ad group performance

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {"DateFrom": "DATE_FROM", "DateTo": "DATE_TO"},
      "FieldNames": ["CampaignId","AdGroupId","AdGroupName","Impressions","Clicks","Ctr","AvgCpc","Cost","Conversions","CostPerConversion"],
      "ReportName": "adgroup-report",
      "ReportType": "ADGROUP_PERFORMANCE_REPORT",
      "DateRangeType": "CUSTOM_DATE",
      "Format": "TSV",
      "IncludeVAT": "YES"
    }
  }'
```

### Ad performance

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {"DateFrom": "DATE_FROM", "DateTo": "DATE_TO"},
      "FieldNames": ["AdId","AdGroupId","CampaignId","Title","Impressions","Clicks","Ctr","AvgCpc","Cost","Conversions"],
      "ReportName": "ad-report",
      "ReportType": "AD_PERFORMANCE_REPORT",
      "DateRangeType": "CUSTOM_DATE",
      "Format": "TSV",
      "IncludeVAT": "YES"
    }
  }'
```

### Keyword / criteria performance

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {"DateFrom": "DATE_FROM", "DateTo": "DATE_TO"},
      "FieldNames": ["CriterionId","Keyword","CampaignId","AdGroupId","Impressions","Clicks","Ctr","AvgCpc","Cost","Conversions","CostPerConversion","AvgEffectiveBid"],
      "ReportName": "keyword-report",
      "ReportType": "CRITERIA_PERFORMANCE_REPORT",
      "DateRangeType": "CUSTOM_DATE",
      "Format": "TSV",
      "IncludeVAT": "YES"
    }
  }'
```

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

### Placement report (RSA / YAN)

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/reports" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -H "processingMode: auto" \
  -d '{
    "params": {
      "SelectionCriteria": {"DateFrom": "DATE_FROM", "DateTo": "DATE_TO"},
      "FieldNames": ["Placement","Impressions","Clicks","Ctr","AvgCpc","Cost","Conversions"],
      "ReportName": "placement-report",
      "ReportType": "REACH_AND_FREQUENCY_PERFORMANCE_REPORT",
      "DateRangeType": "CUSTOM_DATE",
      "Format": "TSV",
      "IncludeVAT": "YES"
    }
  }'
```

---

## Capability 22 — Custom Reports

Replace `FieldNames` with any combination from the tables below.

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

### Available dimensions (group by)

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
| `CarrierType` | Mobile carrier |
| `ClickType` | Click type (title, sitelink, etc.) |
| `Date` | Day |
| `Week` | Week |
| `Month` | Month |
| `Quarter` | Quarter |
| `Year` | Year |

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
| `AvgPageviews` | Страниц за визит |
| `BounceRate` | Отказы % |
| `AvgEffectiveBid` | Средняя ставка |
| `Placement` | Площадка (РСЯ) |
| `Revenue` | Доход |
| `GoalsRoi` | ROI |
| `Profit` | Прибыль |
| `Sessions` | Сессии (Метрика) |
| `AvgSessionDurationSeconds` | Длительность сессии |

---

## Capability 23 — Wordstat (Demand Research)

### Top keywords by frequency

```bash
curl -s -X POST "https://api.direct.yandex.com/json/v5/keywordcompatibilityestimates" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "get",
    "params": {
      "Keywords": ["KEYWORD_1", "KEYWORD_2"],
      "RegionIds": [225],
      "OperationSystemType": "ANY",
      "Currency": "RUB"
    }
  }'
```

For Wordstat data use the Wordstat API:

```bash
# Create Wordstat report
curl -s -X POST "https://api.direct.yandex.com/json/v5/keywordsresearch" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "createWordstatReport",
    "params": {
      "Phrases": ["KEYWORD"],
      "GeoId": [225]
    }
  }'
```

```bash
# Get Wordstat report results (use reportId from create response)
curl -s -X POST "https://api.direct.yandex.com/json/v5/keywordsresearch" \
  -H "Authorization: Bearer $YANDEX_DIRECT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method": "getWordstatReport",
    "params": {
      "ReportId": REPORT_ID
    }
  }'
```

---

## Capability 24 — Dynamics (Period-over-Period)

Run two reports for two periods and compute the delta.

### Step 1 — Fetch period A and period B

```bash
# Period A (e.g. last week)
curl ... -d '{"params": {"DateFrom": "PERIOD_A_START", "DateTo": "PERIOD_A_END", ...}}'

# Period B (e.g. this week)
curl ... -d '{"params": {"DateFrom": "PERIOD_B_START", "DateTo": "PERIOD_B_END", ...}}'
```

### Step 2 — Compute and present deltas

For each metric, calculate:
```
delta_abs = value_B - value_A
delta_pct = ((value_B - value_A) / value_A) * 100
```

### Presentation format

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

Use ▲ for improvements, ▼ for degradations, → for <2% change.

### Daily dynamics (last 7 days)

Use `Date` as a dimension field in a single report:

```bash
"FieldNames": ["Date","Impressions","Clicks","Ctr","Cost","Conversions","CPA"]
"DateRangeType": "LAST_7_DAYS"
```

---

## Capability 25 — Accept and Remember Adjustments

The user may give corrections, targets, or context notes. Store in memory for automatic application.

**Memory tag format:**
```
type: yd-adjustment
campaign_id: {id or "all"}
date: {today}
```

**What to save:**
- Spending limits or budget context ("бюджет на март — 80 000 ₽")
- Target metrics ("целевой CPA — не выше 500 ₽")
- Exclusions ("кампания 123 — в паузе, не включать в отчёт")
- Interpretation notes ("высокий CPA в выходные — это норма")

**On every report run:** retrieve saved adjustments and apply them:
- Filter excluded campaigns
- Flag metrics that breach stated targets
- Add budget pacing if spending limit is set

---

## Capability 26 — Report Schedules

The user can set a recurring report schedule. Store it in memory.

**Memory tag format:**
```
type: yd-schedule
schedule: daily|weekly|monthly
```

**What to store:**
```
Schedule: {daily at 09:00 / weekly Monday / monthly 1st}
Report type: {standard campaign report / custom / dynamics}
Campaigns: {all / specific IDs}
Metrics: {list}
Recipient note: {Telegram / channel}
```

**When the user triggers a message at the scheduled time**, check for saved schedules and generate the corresponding report automatically.

**Schedule commands:**
- "Присылай ежедневный отчёт в 9 утра" → save daily schedule
- "Каждый понедельник — динамика неделя к неделе" → save weekly dynamics schedule
- "Напоминай 1-го числа об итогах месяца" → save monthly schedule
- "Отмени расписание" → remove schedule from memory

---

## Capability 27 — Highlight Specific Metrics

After any report, automatically flag anomalies and threshold breaches.

**Default thresholds** (override with adjustments from Capability 25):

| Metric | Alert condition |
|--------|----------------|
| CTR | < 1% |
| CPA | > 2× the 7-day average |
| Conversions | 0 for any active campaign |
| Cost | > 90% of stated daily/monthly budget |
| BounceRate | > 50% |

**Highlight format** (add after every report):

```
⚠️ Требует внимания:
• [Кампания «Лето»] CPA ₽1 240 — превышает цель ₽500 в 2.5×
• [Кампания «Бренд»] 0 конверсий за 3 дня при расходе ₽4 200
• Расход 94% от месячного бюджета (₽75 200 / ₽80 000)
```

**Green zone:**

```
✅ Всё в норме — аномалий не обнаружено
```

---

## Response Format

All messages must use the agent header:

```
📊 [Яндекс.Директ]
{report or message}
```

---

## API Notes

- **HTTP 200**: report ready (parse TSV response)
- **HTTP 201 / 202**: report is building — wait `Retry-After` seconds and retry
- **Cost values**: in microns (÷ 1 000 000 = rubles)
- **Sandbox**: replace host with `https://api-sandbox.direct.yandex.ru` for testing
- **Agency accounts**: add header `Client-Login: <login>`
- **Pagination**: add `"Page": {"Limit": 10000, "Offset": 0}` inside params
- **Docs**: https://yandex.ru/dev/direct/doc/ref-v5/

---

## LOCKED — Write Operations (не выполнять)

The following operations are **permanently disabled** until explicitly unlocked. Never execute them.

### Campaigns (write)
- `add_campaign` — create campaign
- `update_campaign` — modify campaign settings, budgets, strategy
- `manage_campaigns` — delete, pause, resume, archive campaigns

### Ad Groups (write)
- `add_adgroup` / `add_adgroups` — create ad groups
- `update_adgroup` — modify group settings, regions, negative keywords
- `delete_adgroups` — delete groups with all ads and keywords

### Ads (write)
- `add_ad` / `add_ads` — create ads
- `update_ad` — modify headline, text, URL
- `manage_ads` — delete, pause, resume, archive, moderate ads

### Keywords (write)
- `add_keywords` / `add_keywords_batch` — add keywords
- `update_keywords` — modify keyword text
- `manage_keywords` — delete, pause, resume keywords

### Bids (write)
- `set_keyword_bids` — set search/network bids
- `set_keyword_bids_auto` — enable automatic bid management
- `add_bid_modifiers` / `set_bid_modifiers` — create or modify bid adjustments

### Targeting (write)
- `update_autotargeting` — modify autotargeting categories
- `add_audience_targets` / `delete_audience_targets` — manage audience conditions
- `add_retargeting_lists` / `update_retargeting_lists` — manage remarketing audiences
- `add_dynamic_ad_targets` / `update_dynamic_ad_targets` / `delete_dynamic_ad_targets`
- `add_smart_ad_targets` / `update_smart_ad_targets` / `delete_smart_ad_targets`

### Content (write)
- `add_sitelinks` / `delete_sitelinks` — manage sitelink sets
- `add_ad_extensions` / `delete_ad_extensions` — manage callout extensions
- `upload_ad_images` / `delete_ad_images` — upload/delete image assets
- `upload_ad_videos` — upload video supplements
- `add_creatives` — create video creatives
- `add_vcards` / `update_vcards` / `delete_vcards` — manage business cards
- `add_feeds` / `update_feeds` / `delete_feeds` — manage product data sources

### Account (write)
- `update_client` — modify contact and advertiser details

### Tasks (write)
- `add_tasks` — create monitoring tasks
- `complete_task` — mark tasks as complete or rejected
