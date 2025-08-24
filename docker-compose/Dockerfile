FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y \
    openjdk-17-jdk \
    openssh-server \
    cron \
    openssl \
    nano \
    curl \
    systemctl \
    sudo \
    python3 \
    python3-pip && \
    apt-get clean

RUN mkdir /var/run/sshd
RUN echo 'root:barqpass' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN pip3 install ansible

RUN useradd -m -s /bin/bash barq && \
    echo 'barq:barqpass' | chpasswd && \
    usermod -aG sudo barq

RUN apt-get update && apt-get install -y systemd systemd-sysv
RUN systemctl set-default multi-user.target

EXPOSE 22 8080

CMD ["/usr/sbin/sshd", "-D", "-e"]
