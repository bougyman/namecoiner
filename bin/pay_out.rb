require_relative "../model/payout"
require 'pp'


def validate_address(address)
  if EXCLUDE_PAYEES.include?(address)
    puts "Not paying #{address}, you put it in EXCLUDE_PAYEES"
    return nil
  end
  cmd = "namecoind validateaddress #{address}"
  res = JSON.parse(%x{#{cmd}})
  res["isvalid"]
rescue => e
  warn e
  nil
end

def validate_namecoind # Make sure namecoind is in path
  cmd = "namecoind getinfo"
  %x{#{cmd}}
  if $? != 0
    warn "namecoind test failed, make sure it is in your PATH"
    exit 127
  end
end

def pay_nmc(account, amount)
  if validate_address(account)
    puts "Sending #{amount} to #{account}"
    cmd = "namecoind sendfrom \"\" #{account} #{amount}"
    p cmd
    output = %x{#{cmd}}
    res = $?
    if res != 0
      print "Payment Unsuccessful #{output}, wanna stop? "
      answer = $stdin.gets.chomp
      if answer.match /^[Yy]/
        puts "Ok, stopping"
        exit
      end
      return false
    end
  else
    puts "#{account} didn't validate, not sending"
    return false
  end
  true
end

def pay(nmc, payout = 49.0)
  work = NMC::Shares.won_shares_for(nmc[:id])
  puts "#{work.count} users on this round"

  total_shares = work.inject(0) { |a,b| a + b[:good] }
  puts "#{total_shares} total shares, for #{payout/total_shares} nmc per share per block"
  puts "Winner is #{nmc.username}, good job"

  print "About to pay out, everything look good?? "
  answer = $stdin.gets
  unless answer =~ /^y/i
    puts "Ok, stopping"
    exit
  end

  paid = 0
  paid_potential = 0
  paid_potential_max = payout + 0.1

  puts "Paying out #{payout} nmc"

  payouts = work.map do |worker|
    user = worker[:username]
    worker_shares = worker[:good].to_i
    percentage = Rational(100, total_shares) * worker_shares
    payment = payout * Rational(worker_shares, total_shares)

    paid_potential += payment

    if paid_potential > paid_potential_max
      p paid_potential: paid_potential, allowed: paid_potential_max
      print "You've already calculated to pay out #{paid}, sure you want to continue? "

      ans = $stdin.gets
      if ans =~ /^y/i
        puts "Your call, Santa"
      else
        puts "Good choice, see what's up"
        exit
      end
    end

    [user, payment, percentage]
  end

  # ask questions
  payouts.each do |data|
    puts "%40s | %11.8f (%11.8f%%)" % data
  end

  print "Does this look kosher? "
  ans  = $stdin.gets.chomp
  if ans =~ /^y/i
    puts "Already, here go the payments!"
  else
    puts "Alright, giving up, fix your shit, users are waiting!"
    exit
  end

  payouts.each do |payment|
    user, amount, percentage = payment
    if pay_nmc user, amount
      paid += amount
      puts "PAID #{user} #{amount} (#{"%11.8f" % percentage})"
      NMC::Payout.create(:username => user, :amount => amount, :found_block => nmc[:id], :percentage => percentage.to_f)
    end
  end
  nmc.update(:paid => true, :pay_stop_stamp => Time.now)
  puts "Paid #{paid} nmc of #{payout}, leaving #{payout-paid} in unpaid shares"
end

if $0 == __FILE__
  validate_namecoind # make sure namecoind is available before we care about the rest
  if ENV["EXCLUDE_PAYEES"]
    EXCLUDE_PAYEES=ENV["EXCLUDE_PAYEES"].split(":")
    warn "Excluding addresses #{EXCLUDE_PAYEES} from payout!"
  else
    EXCLUDE_PAYEES=[]
  end

  unpaids = NMC::Shares.unpaid_winning_shares.order(:created_at.asc)
  print "There appear to be #{unpaids.count} unpaid blocks, this seem right? "

  answer = $stdin.gets.chomp
  puts

  if answer.to_s.match /^[Yy]/
    puts "Ok, paying out #{ENV["PAYOUT"]}"
  else
    warn "Ok, backing out, Cap'n!"
    exit
  end

  payout = ENV["PAYOUT"].to_f
  unpaids.each do |nmc|
    nmc_balance = `~/bin/namecoind getbalance ""`.to_f
    puts "Our balance is #{nmc_balance}"

    if nmc_balance < payout
      puts "Not enough funds to pay another block"
      exit
    end

    puts "just in case, hit enter to continue -> Point of No Return, here."
    gets
    puts "Paying for block on share ##{nmc}"
    nmc.update(:pay_start_stamp => Time.now)
    pay nmc, payout
  end
end
