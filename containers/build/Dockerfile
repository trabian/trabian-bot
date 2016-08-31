FROM ubuntu:12.04

RUN apt-get -qq update
RUN apt-get install -y wget

RUN wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb --no-check-certificate && dpkg -i erlang-solutions_1.0_all.deb
RUN apt-get update
RUN apt-get install -y esl-erlang elixir openssh-server git

RUN \
  mkdir -p /var/run/sshd && \
  sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN mkdir -p /tmp/builds/trabian-bot

COPY ssh_key.pub /root/.ssh/authorized_keys

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

CMD ["/usr/sbin/sshd", "-D"]

EXPOSE 22
