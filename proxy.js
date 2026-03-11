'use strict';

/**
 * Minimal HTTP + WebSocket reverse proxy.
 * Listens on 0.0.0.0:$PORT (Railway-exposed) and forwards everything to
 * the OpenClaw gateway on 127.0.0.1:GATEWAY_INTERNAL_PORT.
 *
 * This lets the gateway bind to loopback only, which prevents the
 * pairing-required error on ws://LAN_IP:18789 internal tool calls.
 */

const http = require('http');
const net  = require('net');

const LISTEN_PORT = parseInt(process.env.PORT || '8080', 10);
const GW_PORT     = parseInt(process.env.GATEWAY_INTERNAL_PORT || '8081', 10);
const GW_HOST     = '127.0.0.1';

const server = http.createServer((req, res) => {
  const proxyReq = http.request(
    {
      host: GW_HOST,
      port: GW_PORT,
      path: req.url,
      method: req.method,
      headers: { ...req.headers, host: `${GW_HOST}:${GW_PORT}` },
    },
    (proxyRes) => {
      res.writeHead(proxyRes.statusCode, proxyRes.headers);
      proxyRes.pipe(res);
    },
  );

  proxyReq.on('error', (err) => {
    console.error('[proxy] HTTP error:', err.message);
    if (!res.headersSent) {
      res.writeHead(502);
      res.end('Bad Gateway');
    }
  });

  req.pipe(proxyReq);
});

// Tunnel WebSocket upgrades (Control UI, etc.)
server.on('upgrade', (req, clientSocket, head) => {
  const serverSocket = net.connect(GW_PORT, GW_HOST, () => {
    const reqLine = `${req.method} ${req.url} HTTP/1.1\r\n`;
    const headers = Object.entries(req.headers)
      .map(([k, v]) => `${k}: ${v}\r\n`)
      .join('');
    serverSocket.write(`${reqLine}${headers}\r\n`);
    if (head && head.length) serverSocket.write(head);
    serverSocket.pipe(clientSocket);
    clientSocket.pipe(serverSocket);
  });

  serverSocket.on('error', (err) => {
    console.error('[proxy] WS error:', err.message);
    clientSocket.destroy();
  });
  clientSocket.on('error', () => serverSocket.destroy());
});

server.listen(LISTEN_PORT, '0.0.0.0', () => {
  console.log(`[proxy] 0.0.0.0:${LISTEN_PORT} → ${GW_HOST}:${GW_PORT}`);
});
