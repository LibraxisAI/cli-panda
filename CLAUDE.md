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