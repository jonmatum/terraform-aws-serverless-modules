const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.use(express.json());

// MCP protocol handler
app.post('/', async (req, res) => {
  try {
    const { jsonrpc = "2.0", method, params = {}, id } = req.body;

    if (method === 'initialize') {
      return res.json({
        jsonrpc,
        id,
        result: {
          protocolVersion: "2024-11-05",
          capabilities: {
            tools: {}
          },
          serverInfo: {
            name: "ecs-mcp-server",
            version: "1.0.0"
          }
        }
      });
    }

    if (method === 'tools/list') {
      return res.json({
        jsonrpc,
        id,
        result: {
          tools: [
            {
              name: "uppercase",
              description: "Convert text to uppercase",
              inputSchema: {
                type: "object",
                properties: {
                  text: {
                    type: "string",
                    description: "Text to convert"
                  }
                },
                required: ["text"]
              }
            },
            {
              name: "word_count",
              description: "Count words in text",
              inputSchema: {
                type: "object",
                properties: {
                  text: {
                    type: "string",
                    description: "Text to count words in"
                  }
                },
                required: ["text"]
              }
            },
            {
              name: "get_server_info",
              description: "Get ECS server information",
              inputSchema: {
                type: "object",
                properties: {}
              }
            }
          ]
        }
      });
    }

    if (method === 'tools/call') {
      const { name, arguments: args } = params;

      if (name === 'uppercase') {
        return res.json({
          jsonrpc,
          id,
          result: {
            content: [{
              type: "text",
              text: (args.text || "").toUpperCase()
            }]
          }
        });
      }

      if (name === 'word_count') {
        const count = (args.text || "").split(/\s+/).filter(w => w.length > 0).length;
        return res.json({
          jsonrpc,
          id,
          result: {
            content: [{
              type: "text",
              text: `Word count: ${count}`
            }]
          }
        });
      }

      if (name === 'get_server_info') {
        return res.json({
          jsonrpc,
          id,
          result: {
            content: [{
              type: "text",
              text: JSON.stringify({
                platform: "ECS Fargate",
                environment: process.env.ENVIRONMENT || "dev",
                nodeVersion: process.version
              }, null, 2)
            }]
          }
        });
      }

      return res.json({
        jsonrpc,
        id,
        error: {
          code: -32601,
          message: `Unknown tool: ${name}`
        }
      });
    }

    return res.json({
      jsonrpc,
      id,
      error: {
        code: -32601,
        message: `Method not found: ${method}`
      }
    });

  } catch (error) {
    res.status(500).json({
      jsonrpc: "2.0",
      id: req.body.id,
      error: {
        code: -32603,
        message: "Internal error",
        data: error.message
      }
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(`MCP server listening on port ${port}`);
});
