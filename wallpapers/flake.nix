{
  description = ''
    https://github.com/Endermanbugzjfc/dotnix | Unlicense
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    autum-leaves.url = "https://cdn.discordapp.com/attachments/1266209560234823720/1317688531170099220/autumn_leaves.jpg?ex=68f30393&is=68f1b213&hm=8956177eb2c64e0c0c6cee594eca3103734186a89f51ecfb11c752f0a9759b7c&";
    mount.url = "https://cdn.discordapp.com/attachments/1266209560234823720/1317688534001258527/mount.jpg?ex=68f30393&is=68f1b213&hm=4b67f1dd7c8a42770d9a5e98ef821cb1fe8e7bce328a216d250f42c3ea80979d&";
    planetary-industry.url = "https://cdn.discordapp.com/attachments/1266209560234823720/1343978219619221504/wallhaven-3ldrjd.jpg?ex=68f31301&is=68f1c181&hm=1a7b0e610b7788909409d7fcc0310b9dd7d0dc0f847cc0fe90cb4e0f0b8ba728&";
    autum-trees.url = "https://cdn.discordapp.com/attachments/1266209560234823720/1351835324623360090/pexels-thatguycraig000-1563355.jpg?ex=68f2a781&is=68f15601&hm=c97c4befb0dd2428a9c50aa1cc668ee17caca296c978b6992e14114a47d4624c&";
    rocket-shine.url = "https://cdn.discordapp.com/attachments/1266209560234823720/1380273089882886164/f0mpjw4ddzv41.png?ex=68f29e7c&is=68f14cfc&hm=89e6dfac559099f9dad5ce0309f8091bba1766bee7dfa3052c7d6577e60819f6&";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,

    autum-leaves,
    mount,
    planetary-industry,
    autum-trees,
    rocket-shine,
  }: flake-utils.lib.eachDefaultSystem (system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    packages.default = pkgs.stdenvNoCC.mkDerivation {
      installPhase = ''
        mkdir -p $out/share
        install -Dm644 ${autum-leaves} $out/share/autum-leaves.jpg
        install -Dm644 ${mount} $out/share/mount.jpg
        install -Dm644 ${planetary-industry} $out/share/planetary-industry.jpg
        install -Dm644 ${autum-trees} $out/share/autum-trees.jpg

        install -Dm644 ${rocket-shine} $out/share/rocket-shine.png
      '';

      meta = with pkgs.lib; {
        license = with licenses; unfree;
      };
    };
  });
}
