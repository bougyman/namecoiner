ALTER TABLE shares ADD COLUMN paid BOOLEAN NOT NULL default false;
ALTER TABLE shares ADD COLUMN pay_start_stamp timestamp default now();
ALTER TABLE shares ADD COLUMN pay_stop_stamp timestamp;
