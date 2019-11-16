if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
yum -y install java
yum -y install wget
yum -y install net-tools
ip=$(eval "ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'")
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
cd /etc/yum.repos.d/
sudo wget https://raw.githubusercontent.com/pclever1/centELK/master/elasticsearch.repo
yum -y install elasticsearch
yum -y install kibana
yum -y install logstash
cd /etc/logstash/conf.d
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/01-inputs.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/05-syslog.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/10-pf.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/11-firewall.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/50-outputs.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/12-suricata.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/13-snort.conf
sudo wget https://raw.githubusercontent.com/a3ilson/pfelk/master/conf.d/15-others.conf
mkdir /etc/logstash/conf.d/patterns



ip=$(eval "ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'")
sed -i "s/#network.host: 192.168.0.1/network.host: $ip/g" /etc/elasticsearch/elasticsearch.yml
sed -i 's/#http.port: 9200/http.port: 9200/g' /etc/elasticsearch/elasticsearch.yml
sed -i "s/#discovery.seed_hosts/discovery.seed_hosts/g" /etc/elasticsearch/elasticsearch.yml
sed -i "s/host1/127.0.0.1/g" /etc/elasticsearch/elasticsearch.yml
sed -i "s/host2/$ip/g" /etc/elasticsearch/elasticsearch.yml

sed -i "s/#server.port: 5601/server.port: 5601/g" /etc/kibana/kibana.yml
sed -i "s/#server.host/server.host/g" /etc/kibana/kibana.yml
sed -i "s/#elasticsearch.host/elasticsearch.host/g" /etc/kibana/kibana.yml
sed -i "s/localhost/$ip/g" /etc/kibana/kibana.yml

sed -i "s/localhost/$ip/g" /etc/logstash/conf.d/50-outputs.conf
sed -i "s/localhost/$ip/g" /etc/logstash/conf.d/50-outputs.conf


echo '-------------------------'
echo '-------------------------'
echo '-------------------------'
read -p 'Enter your pfSense IP address: ' pfip
pfip=$(eval echo $pfip | sed 's/\./\\\\\\./g')
sed -i "s/172\\\.22\\\.33\\\.1/$pfip/g" /etc/logstash/conf.d/05-syslog.conf



/bin/systemctl daemon-reload
/bin/systemctl enable elasticsearch.service
/bin/systemctl enable kibana.service
/bin/systemctl enable logstash.service

systemctl stop firewalld
systemctl disable firewalld

systemctl start elasticsearch 
systemctl start kibana 
systemctl start logstash 

echo
echo '-------------------------'
echo "Your ELK is now running, you can access it at $ip:5601"
echo '-------------------------'
