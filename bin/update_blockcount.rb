#!ruby
require "sequel"
require "file/tail"

DB=Sequel.connect("postgres://localhost/namecoin")
class BlockCount
  def self.last
    DB["SELECT block_number, found_stamp from blocks order by found_stamp desc limit 1"].first
  end
end

if $0 == __FILE__
  current = %x{~/bin/namecoind getblockcount}.to_i
  if last = BlockCount.last
    if last[:block_number].to_i < current
      puts "Updating block count from #{last[:block_number]} to #{current}"
      DB.execute("INSERT INTO blocks (block_number) VALUES (#{current})")
    end
  else
    puts "Starting block count at #{current}"
    DB.execute("INSERT INTO blocks (block_number) VALUES (#{current})")
  end
  puts "Current block count: #{current}"
end
