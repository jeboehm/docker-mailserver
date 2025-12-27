<?php
$config = [];
$config['smtp_log'] = false;
$config['log_dir'] = '/opt/roundcube/logs';
$config['temp_dir'] = '/opt/roundcube/temp';
$config['imap_cache'] = 'apcu';
$config['db_dsnw'] = sprintf(
    'mysql://%s:%s@%s:%s/%s',
    getenv('MYSQL_USER'),
    getenv('MYSQL_PASSWORD'),
    getenv('MYSQL_HOST'),
    getenv('MYSQL_PORT'),
    getenv('MYSQL_DATABASE')
);
$config['default_host'] = 'tls://' . getenv('MDA_IMAP_ADDRESS');
$config['smtp_host'] = 'tls://' . getenv('MTA_SMTP_SUBMISSION_ADDRESS');
$config['smtp_user'] = '%u';
$config['smtp_pass'] = '%p';
$config['support_url'] = getenv('SUPPORT_URL');
$config['plugins'] = [
    'archive',
    'zipdownload',
    'managesieve',
];
$config['imap_conn_options'] = [
    'ssl' => [
        'verify_peer'       => false,
        'verify_peer_name'  => false,
        'allow_self_signed' => true,
    ],
];
$config['smtp_conn_options'] = [
    'ssl' => [
        'verify_peer'       => false,
        'verify_peer_name'  => false,
        'allow_self_signed' => true,
    ],
];
