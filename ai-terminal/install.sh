#!/bin/bash

# CLI Panda AI Terminal Installer
# Version: 1.0.1
# Last Updated: 2025-05-29
# Safe for non-programmers!

echo "🐼 CLI Panda AI Terminal Installer"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Error handler
error_exit() {
    echo -e "\n${RED}❌ Error: $1${NC}" >&2
    echo -e "If you need help, please visit: https://github.com/LibraxisAI/cli-panda/issues"
    exit 1
}

# Detect OS
OS="$(uname -s)"
ARCH="$(uname -m)"

# Check if we're in the right directory
check_directory() {
    if [ ! -f "package.json" ]; then
        echo -e "${RED}❌ Error: install.sh must be run from the ai-terminal directory${NC}"
        echo -e "Please run:"
        echo -e "  ${BLUE}cd ai-terminal${NC}"
        echo -e "  ${BLUE}./install.sh${NC}"
        exit 1
    fi
}

# Check for required commands
check_requirements() {
    echo -e "${BLUE}Checking system requirements...${NC}"
    
    # Check for curl
    if ! command -v curl &> /dev/null; then
        error_exit "curl is required but not installed. Please install curl first."
    fi
    
    # Check for git (might need it)
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}⚠️  git not found - some features may be limited${NC}"
    fi
}

# Check Node.js with helpful instructions
check_node() {
    echo -e "\n${BLUE}Checking Node.js...${NC}"
    
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js not found${NC}"
        echo -e "\nTo install Node.js:"
        echo -e "  1. Visit: ${BLUE}https://nodejs.org${NC}"
        echo -e "  2. Download the LTS version (20.x or newer)"
        echo -e "  3. Run the installer"
        echo -e "  4. Restart your terminal"
        echo -e "  5. Run this installer again"
        exit 1
    fi
    
    NODE_VERSION=$(node -v 2>/dev/null | cut -d'v' -f2 | cut -d'.' -f1)
    if [ -z "$NODE_VERSION" ] || [ "$NODE_VERSION" -lt "20" ]; then
        echo -e "${RED}❌ Node.js 20+ required. Current: $(node -v 2>/dev/null || echo 'unknown')${NC}"
        echo -e "Please update Node.js from: ${BLUE}https://nodejs.org${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Node.js $(node -v) detected${NC}"
}

# Check npm
check_npm() {
    echo -e "\n${BLUE}Checking npm...${NC}"
    
    if ! command -v npm &> /dev/null; then
        error_exit "npm not found. Please reinstall Node.js from https://nodejs.org"
    fi
    
    echo -e "${GREEN}✅ npm $(npm -v) detected${NC}"
}

# Check LM Studio with detailed instructions
check_lmstudio() {
    echo -e "\n${BLUE}Checking LM Studio...${NC}"
    
    if curl -s -m 5 http://localhost:1234/v1/models > /dev/null 2>&1; then
        echo -e "${GREEN}✅ LM Studio is running${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  LM Studio not detected${NC}"
        echo -e "\n${YELLOW}LM Studio is required for AI features${NC}"
        echo -e "To set up LM Studio:"
        echo -e "  1. Download from: ${BLUE}https://lmstudio.ai${NC}"
        echo -e "  2. Install and run LM Studio"
        echo -e "  3. Download a model (recommended: ${BLUE}qwen3-8b${NC})"
        echo -e "  4. Start the local server (it should run on port 1234)"
        echo -e "\nYou can continue installation and set up LM Studio later."
        echo -e -n "\nContinue without LM Studio? [Y/n] "
        read -r response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            exit 0
        fi
        return 1
    fi
}

# Install dependencies with progress
install_deps() {
    echo -e "\n${BLUE}Installing dependencies...${NC}"
    echo -e "${YELLOW}This may take a few minutes...${NC}"
    
    if ! npm install 2>&1 | while read -r line; do
        echo -n "."
    done; then
        echo ""
        error_exit "Failed to install dependencies. Please check your internet connection."
    fi
    
    echo -e "\n${GREEN}✅ Dependencies installed${NC}"
}

# Check if ZSH is available
check_shell() {
    echo -e "\n${BLUE}Checking shell configuration...${NC}"
    
    if [ -z "${ZSH_VERSION:-}" ] && [[ "${SHELL:-}" != *"zsh"* ]]; then
        echo -e "${YELLOW}⚠️  ZSH not detected${NC}"
        echo -e "CLI Panda works best with ZSH shell."
        echo -e "\nTo install ZSH:"
        
        if [[ "$OS" == "Darwin" ]]; then
            echo -e "  Run: ${BLUE}brew install zsh${NC}"
        else
            echo -e "  Run: ${BLUE}sudo apt-get install zsh${NC} (Ubuntu/Debian)"
            echo -e "  Or:  ${BLUE}sudo yum install zsh${NC} (CentOS/RHEL)"
        fi
        
        echo -e "\nContinuing with basic installation..."
        return 1
    fi
    
    echo -e "${GREEN}✅ ZSH detected${NC}"
    return 0
}

