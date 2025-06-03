# CLI Panda ZSH Completions
# Provides tab completion for CLI Panda commands

# Basic completion for ai command
compdef _ai ai

_ai() {
    local -a commands
    commands=(
        'explain:Explain a command'
        'run:Run a command with AI explanation'
        'fix:Fix the last command error'
        'help:Show help information'
        'config:Configure CLI Panda'
    )
    
    _describe 'command' commands
}

# Completion for ai-run
compdef _ai_run ai-run

_ai_run() {
    _command_names -e
}

# Completion for ai-fix
compdef _ai_fix ai-fix

_ai_fix() {
    # No arguments needed
    return 0
}

# Add completion for inline ?? trigger
bindkey -M emacs '^I' expand-or-complete
bindkey -M viins '^I' expand-or-complete
bindkey -M vicmd '^I' expand-or-complete