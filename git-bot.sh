#!/bin/bash
# git-bot.sh

# Colors for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
CONFIG_DIR="$HOME/.git-bot"
CONFIG_FILE="$CONFIG_DIR/config"
LOG_FILE="$CONFIG_DIR/git-bot.log"

# Common ignore patterns for different languages/frameworks
declare -A IGNORE_PATTERNS=(
    ["node"]="node_modules/\n.npm\n.npmrc\npackage-lock.json\nyarn.lock\n.pnpm-store/\n.npminstall\n.next/\n.out/\n.nuxt/\n.cache/\n.nyc_output/\ncoverage/\n*.tgz\n*.tar.gz"
    ["python"]="__pycache__/\n*.py[cod]\n*$py.class\n*.so\n.Python\nenv/\nvenv/\n.venv/\nENV/\n.env\n.venv\npip-log.txt\npip-delete-this-directory.txt\n.tox/\n.coverage\n.coverage.*\n.pytest_cache/\n*.egg-info/\n*.egg\n.coverage\n.hypothesis/"
    ["java"]="*.class\n*.jar\n*.war\n*.ear\nhs_err_pid*\nreplay_pid*\n.gradle/\nbuild/\nout/\n.idea/\n*.iml\n*.ipr\n*.iws\n.DS_Store\nThumbs.db"
    ["react"]="node_modules/\n.build/\n.cache/\n.next/\n.out/\n.nuxt/\ndist/\nbuild/\n.nyc_output/\ncoverage/\n*.tgz\n*.tar.gz\n.env.local\n.env.development.local\n.env.test.local\n.env.production.local\n.npm\n.npmrc\n.eslintcache"
    ["vue"]="node_modules/\ndist/\ndist-ssr/\n*.local\n.cache/\n.DS_Store\n.env\n.env.*\n.elasticbeanstalk/\n.nyc_output/\ncoverage/\n.npm\n.npmrc\n.nuxt/"
    ["angular"]="node_modules/\ndist/\n.cache/\n.angular/\n.aot/\n.ng/\n.ng_pkg\n*.tsbuildinfo\n.npm\n.npmrc\n.yarn-integrity"
    ["php"]="vendor/\ncomposer.lock\n.env\n.phpunit.result.cache\n.phan/\n.php_cs.cache\nstorage/framework/views/*\nstorage/logs/*\nstorage/framework/cache/*\n.npm\n.npmrc"
    ["go"]="bin/\nvendor/\n*.exe\n*.exe~\n*.dll\n*.so\n*.dylib\ngo.work\n.env\n.air.conf"
    ["rust"]="target/\n**/*.rs.bk\nCargo.lock\n.env\n.docker/\n.idea/"
    ["docker"]=".docker/\n.dockerignore\n.env\n.dockerenv"
    ["general"]=".DS_Store\n.DS_Store?\n._*\n.Spotlight-V100\n.Trashes\nehthumbs.db\nThumbs.db\n*.log\n*.tmp\n*.temp\n.cache/\n.idea/\n.vscode/\n*.swp\n*.swo\n*~\n#*#\n.#*"
)

# Initialize configuration
init_config() {
    mkdir -p "$CONFIG_DIR"
    touch "$CONFIG_FILE" "$LOG_FILE"
}

# Logging function
log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Print colored output
print_color() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Check if current directory is a git repository
is_git_repo() {
    git rev-parse --git-dir > /dev/null 2>&1
}

