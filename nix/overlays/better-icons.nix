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

#let
#  installIcons = {
#    name,
#    pngSizes ? [],
#    svgPath ? null,
#    icnsPath ? null,
#    icoPath ? null,
#    defaultIconSize ? null,
#    pngPathTemplate ? ../modules/shared/assets/${name}/${name}_SIZE.png,
#    svgPathTemplate ? ../modules/shared/assets/${name}/${name}.svg,
#    icnsPathTemplate ? ../modules/shared/assets/${name}/${name}.icns,
#    icoPathTemplate ? ../modules/shared/assets/${name}/${name}.ico
#  }: ''
#    # Remove original icons if they exist
#    rm -f $out/share/icons/hicolor/*/apps/${name}.*
#
#    ${builtins.concatStringsSep "\n" (map (size: ''
#      mkdir -p $out/share/icons/hicolor/${toString size}x${toString size}/apps
#      cp -f ${builtins.replaceStrings ["SIZE"] [toString size] (toString pngPathTemplate)} $out/share/icons/hicolor/${toString size}x${toString size}/apps/${name}.png
#    '') pngSizes)}
#
#    ${if svgPath != null then ''
#      mkdir -p $out/share/icons/hicolor/scalable/apps
#      cp -f ${svgPath} $out/share/icons/hicolor/scalable/apps/${name}.svg
#    '' else if svgPathTemplate != null then ''
#      mkdir -p $out/share/icons/hicolor/scalable/apps
#      cp -f ${svgPathTemplate} $out/share/icons/hicolor/scalable/apps/${name}.svg
#    '' else ""}
#
#    ${if icnsPath != null then ''
#      mkdir -p $out/Applications/${name}.app/Contents/Resources
#      cp -f ${icnsPath} $out/Applications/${name}.app/Contents/Resources/${name}.icns
#    '' else if icnsPathTemplate != null then ''
#      mkdir -p $out/Applications/${name}.app/Contents/Resources
#      cp -f ${icnsPathTemplate} $out/Applications/${name}.app/Contents/Resources/${name}.icns
#    '' else ""}
#
#    ${if icoPath != null then ''
#      mkdir -p $out/share/icons
#      cp -f ${icoPath} $out/share/icons/${name}.ico
#    '' else if icoPathTemplate != null then ''
#      mkdir -p $out/share/icons
#      cp -f ${icoPathTemplate} $out/share/icons/${name}.ico
#    '' else ""}
#
#    ${if defaultIconSize != null then ''
#      cp -f ${builtins.replaceStrings ["SIZE"] [toString defaultIconSize] (toString pngPathTemplate)} $out/share/icons/hicolor/${name}.png
#    '' else ""}
#  '';
#
#in
#{
#  alacritty = prev.alacritty.overrideAttrs (oldAttrs: {
#    postInstall = (oldAttrs.postInstall or "") + (installIcons {
#      name = "alacritty";
#      pngSizes = [ 64 256 512 ];
#      defaultIconSize = 512;
#      pngPathTemplate = ../modules/shared/assets/alacritty/flat/alacritty_flat_SIZE.png;
#    });
#  });
#
#  obsidian = prev.obsidian.overrideAttrs (oldAttrs: {
#    postInstall = (oldAttrs.postInstall or "") + (installIcons {
#      name = "obsidian";
#      pngSizes = [ 256 512 ];
#      svgPath = ../modules/shared/assets/obsidian/obsidian-icon.svg;
#      icnsPath = ../modules/shared/assets/obsidian/obsidian-icon.icns;
#      icoPath = ../modules/shared/assets/obsidian/obsidian-icon.ico;
#    });
#  });
#
#  firefox = prev.firefox.overrideAttrs (oldAttrs: {
#    postInstall = (oldAttrs.postInstall or "") + (installIcons {
#      name = "firefox";
#      pngSizes = [ 64 72 96 128 256 512 ];
#      defaultIconSize = 256;
#      pngPathTemplate = ../modules/shared/assets/firefox/firefox_nightly_SIZE.png;
#    });
#  });
#}
