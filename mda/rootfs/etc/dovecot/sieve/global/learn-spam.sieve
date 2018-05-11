require ["vnd.dovecot.pipe", "copy", "imapsieve"];
pipe :copy "rspamc" ["learnspam"];
