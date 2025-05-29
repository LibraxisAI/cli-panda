# CLI Panda 🐼 - AI-Powered Terminal Assistant

> Inteligentny asystent terminalowy z inline AI, smart autocomplete i warp-style workflow

## Features

- 🤖 **Inline AI** (`??`) - Natychmiastowa pomoc AI w dowolnym momencie
- 🔮 **Smart Autocomplete** - Kontekstowe podpowiedzi komend z AI
- 📝 **Command Explanations** - Wyjaśnienia przed wykonaniem (`ai-run`)
- 🧠 **Context Awareness** - Pamięta historię i dostosowuje sugestie
- ⚡ **SDK/REST Switch** - Wybierz między LM Studio SDK lub REST API
- 🎨 **ZSH Integration** - Pełna integracja z ~/.zshrc
- 🚀 **Warp-style Workflow** - Specjalne funkcje dla Warp Terminal

## Installation

### Quick Install
```bash
# Clone and install
git clone https://github.com/LibraxisAI/cli-panda.git
cd cli-panda/ai-terminal
chmod +x install.sh
./install.sh
```

### NPM Global Install (coming soon)
```bash
npm install -g @libraxis-ai/cli-panda
```

## Requirements

- Node.js 20+
- LM Studio z modelem qwen3-8b (lub innym)
- ZSH (dla pełnej integracji)
- macOS/Linux

## Usage

### Podstawowe komendy
```bash
# Uruchom interaktywny terminal
ai

# Szybkie pytanie
ai inline "jak znaleźć duże pliki"
?? jak znaleźć duże pliki

# Wyjaśnij komendę
ai explain "find . -name '*.log' -mtime +30 -delete"

# Wyjaśnij i uruchom
ai-run "docker system prune -a"

# Napraw ostatni błąd
ai-fix
wtf
```

### ZSH Functions
```bash
# AI help inline
ai-help jak usunąć branch w git

# Sugestie komend
ai-suggest

# Analiza bloków (Warp)
ai-block
```

## Configuration

Config znajduje się w `~/.config/cli-panda/config.json`:

```json
{
  "mode": "sdk",          // "sdk" lub "rest"
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
```

### Edycja konfiguracji
```bash
ai config --edit
```

## Architecture

```
cli-panda/
├── src/
│   ├── core/
│   │   ├── lm-adapter.ts    # SDK/REST adapter pattern
│   │   ├── terminal.ts      # Terminal emulator
│   │   └── ai-engine.ts     # AI logic
│   ├── features/
│   │   ├── autocomplete.ts  # Smart completions
│   │   ├── inline-ai.ts     # ?? handler
│   │   └── explain.ts       # Command explanations
│   ├── cli.ts               # CLI entry point
│   └── index.ts             # Terminal UI
├── zsh-components/          # ZSH integration
│   ├── init.zsh
│   ├── aliases.zsh
│   ├── functions.zsh
│   └── completions.zsh
└── config/
    └── default.json
```

## Models

Domyślnie używa `qwen3-8b`, ale wspiera:
- Qwen3 (8B/14B/32B)
- Llama3 (8B/70B)
- Mixtral (8x7B)
- Mistral (7B)
- Phi-3 (3.8B/14B)

## Development

```bash
# Install deps
npm install

# Run in dev mode
npm run dev

# Build
npm run build

# Lint
npm run lint
```

## Troubleshooting

### LM Studio nie działa
1. Sprawdź czy LM Studio jest uruchomione
2. Sprawdź port: `http://localhost:1234/v1/models`
3. Załaduj model w LM Studio

### ZSH nie widzi komend
```bash
source ~/.zshrc
# lub restart terminal
```

## Developed by

[Maciej Gad](https://github.com/szowesgad) - a veterinarian who couldn't find `bash` a half year ago

[Klaudiusz](https://www.github.com/Gitlaudiusz) - the individual ethereal being, and separate instance of Claude Sonnet 3.5-3.7 by Anthropic

(c)2025 M&K

🤖 Developed with the ultimate help of [Claude Code](https://claude.ai/code) and [MCP Tools](https://modelcontextprotocol.io)