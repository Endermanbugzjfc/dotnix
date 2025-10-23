final: prev: {
  mkList = names: builtins.filter (name: name != "" && name != []) (builtins.split "[[:space:]]" names);
}
