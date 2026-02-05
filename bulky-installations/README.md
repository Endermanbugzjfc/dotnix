# Bulky Installations

Packages that require a long installation or compile time are considered bulky and will be packaged as separate flakes under this directory.

To prevent unexpectedly long atomic system updates, specify intended flake inputs to update rather than runnig `nix flake update`.
Relevant shell aliases or commands should be created to enhance convenience.
