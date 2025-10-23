{ lib' }: let
  inherit (lib') mkList;
in {
  mkList = {
    testEmpty = {
      expr = mkList "";
      expected = [];
    };
    testRegular = {
      expr = mkList ''
        There ain't no mistaking
        It's true love we're making
      '';
      expected = [
        "There" "ain't" "no" "mistaking"
        "It's" "true" "love" "we're" "making"
      ];
    };
    testDupe = {
      expr = mkList ''
        Lorem ipsum dolor sit amet consectetur adipiscing elit.

        Dolor sit amet consectetur adipiscing elit quisque faucibus.
      '';
      expected = [
        "Lorem" "ipsum" "dolor" "sit" "amet" "consectetur" "adipiscing" "elit."

        "Dolor" "sit" "amet" "consectetur" "adipiscing" "elit" "quisque" "faucibus."
      ];
    };
  };
}
