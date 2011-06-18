CREATE TABLE payout (id serial primary key,
  found_block integer references shares (id) ON DELETE SET NULL ON UPDATE CASCADE,
  username text,
  amount decimal,
  percentage decimal,
  paid_at timestamp default now())
