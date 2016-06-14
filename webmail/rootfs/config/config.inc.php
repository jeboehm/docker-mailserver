<?php
$config = array();
$config['db_dsnw'] = sprintf('mysql://%s:%s@%s/%s', getenv('MYSQL_USER'), getenv('MYSQL_PASSWORD'), getenv('MYSQL_HOST'), getenv('MYSQL_DATABASE'));
$config['default_host'] = 'mda';
$config['smtp_server'] = 'mta';
$config['smtp_port'] = 25;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['support_url'] = 'https://github.com/jeboehm/docker-mailserver';
$config['product_name'] = 'Webmail';
$config['des_key'] = 'rcmail-!24ByteDESkey*Str';
$config['plugins'] = array(
    'archive',
    'zipdownload',
    'managesieve',
    'password',
);
$config['skin'] = 'larry';
$config['session_lifetime'] = 60;
$config['skin_logo'] = './ispmail-logo.png';
