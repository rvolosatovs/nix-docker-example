{
  description = "Build Docker images";

  inputs.nixpkgs.url = github:rvolosatovs/nixpkgs;

  outputs = { self, nixpkgs }: with nixpkgs.legacyPackages.x86_64-linux; {
    packages.x86_64-linux.golang = dockerTools.buildImage {
      name = "golang";
      tag = "1.17";
      contents = go_1_17;
    };

    packages.x86_64-linux.golangWithPython = dockerTools.buildImage {
      name = "golang-with-python";
      tag = "latest"; # TODO: figure out how versioning would work here
      contents = [
        go_1_17
        (python.withPackages(pkgs: with pkgs; [
          numpy
        ]))
      ];
    };
  };
}
