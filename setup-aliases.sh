#!/bin/bash
# Quick alias setup for CLI Panda

echo "Setting up CLI Panda aliases..."

# Add to .zshrc if not already there
if ! grep -q "CLI Panda aliases" ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'EOF'

# CLI Panda aliases
alias panda="cd ~/cli-panda && ./panda"
alias ai="cd ~/cli-panda/ai-terminal && npm start"
alias ai-rag="cd ~/cli-panda/lbrxchat && uv run python -m lbrxchat.tui"
alias ai-py="cd ~/cli-panda/cli && uv run python cli_panda.py"

# Quick shortcuts
alias pandzia="panda"
alias clipanda="panda"
EOF
    echo "✅ Aliases added to ~/.zshrc"
else
    echo "✅ Aliases already configured"
fi

echo
echo "Now run: source ~/.zshrc"
echo
echo "Then you can use:"
echo "  ai        - Launch AI Terminal"
echo "  ai-rag    - Launch RAG system"
echo "  ai-py     - Launch Python CLI"
echo "  panda     - Universal launcher"