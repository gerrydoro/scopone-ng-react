{ lib, buildGo124Module }:

buildGo124Module rec {
  pname = "scopone-server";
  version = "2.0.0";

  src = lib.cleanSourceWith {
    src = ../server;
    filter = path: type: 
      let
        relPath = lib.removePrefix (toString ../server + "/") (toString path);
      in
        !(lib.hasPrefix "." (baseNameOf relPath) && 
          relPath != "go.mod" && 
          relPath != "go.sum");
  };

  vendorHash = "sha256-RGiTwSGf3G/x7MmUP/CDDMMXY5En2E/k7m+h6OCsbaw=";

  subPackages = [ "src/cmd/scopone-mongo" ];

  meta = with lib; {
    description = "Scopone - A traditional Italian card game server";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
    mainProgram = "scopone-mongo";
  };
}
