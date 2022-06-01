require ["vnd.dovecot.pipe", "copy", "imapsieve", "vnd.dovecot.environment", "variables"];
pipe :copy "rspamc" ["learnspam", "${env.vnd.dovecot.config.filter_host}", "${env.vnd.dovecot.config.controller_password}"];
