# vc-sso-redirect (Discourse plugin)

A tiny plugin that:
1) Merges a list of allowed external hosts into Discourse’s
   `discourse_connect_allowed_redirect_hosts` so Discourse can legally
   redirect back to your IdP/OIDC bridge (e.g., distrust at `auth.*`).
2) Adds an **optional** client-side fallback that finishes the redirect
   after login if Discourse’s core flow “forgets” it and dumps the user
   on `/`.

## Settings (Admin -> Settings -> Plugins)
- **vc_sso_fallback_enabled** (default: on) — enable/disable the JS safety net
- **vc_sso_allowed_hosts** — e.g. `auth.victoriouschristians.com|auth.staging.victoriouschristians.com`

These hosts are:
- merged into Discourse’s `discourse_connect_allowed_redirect_hosts` (server)
- used by the JS to validate the fallback target (client)

## Install

Edit `/var/discourse/containers/app.yml` and add under `hooks: -> after_code:`:

```yaml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/YOUR-ORG/discourse-vc-sso-redirect.git