# Find all git repositories in a directory
find_git_repos() {
    local search_dir="${1:-.}"
    local repos=()
    
    print_color $CYAN "🔍 Searching for Git repositories in: $search_dir"
    
    while IFS= read -r -d '' repo; do
        repos+=("$repo")
    done < <(find "$search_dir" -name ".git" -type d 2>/dev/null | sed 's/\/.git$//' | tr '\n' '\0')
    
    if [[ ${#repos[@]} -eq 0 ]]; then
        print_color $YELLOW "📭 No Git repositories found in: $search_dir"
        return 1
    fi
    
    print_color $GREEN "📁 Found ${#repos[@]} Git repositories:"
    for i in "${!repos[@]}"; do
        local repo_name=$(basename "${repos[$i]}")
        local repo_path=$(dirname "${repos[$i]}")
        printf "%2d) %s - %s\n" $((i+1)) "$repo_name" "${repos[$i]}"
    done
    
    return 0
}

# Navigate to git repository
navigate_to_repo() {
    print_color $CYAN "📁 Repository Navigation"
    echo "1) Browse current directory for Git repos"
    echo "2) Enter specific directory path"
    echo "3) Go to parent directory"
    echo "4) Show current directory"
    read -p "Choose option (1-4): " nav_choice

    case $nav_choice in
        1)
            if find_git_repos "."; then
                read -p "Enter repository number to navigate: " repo_num
                local repos=($(find "." -name ".git" -type d 2>/dev/null | sed 's/\/.git$//'))
                if [[ $repo_num -gt 0 && $repo_num -le ${#repos[@]} ]]; then
                    cd "${repos[$((repo_num-1))]}"
                    print_color $GREEN "✅ Navigated to: $(pwd)"
                else
                    print_color $RED "❌ Invalid repository number"
                fi
            fi
            ;;
        2)
            read -p "Enter directory path: " dir_path
            if [[ -d "$dir_path" ]]; then
                cd "$dir_path"
                print_color $GREEN "✅ Navigated to: $(pwd)"
                
                if is_git_repo; then
                    print_color $GREEN "🎉 Found Git repository!"
                else
                    print_color $YELLOW "📭 Current directory is not a Git repository"
                    read -p "Search for Git repositories here? (y/n): " search_here
                    if [[ $search_here == "y" ]]; then
                        find_git_repos "."
                    fi
                fi
            else
                print_color $RED "❌ Directory not found: $dir_path"
            fi
            ;;
        3)
            cd ..
            print_color $GREEN "✅ Moved to parent directory: $(pwd)"
            ;;
        4)
            print_color $CYAN "📂 Current directory: $(pwd)"
            ;;
        *)
            print_color $RED "❌ Invalid choice"
            ;;
    esac
}

# Check for existing .gitignore file
has_gitignore() {
    [[ -f ".gitignore" ]]
}

# Create or update .gitignore file
setup_gitignore() {
    print_color $CYAN "📁 .gitignore Setup"
    echo "This will help you create or update your .gitignore file"
    
    if has_gitignore; then
        print_color $YELLOW "⚠️  Existing .gitignore file found"
        echo "Current content:"
        echo "=================="
        cat .gitignore
        echo "=================="
        read -p "Do you want to (a)dd to existing or (r)eplace it? (a/r/cancel): " choice
        
        case $choice in
            a|add)
                print_color $GREEN "✅ Will add to existing .gitignore"
                local append_mode=true
                ;;
            r|replace)
                print_color $YELLOW "🔄 Replacing existing .gitignore"
                > .gitignore
                local append_mode=false
                ;;
            *)
                print_color $BLUE "❌ .gitignore setup cancelled"
                return 1
                ;;
        esac
    else
        local append_mode=false
        print_color $GREEN "📝 Creating new .gitignore file"
    fi
    
    echo ""
    print_color $BLUE "🎯 Choose patterns to add:"
    echo "1)  Node.js/JavaScript"
    echo "2)  Python"
    echo "3)  Java"
    echo "4)  React"
    echo "5)  Vue.js"
    echo "6)  Angular"
    echo "7)  PHP"
    echo "8)  Go"
    echo "9)  Rust"
    echo "10) Docker"
    echo "11) General (OS files, logs, etc.)"
    echo "12) Custom patterns"
    echo "13) Skip pattern selection"
    echo ""
    
    read -p "Enter choices (comma-separated, e.g., 1,3,11): " pattern_choices
    
    # Process pattern choices
    IFS=',' read -ra choices <<< "$pattern_choices"
    
    local patterns=""
    for choice in "${choices[@]}"; do
        case $choice in
            1) patterns+="${IGNORE_PATTERNS[node]}\n" ;;
            2) patterns+="${IGNORE_PATTERNS[python]}\n" ;;
            3) patterns+="${IGNORE_PATTERNS[java]}\n" ;;
            4) patterns+="${IGNORE_PATTERNS[react]}\n" ;;
            5) patterns+="${IGNORE_PATTERNS[vue]}\n" ;;
            6) patterns+="${IGNORE_PATTERNS[angular]}\n" ;;
            7) patterns+="${IGNORE_PATTERNS[php]}\n" ;;
            8) patterns+="${IGNORE_PATTERNS[go]}\n" ;;
            9) patterns+="${IGNORE_PATTERNS[rust]}\n" ;;
            10) patterns+="${IGNORE_PATTERNS[docker]}\n" ;;
            11) patterns+="${IGNORE_PATTERNS[general]}\n" ;;
            12) 
                print_color $CYAN "📝 Enter custom patterns (one per line, press Ctrl+D when done):"
                local custom_patterns=$(cat)
                patterns+="$custom_patterns\n"
                ;;
            13) 
                print_color $BLUE "⏭️  Skipping pattern selection"
                ;;
            *) 
                print_color $RED "❌ Invalid choice: $choice"
                ;;
        esac
    done
    
    # Add custom files/folders
    print_color $CYAN "📂 Add specific files/folders to ignore:"
    read -p "Enter files/folders (space-separated, e.g., .env temp/ logs/*.log): " custom_items
    
    if [[ -n "$custom_items" ]]; then
        for item in $custom_items; do
            patterns+="$item\n"
        done
    fi
    
    # Write to .gitignore
    if [[ -n "$patterns" ]]; then
        if [[ "$append_mode" == "true" ]]; then
            echo -e "\n# Added by Git Bot - $(date)" >> .gitignore
            echo -e "$patterns" >> .gitignore
        else
            echo -e "# Generated by Git Bot - $(date)" > .gitignore
            echo -e "$patterns" >> .gitignore
        fi
        
        print_color $GREEN "✅ .gitignore file updated successfully!"
        echo "Contents:"
        echo "=================="
        cat .gitignore
        echo "=================="
    else
        print_color $YELLOW "⚠️  No patterns selected, .gitignore unchanged"
    fi
    
    # Ask if user wants to add .gitignore to git
    if is_git_repo && [[ -f ".gitignore" ]]; then
        read -p "Add .gitignore to git staging? (y/n): " stage_choice
        if [[ $stage_choice == "y" ]]; then
            git add .gitignore
            print_color $GREEN "✅ .gitignore added to git staging"
        fi
    fi
}

