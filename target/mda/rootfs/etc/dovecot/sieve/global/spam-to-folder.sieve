require "fileinto";

if header :contains "X-Spam" "Yes" {
    fileinto "Junk";
    stop;
}
