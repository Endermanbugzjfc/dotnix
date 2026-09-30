#!/usr/bin/env php
<?php
// Sshclone accepts an HTTPS repository URL but clones it via SSH.
// This is useful when your Git is authenticated with SSH but not HTTPS.
// Optional dry run via --dry argument.

// Example (UNSW GitLab):
// $ sshclone --dry https://gitlab.cse.unsw.edu.au/coursework/comp1531/26t1/groups/W09B_EAGLE/project-backend
// git@gitlab.cse.unsw.edu.au:coursework/comp1531/26t1/groups/W09B_EAGLE/project-backend.git
//
// Example (official GitLab):
// $ sshclone --dry https://gitlab.com/zjfc/ezjfc
// git@gitlab.com:zjfc/ezjfc.git
//
// Example (official GitHub):
// $ sshclone --dry https://github.com/Ezjfc/Ezjfc
// git@github.com:Ezjfc/Ezjfc.git

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

$parts = explode("/", $url);
array_shift($parts); // "https:/"
array_shift($parts); // "/"
$host = array_shift($parts); // "/"
$repo = implode("/", $parts);
if (!str_ends_with($repo, ".git")) {
    $repo .= ".git";
}

$unsafeSsh = "git@$host:$repo";
echo $unsafeSsh;
if (shouldDryRun($argv, $argc)) {
    return;
}

echo "\n";
$ssh = escapeshellarg($unsafeSsh);
$status = 0;
system("git clone $ssh", $status);
exit($status);