# Initialize new git repository with .gitignore option
init_new_repo() {
    print_color $CYAN "🆕 Initialize New Git Repository"
    
    if is_git_repo; then
        print_color $RED "❌ This directory is already a Git repository"
        return 1
    fi
    
    read -p "Enter repository name (optional): " repo_name
    if [[ -n "$repo_name" ]]; then
        mkdir -p "$repo_name"
        cd "$repo_name"
    fi
    
    git init
    print_color $GREEN "✅ Git repository initialized"
    
    read -p "Do you want to create a .gitignore file? (y/n): " create_gitignore
    if [[ $create_gitignore == "y" ]]; then
        setup_gitignore
    fi
    
    # Initial commit
    if [[ -f ".gitignore" ]]; then
        git add .
        git commit -m "Initial commit with .gitignore"
    else
        git add .
        git commit -m "Initial commit"
    fi
    
    print_color $GREEN "✅ Initial commit created"
    
    if [[ -n "$repo_name" ]]; then
        print_color $GREEN "📁 Repository created in: $(pwd)"
    fi
}

# Check for changes in repository - FIXED VERSION
check_changes() {
    if ! is_git_repo; then
        print_color $RED "❌ Not a Git repository"
        return 1
    fi

    local changes=0
    local status_output=$(git status --porcelain)
    
    if [[ -n "$status_output" ]]; then
        print_color $YELLOW "📋 Changes detected:"
        git status --short
        changes=1
        
        # Show detailed change information
        echo ""
        print_color $CYAN "📊 Detailed change summary:"
        local untracked=$(git status --porcelain | grep -c '^??')
        local modified=$(git status --porcelain | grep -c '^ M')
        local added=$(git status --porcelain | grep -c '^A ')
        local deleted=$(git status --porcelain | grep -c '^ D')
        
        [[ $untracked -gt 0 ]] && echo "❓ Untracked files: $untracked"
        [[ $modified -gt 0 ]] && echo "📝 Modified files: $modified"
        [[ $added -gt 0 ]] && echo "✅ Added files: $added"
        [[ $deleted -gt 0 ]] && echo "🗑️  Deleted files: $deleted"
    else
        print_color $GREEN "✅ No changes detected"
        changes=0
    fi
    
    # Check branch status
    local current_branch=$(git branch --show-current)
    local remote_branch=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)" 2>/dev/null)
    
    if [[ -n "$remote_branch" ]]; then
        local ahead=$(git rev-list --count "$remote_branch"..HEAD 2>/dev/null || echo "0")
        local behind=$(git rev-list --count HEAD.."$remote_branch" 2>/dev/null || echo "0")
        
        if [[ $ahead -gt 0 ]] || [[ $behind -gt 0 ]]; then
            print_color $CYAN "📊 Branch '$current_branch' is ahead by $ahead, behind by $behind compared to '$remote_branch'"
            changes=1
        fi
    fi
    
    return $changes
}

