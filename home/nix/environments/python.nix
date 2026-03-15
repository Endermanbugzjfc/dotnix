{ pkgs, ... }: {
  home.packages = with pkgs; [
    (python3.withPackages (python-pkgs: with python-pkgs; [
      tkinter # For IDLE.
      httpserver # For TryHackMe rooms.
    ]))
  ];
}
