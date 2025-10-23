{ lib' }: let
  inherit (lib') warnDupe;
in {
  warnDupe = {
    testEmpty = {
      expr = warnDupe [] "testEmpty";
      expected = [];
    };
    testNoDupe = {
      expr = warnDupe [ "a" "b" ] "testNoDupe";
      expected = [ "a" "b" ];
    };
    testDupeSingle = {
      expr = warnDupe [ "a" "a" ] "testDupeSingle";
      expected = [
        "a" "a"
        "testDupeSingle: \"a\"" # unit-test specfic behaviour.
      ];
    };
    testDupeMany = {
      expr = warnDupe [ "a" "a" "b" "b" "a" ] "testDupeMany";
      expected = [
        "a" "a" "b" "b" "a"
        "testDupeMany: \"a\", \"b\"" # unit-test specfic behaviour.

      ];
    };
    testMixed = {
      expr = warnDupe [ "d" "b" "c" "d" "a" "a" "a" ] "testMixed";
      expected = [
        "d" "b" "c" "d" "a" "a" "a"
        "testMixed: \"a\", \"d\"" # unit-test specfic behaviour.
      ];
    };
  };
}
