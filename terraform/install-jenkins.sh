#!/bin/sh
sed -i 's/#$nrconf{kernelhints} = -1;/nrconf{kernelhints} = 0;/' /etc/needrestart/needrestart.conf
# swamp
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo cp /etc/fstab /etc/fstab.bak
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
sleep 10
# update and upgrade
sudo apt update 
sudo DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade
# jenkins install
sudo apt install -y openjdk-11-jdk
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
echo "deb https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update
sudo apt-get install -y --no-install-recommends jenkins
sudo sed -i '/\[Service\]/a TimeoutStartSec=600\nTimeoutStopUSec=infinity' /lib/systemd/system/jenkins.service
sudo systemctl daemon-reload
sudo systemctl restart jenkins
sudo systemctl enable jenkins  
# docker install
sleep 20
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
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
# change ownership of Jenkins directory
sudo systemctl stop jenkins
sudo chown -R jenkins:jenkins /var/lib/jenkins
sudo systemctl start jenkins
# display jenkins admin password
echo "Jenkins admin password: ${JENKINS_ADMIN_PASSWORD}"
sudo sudo shutdown -r 1
