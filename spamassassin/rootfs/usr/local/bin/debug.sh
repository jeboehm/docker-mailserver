#!/bin/sh

echo asd > /tmp/spam
spamassassin -t -D < /tmp/spam
rm /tmp/spam
