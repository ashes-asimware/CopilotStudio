# Contributing to Copilot Studio Artifacts

Thank you for contributing to the Copilot Studio Artifacts repository! This document provides guidelines for adding and maintaining artifacts in this repository.

## Table of Contents

- [Getting Started](#getting-started)
- [Directory Structure](#directory-structure)
- [Adding Applications](#adding-applications)
- [Adding Agents](#adding-agents)
- [Code Standards](#code-standards)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)

## Getting Started

Before contributing:

1. Familiarize yourself with the repository structure
2. Review existing apps and agents for examples
3. Ensure you have necessary permissions
4. Review security and privacy guidelines

## Directory Structure

### Apps Directory (`/apps`)

Each application should follow this structure:

```
apps/
└── your-app-name/
    ├── README.md          # Required: Application documentation
    ├── src/              # Source code
    ├── config/           # Configuration files
    ├── assets/           # Images, styles, etc.
    ├── tests/            # Test files
    └── docs/             # Additional documentation
```

### Agents Directory (`/agents`)

Each agent should follow this structure:

```
agents/
└── your-agent-name/
    ├── README.md          # Required: Agent documentation
    ├── manifest.json      # Agent configuration
    ├── skills/           # Agent capabilities
    ├── prompts/          # Prompt templates
    └── docs/             # Additional documentation
```

### Shared Directory (`/shared`)

Only add truly reusable components:

```
shared/
├── utilities/            # Common functions
├── templates/            # Reusable templates
└── configs/              # Shared configurations
```

## Adding Applications

1. **Create Directory**: Create a new directory under `/apps` with a descriptive name
2. **Add README**: Include a comprehensive README.md with:
   - Application name and description
   - Purpose and use cases
   - Installation/setup instructions
   - Usage examples
   - Dependencies and requirements
   - Configuration details
   - Troubleshooting tips
3. **Organize Code**: Structure your code logically
4. **Add Tests**: Include tests where applicable
5. **Document Changes**: Update the main README if needed

## Adding Agents

1. **Create Directory**: Create a new directory under `/agents` with a descriptive name
2. **Add README**: Include a comprehensive README.md with:
   - Agent name and description
   - Capabilities and skills
   - Setup instructions
   - Usage examples and scenarios
   - Limitations and known issues
3. **Add Manifest**: Create a manifest.json with agent configuration
4. **Organize Skills**: Place skills in the `skills/` subdirectory
5. **Add Prompts**: Store prompt templates in `prompts/`

## Code Standards

- **Naming Conventions**: Use lowercase with hyphens (kebab-case) for directories
- **Comments**: Include comments for complex logic
- **Error Handling**: Implement proper error handling
- **Dependencies**: Document all dependencies clearly
- **Secrets**: Never commit secrets or sensitive data

## Documentation

### Required Documentation

Every artifact must include:

1. **README.md**: Primary documentation file
2. **Setup Instructions**: Clear steps to get started
3. **Usage Examples**: Practical examples of usage
4. **Dependencies**: List all required dependencies

### Optional Documentation

Consider adding:

- Architecture diagrams
- API documentation
- Troubleshooting guides
- FAQ section
- Changelog

## Pull Request Process

1. **Create Branch**: Use descriptive branch names (e.g., `add-weather-app`, `update-chat-agent`)
2. **Make Changes**: Follow the guidelines above
3. **Test**: Verify your artifact works as expected
4. **Commit**: Write clear, descriptive commit messages
5. **Submit PR**: Include a description of your changes
6. **Review**: Address any feedback from reviewers

### Commit Message Format

Use clear, descriptive commit messages:

```
Add: New weather forecasting app
Update: Chat agent with improved context handling
Fix: Configuration error in customer service agent
```

## Security Considerations

- Never commit API keys, passwords, or credentials
- Use environment variables for sensitive configuration
- Review .gitignore to ensure exclusions are correct
- Sanitize any example data
- Follow your organization's security policies

## Questions?

If you have questions about contributing:

1. Review existing artifacts for examples
2. Check the documentation in each directory
3. Contact your repository administrator
4. Refer to your organization's Copilot Studio documentation

Thank you for contributing!
