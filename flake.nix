{
  description = "Build Docker images";

  inputs.nixpkgs.url = github:rvolosatovs/nixpkgs;
  # This fails with:
  # error: cannot get archive member name: Pathname cannot be converted from UTF-8 to current locale.
  # TODO: Figure out how to fix, probably requires upstream work in adding support for Windows here.
  #inputs.golang-windows-amd64.url = https://dl.google.com/go/go1.17.1.windows-amd64.zip;

  outputs = { self, nixpkgs }: with nixpkgs.legacyPackages.x86_64-linux; let
    # TODO: Covert these to flakes to simplify updates (that requires work in nixpkgs)
    # Eventually, we want to base these on disk images, similar how it's done in:
    # https://github.com/NixOS/nixpkgs/blob/1536a6f2f91bd0ec28284c38ed5b2d0ac0c38c50/pkgs/build-support/vm/default.nix
    alpine = dockerTools.pullImage {
      imageName = "alpine";
      imageDigest = "sha256:e1c082e3d3c45cccac829840a25941e679c25d438cc8412c2fa221cf1a824e6a";
      sha256 = "0m0rw2md4clcd2crfbbcz958gyipwgcq47k5kkzllgwcrszp0kzi";
    };
    windows-server-core-ltsc2022 = dockerTools.pullImage {
      imageName = "mcr.microsoft.com/windows/servercore";
      imageDigest = "sha256:591f3c76c17869b99700815aa259f728a92f4912dcd68bcce21b7e9a4309cda4";
      sha256 = "1ym73fbm5zpbpfpdk0aczjmbfhhadmhhv72rhdvn2gbynlxmrca3";
      os = "windows";
    };
    go-1_17-windows-amd64 = fetchzip {
      url = "https://dl.google.com/go/go1.17.1.windows-amd64.zip";
      sha256 = "01j7smkh1j3fsml7lvxnq7xb7f9ichig06ci83cnmg6alk0ay5m1";
    };
  in
    {
      packages.x86_64-linux = {
        golang = rec {
          latest = v1_17;

          v1_17 = dockerTools.buildLayeredImage {
            name = "golang";
            tag = "1.17";
            contents = go_1_17;
          };

          v1_17-alpine = dockerTools.buildLayeredImage {
            name = "golang";
            tag = "1.17-alpine";
            fromImage = alpine;
            contents = go_1_17;
          };

          v1_17-windowsservercore-ltsc2022 = dockerTools.buildLayeredImage {
            name = "golang";
            tag = "1.17-windowsservercore-ltsc2022";
            fromImage = windows-server-core-ltsc2022;
            # TODO: Figure out how to make downloaded go archive contents accessible in the image and set related environment variables.
            # Probably we can use QEMU here to boot into the windows image and perform install.
            contents = go-1_17-windows-amd64;
          };
        };

        golang-with-python = dockerTools.buildImage {
          name = "golang-with-python";
          tag = "latest"; # TODO: figure out how versioning would work here
          contents = [
            go_1_17
            (
              python.withPackages (
                pkgs: with pkgs; [
                  numpy
                ]
              )
            )
          ];
        };
      };
    };
}
