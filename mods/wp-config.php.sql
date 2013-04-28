## CREATE NEW USER ##
CREATE USER wordpress@localhost IDENTIFIED BY "<WP PASSWORD>";

## CREATE NEW DATABASE ##
CREATE DATABASE wordpress_blog;

## GRANT needed permissions ##
GRANT ALL ON wordpress_blog.* TO wordpress@localhost;

## FLUSH privileges ##
FLUSH PRIVILEGES;

## Exit ##
exit

