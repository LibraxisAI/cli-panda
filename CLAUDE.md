# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Development Commands

### Install Everything
```bash
./install-all.sh
```

### Test Everything (Like lbrxWhisper!)
```bash
./run.sh test
# or directly:
uv run python test_all.py
```

### Component-Specific Commands

**AI Terminal (TypeScript):**
```bash
cd ai-terminal
npm install      # Install dependencies
npm run dev      # Development mode with hot reload
npm run build    # Build for production
npm run lint     # Run ESLint
npm test         # Run tests
```

**LBRXCHAT RAG System (Python/MLX):**
```bash
cd lbrxchat
uv sync                            # Install dependencies (no activation needed!)
uv run python -m lbrxchat.tui      # Launch TUI interface
uv run python -m lbrxchat.tools.build_index  # Build RAG index
uv run pytest                      # Run tests
```

**PostDevAI Distributed Memory (Rust + Python/MLX):**
```bash
cd PostDevAi
cargo build --release              # Build Rust components
cargo test                         # Run Rust tests
uv sync                            # Install Python dependencies
uv run python -m PostDevAi.client  # Run Python client
./target/release/dragon_node       # Run Dragon Node (M3 Ultra)
./target/release/developer_node    # Run Developer Node
```

### Linting and Type Checking
```bash
# Python (from root or any Python component)
uv run ruff check .                # Fast linting
uv run black . --check             # Code formatting check
uv run mypy .                      # Type checking

# TypeScript (in ai-terminal)
npm run lint                       # ESLint
npm run lint:fix                   # Auto-fix issues
```

## Architecture Overview

### Three-Component Ecosystem

1. **AI Terminal** (`ai-terminal/`) - TypeScript/Node.js
   - Inline AI assistance with `??` trigger
   - LM Studio integration via SDK
   - ZSH shell integration
   - 40k token context window
   - Key files: `src/core/lmstudio.ts`, `src/features/inline-ai.ts`

2. **LBRXCHAT** (`lbrxchat/`) - Python/MLX RAG System
   - Document ingestion and semantic search
   - MLX-optimized models for Apple Silicon
   - Textual-based TUI interface
   - ChromaDB vector storage
   - Key files: `lbrxchat/core/rag.py`, `lbrxchat/ui/tui.py`

3. **PostDevAI** (`PostDevAi/`) - Rust + Python/MLX (Work in Progress)
   - Distributed RAM-Lake memory architecture
   - Dragon Node (M3 Ultra) + Developer Node pattern
   - gRPC communication between nodes
   - Rust TUI with Ratatui
   - Key files: `src/core/memory/ramlake.rs`, `src/mlx/inference/llm.rs`

### Key Architectural Decisions

- **uv-first Python**: ALL Python components use `uv` exclusively. No pip, no conda, no poetry.
- **MLX for AI**: Apple Silicon optimization via MLX framework for all ML workloads
- **LM Studio Integration**: Local LLM server required for AI features (port 1234)
- **Rust for Performance**: Core memory and networking components in Rust
- **TypeScript for Terminal**: Type-safe development for terminal interactions

### Integration Points

- AI Terminal calls LM Studio API for completions
- LBRXCHAT can be invoked from AI Terminal for document analysis
- PostDevAI provides persistent memory across all components
- All components share configuration via `~/.config/cli-panda/`

## Important Context

- Project created by a veterinarian (Maciej) learning to code with AI assistance
- Heavy use of Claude Code and MCP tools for development
- Designed for Apple Silicon Macs (M1/M2/M3)
- Prioritizes developer experience with fast tools (uv, Rust, MLX)
- PostDevAI is marked as Work in Progress - optional in tests

## uv - Twoja Brama do Pythona 🚀

> "Nienawidzę conda/miniconda, nie znam poetry, uv to moje jedyne gate do Pythona"
> 
> Ten przewodnik jest dla Ciebie, Maciej!

### Co to jest uv?

`uv` to najszybszy menedżer pakietów Python w 2025, napisany w Rust przez Astral (twórców Ruff). Jest **10-100x szybszy** niż pip i zastępuje:
- pip
- pip-tools
- pipx
- poetry
- pyenv
- virtualenv
- conda/miniconda

