const { Server } = require('@modelcontextprotocol/sdk/server/index.js');
const { ListToolsRequestSchema, CallToolRequestSchema } = require('@modelcontextprotocol/sdk/types.js');
const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'mcp-server' });
});

// Create MCP server instance
const server = new Server(
  {
    name: 'aws-ecs-mcp-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Register tools/list handler
server.setRequestHandler(ListToolsRequestSchema, async () => {
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

// Register tools/call handler
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'get_system_info':
      return {
        content: [
          {
            type: 'text',
            text: JSON.stringify({
              platform: process.platform,
              arch: process.arch,
              nodeVersion: process.version,
              memory: process.memoryUsage(),
              uptime: process.uptime(),
              hostname: os.hostname(),
              env: {
                AWS_REGION: process.env.AWS_REGION,
                NODE_ENV: process.env.NODE_ENV,
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

// MCP endpoint for AgentCore Gateway
app.post('/mcp', async (req, res) => {
  try {
    const request = req.body;
    const response = await server.request(request, {});
    res.json(response);
  } catch (error) {
    res.status(500).json({ 
      jsonrpc: '2.0',
      error: {
        code: -32603,
        message: error.message
      },
      id: req.body.id
    });
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
