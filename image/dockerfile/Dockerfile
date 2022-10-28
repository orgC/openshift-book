FROM quay.io/centos/centos:stream8
RUN yum -y install traceroute iproute httpd fio qperf iperf3 bind-utils iputils telnet nmap-ncat net-tools; yum clean all; systemctl enable httpd;
RUN echo "Successful Web Server Test" > /var/www/html/index.html
RUN mkdir /etc/systemd/system/httpd.service.d/; echo -e '[Service]\nRestart=always' > /etc/systemd/system/httpd.service.d/httpd.conf
EXPOSE 80
CMD [ "/sbin/init" ]
