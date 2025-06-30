{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

        # canup = pkgs.writeShellScript
        in
      with builtins;
       {

        devShells.default = pkgs.mkShell {
          name = "sound-camera";
          packages = with pkgs; [
            gcc-arm-embedded
            bear
            cmake
            gcc
            gdb
            zig
            zls
            python3Packages.python-can
            (writeShellScriptBin "canup"  ''
            sudo ip link set can0 type can bitrate 1000000
            sudo ip link set up can0
            '')
            (writeShellScriptBin "vcanup"  ''
            sudo ip link add dev vcan0 type vcan
            sudo ip link set up vcan0
            '')
            (writeScriptBin "candump-fmt" ''
            #!${pkgs.python3}/bin/python3
            import sys

            for line in sys.stdin:
                print(" ".join((line[0:line.find("[") - 3] + "#").split()), end = "")
                print(line[line.find("]") + 1: -1].replace(" ", ""))
            '')

            (writeShellScriptBin "sshcan" ''
            vcanup
            ssh $1 candump -ta $2 | candump-fmt | canplayer -v vcan0=$2
            '')
          ] ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux [
            stm32cubemx
            openocd
            can-utils
          ];
          
        };
      }
    );
}
