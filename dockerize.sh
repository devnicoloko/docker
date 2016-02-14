sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" > docker.list
sudo cp docker.list /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get install -q -y docker-engine
sudo service docker start
sudo usermod -aG docker admin
