#!/bin/sh
sed -i 's/#$nrconf{kernelhints} = -1;/nrconf{kernelhints} = 0;/' /etc/needrestart/needrestart.conf
# swamp
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sleep 30
sudo apt update 
sudo DEBIAN_FRONTEND=noninteractive apt-get -o "Dpkg::Options::=--force-confold" dist-upgrade -y \
--allow-downgrades --allow-remove-essential --allow-change-held-packages
# jenkins install
sudo apt update 
sudo apt install default-jre -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key |sudo gpg --dearmor -o /usr/share/keyrings/jenkins.gpg
sudo sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins.gpg] \
http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt update
sudo apt install jenkins -y
sudo systemctl enable jenkins
sudo systemctl start jenkins
# docker install
sleep 10
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER
sudo usermod -aG docker jenkins
# jenkins plugins
JENKINS_ADMIN_PASSWORD=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)
echo "Jenkins admin password: ${JENKINS_ADMIN_PASSWORD}"
sudo apt-get install -y jq
sudo curl -L --silent --location http://localhost:8080/jnlpJars/jenkins-cli.jar > jenkins-cli.jar
java -jar jenkins-cli.jar -s http://localhost:8080/ -auth admin:${JENKINS_ADMIN_PASSWORD} install-plugin \
docker-plugin:1.3.0 docker-commons docker-workflow
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
sudo sudo shutdown -r 1
