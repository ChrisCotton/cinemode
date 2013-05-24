create database if not exists cinemode;

use cinemode;

create table if not exists users(
  id                int           auto_increment,
  email             varchar(50)   not null,
  password_enable   boolean       default false,    -- user login with facebook may not have password
  password_hash     char(64)      default null,     -- SHA-256
  created_at        timestamp     default current_timestamp,

  primary key (id),
  index (email)
);

create table if not exists products(
  id            int             auto_increment,
  name          varchar(50)     not null,
  price         double          not null, 
  description   text            default "",
  like_count    int             default 0,    -- cache for users_like_products
  
  primary key(id)
);

create table if not exists users_like_products(
  user_id     int not null,
  product_id  int not null,
  
  
  index(user_id),
  index(product_id),
  foreign key(user_id)    references users(id)     on delete cascade,
  foreign key(product_id) references products(id)  on delete cascade 
);