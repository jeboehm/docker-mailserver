require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamc" ["learn_ham"];
