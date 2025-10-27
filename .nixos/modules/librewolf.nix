{ config, pkgs, ... }:

{
  programs.librewolf = {
    enable = true;
    package = pkgs.librewolf;

    profiles.default = {
      isDefault = true;

      settings = {
        ## Privacy & Security
        "privacy.resistFingerprinting" = true;
        "privacy.firstparty.isolate" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.partition.network_state.ocsp_cache" = true;
        "privacy.query_stripping.enabled" = true;

        ## Disable Telemetry & Data Reporting
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.archive.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "browser.ping-centre.telemetry" = false;
        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;

        ## Disable History & Suggestions
        "places.history.enabled" = false;
        "browser.formfill.enable" = false;
        "browser.urlbar.suggest.history" = false;
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.urlbar.suggest.engines" = false;
        "browser.search.suggest.enabled" = false;

        ## Disable Cache & Session Storage
        "browser.cache.disk.enable" = false;
        "browser.cache.memory.enable" = false;
        "browser.sessionstore.enabled" = false;
        "browser.sessionstore.resume_from_crash" = false;

        ## Disable JavaScript (you can toggle per-site with NoScript)
        "javascript.enabled" = false;

        ## Disable Clipboard and Drag-drop
        "dom.event.clipboardevents.enabled" = false;
        "dom.disable_beforeunload" = true;
        "dom.disable_window_move_resize" = true;
        "dom.disable_window_flip" = true;

        ## Network Isolation
        "network.http.referer.XOriginPolicy" = 2;
        "network.http.referer.XOriginTrimmingPolicy" = 2;
        "network.cookie.cookieBehavior" = 1; # Block 3rd-party cookies
        "network.cookie.lifetimePolicy" = 2; # Session-only cookies
        "network.predictor.enabled" = false;
        "network.prefetch-next" = false;
        "network.dns.disablePrefetch" = true;
        "network.IDN_show_punycode" = true;

        ## Disable WebRTC & Geolocation
        "media.peerconnection.enabled" = false;
        "geo.enabled" = false;
        "geo.provider.network.url" = "";
        "permissions.default.geo" = 2;

        ## Harden HTTPS & Mixed Content
        "dom.security.https_only_mode" = true;
        "security.mixed_content.block_active_content" = true;
        "security.mixed_content.block_display_content" = true;

        ## UI & Misc
        "browser.startup.homepage" = "about:blank";
        "browser.newtabpage.enabled" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "extensions.pocket.enabled" = false;
        "extensions.screenshots.disabled" = true;
        "signon.rememberSignons" = false;
      };
    };
  };
}
