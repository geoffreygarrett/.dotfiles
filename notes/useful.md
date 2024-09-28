

## Create host list from tailscale

```bash
  tailscale status --json | jq -r '
    .Peer[]
    | "\"\(.TailscaleIPs[0])\" = [ \"\(.DNSName | split(".")[0]).tail\" ];"
```
