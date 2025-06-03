# CLI Panda ZSH Keybindings
# Custom keybindings for enhanced CLI Panda experience

# Ctrl+E - AI explain last command
bindkey '^E' cli-panda-explain-last

# Ctrl+R - Enhanced reverse search with AI
bindkey '^R' cli-panda-smart-history

# Alt+Enter - Run command with AI explanation
bindkey '^[^M' cli-panda-run-with-explain

# Functions for keybindings
cli-panda-explain-last() {
    BUFFER="ai explain !!"
    zle accept-line
}

cli-panda-smart-history() {
    # Fall back to regular history search for now
    zle history-incremental-search-backward
}

cli-panda-run-with-explain() {
    if [[ -n "$BUFFER" ]]; then
        BUFFER="ai-run $BUFFER"
    fi
    zle accept-line
}

# Register functions as ZLE widgets
zle -N cli-panda-explain-last
zle -N cli-panda-smart-history
zle -N cli-panda-run-with-explain