# FIXED: Smart commit that properly adds ALL changes
smart_commit() {
    if ! is_git_repo; then
        print_color $RED "❌ Not a Git repository"
        return 1
    fi

    # Show changes first
    print_color $YELLOW "📋 Current changes:"
    git status --short
    
    # Count different types of changes
    local untracked_count=$(git ls-files --others --exclude-standard | wc -l)
    local modified_count=$(git diff --name-only | wc -l)
    local staged_count=$(git diff --cached --name-only | wc -l)
    
    echo ""
    print_color $CYAN "📊 Change summary:"
    echo "❓ Untracked files: $untracked_count"
    echo "📝 Modified files: $modified_count"
    echo "✅ Staged files: $staged_count"
    
    if [[ $untracked_count -eq 0 && $modified_count -eq 0 && $staged_count -eq 0 ]]; then
        print_color $YELLOW "⚠️  No changes to commit"
        return 0
    fi
    
    # Add all changes (including untracked files)
    print_color $BLUE "📦 Staging all changes..."
    git add -A
    local after_stage_count=$(git diff --cached --name-only | wc -l)
    print_color $GREEN "✅ Staged $after_stage_count files for commit"
    
    # Show what will be committed
    echo ""
    print_color $CYAN "📝 Files to be committed:"
    git diff --cached --name-only
    
    # Get commit message
    echo ""
    read -p "💬 Commit message (or press enter for auto-generated): " commit_msg
    
    if [[ -z "$commit_msg" ]]; then
        # Auto-generate commit message based on changes
        if [[ $untracked_count -gt 0 ]]; then
            local first_file=$(git diff --cached --name-only | head -1)
            commit_msg="Add $first_file"
            if [[ $untracked_count -gt 1 ]]; then
                commit_msg="Add $first_file and $((untracked_count-1)) more files"
            fi
        elif [[ $modified_count -gt 0 ]]; then
            local first_file=$(git diff --cached --name-only | head -1)
            commit_msg="Update $first_file"
            if [[ $modified_count -gt 1 ]]; then
                commit_msg="Update $first_file and $((modified_count-1)) more files"
            fi
        else
            commit_msg="Update files"
        fi
        print_color $CYAN "🤖 Auto-generated message: $commit_msg"
    fi
    
    # Commit changes
    if git commit -m "$commit_msg"; then
        print_color $GREEN "✅ Successfully committed: $commit_msg"
        
        # Ask about pushing
        local remote_branch=$(git for-each-ref --format='%(upstream:short)' "$(git symbolic-ref -q HEAD)" 2>/dev/null)
        if [[ -n "$remote_branch" ]]; then
            read -p "🚀 Push to remote '$remote_branch'? (y/n): " push_choice
            if [[ $push_choice == "y" ]]; then
                if git push; then
                    print_color $GREEN "✅ Changes pushed to remote successfully!"
                else
                    print_color $RED "❌ Failed to push changes"
                fi
            fi
        else
            print_color $YELLOW "ℹ️  No remote branch set. Use remote operations to add a remote."
        fi
    else
        print_color $RED "❌ Commit failed"
    fi
}

