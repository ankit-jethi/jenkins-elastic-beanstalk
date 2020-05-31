#!/bin/bash

# Install Runtime libraries
sudo amazon-linux-extras install -y epel
sudo yum install -y python-pip git
sudo pip install --upgrade pip
sudo pip install virtualenv

# Clone the app from GitHub
cd /opt/
git clone https://github.com/ankit-jethi/python-news-app.git
cd /opt/python-news-app/

# Create a Virtual Environment for the app
virtualenv /opt/python-news-app/
source /opt/python-news-app/bin/activate

# Install the app dependencies & gunicorn server
pip install -r requirements.txt
pip install gunicorn

# Deactivate
deactivate

# Create systemd service
sudo cp /opt/python-news-app/install/python-news-app.service /etc/systemd/system/python-news-app.service

# Create directory for storing gunicorn logs
sudo mkdir -p /var/log/python-news-app/gunicorn/
sudo chown -R ec2-user:ec2-user /var/log/python-news-app/gunicorn/

# Start & Enable the service
sudo systemctl daemon-reload
sudo systemctl start python-news-app
sudo systemctl enable python-news-app

