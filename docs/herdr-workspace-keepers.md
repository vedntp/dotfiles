# Herdr workspace resurrection

`mac/.config/herdr/workspace-keepers/` contains the tracked source for the
`local.workspace-keepers` Herdr plugin. It protects the `general`, `bte`,
`stryde`, and `vqa` workspace containers. `personal` is intentionally not
protected.

## What it does

Herdr normally closes a workspace when its last tab closes. This plugin listens
to Herdr lifecycle events and recreates a protected workspace after that
happens. The recreated workspace keeps its label, the most recently observed
pane directory, and its sidebar logo metadata. Herdr creates one ordinary fresh
tab because an empty workspace is not supported by the native API.

There are no permanent keeper tabs, sleeping processes, polling loops, or
background daemons. A short-lived Python process runs only for a matching event,
and a filesystem lock serializes overlapping events. A three-second circuit
breaker prevents repeated pane/tab events from creating duplicates; an explicit
`workspace.closed` event always restores the protected workspace immediately.
Runtime state and the lock are outside Git in the directory supplied by
`HERDR_PLUGIN_STATE_DIR`.

## Files and operations

- `herdr-plugin.toml`: manifest, startup hook, lifecycle hooks, and reconcile action.
- `config.json`: protected workspace labels and their display tokens.
- `keepers.py`: bounded event-driven reconciliation logic.
- `docs/herdr-workspace-keepers.md`: this operational note.

The plugin is linked into Herdr from the dotfiles path. After a dotfiles
checkout on another machine, relink it with:

```sh
herdr plugin link ~/.dotfiles/mac/.config/herdr/workspace-keepers --enabled
```

Useful commands:

```sh
herdr plugin list
herdr plugin action invoke reconcile --plugin local.workspace-keepers
herdr plugin log list --plugin local.workspace-keepers --limit 20
herdr plugin disable local.workspace-keepers
herdr plugin enable local.workspace-keepers
```

Disabling the plugin stops automatic resurrection. It does not close existing
workspaces or tabs.
