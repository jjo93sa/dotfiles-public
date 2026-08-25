{
  lib,
  userConfig,
  ...
}: {
  # Interactive macOS preferences. A host imports this capability only when it
  # wants this exact opinionated desktop behavior.
  security.pam.services.sudo_local.touchIdAuth = true;

  system = {
    defaults = {
      ".GlobalPreferences"."com.apple.mouse.scaling" = -1.0;

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticWindowAnimationsEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        PMPrintingExpandedStateForPrint = true;
      };

      LaunchServices.LSQuarantine = false;

      trackpad = {
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
        Clicking = true;
      };

      finder = {
        AppleShowAllFiles = true;
        CreateDesktop = false;
        FXDefaultSearchScope = "SCcf";
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
      };

      dock = {
        autohide = true;
        expose-animation-duration = 0.15;
        show-recents = false;
        showhidden = true;
        tilesize = 30;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };

      screencapture = {
        # Private host modules can replace this default with a normal
        # assignment, without needing lib.mkForce.
        location = lib.mkDefault "/Users/${userConfig.name}/Desktop/Screenshots and recordings";
        type = "png";
        disable-shadow = true;
      };
    };

    keyboard.enableKeyMapping = true;
  };
}
