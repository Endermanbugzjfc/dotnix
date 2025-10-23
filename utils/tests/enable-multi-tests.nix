{ lib' }: with lib'; {
  testEmpty = {
    expr = enableMulti "";
    expected = {};
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
      "enable-multi has duplicated names: adipiscing, amet, consectetur, sit" = { enable = true; };
    };
  };
}
