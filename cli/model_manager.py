#!/usr/bin/env python3
"""
Model Manager for CLI Panda
Manages local LLM models without LM Studio GUI
"""

import asyncio
import os
import sys
from pathlib import Path
from typing import Optional

import click
from lmstudio import Client as LMStudioClient
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.prompt import Prompt
from rich.table import Table

console = Console()

# Default model recommendation
DEFAULT_MODEL = "LibraxisAI/qwen3-8b-MLX-Q5"
MODEL_SUGGESTIONS = [
    "LibraxisAI/qwen3-8b-MLX-Q5",
    "mlx-community/Qwen2.5-7B-Instruct-MLX-4bit",
    "mlx-community/Llama-3.2-3B-Instruct-4bit",
    "mlx-community/Phi-3.5-mini-instruct-4bit",
]


class ModelManager:
    def __init__(self):
        self.client = None
        self.models_dir = Path.home() / ".lmstudio" / "models"
        self.config_file = Path.home() / ".config" / "cli-panda" / "models.json"
        
    async def connect(self):
        """Connect to LM Studio SDK"""
        try:
            self.client = LMStudioClient()
            return True
        except Exception as e:
            console.print(f"[red]❌ Cannot connect to LM Studio: {e}[/red]")
            return False
    
    async def list_local_models(self):
        """List locally available models"""
        if not self.models_dir.exists():
            return []
        
        models = []
        for model_path in self.models_dir.rglob("*.gguf"):
            models.append(str(model_path.relative_to(self.models_dir)))
        
        for model_path in self.models_dir.rglob("*.safetensors"):
            models.append(str(model_path.relative_to(self.models_dir)))
            
        return models
    
    async def download_model(self, model_id: str):
        """Download model from HuggingFace"""
        console.print(f"\n[blue]📥 Downloading model: {model_id}[/blue]")
        
        with Progress(
            SpinnerColumn(),
            TextColumn("[progress.description]{task.description}"),
            console=console
        ) as progress:
            task = progress.add_task("Downloading...", total=None)
            
            try:
                # Use LM Studio SDK to download
                if self.client:
                    await self.client.models.download(model_id)
                    progress.update(task, completed=True, description="✅ Downloaded!")
                    return True
                else:
                    # Fallback to huggingface-cli
                    import subprocess
                    cmd = ["huggingface-cli", "download", model_id, "--local-dir", 
                           str(self.models_dir / model_id.replace("/", "--"))]
                    
                    result = subprocess.run(cmd, capture_output=True, text=True)
                    if result.returncode == 0:
                        progress.update(task, completed=True, description="✅ Downloaded!")
                        return True
                    else:
                        console.print(f"[red]❌ Download failed: {result.stderr}[/red]")
                        return False
                        
            except Exception as e:
                console.print(f"[red]❌ Error downloading: {e}[/red]")
                return False
    
    async def setup_default_model(self):
        """Interactive setup for default model"""
        console.print("\n[bold cyan]🐼 CLI Panda Model Setup[/bold cyan]")
        console.print("\nCLI Panda can work with local LLM models.")
        console.print("We recommend small, fast models optimized for Apple Silicon.\n")
        
        # Show suggestions
        table = Table(title="Suggested Models")
        table.add_column("Model", style="cyan")
        table.add_column("Size", style="green")
        table.add_column("Description", style="white")
        
        table.add_row(
            "LibraxisAI/qwen3-8b-MLX-Q5",
            "~5GB",
            "🌟 Recommended - Fast & smart"
        )
        table.add_row(
            "mlx-community/Qwen2.5-7B-Instruct-MLX-4bit",
            "~4GB",
            "Latest Qwen, very capable"
        )
        table.add_row(
            "mlx-community/Llama-3.2-3B-Instruct-4bit",
            "~2GB",
            "Smaller but efficient"
        )
        table.add_row(
            "mlx-community/Phi-3.5-mini-instruct-4bit",
            "~2GB",
            "Microsoft's tiny powerhouse"
        )
        
        console.print(table)
        
        # Get user choice
        console.print("\nYou can:")
        console.print("1. Enter a HuggingFace model ID (e.g., LibraxisAI/qwen3-8b-MLX-Q5)")
        console.print("2. Press Enter to use the recommended model")
        console.print("3. Type 'skip' to configure later\n")
        
        choice = Prompt.ask(
            "Model choice",
            default=DEFAULT_MODEL
        )
        
        if choice.lower() == "skip":
            console.print("[yellow]⏭️  Skipping model setup. You can run 'panda model setup' later.[/yellow]")
            return None
            
        # Download the model
        success = await self.download_model(choice)
        if success:
            # Save as default
            self.config_file.parent.mkdir(parents=True, exist_ok=True)
            import json
            config = {"default_model": choice}
            self.config_file.write_text(json.dumps(config, indent=2))
            
            console.print(f"\n[green]✅ Model '{choice}' set as default![/green]")
            console.print("\n[bold]🚀 You're ready to use CLI Panda![/bold]")
            console.print("Try: [cyan]panda 'explain git rebase'[/cyan]")
            return choice
        else:
            console.print("[red]❌ Model setup failed. You can try again with 'panda model setup'[/red]")
            return None


async def setup_model():
    """Run model setup"""
    manager = ModelManager()
    await manager.connect()
    await manager.setup_default_model()


async def list_models():
    """List available models"""
    manager = ModelManager()
    models = await manager.list_local_models()
    
    if models:
        console.print("\n[bold]📦 Local Models:[/bold]")
        for model in models:
            console.print(f"  • {model}")
    else:
        console.print("[yellow]No local models found. Run 'panda model setup' to download one.[/yellow]")


async def download_model(model_id: str):
    """Download a specific model"""
    manager = ModelManager()
    await manager.connect()
    await manager.download_model(model_id)


if __name__ == "__main__":
    # CLI for testing
    import sys
    if len(sys.argv) > 1:
        if sys.argv[1] == "setup":
            asyncio.run(setup_model())
        elif sys.argv[1] == "list":
            asyncio.run(list_models())
        elif sys.argv[1] == "download" and len(sys.argv) > 2:
            asyncio.run(download_model(sys.argv[2]))
    else:
        asyncio.run(setup_model())