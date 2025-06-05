"""Top-level TUI launcher.

This thin wrapper exists so that users can run the application with the more
intuitive module path ``python -m lbrxchat.tui`` (similar to e.g. ``python -m
http.server``) in addition to the canonical ``lbrxchat.ui.tui`` path.

Keeping this shim separate avoids having to duplicate any real logic – we just
delegate straight to :pymod:`lbrxchat.ui.tui`.
"""

from lbrxchat.ui.tui import main  # Re-export


if __name__ == "__main__":  # pragma: no cover – executed only when run directly
    main()
