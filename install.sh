apt install squid -y
apt install aptitude -y
apt-get install moreutils -y
apt-get update -y
apt-get install build-essential libltdl-dev -y
aptitude build-dep squid
apt-get install perl -y
apt-get install binutils -y
apt-get install c++11 -y
apt-get install wget -y
apt-get install apache2 apache2-utils -y
sudo touch squidip.txt
sudo touch /etc/squid/squid.passwd
systemctl start squid
systemctl enable squid
sudo touch proxies.txt
sudo apt install at
sudo systemctl enable --now at
sudo touch users.txt
sudo touch /etc/squid/blacklist.txt
sudo touch user_*
wget http://www.squid-cache.org/Versions/v4/squid-4.10.tar.gz
tar -zxf squid-4.10.tar.gz
cd squid-4.10
apt-get install automake autoconf libtool 
./bootstrap.sh
./configure --prefix=/usr --includedir=${prefix}/include --mandir=${prefix}/share/man --infodir=${prefix}/share/info --sysconfdir=/etc --localstatedir=/var --libexecdir=${prefix}/lib/squid --disable-maintainer-mode --disable-dependency-tracking --disable-silent-rules --enable-async-io --enable-icmp --enable-delay-pools --enable-useragent-log --enable-snmp --enable-http-violation --datadir=/usr/share/squid --sysconfdir=/etc/squid --libexecdir=/usr/lib/squid --mandir=/usr/share/man --enable-inline --enable-storeio=ufs,aufs,diskd,rock --enable-cache-digests --enable-icap-client  --enable-follow-x-forwarded-for --with-swapdir=/var/spool/squid --with-logdir=/var/log/squid --with-pidfile=/var/run/squid.pid --with-filedescriptors=1000000  --with-large-files --with-default-user=proxy --enable-build-info="Ubuntu linux" --enable-linux-netfilter CXXFLAGS="-DMAXTCPLISTENPORTS=4096"
make
make install
systemctl daemon-reload
systemctl enable squid
systemctl start squid


echo "http_port 1234
visible_hostname HollandoProxy
forwarded_for delete
via off



logformat squid %ts.%03tu %6tr %>a %Ss/%03>Hs %<st %rm %ru %un %Sh/%<A %mt
access_log /var/log/squid/access.log squid

cache deny all
coredump_dir /var/spool/squid

acl QUERY urlpath_regex cgi-bin \?

auth_param basic program /usr/lib/squid/basic_ncsa_auth /etc/squid/squid.passwd
auth_param basic children 1024
auth_param basic realm Proxy
auth_param basic credentialsttl 2 hours
auth_param basic casesensitive off

shutdown_lifetime 3 seconds
acl blockList dstdomain '/etc/squid/blacklist.txt'
http_access deny blockList
max_filedescriptors 100000000

include /etc/squid/conf.d/*.conf" > '/etc/squid/squid.conf'
