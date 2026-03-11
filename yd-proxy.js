'use strict';

/**
 * Yandex Direct data fetcher.
 * Runs as a background process, fetches reports and writes them to
 * /data/workspace/yd-cache/ so the OpenClaw agent can read them as files.
 *
 * Refreshes every REFRESH_INTERVAL_MS (default 1 hour).
 */

const https = require('https');
const fs = require('fs');
const path = require('path');

const TOKEN          = process.env.YANDEX_DIRECT_TOKEN;
const WORKSPACE_DIR  = process.env.OPENCLAW_WORKSPACE_DIR || '/data/workspace';
const CACHE_DIR      = path.join(WORKSPACE_DIR, 'yd-cache');
const REFRESH_MS     = parseInt(process.env.YD_REFRESH_MS || '3600000', 10); // 1 hour

const CAMPAIGN_FIELDS = [
  'CampaignId', 'CampaignName',
  'Impressions', 'Clicks', 'Ctr',
  'AvgCpc', 'Cost', 'Conversions', 'CostPerConversion', 'ConversionRate',
];

const QUERY_FIELDS = [
  'Query', 'Impressions', 'Clicks', 'Ctr', 'AvgCpc', 'Cost', 'Conversions',
];

const REPORTS = [
  {
    file: 'yesterday.tsv',
    params: {
      SelectionCriteria: {},
      FieldNames: CAMPAIGN_FIELDS,
      ReportName: `campaigns-yesterday-${Date.now()}`,
      ReportType: 'CAMPAIGN_PERFORMANCE_REPORT',
      DateRangeType: 'YESTERDAY',
      Format: 'TSV',
      IncludeVAT: 'YES',
      IncludeDiscount: 'NO',
    },
  },
  {
    file: 'last7days.tsv',
    params: {
      SelectionCriteria: {},
      FieldNames: CAMPAIGN_FIELDS,
      ReportName: `campaigns-last7days-${Date.now()}`,
      ReportType: 'CAMPAIGN_PERFORMANCE_REPORT',
      DateRangeType: 'LAST_7_DAYS',
      Format: 'TSV',
      IncludeVAT: 'YES',
      IncludeDiscount: 'NO',
    },
  },
  {
    file: 'last30days.tsv',
    params: {
      SelectionCriteria: {},
      FieldNames: CAMPAIGN_FIELDS,
      ReportName: `campaigns-last30days-${Date.now()}`,
      ReportType: 'CAMPAIGN_PERFORMANCE_REPORT',
      DateRangeType: 'LAST_30_DAYS',
      Format: 'TSV',
      IncludeVAT: 'YES',
      IncludeDiscount: 'NO',
    },
  },
  {
    file: 'thismonth.tsv',
    params: {
      SelectionCriteria: {},
      FieldNames: CAMPAIGN_FIELDS,
      ReportName: `campaigns-thismonth-${Date.now()}`,
      ReportType: 'CAMPAIGN_PERFORMANCE_REPORT',
      DateRangeType: 'THIS_MONTH',
      Format: 'TSV',
      IncludeVAT: 'YES',
      IncludeDiscount: 'NO',
    },
  },
];

function fetchReport(params) {
  return new Promise((resolve, reject) => {
    // Unique name per request to avoid Yandex caching by name
    params.ReportName = params.ReportName.replace(/-\d+$/, `-${Date.now()}`);
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

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        if (res.statusCode === 200) {
          resolve(data);
        } else if (res.statusCode === 201 || res.statusCode === 202) {
          const retry = parseInt(res.headers['retry-after'] || '30', 10);
          console.log(`[yd-proxy] Report building, retrying in ${retry}s...`);
          setTimeout(() => fetchReport(params).then(resolve).catch(reject), retry * 1000);
        } else {
          reject(new Error(`HTTP ${res.statusCode}: ${data}`));
        }
      });
    });

    req.on('error', reject);
    req.write(body);
    req.end();
  });
}

async function refreshAll() {
  if (!TOKEN) {
    console.error('[yd-proxy] YANDEX_DIRECT_TOKEN is not set — skipping fetch');
    return;
  }

  fs.mkdirSync(CACHE_DIR, { recursive: true });

  const meta = { updatedAt: new Date().toISOString(), files: {} };

  for (const report of REPORTS) {
    const filePath = path.join(CACHE_DIR, report.file);
    try {
      console.log(`[yd-proxy] Fetching ${report.file}...`);
      const tsv = await fetchReport({ ...report.params });
      fs.writeFileSync(filePath, tsv, 'utf8');
      meta.files[report.file] = { updatedAt: new Date().toISOString(), ok: true };
      console.log(`[yd-proxy] Saved ${report.file} (${tsv.length} bytes)`);
    } catch (err) {
      console.error(`[yd-proxy] Failed ${report.file}: ${err.message}`);
      meta.files[report.file] = { updatedAt: new Date().toISOString(), ok: false, error: err.message };
    }
  }

  fs.writeFileSync(path.join(CACHE_DIR, 'meta.json'), JSON.stringify(meta, null, 2), 'utf8');
  console.log(`[yd-proxy] Refresh complete at ${meta.updatedAt}`);
}

// Initial fetch on startup, then periodic refresh
refreshAll();
setInterval(refreshAll, REFRESH_MS);