# GitHub authentication
authenticate_github() {
    if [[ -f "$CONFIG_FILE" ]] && grep -q "GITHUB_TOKEN" "$CONFIG_FILE"; then
        source "$CONFIG_FILE"
        if [[ -n "$GITHUB_TOKEN" ]]; then
            print_color $GREEN "✅ Already authenticated with GitHub"
            return 0
        fi
    fi

    print_color $CYAN "🔐 GitHub Authentication Required"
    echo "You need a Personal Access Token with repo permissions"
    echo "Get one from: https://github.com/settings/tokens"
    echo ""
    
    read -p "Enter your GitHub username: " github_username
    read -s -p "Enter your GitHub Personal Access Token: " github_token
    echo ""
    
    # Test authentication
    response=$(curl -s -H "Authorization: token $github_token" https://api.github.com/user)
    
    if echo "$response" | grep -q '"login"'; then
        echo "GITHUB_USERNAME='$github_username'" > "$CONFIG_FILE"
        echo "GITHUB_TOKEN='$github_token'" >> "$CONFIG_FILE"
        print_color $GREEN "✅ Successfully authenticated as $github_username"
        log "User authenticated: $github_username"
        return 0
    else
        print_color $RED "❌ Authentication failed. Please check your token."
        return 1
    fi
}

# Fork a repository
fork_repository() {
    source "$CONFIG_FILE"
    read -p "Enter owner/repo (e.g., owner/repository): " repo_path
    
    print_color $BLUE "🍴 Forking repository $repo_path..."
    
    response=$(curl -s -X POST -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$repo_path/forks")
    
    if echo "$response" | grep -q '"clone_url"'; then
        clone_url=$(echo "$response" | grep '"clone_url"' | head -1 | cut -d'"' -f4)
        print_color $GREEN "✅ Repository forked successfully!"
        echo "Clone URL: $clone_url"
        
        read -p "Do you want to clone the forked repository? (y/n): " clone_choice
        if [[ $clone_choice == "y" ]]; then
            git clone "$clone_url"
            print_color $GREEN "✅ Forked repository cloned!"
            
            # Navigate to cloned repo and offer .gitignore setup
            repo_dir=$(basename "$clone_url" .git)
            cd "$repo_dir"
            read -p "Do you want to setup .gitignore for the cloned repository? (y/n): " gitignore_choice
            if [[ $gitignore_choice == "y" ]]; then
                setup_gitignore
            fi
        fi
    else
        print_color $RED "❌ Failed to fork repository"
    fi
}

# Branch management
branch_operations() {
    if ! is_git_repo; then
        print_color $RED "❌ Not a Git repository"
        return 1
    fi

    print_color $CYAN "🌿 Branch Operations:"
    echo "1) Create new branch"
    echo "2) Switch branch"
    echo "3) List branches"
    echo "4) Delete branch"
    echo "5) Merge branch"
    read -p "Choose operation (1-5): " branch_choice

    case $branch_choice in
        1)
            read -p "Enter new branch name: " new_branch
            git checkout -b "$new_branch"
            print_color $GREEN "✅ Created and switched to branch: $new_branch"
            ;;
        2)
            echo "Available branches:"
            git branch
            read -p "Enter branch name to switch to: " switch_branch
            git checkout "$switch_branch"
            print_color $GREEN "✅ Switched to branch: $switch_branch"
            ;;
        3)
            print_color $CYAN "🌿 Available branches:"
            git branch -a
            ;;
        4)
            echo "Available branches:"
            git branch
            read -p "Enter branch name to delete: " delete_branch
            if [[ $delete_branch == "main" || $delete_branch == "master" ]]; then
                print_color $RED "❌ Cannot delete main/master branch"
                return 1
            fi
            git branch -d "$delete_branch"
            print_color $GREEN "✅ Deleted branch: $delete_branch"
            ;;
        5)
            current_branch=$(git branch --show-current)
            echo "Available branches:"
            git branch
            read -p "Enter branch to merge into $current_branch: " merge_branch
            git merge "$merge_branch"
            print_color $GREEN "✅ Merged $merge_branch into $current_branch"
            ;;
        *)
            print_color $RED "❌ Invalid choice"
            ;;
    esac
}

