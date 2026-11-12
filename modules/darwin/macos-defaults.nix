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
        AppleKeyboardUIMode = 2;
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
        "com.apple.keyboard.fnState" = true;
      };

      controlcenter.Bluetooth = true;

      # Safari's AutoFill preferences are per-user rather than global defaults.
      CustomUserPreferences."com.apple.Safari" = {
        AutoFillFromAddressBook = false;
        AutoFillPasswords = false;
        AutoFillCreditCardData = false;
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
        wvous-bl-corner = 3;
        wvous-br-corner = 2;
        wvous-tl-corner = 4;
        wvous-tr-corner = 10;
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