# Check for uv (optional but recommended)
check_uv() {
    echo -e "\n${BLUE}Checking for uv (Python package manager)...${NC}"
    
    if command -v uv &> /dev/null; then
        echo -e "${GREEN}✅ uv $(uv --version 2>/dev/null | head -1) detected${NC}"
        echo -e "${YELLOW}ℹ️  For Python components, we recommend using uv${NC}"
    else
        echo -e "${YELLOW}ℹ️  uv not found (optional)${NC}"
        echo -e "For faster Python package management, install uv:"
        echo -e "  ${BLUE}curl -LsSf https://astral.sh/uv/install.sh | sh${NC}"
    fi
}

# Setup ZSH integration
setup_zsh() {
    if ! check_shell; then
        echo -e "${YELLOW}Skipping ZSH integration${NC}"
        return
    fi
    
    echo -e "\n${BLUE}Setting up ZSH integration...${NC}"
    
    # Check if zsh-components exists
    if [ ! -d "zsh-components" ]; then
        echo -e "${YELLOW}⚠️  ZSH components not found, skipping ZSH setup${NC}"
        return
    fi
    
    # Backup .zshrc if it exists
    if [ -f "$HOME/.zshrc" ]; then
        BACKUP_FILE="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.zshrc" "$BACKUP_FILE" || error_exit "Failed to backup .zshrc"
        echo -e "${GREEN}✅ Created backup: $BACKUP_FILE${NC}"
    fi
    
    ZSH_DIR="$HOME/.zsh/cli-panda"
    mkdir -p "$ZSH_DIR" || error_exit "Failed to create $ZSH_DIR"
    
    # Copy components
    cp -r zsh-components/* "$ZSH_DIR/" || error_exit "Failed to copy ZSH components"
    
    # Add to .zshrc if not already there
    if ! grep -q "source.*cli-panda/init.zsh" "$HOME/.zshrc" 2>/dev/null; then
        echo -e "\n# CLI Panda AI Terminal" >> "$HOME/.zshrc"
        echo "source $ZSH_DIR/init.zsh" >> "$HOME/.zshrc"
        echo -e "${GREEN}✅ Added to ~/.zshrc${NC}"
        echo -e "${YELLOW}ℹ️  Your existing .zshrc settings (API keys, aliases, etc.) are preserved${NC}"
    else
        echo -e "${GREEN}✅ Already configured in ~/.zshrc${NC}"
    fi
}

# Create config
create_config() {
    echo -e "\n${BLUE}Creating configuration...${NC}"
    
    CONFIG_DIR="$HOME/.config/cli-panda"
    mkdir -p "$CONFIG_DIR" || error_exit "Failed to create config directory"
    
    if [ ! -f "$CONFIG_DIR/config.json" ]; then
        cat > "$CONFIG_DIR/config.json" << EOF
{
  "mode": "sdk",
  "model": "qwen3-8b",
  "temperature": 0.7,
  "maxTokens": 200,
  "theme": "warp",
  "features": {
    "inlineAI": true,
    "smartAutocomplete": true,
    "contextAwareness": true,
    "warpStyleBlocks": true
  }
}
EOF
        echo -e "${GREEN}✅ Created config at $CONFIG_DIR/config.json${NC}"
    else
        echo -e "${GREEN}✅ Config already exists${NC}"
    fi
}

# Setup endpoint configuration
setup_endpoints() {
    echo -e "\n${BLUE}Setting up endpoint configuration...${NC}"
    
    # Create .env from .env.example if it doesn't exist
    if [ ! -f ".env" ] && [ -f ".env.example" ]; then
        cp .env.example .env
        echo -e "${GREEN}✅ Created .env file${NC}"
        
        # Ask if user wants to configure remote endpoint
        echo -e "\n${YELLOW}Do you have a remote LM Studio server?${NC}"
        echo -e "Press Y to configure, N to use local only: \c"
        read -r response
        
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "\n${BLUE}Enter your remote endpoint URL (e.g., ws://example.com:1234):${NC} \c"
            read -r remote_url
            
            if [ ! -z "$remote_url" ]; then
                # Update .env file
                sed -i.bak "s|# LMSTUDIO_REMOTE_URL=.*|LMSTUDIO_REMOTE_URL=$remote_url|" .env
                sed -i.bak "s|# LMSTUDIO_USE_REMOTE=.*|LMSTUDIO_USE_REMOTE=true|" .env
                rm -f .env.bak
                echo -e "${GREEN}✅ Remote endpoint configured${NC}"
                echo -e "${YELLOW}ℹ️  CLI Panda will try remote first, fall back to local if it fails${NC}"
            fi
        fi
    elif [ -f ".env" ]; then
        echo -e "${GREEN}✅ .env file already exists${NC}"
    fi
}

# Create simple launcher script
create_launcher() {
    echo -e "\n${BLUE}Creating launcher...${NC}"
    
    # Create main launcher
    LAUNCHER="$HOME/.local/bin/ai"
    mkdir -p "$HOME/.local/bin" || error_exit "Failed to create ~/.local/bin"
    
    cat > "$LAUNCHER" << EOF
#!/bin/bash
# CLI Panda AI Terminal launcher
cd "$PWD" && npm start
EOF
    
    chmod +x "$LAUNCHER" || error_exit "Failed to make launcher executable"
    
    # Create additional launchers
    cat > "$HOME/.local/bin/cli-panda" << EOF
#!/bin/bash
# CLI Panda launcher (alias for ai)
exec "$LAUNCHER" "\$@"
EOF
    
    chmod +x "$HOME/.local/bin/cli-panda" || error_exit "Failed to make cli-panda executable"
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo -e "${YELLOW}ℹ️  Add this to your shell config to use 'cli-panda' command:${NC}"
        echo -e "  ${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
    fi
}

# Main installation
main() {
    # Check for dry-run flag
    DRY_RUN=false
    if [[ "${1:-}" == "--dry-run" ]]; then
        DRY_RUN=true
        echo -e "${BLUE}🏃 Running in DRY-RUN mode (no changes will be made)${NC}\n"
    fi
    
    echo -e "${YELLOW}This installer will:${NC}"
    echo -e "  • Check system requirements"
    echo -e "  • Install necessary files"
    echo -e "  • Set up AI terminal commands"
    echo -e "  • Preserve all your existing settings"
    echo -e "\n${GREEN}Let's get started!${NC}\n"
    
    # Run all checks
    check_directory
    check_requirements
    check_node
    check_npm
    check_uv
    check_lmstudio || true
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "\n${BLUE}Would perform:${NC}"
        echo -e "  • Install npm dependencies"
        echo -e "  • Setup ZSH integration in ~/.zsh/cli-panda"
        echo -e "  • Create config at ~/.config/cli-panda/config.json"
        echo -e "  • Create launcher at ~/.local/bin/cli-panda"
        echo -e "\n${GREEN}✅ Dry-run complete (no changes made)${NC}"
        exit 0
    fi
    
    # Install
    install_deps
    setup_zsh
    create_config
    setup_endpoints
    create_launcher
    
    # Success!
    echo -e "\n${GREEN}🎉 Installation complete!${NC}"
    echo -e "\n${BLUE}Next steps:${NC}"
    
    if check_shell; then
        echo -e "  1. Restart your terminal or run: ${BLUE}source ~/.zshrc${NC}"
        echo -e "  2. Type ${BLUE}ai${NC} to start AI Terminal"
        echo -e "  3. Use ${BLUE}??${NC} for inline AI assistance"
    else
        echo -e "  1. Run: ${BLUE}cli-panda${NC} to start"
    fi
    
    echo -e "\n${BLUE}Configuration:${NC} ~/.config/cli-panda/config.json"
    
    if ! curl -s -m 2 http://localhost:1234/v1/models > /dev/null 2>&1; then
        echo -e "\n${YELLOW}Remember to:${NC}"
        echo -e "  • Download and run LM Studio"
        echo -e "  • Load the ${BLUE}qwen3-8b${NC} model"
        echo -e "  • Start the local server"
    fi
    
    echo -e "\n${BLUE}For Python/MLX components:${NC}"
    echo -e "  • Check out ${BLUE}lbrxchat/${NC} for RAG system"
    echo -e "  • Check out ${BLUE}PostDevAi/${NC} for distributed memory"
    echo -e "  • Use ${BLUE}uv${NC} for fast Python package management"
    
    echo -e "\n${GREEN}Happy coding with CLI Panda! 🐼${NC}"
}

# Run with error handling
set -euo pipefail
trap 'error_exit "Installation failed at line $LINENO"' ERR

main "$@"