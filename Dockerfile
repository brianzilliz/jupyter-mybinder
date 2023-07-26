FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN rm /bin/sh && ln -s /bin/bash /bin/sh && \
    apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && apt-get update && \
    apt-get install -y python3.11 python3.11-distutils python3-pip && \
    python3.11 -m pip install notebook

# Install javascript kernel
RUN useradd -ms /bin/bash demo && \
    apt-get update --fix-missing && \
    curl -fsSL https://deb.nodesource.com/setup_lts | sudo -E bash - &&\
    apt-get install -y nodejs && \
    npm install -g --unsafe-perm ijavascript && \
    ijsinstall --install=global 

# Install java kernel
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk && \
    apt-get install -y maven && \
    apt-get install -y wget unzip && \
    wget https://github.com/SpencerPark/IJava/releases/download/v1.3.0/ijava-1.3.0.zip && \
    unzip ijava-1.3.0.zip && \
    wget -P /home/demo https://repo1.maven.org/maven2/io/milvus/milvus-sdk-java/2.2.9/milvus-sdk-java-2.2.9.jar && \
    python3 install.py --sys-prefix --classpath /home/demo && \
    rm -rf ijava-1.3.0.zip

# Install golang kernel
ENV USER=demo
ENV HOME=/home/demo
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
USER ${USER}
WORKDIR ${HOME}
RUN go install "github.com/janpfeifer/gonb@${GONB_VERSION}" && \
    go install golang.org/x/tools/cmd/goimports@latest && \
    go install golang.org/x/tools/gopls@latest && \
    gonb --install

# Clean up space used by apt.
USER root
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

USER ${USER}
WORKDIR ${HOME}/work
EXPOSE 8888
CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888"]


