#!/bin/bash
. ~/.rvm/scripts/rvm
cd ~/g/namecoiner > /dev/null 2>&1
ruby ./bin/update_blockcount.rb
