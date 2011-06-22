#!/bin/bash
PAYOUT=$1
. ~/.rvm/scripts/rvm
cd ~/g/namecoiner > /dev/null 2>&1
PAYOUT=${PAYOUT:-50} ruby ./bin/pay_out.rb