### Instalacja uv

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Kluczowe Komendy

#### 1. `uv init` - Tworzenie nowego projektu

```bash
uv init moj-projekt
cd moj-projekt
```

Co robi:
- ✅ Tworzy folder projektu
- ✅ Inicjalizuje Git (.git + .gitignore)
- ✅ Tworzy `pyproject.toml` 
- ✅ Tworzy `README.md`
- ✅ Tworzy `.python-version`
- ✅ Dodaje przykładowy plik Python

#### 2. `uv add` - Dodawanie pakietów

```bash
# Dodaj pojedynczy pakiet
uv add numpy

# Dodaj wiele pakietów
uv add pandas scikit-learn matplotlib

# Dodaj pakiety deweloperskie
uv add --dev pytest black ruff

# Dodaj z pliku requirements.txt
uv add -r requirements.txt

# Dodaj konkretną wersję
uv add "django>=4.2,<5.0"
```

Co robi:
- ✅ Automatycznie tworzy `.venv`
- ✅ Aktualizuje `pyproject.toml`
- ✅ Tworzy/aktualizuje `uv.lock`
- ✅ Instaluje pakiety (BŁYSKAWICZNIE!)

#### 3. `uv sync` - Synchronizacja środowiska

```bash
# Synchronizuj wszystko
uv sync

# Tylko produkcyjne (bez dev)
uv sync --no-dev

# Z dodatkową grupą
uv sync --group docs
```

Co robi:
- ✅ Czyta `uv.lock`
- ✅ Instaluje dokładnie te same wersje
- ✅ Usuwa niepotrzebne pakiety
- ✅ INSTANT z gorącym cache!

#### 4. `uv run` - Uruchamianie w środowisku

```bash
# Zamiast:
source .venv/bin/activate
python main.py

# Po prostu:
uv run python main.py

# Lub dowolną komendę
uv run pytest
uv run black .
uv run python -m lbrxchat.tui
```

**MAGIA**: `uv run` automatycznie robi `uv sync` przed uruchomieniem!

### Workflow dla CLI Panda

#### Nowy komponent Python

```bash
# 1. Stwórz projekt
uv init lbrxchat-v2
cd lbrxchat-v2

# 2. Dodaj zależności
uv add mlx mlx-lm numpy
uv add --dev pytest ruff

# 3. Dodaj z requirements.txt (jeśli masz)
uv add -r ../requirements.txt

# 4. Uruchom
uv run python main.py
```

#### Istniejący projekt

```bash
cd lbrxchat

# Opcja 1: Migruj z requirements.txt
uv init .  # Inicjalizuj w istniejącym folderze
uv add -r requirements.txt
rm requirements.txt  # Już niepotrzebny!

# Opcja 2: Ręcznie dodaj pakiety
uv add textual numpy scikit-learn
uv add lmstudio chromadb langchain

# Synchronizuj
uv sync
```

#### Współdzielenie projektu

```bash
# Deweloper 1 (Ty)
uv add nowy-pakiet
git add pyproject.toml uv.lock
git commit -m "Add nowy-pakiet"
git push

# Deweloper 2 (Klaudiusz)
git pull
uv sync  # BOOM! Identyczne środowisko
```

### Zaawansowane Funkcje

#### Grupy zależności

```toml
# pyproject.toml
[project]
dependencies = ["numpy", "pandas"]  # Główne

[tool.uv]
dev-dependencies = ["pytest", "ruff"]  # Dev

[project.optional-dependencies]
ml = ["mlx", "mlx-lm", "torch"]  # Opcjonalne
docs = ["sphinx", "mkdocs"]
```

```bash
# Instaluj z grupą ML
uv sync --group ml

# Tylko produkcyjne
uv sync --no-dev

# Tylko konkretna grupa
uv sync --only-group docs
```

#### Python Version Management

```bash
# uv automatycznie zarządza wersjami Python!
echo "3.12" > .python-version

# uv sync automatycznie:
# 1. Sprawdza czy masz Python 3.12
# 2. Jeśli nie - POBIERA I INSTALUJE!
# 3. Tworzy venv z właściwą wersją
uv sync
```

#### Inline Script Dependencies

