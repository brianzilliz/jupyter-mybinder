FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install javascript kernel
RUN useradd -ms /bin/bash demo && \
    apt-get update --fix-missing && \
    apt-get install -y sudo nodejs npm jupyter && \
    npm install -g --unsafe-perm ijavascript && \
    ijsinstall --install=global 

# Install java kernel
RUN apt-get update && \
    apt-get install -y openjdk-17-jdk && \
    apt-get install -y maven && \
    apt-get install -y wget unzip && \
    wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
    unzip ijava-1.3.0.zip && \
    python3 install.py --sys-prefix && \
    rm -rf ijava-1.3.0.zip

# Install golang kernel
ENV GO_VERSION=1.20.6
ENV GONB_VERSION="v0.7.4"
ENV GOROOT=/usr/local/go
ENV GOPATH=${HOME}/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

USER root
WORKDIR /usr/local
RUN wget --quiet --output-document=- "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz \
    && go version

# Install GoNB (https://github.com/janpfeifer/gonb) in the jovyan's user account (default user)
USER demo
WORKDIR ${HOME}
RUN go install "github.com/janpfeifer/gonb@${GONB_VERSION}" && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install golang.org/x/tools/gopls@latest && \
    gonb --install

# Clean up space used by apt.
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

USER demo
WORKDIR /home/demo
EXPOSE 8888
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888"]


