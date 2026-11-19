#!/bin/bash

dnf install -y httpd         # Install the Apache httpd server

systemctl enable --now httpd  # Start the Apache httpd server now and on every reboot

echo "<h1>Hello Cloud Learners</h1>" > /var/www/html/index.html  # Write the custom page into Apache's httpd web root

curl http://localhost     # Test locally with local host and prints the page if everything worked
