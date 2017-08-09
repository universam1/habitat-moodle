{{#if cfg.app_username}}
DELETE FROM mysql.user WHERE USER LIKE '';
drop user {{cfg.app_username}};
FLUSH PRIVILEGES;
CREATE USER '{{cfg.app_username}}'@'%' IDENTIFIED BY '{{cfg.app_password}}';
GRANT ALL ON `%`.* TO {{cfg.app_username}}@`%`;
FLUSH PRIVILEGES;
DELETE FROM mysql.db WHERE db LIKE 'test%';
DROP DATABASE IF EXISTS test ;
{{/if}}