require_relative "../model/payout"
require 'pp'


def validate_address(address)
  cmd = "namecoind validateaddress #{address}"
  res = JSON.parse(%x{#{cmd}})
  res["isvalid"]
rescue => e
  warn e
  nil
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
  puts "#{total_shares} total shares, for #{50.0/total_shares} nmc per share per block"
  puts "Winner is #{nmc.username}, good job"
  print "About to pay out, everything look good?? "
  answer = $stdin.gets.chomp
  unless answer.match /^[Yy]/
    puts "Ok, stopping"
    exit
  end
  paid = 0
  paid_potential = 0
  puts "Paying out #{payout} nmc"
  #bonus logic
=begin
  if pay_nmc nmc.username, 5
    paid += 5
    payout -= 5
    print "BONUS PAID #{nmc.username} 5"
    NMC::Payout.create(:username => account, :amount => amount, :found_block => nmc[:id])
  end
=end
  payouts = work.map do |worker|
    percentage = worker[:good]/total_shares.to_f
    user, payment = worker[:username], payout*percentage
    paid_potential  += payment
    if paid_potential > (payout + 0.1)
      print "You've already calculated to pay out #{paid}, sure you want to continue? "
      ans  = $stdin.gets.chomp
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
  pp payouts

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
      puts "PAID #{user} #{amount}"
      NMC::Payout.create(:username => user, :amount => amount, :found_block => nmc[:id], :percentage => percentage)
    end
  end
  nmc.update(:paid => true, :pay_stop_stamp => Time.now)
  puts "Paid #{paid} nmc of #{payout}, leaving #{50-paid} profit"
end

if $0 == __FILE__
  unpaids = NMC::Shares.unpaid_winning_shares.order(:created_at.asc)

  print "There appear to be #{unpaids.count} unpaid blocks, this seem right? "

  answer = $stdin.gets.chomp
  puts

  if answer.to_s.match /^[Yy]/
    puts "Ok, paying out"
  else
    warn "Ok, backing out, Cap'n!"
    exit
  end
  unpaids.each do |nmc|
    puts "Paying for block on share ##{nmc}"
    nmc.update(:pay_start_stamp => Time.now)
    pay nmc
  end
end
