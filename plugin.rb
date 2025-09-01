# frozen_string_literal: true
# name: vc-sso-redirect
# about: Safe SSO redirect allowlist + optional client-side fallback for DiscourseConnect provider flows
# version: 0.1.0
# authors: Victorious Christians
# url: https://victoriouschristians.com

enabled_site_setting :vc_sso_fallback_enabled
enabled_site_setting :vc_sso_allowed_hosts

after_initialize do
  # Merge plugin's allowed hosts into Discourse's built-in allowlist
  begin
    allowed = SiteSetting.vc_sso_allowed_hosts.to_s.split(/[,|\s]+/).map(&:strip).reject(&:blank?).uniq
    current = SiteSetting.discourse_connect_allowed_redirect_hosts.to_s.split("|").map(&:strip).reject(&:blank?)
    merged  = (current + allowed).uniq.join("|")

    if merged != SiteSetting.discourse_connect_allowed_redirect_hosts
      SiteSetting.discourse_connect_allowed_redirect_hosts = merged
      Rails.logger.info("[vc-sso-redirect] merged allowed hosts => #{merged}")
    end
  rescue => e
    Rails.logger.warn("[vc-sso-redirect] failed merging allowed hosts: #{e.message}")
  end

  # ---- OPTIONAL server-side guard (disabled by default) ----
  # If you ever want to enforce redirect server-side (in addition to JS),
  # uncomment this block. It only redirects when host is allow-listed.
  #
  # module ::VCSsoRedirect
  #   def self.allowed_host?(host)
  #     allowed = SiteSetting.vc_sso_allowed_hosts.to_s.split(/[,|\s]+/).map(&:strip).reject(&:blank?).uniq
  #     allowed.include?(host)
  #   end
  # end
  #
  # module ::VCSsoRedirect::StaticControllerPatch
  #   def enter
  #     if SiteSetting.vc_sso_fallback_enabled && params[:redirect].present?
  #       begin
  #         uri = URI.parse(params[:redirect])
  #         if uri.host.present? && ::VCSsoRedirect.allowed_host?(uri.host)
  #           return redirect_to(params[:redirect])
  #         end
  #       rescue URI::InvalidURIError
  #         # fall through to default behavior
  #       end
  #     end
  #     super
  #   end
  # end
  #
  # ::StaticController.prepend(::VCSsoRedirect::StaticControllerPatch)
end
