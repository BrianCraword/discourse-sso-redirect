import { withPluginApi } from "discourse/lib/plugin-api";

export default {
  name: "vc-sso-redirect",
  initialize() {
    withPluginApi("1.8.0", (api) => {
      const enabled = settings.vc_sso_fallback_enabled;
      if (!enabled) return;

      // Allowed hosts from site setting (comma/pipe/space separated)
      const allowList = (settings.vc_sso_allowed_hosts || "")
        .split(/[,|\s]+/)
        .map((s) => s.trim())
        .filter(Boolean);

      const captureRedirectOnLogin = () => {
        // Discourse login form carries a hidden 'redirect' when SSO initiated
        const input = document.querySelector("input[name='redirect']");
        if (input && input.value) {
          sessionStorage.setItem("vc_sso_redirect", input.value);
        }
      };

      const tryClientFallbackRedirect = () => {
        const url = sessionStorage.getItem("vc_sso_redirect");
        if (!url) return;

        try {
          const u = new URL(url);
          if (allowList.includes(u.hostname)) {
            sessionStorage.removeItem("vc_sso_redirect"); // avoid loops
            window.location.href = url;
          } else {
            // not allow-listed, drop it
            sessionStorage.removeItem("vc_sso_redirect");
          }
        } catch {
          sessionStorage.removeItem("vc_sso_redirect");
        }
      };

      api.onAppEvent("page:changed", () => {
        const currentUser = api.getCurrentUser();

        if (window.location.pathname === "/login") {
          captureRedirectOnLogin();
          return;
        }

        // If user just landed at '/', and we still have a target, finish the redirect
        if (currentUser && window.location.pathname === "/") {
          tryClientFallbackRedirect();
        }
      });
    });
  },
};
