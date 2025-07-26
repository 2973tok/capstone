#!/bin/bash

# Switch to root only for necessary commands
exec > /var/log/user-data.log 2>&1
set -x

# Update and install necessary packages
apt-get update -y
apt-get upgrade -y
apt-get install -y git python3 python3-pip awscli python3.10-dev default-libmysqlclient-dev

# Install boto3
pip3 install --upgrade pip
pip3 install boto3

# Set working directory
cd /home/ubuntu

# Get GitHub token from AWS SSM Parameter Store
TOKEN=$(aws ssm get-parameter \
  --region us-east-1 \
  --name "/<yourname>/capstone/token" \
  --with-decryption \
  --query 'Parameter.Value' \
  --output text)

# Clone the private repository using token
git clone https://$TOKEN@github.com/<yourreponame>/aws-capstone-project.git

# Navigate to the project directory
cd /home/ubuntu/aws-capstone-project

# Install Python dependencies
pip3 install -r requirements.txt

# Django setup
cd src
python3 manage.py collectstatic --noinput
python3 manage.py makemigrations
python3 manage.py migrate

# Start Django development server (should be replaced with Gunicorn or similar in production)
nohup python3 manage.py runserver 0.0.0.0:80 &
