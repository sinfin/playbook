# Playbook - Cursor IDE Rules Sync

This document explains how to synchronize Cursor IDE rules from the repository to your local project.

## Syncing Cursor Rules

The project includes a script that allows you to easily sync Cursor IDE rules and configuration from the git repository. This ensures that you're using the most up-to-date Cursor IDE settings for the project.

### Prerequisites

- Ruby installed on your system
- Git access to the repository

### Running the Sync Script

To sync the Cursor IDE rules, run the following command from the project root:

```bash
./scripts/sync_rules.sh
```

By default, this will sync rules from the `sinfin/playbook` repository (`@https://github.com/sinfin/playbook`) using the `main` branch.

### Command Line Options

The sync script supports the following options:

- `-u, --url URL`: Specify a different GitHub repository URL
  - Example: `./scripts/sync_rules.sh -u @https://github.com/sinfin/playbook`
- `-b, --branch BRANCH`: Specify a different branch (default: main)
  - Example: `./scripts/sync_rules.sh -b develop`
- `-h, --help`: Display help information

### What Gets Synced

Running the script will:

1. Download all files from the `.cursor/rules` directory in the repository
2. Download the `.cursor/config.json` file
3. Create or update these files in your local project
4. Ask for confirmation before overwriting existing files

### Example Usage

Sync rules from the default repository and branch:
```bash
./scripts/sync_rules.sh
```

Sync rules from a specific repository:
```bash
./scripts/sync_rules.sh -u @https://github.com/sinfin/playbook
```

Sync rules from a specific branch:
```bash
./scripts/sync_rules.sh -b develop
```

Sync rules from a specific repository and branch:
```bash
./scripts/sync_rules.sh -u @https://github.com/sinfin/playbook -b develop
``` 