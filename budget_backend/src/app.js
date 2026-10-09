const express = require('express');
const cors = require('cors');
const routes = require('./routes');
const errorHandler = require('./middleware/errorHandler');
const openapi = require('./docs/openapi');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ status: 'ok', message: 'Budget API is running' });
});

// API docs: UI loaded from a CDN because swagger-ui's bundled assets 404 on Vercel serverless.
app.get('/api/docs.json', (req, res) => res.json(openapi));
app.get('/api/docs', (req, res) => {
  res.type('html').send(`<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Budgie API Docs</title>
<link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css"></head>
<body><div id="ui"></div>
<script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
<script>SwaggerUIBundle({ url: '/api/docs.json', dom_id: '#ui', persistAuthorization: true });</script>
</body></html>`);
});

app.use('/api', routes);
app.use(errorHandler);

module.exports = app;
