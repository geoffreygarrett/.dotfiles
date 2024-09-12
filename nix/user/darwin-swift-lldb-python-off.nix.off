final: prev: {
  swift = prev.swift.overrideAttrs (oldAttrs: {
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ [
      "-DLLDB_ENABLE_PYTHON=OFF"
    ];
  });
}
