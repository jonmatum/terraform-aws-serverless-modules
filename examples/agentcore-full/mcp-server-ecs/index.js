import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import express from 'express';
import { createServer } from 'http';

const PORT = process.env.PORT || 3000;

// MCP Server
const mcpServer = new Server(
  {
    name: 'ecs-mcp-server',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Register tools
mcpServer.setRequestHandler('tools/list', async () => ({
  tools: [
    {
      name: 'echo',
      description: 'Echo back a message',
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
    {
      name: 'get_system_info',
      description: 'Get ECS container system information',
      inputSchema: {
        type: 'object',
        properties: {},
      },
    },
    {
      name: 'calculate',
      description: 'Perform basic calculations',
      inputSchema: {
        type: 'object',
        properties: {
          operation: {
            type: 'string',
            enum: ['add', 'subtract', 'multiply', 'divide'],
            description: 'Mathematical operation',
          },
          a: { type: 'number', description: 'First number' },
          b: { type: 'number', description: 'Second number' },
        },
        required: ['operation', 'a', 'b'],
      },
    },
  ],
}));

mcpServer.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'echo':
      return {
        content: [
          {
            type: 'text',
            text: `Echo: ${args.message}`,
          },
        ],
      };

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
              env: process.env.NODE_ENV,
            }, null, 2),
          },
        ],
      };

    case 'calculate':
      let result;
      switch (args.operation) {
        case 'add': result = args.a + args.b; break;
        case 'subtract': result = args.a - args.b; break;
        case 'multiply': result = args.a * args.b; break;
        case 'divide': result = args.b !== 0 ? args.a / args.b : 'Error: Division by zero'; break;
      }
      return {
        content: [
          {
            type: 'text',
            text: `Result: ${result}`,
          },
        ],
      };

    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

// HTTP Server for health checks and MCP over HTTP
const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.post('/mcp', async (req, res) => {
  try {
    const response = await mcpServer.handleRequest(req.body);
    res.json(response);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

const httpServer = createServer(app);

httpServer.listen(PORT, () => {
  console.log(`MCP Server listening on port ${PORT}`);
});

// Handle shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  httpServer.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
