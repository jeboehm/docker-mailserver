<?php

$config['managesieve_port'] = 4190;
$config['managesieve_host'] = '%h';
$config['managesieve_auth_type'] = 'PLAIN';
$config['managesieve_auth_cid'] = null;
$config['managesieve_auth_pw'] = null;
$config['managesieve_usetls'] = true;
$config['managesieve_conn_options'] = [
    'ssl' => [
        'verify_peer'       => false,
        'verify_peer_name'  => false,
        'allow_self_signed' => false,
    ],
];
$config['managesieve_default'] = '/etc/dovecot/sieve/global';
$config['managesieve_script_name'] = 'managesieve';
$config['managesieve_mbox_encoding'] = 'UTF-8';
$config['managesieve_replace_delimiter'] = '';
$config['managesieve_disabled_extensions'] = [];
$config['managesieve_debug'] = false;
$config['managesieve_kolab_master'] = false;
$config['managesieve_filename_extension'] = '.sieve';
$config['managesieve_filename_exceptions'] = [];
$config['managesieve_domains'] = [];
$config['managesieve_vacation'] = 0;
$config['managesieve_vacation_interval'] = 0;
$config['managesieve_vacation_addresses_init'] = false;
$config['managesieve_notify_methods'] = ['mailto'];
