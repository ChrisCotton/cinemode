create database if not exists cinemode;

use cinemode;

-- ### Properties
-- + single row table
-- create table configuration(
  
-- );

create table if not exists users(
  id                int           auto_increment,
  email             varchar(50)   unique not null,
  is_admin          boolean       default false,
  password_enable   boolean       default false,    -- user login with facebook may not have password
  password_hash     char(64)      default null,     -- SHA-256
  created_at        timestamp     default current_timestamp,
 
  primary key (id),
  index(email)
);

create table if not exists products(
  id            int             auto_increment,
  name          varchar(50)     not null,
  price         double          not null, 
  image_url     text            not null,
  description   text            default "",
  like_count    int             default 0,    -- cache for users_like_products
  
  primary key(id)
);

create table if not exists videos(
  id            int               auto_increment,
  url           text              not null,
  description   text              default "",
  
  primary key(id)
);

-- ### Properties
-- + there is always a identifer for public
create table group(
  id            int               auto_increment,
  identifier    varchar(50)       not null,
  
  primary key(id),
  index(indentifier)
)

create table groups_of_videos(
  group_id
);

-- ### Constraints
-- + add/remove row should update products.like_count
--      select count(*) from users_like_products where product_id = x == select like_count from products where id = x
create table if not exists users_like_products(
  user_id     int not null,
  product_id  int not null,
  
  index(user_id),
  index(product_id),
  foreign key(user_id)    references users(id)     on delete cascade,
  foreign key(product_id) references products(id)  on delete cascade 
);

create table if not exists products_in_videos(
  video_id    int       not null,
  product_id  int       not null,
  start_time  double    not null,     -- duration of showing video
  end_time    double    not null,     
  rank        int       default 0,    -- for sorting from top to bottom
  
  index(video_id),
  index(product_id),
  foreign key(video_id)   references videos(id)     on delete cascade,
  foreign key(product_id) references products(id)   on delete cascade
);
