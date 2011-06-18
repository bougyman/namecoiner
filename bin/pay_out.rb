require_relative "../model/payout"

unpaids = NMC::Shares.unpaid_winning_shares

print "There appear to be #{unpaids.count} unpaid blocks, this seem right? "

answer = $stdin.gets.chomp
puts

if answer.to_s.match /^[Yy]/
  puts "Ok, paying out"
else
  warn "Ok, backing out, Cap'n!"
  exit
end

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

def pay(nmc)
  paid = 0
  work = NMC::Shares.won_shares_for(nmc)
  puts "#{work.count} users on this block"
  total_shares = work.inject(0) { |a,b| a + b[:good] }
  puts "#{total_shares} total shares, for #{50.0/total_shares} nmc per block"
  puts "Winner is #{nmc.username}, lets get that 5 out first"
  #if pay_nmc nmc.username, 5
  #  paid += 5
  #  print "PAID #{nmc.username} 5"
  #  NMC::Payout.create(:username => account, :amount => amount, :found_block => nmc[:id])
  #end
  puts "Now we'll pay shares"
  work.each do |worker|
    percentage = worker[:good]/total_shares.to_f
    user, payment = worker[:username], 44*percentage
    paid += payment
    if paid > 45
      print "You've already paid out #{paid}, sure you want to continue? "
      ans  = $stdin.gets.chomp
      if ans =~ /^y/i
        puts "Your call, Santa"
      else
        puts "Good choice, see what's up"
        exit
      end
    end
    if pay_nmc user, payment
      puts "PAID #{user} #{payment}"
      NMC::Payout.create(:username => user, :amount => payment, :found_block => nmc[:id], :percentage => percentage)
    end
  end
  nmc.update(:paid => true, :pay_stop_stamp => Time.now)
  puts "Paid #{paid} nmc"
end

unpaids.each do |nmc|
  nmc.update(:pay_start_stamp => Time.now)
  pay nmc
end
