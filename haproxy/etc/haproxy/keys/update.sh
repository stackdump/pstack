
# hacky script to make haproxy work
cat /etc/letsencrypt/live/your.domain.example.com/fullchain.pem /etc/letsencrypt/live/your.domain.example.com/privkey.pem > letsencrypt.pem
