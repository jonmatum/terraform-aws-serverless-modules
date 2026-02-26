const express = require('express');
const app = express();
const PORT = 3000;

app.use(express.json());

app.get('/api/mcp', (req, res) => {
  res.json({ service: 'mcp', message: 'Hello from Node MCP on ECS!' });
});

app.get('/api/mcp/', (req, res) => {
  res.json({ service: 'mcp', message: 'Hello from Node MCP on ECS!' });
});

app.get('/api/mcp/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`MCP service listening on port ${PORT}`);
});
