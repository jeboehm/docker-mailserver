<?php
$config = [];
$config['debug_level'] = 0;
$config['smtp_log'] = false;
$config['log_dir'] = '/tmp/';
$config['temp_dir'] = '/tmp/';
$config['imap_cache'] = 'apc';
$config['db_dsnw'] = sprintf(
    'mysql://%s:%s@%s/%s',
    getenv('MYSQL_USER'),
    getenv('MYSQL_PASSWORD'),
    getenv('MYSQL_HOST'),
    getenv('MYSQL_DATABASE')
);
$config['default_host'] = 'tls://' . getenv('MDA_HOST');
$config['smtp_server'] = 'tls://' . getenv('MTA_HOST');
$config['smtp_port'] = 25;
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['support_url'] = getenv('SUPPORT_URL');
$config['product_name'] = 'Webmail';
$config['des_key'] = 'rcmail-!24ByteDESkey*Str';
$config['plugins'] = [
    'archive',
    'zipdownload',
    'managesieve',
    'password',
];
$config['skin_logo'] = './ispmail-logo.png';
$config['imap_conn_options'] = [
    'ssl' => [
        'verify_peer'       => false,
        'verify_peer_name'  => false,
        'allow_self_signed' => false,
    ],
];
$config['smtp_conn_options'] = [
    'ssl' => [
        'verify_peer'       => false,
        'verify_peer_name'  => false,
        'allow_self_signed' => false,
    ],
];
