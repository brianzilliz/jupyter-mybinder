FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive

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

EXPOSE 8888

USER demo
WORKDIR /home/demo

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8888"]

# ## Install golang kernel

# RUN wget https://go.dev/dl/go1.20.6.linux-amd64.tar.gz && \
#     rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.6.linux-amd64.tar.gz && \
#     export PATH=$PATH:/usr/local/go/bin && \
#     go install github.com/janpfeifer/gonb@latest && \
#     go install golang.org/x/tools/cmd/goimports@latest && \
#     go install golang.org/x/tools/gopls@latest && \
#     gonb --install
