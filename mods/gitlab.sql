# Create a user for GitLab. (change $password to a real password)
#CREATE USER IF NOT EXISTS 'gitlab'@'localhost' IDENTIFIED BY '$password';

# Create the GitLab production database
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;

# Grant the GitLab user necessary permissopns on the table.
GRANT SELECT, LOCK TABLES, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER ON `gitlabhq_production`.* TO 'gitlab'@'localhost'  IDENTIFIED BY '$password';

# Quit the database session
\q

