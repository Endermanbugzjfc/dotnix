{ pkgs, ... }: {
  home.packages = with pkgs; [
    cargo
    rust-analyzer
    lspmux # Rust-analyzer multiplexer
  ];
}
