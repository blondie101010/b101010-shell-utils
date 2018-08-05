# b101010-shell-utils

Shell scripting utilities

These are meant to simplify recurring shell scripting tasks and to normalize service control over various operating systems.

## Installation

It is strongly suggested to place these files in `/usr/local/lib` so that any script that uses them as dependencies can rely on their consistent position.

You can simply use the following commands to install it from the command line:

    wget https://github.com/blondie101010/b101010-shell-utils/archive/master.tar.gz
    tar -xzf master.tar.gz
    cp b101010-shell-utils-master/b101010* /usr/local/lib/.
    rm -rf b101010-shell-utils-master master.tar.gz

## Status

This package is currently in testing phase and is not ready for production yet!

That said, so far it works well on most CentOS, Gentoo, and Ubuntu systems tested.
