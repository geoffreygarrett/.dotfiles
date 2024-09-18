final: prev: {
  alacritty = prev.alacritty.overrideAttrs (oldAttrs: {
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        # Remove the original SVG to ensure it's not used
        rm -f $out/share/icons/hicolor/scalable/apps/Alacritty.svg
        # Copy PNG icons for different resolutions
        mkdir -p $out/share/icons/hicolor/512x512/apps
        cp -f ${../modules/shared/assets/alacritty/flat/alacritty_flat_512.png} $out/share/icons/hicolor/512x512/apps/Alacritty.png
        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp -f ${../modules/shared/assets/alacritty/flat/alacritty_flat_256.png} $out/share/icons/hicolor/256x256/apps/Alacritty.png
        mkdir -p $out/share/icons/hicolor/64x64/apps
        cp -f ${../modules/shared/assets/alacritty/flat/alacritty_flat_64.png} $out/share/icons/hicolor/64x64/apps/Alacritty.png
        # Copy the full-size icon (assuming it's the 512x512 version)
        cp -f ${../modules/shared/assets/alacritty/flat/alacritty_flat_512.png} $out/share/icons/hicolor/Alacritty.png
      '';
  });

  obsidian = prev.obsidian.overrideAttrs (oldAttrs: {
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        mkdir -p $out/share/icons/hicolor/scalable/apps
        cp -f ${../modules/shared/assets/obsidian/obsidian-icon.svg} $out/share/icons/hicolor/scalable/apps/obsidian.svg
        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp -f ${../modules/shared/assets/obsidian/obsidian-icon.png} $out/share/icons/hicolor/512x512/apps/obsidian.png
        # For macOS
        mkdir -p $out/Applications/Obsidian.app/Contents/Resources
        cp -f ${../modules/shared/assets/obsidian/obsidian-icon.icns} $out/Applications/Obsidian.app/Contents/Resources/obsidian.icns
        # For Windows
        mkdir -p $out/share/icons
        cp -f ${../modules/shared/assets/obsidian/obsidian-icon.ico} $out/share/icons/obsidian.ico
      '';
  });

  firefox = prev.firefox.overrideAttrs (oldAttrs: {
    postInstall =
      (oldAttrs.postInstall or "")
      + ''
        # Remove original icons
        rm -f $out/share/icons/hicolor/*/apps/firefox.png

        # Copy Firefox icons for different resolutions
        mkdir -p $out/share/icons/hicolor/64x64/apps
        cp -f ${../modules/shared/assets/firefox/firefox_nightly_64.png} $out/share/icons/hicolor/64x64/apps/firefox.png

        mkdir -p $out/share/icons/hicolor/72x72/apps
        cp -f ${../modules/shared/assets/firefox/firefox_nightly_72.png} $out/share/icons/hicolor/72x72/apps/firefox.png

        mkdir -p $out/share/icons/hicolor/96x96/apps
        cp -f ${../modules/shared/assets/firefox/firefox_nightly_96.png} $out/share/icons/hicolor/96x96/apps/firefox.png

        mkdir -p $out/share/icons/hicolor/128x128/apps
        cp -f ${../modules/shared/assets/firefox/firefox_nightly_128.png} $out/share/icons/hicolor/128x128/apps/firefox.png

        mkdir -p $out/share/icons/hicolor/256x256/apps
        cp -f ${../modules/shared/assets/firefox/firefox_nightly_256.png} $out/share/icons/hicolor/256x256/apps/firefox.png

        mkdir -p $out/share/icons/hicolor/512x512/apps
        cp -f ${../modules/shared/assets/firefox/firefox_nightly_512.png} $out/share/icons/hicolor/512x512/apps/firefox.png

        # Set the default icon (using the 256x256 version)
        cp -f ${../modules/shared/assets/firefox/firefox_nightly_256.png} $out/share/icons/hicolor/firefox.png
      '';
  });
}
