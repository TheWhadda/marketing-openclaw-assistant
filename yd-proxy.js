/**
 * Yandex Direct API proxy — runs on localhost:9001 inside the Railway container.
 * Agent calls it via web_fetch (GET) to avoid exec/Session Send pairing issues.
 *
 * Endpoints:
 *   GET /yd?report=yesterday
 *   GET /yd?report=last7days
 *   GET /yd?report=last30days
 *   GET /yd?report=thismonth
 *   GET /yd?report=lastmonth
 *   GET /yd?report=custom&from=YYYY-MM-DD&to=YYYY-MM-DD
 *   GET /yd?report=queries&from=YYYY-MM-DD&to=YYYY-MM-DD
 *
 * Returns TSV on HTTP 200, plain text error on other status codes.
 */

'use strict';

const http = require('http');
const https = require('https');

const TOKEN = process.env.YANDEX_DIRECT_TOKEN;
const PORT = 9001;
const YD_URL = 'https://api.direct.yandex.com/json/v5/reports';

const CAMPAIGN_FIELDS = [
  'CampaignId', 'CampaignName',
  'Impressions', 'Clicks', 'Ctr',
  'AvgCpc', 'Cost', 'Conversions', 'CostPerConversion', 'ConversionRate',
];

const QUERY_FIELDS = [
  'Query', 'Impressions', 'Clicks', 'Ctr', 'AvgCpc', 'Cost', 'Conversions',
];

function buildParams(report, from, to) {
  const base = {
    Format: 'TSV',
    IncludeVAT: 'YES',
    IncludeDiscount: 'NO',
  };

  const presets = {
    yesterday:  { DateRangeType: 'YESTERDAY' },
    last7days:  { DateRangeType: 'LAST_7_DAYS' },
    last30days: { DateRangeType: 'LAST_30_DAYS' },
    thismonth:  { DateRangeType: 'THIS_MONTH' },
    lastmonth:  { DateRangeType: 'LAST_MONTH' },
  };

  if (report === 'queries') {
    const criteria = from && to ? { DateFrom: from, DateTo: to } : {};
    return {
      ...base,
      SelectionCriteria: criteria,
      FieldNames: QUERY_FIELDS,
      ReportName: `queries-${Date.now()}`,
      ReportType: 'SEARCH_QUERY_PERFORMANCE_REPORT',
      DateRangeType: from && to ? 'CUSTOM_DATE' : 'YESTERDAY',
    };
  }

  if (report === 'custom') {
    if (!from || !to) return null;
    return {
      ...base,
      SelectionCriteria: { DateFrom: from, DateTo: to },
      FieldNames: CAMPAIGN_FIELDS,
      ReportName: `campaigns-custom-${Date.now()}`,
      ReportType: 'CAMPAIGN_PERFORMANCE_REPORT',
      DateRangeType: 'CUSTOM_DATE',
    };
  }

  const preset = presets[report];
  if (!preset) return null;

  return {
    ...base,
    SelectionCriteria: {},
    FieldNames: CAMPAIGN_FIELDS,
    ReportName: `campaigns-${report}-${Date.now()}`,
    ReportType: 'CAMPAIGN_PERFORMANCE_REPORT',
    ...preset,
  };
}

function callYandexDirect(params, res) {
  const body = JSON.stringify({ params });
  const options = {
    hostname: 'api.direct.yandex.com',
    path: '/json/v5/reports',
    method: 'POST',
    headers: {
      Authorization: `Bearer ${TOKEN}`,
      'Content-Type': 'application/json',
      'Accept-Language': 'ru',
      processingMode: 'auto',
      'Content-Length': Buffer.byteLength(body),
    },
  };

  const req = https.request(options, (apiRes) => {
    let data = '';
    apiRes.on('data', (chunk) => { data += chunk; });
    apiRes.on('end', () => {
      if (apiRes.statusCode === 200) {
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(data);
      } else if (apiRes.statusCode === 201 || apiRes.statusCode === 202) {
        const retry = apiRes.headers['retry-after'] || '60';
        res.writeHead(202, { 'Retry-After': retry, 'Content-Type': 'text/plain' });
        res.end(`Report is building. Retry in ${retry}s.`);
      } else {
        res.writeHead(apiRes.statusCode, { 'Content-Type': 'text/plain' });
        res.end(`Yandex Direct error ${apiRes.statusCode}: ${data}`);
      }
    });
  });

  req.on('error', (err) => {
    res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end(`Proxy error: ${err.message}`);
  });

  req.write(body);
  req.end();
}

const server = http.createServer((req, res) => {
  if (!req.url.startsWith('/yd')) {
    res.writeHead(404).end('Not found');
    return;
  }

  if (!TOKEN) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end('YANDEX_DIRECT_TOKEN is not set');
    return;
  }

  const url = new URL(req.url, `http://localhost:${PORT}`);
  const report = url.searchParams.get('report') || 'yesterday';
  const from   = url.searchParams.get('from');
  const to     = url.searchParams.get('to');

  const params = buildParams(report, from, to);
  if (!params) {
    res.writeHead(400, { 'Content-Type': 'text/plain' });
    res.end(`Unknown report type: ${report}. Valid: yesterday, last7days, last30days, thismonth, lastmonth, custom, queries`);
    return;
  }

  callYandexDirect(params, res);
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`[yd-proxy] Listening on 127.0.0.1:${PORT}`);
});
