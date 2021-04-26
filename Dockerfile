FROM centos:8

RUN yum install -y httpd httpd-devel
RUN dnf install -y python3 python3-devel
RUN yum install -y python3-mod_wsgi

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY wsgi/etc /etc
COPY wsgi/usr /usr

RUN chmod a+rx /usr/local/www -R

EXPOSE 80

ENTRYPOINT ["httpd", "-D", "FOREGROUND"]
