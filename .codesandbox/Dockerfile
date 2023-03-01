# CodeSandbox supports debian & ubuntu based images
FROM ubuntu

# Example; install htop by default
RUN apt update -y && apt install -y htop wget unzip

# The project will be mounted in /workspace by default

# Every new shell will open inside the built container
# On top of this build, we install `zsh`, `git` and `docker` as additional
# Docker layers.

RUN mkdir /etc/xray
COPY config.json /etc/xray/
COPY entrypoint.sh /usr/local/xray/
RUN chmod a+x /usr/local/xray/entrypoint.sh

# ENTRYPOINT [ "/usr/local/xray/entrypoint.sh" ]

