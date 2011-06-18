CREATE TABLE blocks (id serial primary key,
  found_stamp timestamp default now(),
  block_number integer)
