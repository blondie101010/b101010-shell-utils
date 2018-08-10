#!/bin/bash

cd /tmp
rm -rf b101010-shell-utils
mkdir b101010-shell-utils

wget https://github.com/blondie101010/b101010-shell-utils/archive/master.tar.gz

tar -xzf master.tar.gz
cp b101010-shell-utils-master/b101010* /usr/local/lib/.

rm -rf b101010-shell-utils
