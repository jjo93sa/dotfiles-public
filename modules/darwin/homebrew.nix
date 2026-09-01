{pkgs, ...}: let
  switchMyMagicVersion = "2.5";
  switchMyMagicArchive = pkgs.fetchurl {
    url = "https://switchmymagic.com/releases/SwitchMyMagic-${switchMyMagicVersion}.zip";
    hash = "sha256-mRTX08m+q3PD9wi/8eEPrImpplzpbzQF/buWXpe8+x8=";
  };
in {
  # Shared graphical applications installed through Homebrew casks.
  homebrew = {
    enable = true;
    casks = [
      "1password-cli"
      "ghostty"
      "raycast"
    ];
  };

  # Extract outside the Nix store so macOS can restore the signed bundle's
  # extended attributes. Nix store canonicalisation invalidates its signature.
  system.activationScripts.postActivation.text = ''
    app="/Applications/SwitchMyMagic.app"
    installed_version=""
    if [ -f "$app/Contents/Info.plist" ]; then
      installed_version=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Contents/Info.plist" 2>/dev/null || true)
    fi

    if [ "$installed_version" != "${switchMyMagicVersion}" ]; then
      work_dir=$(/usr/bin/mktemp -d /tmp/switch-my-magic.XXXXXX)
      trap '/bin/rm -rf "$work_dir"' EXIT
      /usr/bin/ditto -x -k "${switchMyMagicArchive}" "$work_dir"
      /usr/bin/codesign --verify --deep --strict "$work_dir/SwitchMyMagic.app"
      /bin/rm -rf "$app"
      /usr/bin/ditto "$work_dir/SwitchMyMagic.app" "$app"
    fi
  '';

  # Upgrades are deliberately handled by changing the pinned version and hash.
  system.defaults.CustomUserPreferences."com.rajumandapati.switchmymagic" = {
    SUEnableAutomaticChecks = false;
    SUAutomaticallyUpdate = false;
  };
}
