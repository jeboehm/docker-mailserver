<?php

$config['password_driver'] = 'sql';
$config['password_confirm_current'] = true;
$config['password_minimum_length'] = 6;
$config['password_require_nonalpha'] = false;
$config['password_log'] = false;
$config['password_login_exceptions'] = null;
$config['password_hosts'] = null;
$config['password_force_save'] = true;
$config['password_force_new_user'] = false;
$config['password_algorithm'] = 'clear';
$config['password_algorithm_prefix'] = '';
$config['password_blowfish_cost'] = 12;
$config['password_disabled'] = false;
$config['password_db_dsn'] = sprintf(
    'mysql://%s:%s@%s:%s/%s',
    getenv('MYSQL_USER'),
    getenv('MYSQL_PASSWORD'),
    getenv('MYSQL_HOST'),
    getenv('MYSQL_PORT'),
    getenv('MYSQL_DATABASE')
);
$config['password_query'] = "UPDATE mail_users JOIN mail_domains ON mail_users.domain_id = mail_domains.id SET password=CONCAT('{SHA256-CRYPT}', ENCRYPT (%p, CONCAT('$5$', SUBSTRING(SHA(RAND()), -16)))) WHERE CONCAT(mail_users.name, '@', mail_domains.name)=%u;";
$config['password_crypt_hash'] = 'md5';
$config['password_idn_ascii'] = false;
$config['password_dovecotpw_with_method'] = false;
$config['password_hash_algorithm'] = 'sha1';
$config['password_hash_base64'] = false;
