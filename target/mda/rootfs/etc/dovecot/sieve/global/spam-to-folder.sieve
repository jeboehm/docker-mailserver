require "fileinto";

if header :contains "X-Spam" "Yes" {
    fileinto :create "Junk";
    stop;
}
