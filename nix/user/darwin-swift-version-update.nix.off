final: prev: {
  swift = prev.swift.overrideAttrs (oldAttrs: {
    version = "5.10.1";
    src = final.fetchurl {
      url = "https://download.swift.org/swift-5.10.1-release/xcode/swift-5.10.1-RELEASE/swift-5.10.1-RELEASE-osx.pkg";
      sha256 = "c4e1d693d48c7ffd67724b74ffcbdca0aca05b37d2c41649aab13d2c649d19e7";
    };
  });
}
