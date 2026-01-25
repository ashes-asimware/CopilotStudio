# Agents

This directory contains Copilot Studio generated agents.

## Structure

Each agent should be organized in its own subdirectory with the following recommended structure:

```
agents/
├── agent-name/
│   ├── README.md          # Agent documentation
│   ├── manifest.json      # Agent manifest/configuration
│   ├── skills/           # Agent skills and capabilities
│   ├── prompts/          # Prompt templates
│   └── docs/             # Additional documentation
```

## Adding a New Agent

1. Create a new directory with a descriptive name for your agent
2. Include a README.md with:
   - Agent description
   - Capabilities and skills
   - Setup instructions
   - Usage examples
3. Add a manifest.json file with agent configuration
4. Organize skills, prompts, and other resources in appropriate subdirectories
5. Document any dependencies or requirements

## Guidelines

- Use clear, descriptive names for agent directories
- Keep each agent self-contained
- Include comprehensive documentation
- Follow consistent naming conventions
- Document all agent capabilities and limitations