# Stash operations
stash_operations() {
    if ! is_git_repo; then
        print_color $RED "❌ Not a Git repository"
        return 1
    fi

    print_color $CYAN "💾 Stash Operations:"
    echo "1) Stash changes"
    echo "2) Apply last stash"
    echo "3) List stashes"
    echo "4) Pop stash"
    read -p "Choose operation (1-4): " stash_choice

    case $stash_choice in
        1)
            read -p "Enter stash message: " stash_msg
            git stash push -m "$stash_msg"
            print_color $GREEN "✅ Changes stashed: $stash_msg"
            ;;
        2)
            git stash apply
            print_color $GREEN "✅ Applied last stash"
            ;;
        3)
            print_color $CYAN "📦 Available stashes:"
            git stash list
            ;;
        4)
            git stash pop
            print_color $GREEN "✅ Popped and applied last stash"
            ;;
        *)
            print_color $RED "❌ Invalid choice"
            ;;
    esac
}

# Remote repository operations
remote_operations() {
    if ! is_git_repo; then
        print_color $RED "❌ Not a Git repository"
        return 1
    fi

    print_color $CYAN "🌐 Remote Operations:"
    echo "1) Add remote"
    echo "2) List remotes"
    echo "3) Remove remote"
    echo "4) Fetch from remote"
    read -p "Choose operation (1-4): " remote_choice

    case $remote_choice in
        1)
            read -p "Enter remote name: " remote_name
            read -p "Enter remote URL: " remote_url
            git remote add "$remote_name" "$remote_url"
            print_color $GREEN "✅ Added remote: $remote_name"
            ;;
        2)
            print_color $CYAN "🌐 Current remotes:"
            git remote -v
            ;;
        3)
            git remote -v
            read -p "Enter remote name to remove: " remove_remote
            git remote remove "$remove_remote"
            print_color $GREEN "✅ Removed remote: $remove_remote"
            ;;
        4)
            read -p "Enter remote name (default: origin): " fetch_remote
            fetch_remote=${fetch_remote:-origin}
            git fetch "$fetch_remote"
            print_color $GREEN "✅ Fetched from remote: $fetch_remote"
            ;;
        *)
            print_color $RED "❌ Invalid choice"
            ;;
    esac
}

# View and manage .gitignore
manage_gitignore() {
    if ! is_git_repo; then
        print_color $RED "❌ Not a Git repository"
        return 1
    fi

    print_color $CYAN "📁 .gitignore Management"
    echo "1) View current .gitignore"
    echo "2) Edit .gitignore"
    echo "3) Add patterns to .gitignore"
    echo "4) Create new .gitignore"
    read -p "Choose operation (1-4): " gitignore_choice

    case $gitignore_choice in
        1)
            if has_gitignore; then
                print_color $CYAN "📄 Current .gitignore content:"
                echo "=================="
                cat .gitignore
                echo "=================="
            else
                print_color $YELLOW "⚠️  No .gitignore file found"
            fi
            ;;
        2)
            if has_gitignore; then
                ${EDITOR:-nano} .gitignore
                print_color $GREEN "✅ .gitignore updated"
            else
                print_color $RED "❌ No .gitignore file found"
            fi
            ;;
        3)
            setup_gitignore
            ;;
        4)
            setup_gitignore
            ;;
        *)
            print_color $RED "❌ Invalid choice"
            ;;
    esac
}

