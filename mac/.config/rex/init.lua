-- Rex config. Reload with `rex config reload`.

-- omarchy runs a personal Rex server (systemd user unit ~/.config/systemd/user/rex.service)
-- with built-in Tailscale (`--tailscale`), the docs' remote path for a personal
-- server. It joins the tailnet as its own device, omarchy-rex. Only my Tailscale
-- login is let in.
-- This declares it for the CLI (`rex -S omarchy ...`). The Mac app keeps its own
-- host list, added once via Add Remote Host.
rex.host{
  label = "omarchy",
  endpoint = "https://omarchy-rex.tailef584e.ts.net",
}

rex.bind("shift+cmd+o", "client.host.switch")