```python
# skrypt.py
# /// script
# dependencies = [
#   "requests",
#   "rich",
# ]
# ///

import requests
from rich.console import Console

console = Console()
response = requests.get("https://api.github.com")
console.print(response.json())
```

```bash
# Dodaj zależności do skryptu
uv add --script skrypt.py requests rich

# Uruchom (automatycznie instaluje!)
uv run skrypt.py
```

### Porównanie z innymi

#### vs pip + venv
```bash
# Stare (wolne)
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt  # ☕ Idź na kawę

# Nowe (BŁYSKAWICZNE)
uv sync  # ⚡ Gotowe!
```

#### vs conda
```bash
# Conda (ciężkie, wolne)
conda create -n myenv python=3.12
conda activate myenv
conda install numpy pandas  # ☕☕ Idź na obiad

# uv (lekkie, szybkie)
uv init myproject
uv add numpy pandas  # ⚡ 0.5s
```

#### vs poetry
```bash
# Poetry (skomplikowane)
poetry new myproject
poetry add numpy
poetry install
poetry shell

# uv (proste)
uv init myproject
uv add numpy
uv run python
```

### Tips & Tricks

#### 1. Globalny cache
uv używa globalnego cache dla pakietów. Instalacja numpy w projekcie #2 jest INSTANT jeśli już masz w projekcie #1!

#### 2. Lockfile = Reprodukowalność
`uv.lock` gwarantuje DOKŁADNIE te same wersje wszędzie. Commituj go do Git!

#### 3. Nie musisz aktywować venv!
```bash
# Zapomnij o tym
source .venv/bin/activate
deactivate

# Po prostu używaj
uv run <komenda>
```

#### 4. Workspace (monorepo)
```toml
# pyproject.toml w root
[tool.uv.workspace]
members = ["lbrxchat", "PostDevAi", "cli"]
```

#### 5. Szybka prototypowanie
```bash
# Stwórz i uruchom w 5 sekund
uv init demo && cd demo
uv add requests
echo "import requests; print(requests.get('https://httpbin.org/ip').json())" > demo.py
uv run python demo.py
```

### Migracja CLI Panda na uv

#### Krok 1: Komponenty Python
```bash
# LBRXCHAT
cd lbrxchat
uv init .
uv add -r requirements.txt
rm requirements.txt
echo "uv.lock" >> .gitignore

# PostDevAI Python
cd ../PostDevAi
uv init .
uv add -r requirements.txt
rm requirements.txt

# CLI
cd ../cli
uv init .
uv add lmstudio aiohttp rich
```

#### Krok 2: Aktualizuj dokumentację
Zamień wszędzie:
- `pip install -r requirements.txt` → `uv sync`
- `python -m venv .venv` → `uv init`
- `pip install pakiet` → `uv add pakiet`
- `source .venv/bin/activate` → `uv run`

#### Krok 3: Skrypty
```bash
# install.sh
- pip install -r requirements.txt
+ uv sync

# Lub jeszcze lepiej
+ uv run python main.py  # Automatyczny sync!
```

### Troubleshooting

#### "uv: command not found"
```bash
# Re-instaluj
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.zshrc
```

#### "No pyproject.toml found"
```bash
uv init .  # Inicjalizuj w bieżącym folderze
```

#### "Failed to resolve dependencies"
```bash
# Wyczyść cache
uv cache clean

# Spróbuj ponownie
uv sync --refresh
```

### Podsumowanie

`uv` to Twoja brama do Pythona bo:
- ⚡ SZYBKOŚĆ - 10-100x szybsze niż pip
- 🎯 PROSTOTA - 3 komendy: init, add, sync
- 🔒 PEWNOŚĆ - Lockfile = reprodukowalność
- 🚀 NOWOCZESNOŚĆ - Rust pod spodem
- 🧹 CZYSTOŚĆ - Jeden tool zamiast 5

Zapomnij o:
- ❌ conda activate
- ❌ poetry shell
- ❌ pip freeze > requirements.txt
- ❌ virtualenv
- ❌ pyenv

Używaj:
- ✅ `uv init` - nowy projekt
- ✅ `uv add` - dodaj pakiety
- ✅ `uv sync` - synchronizuj
- ✅ `uv run` - uruchom

To wszystko! Witaj w świecie Pythona bez bólu! 🐍✨