data "aws_ami" "ubuntu" {
  most_recent = true

  owners = [
    "099720109477"
  ]

  filter {
    name = "name"

    values = [
      "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  app_user_data = <<-EOF
#!/bin/bash

set -e

apt-get update

apt-get install -y nodejs npm

mkdir -p /opt/employee-api

cat > /opt/employee-api/package.json <<'PACKAGE'
${file("${path.module}/../backend/package.json")}
PACKAGE

cat > /opt/employee-api/server.js <<'SERVER'
${file("${path.module}/../backend/server.js")}
SERVER

cd /opt/employee-api

npm install --omit=dev

cat > /etc/systemd/system/employee-api.service <<'SERVICE'
[Unit]
Description=Employee Management Node.js API
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/opt/employee-api
ExecStart=/usr/bin/node /opt/employee-api/server.js
Restart=always
RestartSec=5

Environment=PORT=3000
Environment=DB_HOST=${aws_db_instance.mysql.address}
Environment=DB_PORT=3306
Environment=DB_USER=${var.db_user}
Environment=DB_PASSWORD=${var.db_password}
Environment=DB_NAME=${var.db_name}

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload

systemctl enable employee-api

systemctl start employee-api
EOF

  web_user_data = <<-EOF
#!/bin/bash

set -e

apt-get update

apt-get install -y apache2

a2enmod proxy
a2enmod proxy_http
a2enmod headers

rm -f /var/www/html/index.html

cat > /var/www/html/index.html <<'HTML'
${file("${path.module}/../frontend/index.html")}
HTML

cat > /var/www/html/styles.css <<'CSS'
${file("${path.module}/../frontend/styles.css")}
CSS

cat > /var/www/html/app.js <<'JS'
${file("${path.module}/../frontend/app.js")}
JS

cat > /etc/apache2/sites-available/000-default.conf <<'CONF'
<VirtualHost *:80>

    DocumentRoot /var/www/html

    ProxyPass /api/ http://${aws_lb.app.dns_name}:3000/

    ProxyPassReverse /api/ http://${aws_lb.app.dns_name}:3000/

    <Directory /var/www/html>
        Require all granted
    </Directory>

</VirtualHost>
CONF

systemctl restart apache2
EOF
}
