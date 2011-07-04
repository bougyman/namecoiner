#!/bin/bash
PAYOUT=$1
. ~/.rvm/scripts/rvm
cd ~/g/namecoiner > /dev/null 2>&1
PAYOUT=${PAYOUT:-49} ruby ./bin/pay_out.rb
