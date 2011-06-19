CREATE TABLE news (id serial primary key,
  username text not null,
  excerpt text not null,
  body text not null,
  title text not null,
  urgency integer default 0,
  created_at timestamp default now())
