FROM centos:8

# Install dependencies - Remember to convert these to dnf later (uses less memory than yum)
RUN yum install -y httpd httpd-devel
RUN dnf install -y python3 python3-devel
RUN yum install -y python3-mod_wsgi

# Install Python application requirements
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Copy application source code into container
COPY wsgi/etc /etc
COPY wsgi/usr /usr

# Grant permissions to read/execute source code - Remember to restrict this to the apache user/group later.
RUN chmod a+rx /usr/local/www -R

EXPOSE 80

# Start Apache
ENTRYPOINT ["httpd", "-D", "FOREGROUND"]
