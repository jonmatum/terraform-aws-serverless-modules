const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const express = require('express');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'mcp-server' });
});

// MCP server instance
const mcpServer = new Server(
  {
    name: 'aws-ecs-mcp-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
      resources: {},
      prompts: {},
    },
  }
);

// Register MCP tools
mcpServer.setRequestHandler('tools/list', async () => {
  return {
    tools: [
      {
        name: 'get_system_info',
        description: 'Get system information from the ECS container',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'echo',
        description: 'Echo back the input message',
        inputSchema: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              description: 'Message to echo',
            },
          },
          required: ['message'],
        },
      },
    ],
  };
});

// Handle tool calls
mcpServer.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'get_system_info':
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              platform: process.platform,
              nodeVersion: process.version,
              memory: process.memoryUsage(),
              uptime: process.uptime(),
              env: {
                AWS_REGION: process.env.AWS_REGION,
                ECS_CONTAINER_METADATA_URI: process.env.ECS_CONTAINER_METADATA_URI ? 'set' : 'not set',
              },
            }, null, 2),
          },
        ],
      };

    case 'echo':
      return {
        content: [
          {
            type: 'text',
            text: args.message,
          },
        ],
      };

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

// HTTP endpoint to interact with MCP server
app.post('/mcp/tools/list', async (req, res) => {
  try {
    const result = await mcpServer.request({ method: 'tools/list' }, {});
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post('/mcp/tools/call', async (req, res) => {
  try {
    const { name, arguments: args } = req.body;
    const result = await mcpServer.request(
      { method: 'tools/call', params: { name, arguments: args } },
      {}
    );
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Start HTTP server
app.listen(PORT, () => {
  console.log(`MCP Server listening on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`MCP endpoints: http://localhost:${PORT}/mcp/*`);
});

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});
