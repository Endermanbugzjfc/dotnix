{ lib' }: let
  inherit (lib') enableMultiWith enableMulti;
in {
  enableMulti = {
    testEmpty = {
      expr = enableMulti "";
      expected = {};
    };
    testRegular = {
      expr = enableMulti ''
        There ain't no mistaking
        It's true love we're making
      '';
      expected = {
        There = { enable = true; };
        ain't = { enable = true; };
        no = { enable = true; };
        mistaking = { enable = true; };
        It's = { enable = true; };
        true = { enable = true; };
        love = { enable = true; };
        we're = { enable = true; };
        making = { enable = true; };
      };
    };
    testDupe = {
      expr = enableMulti ''
        Lorem ipsum dolor sit amet consectetur adipiscing elit.

        Dolor sit amet consectetur adipiscing elit quisque faucibus.
      '';
      expected = {
        Lorem = { enable = true; };
        ipsum = { enable = true; };
        dolor = { enable = true; };
        sit = { enable = true; };
        amet = { enable = true; };
        consectetur = { enable = true; };
        adipiscing = { enable = true; };
        "elit." = { enable = true; };
        Dolor = { enable = true; };
        elit = { enable = true; };
        quisque = { enable = true; };
        "faucibus." = { enable = true; };
        # unit-test specfic behaviour:
        "enable-multi has duplicated names: \"adipiscing\", \"amet\", \"consectetur\", \"sit\"" = { enable = true; };
      };
    };
  };

  enableMultiWith = {
    testOverride = {
      expr = enableMultiWith { enable = false; } ''
        There ain't no mistaking
        It's true love we're making
      '';
      expected = {
        There = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
        ain't = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
        no = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
        mistaking = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
        It's = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
        true = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
        love = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
        we're = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
        making = {
          enable = true;
          # unit-test specfic behaviour:
          "_warn" = "enable-multi-with will override the attr `enable`: false";
        };
      };
    };
  };
}
