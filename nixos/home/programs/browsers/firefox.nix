{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.lolwierd = {
      id = 0;
      isDefault = true;
      # containers = {
      #   fn = {
      #    id = 1;
      #    color = "blue";
      #    icon = "fingerprint";
      #  };
      #   wrk = {
      #    id = 2;
      #    color = "yellow";
      #    icon = "briefcase";
      #  };
      #   msc = {
      #    id = 3;
      #    color = "green";
      #    icon = "fruit";
      #  };
      # };
      settings = {
        "dom.security.https_only_mode" = true;
        "privacy.trackingprotection.enabled" = true;
        "app.normandy.first_run" = false;
        # disable updates (pretty pointless with nix)
        "app.update.channel" = "default";
        "browser.contentblocking.category" = "standard"; # "strict"
        "browser.ctrlTab.recentlyUsedOrder" = false;
        "browser.download.viewableInternally.typeWasRegistered.svg" = true;
        "browser.download.viewableInternally.typeWasRegistered.webp" = true;
        "browser.download.viewableInternally.typeWasRegistered.xml" = true;
        "browser.link.open_newwindow" = true;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.tabs.loadInBackground" = true;
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.urlbar.quickactions.enabled" = false;
        "browser.urlbar.quickactions.showPrefs" = false;
        "browser.urlbar.shortcuts.quickactions" = false;
        "browser.urlbar.suggest.quickactions" = false;
        "distribution.searchplugins.defaultLocale" = "en-US";
        "dom.forms.autocomplete.formautofill" = false;
        "general.autoScroll" = true;
        "general.useragent.locale" = "en-US";
        "extensions.update.enabled" = false;
        "extensions.webcompat.enable_picture_in_picture_overrides" = true;
        "extensions.webcompat.enable_shims" = true;
        "extensions.webcompat.perform_injections" = true;
        "extensions.webcompat.perform_ua_overrides" = true;
        "privacy.donottrackheader.enabled" = true;
        # Mozilla VPN
        # [1] https://github.com/yokoffing/Betterfox/issues/169
        "browser.privatebrowsing.vpnpromourl" = "";
        # Hide "More from Mozilla" in Settings
        "browser.preferences.moreFromMozilla" = false;
        # Disable welcome notices
        "browser.aboutwelcome.enabled" = false;
        # Only show List All Tabs icon when needed
        # true=always show tab overflow dropdown (FF106+ default)
        # false=only display tab dropdown when there are too many tabs
        # [1] https://www.ghacks.net/2022/10/19/how-to-hide-firefoxs-list-all-tabs-icon/
        "browser.tabs.tabmanager.enabled" = false;
        # Add compact mode back to options
        "browser.compactmode.show" = true;
        # Remove focus indicator for links
        "browser.display.focus_ring_on_anything" = true;
        "browser.display.focus_ring_style" = 0;
        "browser.display.focus_ring_width" = 0;
        # Preferred color scheme for websites
        # [SETTING] General>Language and Appearance>Website appearance
        # By default, color scheme matches the theme of your browser toolbar (3).
        # Set this pref to choose Dark on sites that support it (0) or Light (1).
        # Before FF95, the pref was 2, which determined site color based on OS theme.
        # Dark (0), Light (1), System (2), Browser (3) [DEFAULT FF95+]
        # [1] https://www.reddit.com/r/firefox/comments/rfj6yc/how_to_stop_firefoxs_dark_theme_from_overriding/hoe82i5/?context=3
        "layout.css.prefers-color-scheme.content-override" = 2;
        # Remove fullscreen delay
        "full-screen-api.transition-duration.enter" = "0 0"; # default=200 200
        "full-screen-api.transition-duration.leave" = "0 0"; # default=200 200
        # Disable fullscreen notice
        "full-screen-api.warning.delay" = -1; # default=500
        "full-screen-api.warning.timeout" = 0; # default=3000
        # Disable urlbar trending search suggestions [FF118+]
        # [SETTING] Search>Search Suggestions>Show trending search suggestions (FF119)
        "browser.urlbar.trending.featureGate" = false;
        # Disable built-in Pocket extension
        "extensions.pocket.enabled" = false;
        # Do not select the space next to a word when selecting a word
        "layout.word_select.eat_space_to_next_word" = false;
        # SmOOtH ScrOlLinG
        # "apz.overscroll.enabled"= true; # DEFAULT NON-LINUX
        # "mousewheel.min_line_scroll_amount" = 10; # 10-40; adjust this number to your liking; default=5
        # "general.smoothScroll.mouseWheel.durationMinMS" = 80; # default=50
        # "general.smoothScroll.currentVelocityWeighting" = "0.15"; # default=.25
        # "general.smoothScroll.stopDecelerationWeighting" = "0.6"; # default=.4
        # "general.smoothScroll" = true;
        # "mousewheel.default.delta_multiplier_y" = 275;
        # Yubikey
        # "security.webauth.u2f" = true;
        # "security.webauth.webauthn" = true;
        # "security.webauth.webauthn_enable_softtoken" = true;
        # "security.webauth.webauthn_enable_usbtoken" = true;
        "accessibility.force_disabled" = 1;
        # disable Studies
        # disable Normandy/Shield [FF60+]
        # Shield is a telemetry system that can push and test "recipes"
        "app.normandy.api_url" = "";
        "app.normandy.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        # personalized Extension Recommendations in about:addons and AMO [FF65+]
        # https://support.mozilla.org/kb/personalized-extension-recommendations
        "browser.discovery.enabled" = false;
        "browser.helperApps.deleteTempFileOnExit" = true;
        "browser.newtabpage.activity-stream.default.sites" = "";
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.uitour.enabled" = false;
        # use Mozilla geolocation service instead of Google.
        # "geo.provider.network.url"= "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";
        # disable using the OS's geolocation service
        # "geo.provider.use_gpsd" = false;
        # "geo.provider.use_geoclue" = false;
        # HIDDEN PREF: disable recommendation pane in about:addons (uses Google Analytics)
        "extensions.getAddons.showPane" = false;
        # recommendations in about:addons' Extensions and Themes panes [FF68+]
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        # disable Network Connectivity checks
        # [1] https://bugzilla.mozilla.org/1460537
        "network.connectivity-service.enabled" = false;
        # integrated calculator
        "browser.urlbar.suggest.calculator" = true;
        # TELEMETRY
        # disable new data submission
        "datareporting.policy.dataSubmissionEnabled" = false;
        # disable Health Reports
        "datareporting.healthreport.uploadEnabled" = false;
        # 0332: disable telemetry
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "data:,";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        # disable Telemetry Coverage
        "toolkit.telemetry.coverage.opt-out" = true; # [HIDDEN PREF]
        "toolkit.coverage.opt-out" = true; # [FF64+] [HIDDEN PREF]
        "toolkit.coverage.endpoint.base" = "";
        # disable PingCentre telemetry (used in several System Add-ons) [FF57+]
        "browser.ping-centre.telemetry" = false;
        # disable Firefox Home (Activity Stream) telemetry
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;
        "toolkit.telemetry.reportingpolicy.firstRun" = false;
        "toolkit.telemetry.shutdownPingSender.enabledFirstsession" = false;
        "browser.vpn_promo.enabled" = false;
      };
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        bitwarden
        ublock-origin
        multi-account-containers
        vimium
        auto-tab-discard
        i-dont-care-about-cookies
        sponsorblock
        plasma-integration
        raindropio
        mal-sync
        clearurls
        flagfox
        translate-web-pages
      ];
      search = {
        force = true;
        default = "Google";
        # order = [ "Searx" "Google" ];
        engines = {
          "Nix Packages" = {
            urls = [
              {
                template = "https://search.nixos.org/packages";
                params = [
                  {
                    name = "channel";
                    value = "unstable";
                  }
                  {
                    name = "type";
                    value = "packages";
                  }
                  {
                    name = "query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@n" ];
          };
          "YouTube" = {
            urls = [
              {
                template = "https://www.youtube.com/results";
                params = [
                  {
                    name = "search_query";
                    value = "{searchTerms}";
                  }
                ];
              }
            ];
            definedAliases = [ "@y" ];
          };
          "Bing".metaData.alias = "@b";
          "Google".metaData.alias = "@g";
        };
      };
    };
  };

  # plasma-browser-integration workaround for firefox and plasma 6
  home.file.".mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json".source = "${pkgs.kdePackages.plasma-browser-integration}/lib/mozilla/native-messaging-hosts/org.kde.plasma.browser_integration.json";
}
