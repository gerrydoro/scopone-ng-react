{ lib, buildGo124Module }:

buildGo124Module  {
  pname = "scopone-server";
  version = "2.0.0";

  src = lib.cleanSourceWith {
    src = ../server;
    filter = path: type: 
      let
        baseName = baseNameOf (toString path);
      in
        !(baseName == ".vscode" || 
          lib.hasSuffix ".md" baseName ||
          (lib.hasPrefix "." baseName && baseName != "go.mod" && baseName != "go.sum"));
  };

  vendorHash = "sha256-RGiTwSGf3G/x7MmUP/CDDMMXY5En2E/k7m+h6OCsbaw=";

  subPackages = [ "src/cmd/scopone-mongo" ];

  meta = with lib; {
    description = "Scopone - A traditional Italian card game server";
    homepage = "https://github.com/gerardo/scopone-ng-react";
    license = licenses.mit;
    maintainers = [ maintainers.gerardo ];
    mainProgram = "scopone-app";
  };
}
