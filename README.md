# Git Bot 🤖

A comprehensive, user-friendly Git automation shell script that simplifies GitHub operations with natural language commands and intelligent automation.

![Git Bot](https://img.shields.io/badge/Git-Bot-blue?style=for-the-badge&logo=git)
![Bash](https://img.shields.io/badge/Bash-Script-green?style=for-the-badge&logo=gnu-bash)

## ✨ Features

### 🎯 Core Git Operations
- **Smart Commit & Push**: Automatically stages all changes and generates commit messages
- **Branch Management**: Create, switch, list, merge, and delete branches safely
- **Stash Operations**: Easily stash, apply, and manage your changes
- **Remote Management**: Add, remove, and manage remote repositories
- **Change Detection**: Comprehensive change scanning with detailed breakdowns

### 🧭 Navigation & Discovery
- **Repository Browser**: Find and navigate to Git repositories in any directory
- **Directory Navigation**: Manual path entry and parent directory navigation
- **Auto-detection**: Automatic Git repository detection when navigating

### 📁 Repository Management
- **Initialize New Repos**: Create new Git repositories with optional `.gitignore` setup
- **Clone & Fork**: Clone repositories and fork directly from GitHub
- **GitIgnore Management**: Smart `.gitignore` creation with pre-defined templates

### 🔐 Security & Integration
- **GitHub Authentication**: Secure token-based authentication
- **Auto-login**: Persistent authentication across sessions
- **API Integration**: Direct GitHub API access for forking operations

### 🎨 User Experience
- **Color-coded UI**: Intuitive color scheme for different message types
- **Natural Language**: Human-friendly commands and prompts
- **Interactive Menus**: Easy-to-navigate menu system
- **Comprehensive Logging**: Detailed operation logging

## 🚀 Installation

### Prerequisites
- Git installed on your system
- Bash shell
- GitHub Personal Access Token (for full functionality)

### Quick Install
```bash
# Download the script
curl -o git-bot.sh https://raw.githubusercontent.com/yourusername/git-bot/main/git-bot.sh

# Make it executable
chmod +x git-bot.sh

# Run it
./git-bot.sh
```

### Global Installation (Recommended)
```bash
# Copy to system path
sudo cp git-bot.sh /usr/local/bin/gitbot

# Make executable
sudo chmod +x /usr/local/bin/gitbot

# Run from anywhere
gitbot
```

## 🔧 Setup

### GitHub Authentication
1. Run `gitbot` for the first time
2. You'll be prompted for GitHub authentication
3. Get your Personal Access Token from: https://github.com/settings/tokens
4. Required token permissions: `repo`, `read:org`, `user`

### Configuration
The bot automatically creates configuration in:
```
~/.git-bot/
├── config          # GitHub credentials
└── git-bot.log     # Operation logs
```

## 📖 Usage

### Starting the Bot
```bash
gitbot
```

### Main Menu Options

| Option | Icon | Description |
|--------|------|-------------|
| 1 | 📊 | Check changes in current repository |
| 2 | 💾 | Smart commit & push (recommended) |
| 3 | 🌿 | Branch operations |
| 4 | 💾 | Stash operations |
| 5 | 🌐 | Remote operations |
| 6 | 🍴 | Fork repository |
| 7 | 📥 | Clone repository |
| 8 | 🔄 | Pull latest changes |
| 9 | 🚀 | Push changes |
| 10 | 📜 | View commit history |
| 11 | 🆕 | Initialize new repository |
| 12 | 📁 | Manage .gitignore |
| 13 | 📂 | Navigate to repository |
| 14 | 🔐 | Re-authenticate GitHub |
| 15 | 🚪 | Exit |

## 🛠️ Key Features Deep Dive

### Smart Commit & Push 🤖
The bot automatically:
- Scans for all changes (untracked, modified, deleted)
- Stages everything with `git add -A`
- Generates intelligent commit messages
- Shows exactly what will be committed
- Offers to push to remote automatically

### GitIgnore Management 📄
Pre-defined templates for:
- **Node.js/JavaScript**: `node_modules/`, `.npm`, etc.
- **Python**: `__pycache__/`, `venv/`, etc.
- **Java**: `*.class`, `build/`, etc.
- **React**: `.next/`, `dist/`, etc.
- **Vue.js**: `node_modules/`, `dist/`, etc.
- **Angular**: `node_modules/`, `dist/`, etc.
- **PHP**: `vendor/`, `.env`, etc.
- **Go**: `bin/`, `vendor/`, etc.
- **Rust**: `target/`, `Cargo.lock`, etc.
- **Docker**: `.docker/`, `.dockerignore`, etc.
- **General**: `.DS_Store`, logs, temp files, etc.

### Repository Navigation 🧭
- **Browse**: Find all Git repos in current directory
- **Search**: Manually enter directory paths
- **Parent**: Navigate to parent directory
- **Auto-detect**: Automatic Git repo detection

## 🎯 Common Workflows

### Daily Development
```bash
gitbot
# Choose 1 to check changes
# Choose 2 for smart commit & push
```

### Starting a New Project
```bash
gitbot
# Choose 11 to initialize new repo
# Set up .gitignore with appropriate templates
# Make initial commit
```

### Working with Multiple Repos
```bash
gitbot
# Choose 13 to navigate between repositories
# Browse or enter specific paths
```

### Fork and Contribute
```bash
gitbot
# Choose 6 to fork a repository
# Choose 7 to clone your fork
# Choose 12 to set up .gitignore if needed
```

## 🔧 Advanced Usage

### Command Line Arguments
```bash
# Run with specific option
gitbot --commit "My commit message"

# Skip authentication (for CI/CD)
gitbot --no-auth

# Set specific directory
gitbot --dir /path/to/repo
```

### Environment Variables
```bash
export GITBOT_AUTO_PUSH=true    # Auto-push after commit
export GITBOT_EDITOR=vim        # Set preferred editor
export GITBOT_LOG_LEVEL=debug   # Set log level
```

## 🐛 Troubleshooting

### Common Issues

**Authentication Failed**
- Verify your GitHub Personal Access Token has correct permissions
- Check token expiration date
- Re-authenticate using option 14

**Changes Not Detected**
- The bot uses `git add -A` to stage all changes
- Ensure you're in the correct Git repository
- Use option 1 to verify change detection

**Push/Pull Fails**
- Verify remote repository URL
- Check network connectivity
- Ensure you have proper permissions

### Logs and Debugging
View operation logs:
```bash
tail -f ~/.git-bot/git-bot.log
```

### Development Setup
```bash
git clone https://github.com/yourusername/git-bot.git
cd git-bot
./git-bot.sh
```

### Reporting Issues
- If you believe that there are changes required to be made, please reach out to me via mail: tausifmushtaque@gmail.com

---

**Happy coding!** 🎉 Remember, Git Bot is here to make your Git experience smoother and more enjoyable. If you encounter any issues or have suggestions, don't hesitate to reach out!