# Main menu
main_menu() {
    while true; do
        echo ""
        print_color $PURPLE "🤖 Git Bot - Comprehensive Git Assistant"
        echo "=============================================="
        
        # Show current directory info
        print_color $CYAN "📂 Current directory: $(pwd)"
        
        # Show current repo info if in git repo
        if is_git_repo; then
            current_branch=$(git branch --show-current)
            repo_name=$(basename $(git rev-parse --show-toplevel))
            print_color $GREEN "📁 Repo: $repo_name | 🌿 Branch: $current_branch"
            
            # Show .gitignore status
            if has_gitignore; then
                print_color $GREEN "📄 .gitignore: Present"
            else
                print_color $YELLOW "📄 .gitignore: Not found"
            fi
            
            # Quick status
            check_changes
        else
            print_color $RED "📭 Not in a Git repository"
        fi
        
        echo ""
        print_color $BLUE "📋 Available Commands:"
        echo "1)  📊 Check changes"
        echo "2)  💾 Smart commit & push"
        echo "3)  🌿 Branch operations"
        echo "4)  💾 Stash operations"
        echo "5)  🌐 Remote operations"
        echo "6)  🍴 Fork repository"
        echo "7)  📥 Clone repository"
        echo "8)  🔄 Pull latest changes"
        echo "9)  🚀 Push changes"
        echo "10) 📜 View history"
        echo "11) 🆕 Initialize new repository"
        echo "12) 📁 Manage .gitignore"
        echo "13) 📂 Navigate to repository"
        echo "14) 🔐 Re-authenticate GitHub"
        echo "15) 🚪 Exit"
        echo ""
        
        read -p "💭 Choose option (1-15): " main_choice

        case $main_choice in
            1) check_changes ;;
            2) smart_commit ;;
            3) branch_operations ;;
            4) stash_operations ;;
            5) remote_operations ;;
            6) fork_repository ;;
            7) 
                read -p "Enter repository URL to clone: " clone_url
                git clone "$clone_url"
                print_color $GREEN "✅ Repository cloned!"
                
                # Offer .gitignore setup after cloning
                repo_dir=$(basename "$clone_url" .git)
                if [[ -d "$repo_dir" ]]; then
                    cd "$repo_dir"
                    read -p "Do you want to setup .gitignore for the cloned repository? (y/n): " gitignore_choice
                    if [[ $gitignore_choice == "y" ]]; then
                        setup_gitignore
                    fi
                fi
                ;;
            8)
                if is_git_repo; then
                    git pull
                    print_color $GREEN "✅ Pulled latest changes!"
                else
                    print_color $RED "❌ Not a Git repository"
                fi
                ;;
            9)
                if is_git_repo; then
                    git push
                    print_color $GREEN "✅ Changes pushed!"
                else
                    print_color $RED "❌ Not a Git repository"
                fi
                ;;
            10)
                if is_git_repo; then
                    git log --oneline -10
                else
                    print_color $RED "❌ Not a Git repository"
                fi
                ;;
            11) init_new_repo ;;
            12) manage_gitignore ;;
            13) navigate_to_repo ;;
            14) authenticate_github ;;
            15) 
                print_color $GREEN "👋 Goodbye!"
                exit 0
                ;;
            *) 
                print_color $RED "❌ Invalid option. Please try again."
                ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
        clear
    done
}

# Error handling
trap 'print_color $RED "Script interrupted. Exiting safely..."; exit 1' INT TERM

# Main execution
init_config
clear
print_color $GREEN "🚀 Initializing Git Bot..."

if authenticate_github; then
    main_menu
else
    print_color $RED "❌ Authentication failed. Cannot continue."
    exit 1
fi
