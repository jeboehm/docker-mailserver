require ["fileinto", "mailbox"];

if header :contains "X-Spam" "Yes" {
    fileinto :create "Junk";
    stop;
}

if header :contains "X-Is-Spam" "Yes" {
    fileinto :create "Junk";
    stop;
}
