<?php

function areValidArgs($argv, $argc) {
    if ($argc === 2) {
        return true;
    }
    if ($argc === 3) {
        switch ("--dry") {
            case $argv[1]:
            case $argv[2]:
                return true;
        }
    }

    return false;
}

function shouldDryRun($argv, $argc) {
    return $argc === 3;
}

if (!areValidArgs($argv, $argc)) {
    echo "Please enter exactly one URL and optionally the --dry flag\n";
    exit(1);
}

$url = null;
foreach ([
    $argv[2] ?? "",
    $argv[1],
] as $argn => $check) {
    if (!filter_var($check, FILTER_VALIDATE_URL)) {
        if ($argn === 1) {
            echo "Invalid URL: $check\n";
            exit(1);
        }
    } else {
        $url = $check;
        break;
    }
}

// Sample:
// https://gitlab.cse.unsw.edu.au/coursework/comp1531/26t1/groups/W09B_EAGLE/project-backend
// git@gitlab.cse.unsw.edu.au:coursework/comp1531/26t1/groups/W09B_EAGLE/project-backend.git

$parts = explode("/", $url);
array_shift($parts); // "https:/"
array_shift($parts); // "/"
$host = array_shift($parts); // "/"
$repo = implode("/", $parts);
if (!str_ends_with($repo, ".git")) {
    $repo .= ".git";
}

$ssh = "git@$host:$repo";
echo $ssh;
if (shouldDryRun($argv, $argc)) {
    return;
}

echo "\n";
system("git clone $ssh");

