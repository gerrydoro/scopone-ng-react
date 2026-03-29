{
  lib,
  buildGoModule,
  go_1_24,
}:

buildGoModule rec {
  pname = "scopone-server";
  version = "2.0.0";

  go = go_1_24;

  src = lib.cleanSourceWith {
    src = ../server;
    filter =
      path: type:
      let
        relPath = lib.removePrefix (toString ../server + "/") (toString path);
      in
      !(lib.hasPrefix "." (baseNameOf relPath) && relPath != "go.mod" && relPath != "go.sum");
  };

  vendorHash = "sha256-nqsHINT9MUH7w4Atmeiz89V5r1xJHqyrcfcObg9hfG4=";

  subPackages = [ "src/cmd/scopone-in-memory-only" ];

  meta = with lib; {
    description = "Scopone - A traditional Italian card game server (in-memory mode)";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
    mainProgram = "scopone-in-memory-only";
  };
}
