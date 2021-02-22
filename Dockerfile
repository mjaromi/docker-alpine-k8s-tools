FROM alpine:3.12.3

ENV KUBECTL_PATH=/usr/local/bin/kubectl

ENV HELM_PATH=/usr/local/bin/helm
ENV HELM_VERSION=3.4.2
ENV HELM_PACKAGE=helm-v${HELM_VERSION}-linux-amd64.tar.gz
ENV HELM_URL=https://get.helm.sh/${HELM_PACKAGE}

ENV YQ_PATH=/usr/local/bin/yq
ENV YQ_VERSION=4.3.2
ENV YQ_PACKAGE=yq_linux_amd64.tar.gz
ENV YQ_URL=https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/${YQ_PACKAGE}

RUN apk add --no-cache bash bash-completion curl git groff jq ncurses && \
    ### eksctl
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin && \
    ### kubectl
    KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt) && \
    KUBECTL_URL=https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    curl -Ls ${KUBECTL_URL} -o ${KUBECTL_PATH} && \
    chmod +x ${KUBECTL_PATH} && \
    ### krew and ctx, ns plugins
    curl --silent --location https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz | tar xz -C /tmp && \
    /tmp/krew-linux_amd64 install krew && \
    PATH="$HOME/.krew/bin:$PATH" && \
    kubectl krew install ctx ns && \
    ### helm
    curl -Ls ${HELM_URL} -o /tmp/${HELM_PACKAGE} && \
    tar -zxvf /tmp/${HELM_PACKAGE} && \
    mv linux-amd64/helm ${HELM_PATH} && \
    chmod +x ${HELM_PATH} && \
    rm -rf linux-amd64 /tmp/${HELM_PACKAGE} && \
    ### yq
    curl -Ls ${YQ_URL} -o /tmp/${YQ_PACKAGE} && \
    tar -zxvf /tmp/${YQ_PACKAGE} && \
    mv yq_linux_amd64 ${YQ_PATH} && \
    chmod +x ${YQ_PATH} && \
    rm -f yq_linux_amd64 /tmp/${YQ_PACKAGE} && \
    ### awscli v2 - https://github.com/mjaromi/docker-alpine-awscli
    GLIBC_VER=$(wget -q -O - https://api.github.com/repos/sgerrand/alpine-pkg-glibc/git/refs/tags | jq -r '.[-1].ref' | awk -F/ '{print $NF}') && \
    wget -q -O glibc-${GLIBC_VER}.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-${GLIBC_VER}.apk && \
    wget -q -O glibc-bin-${GLIBC_VER}.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VER}/glibc-bin-${GLIBC_VER}.apk && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
    apk add --no-cache glibc-${GLIBC_VER}.apk && \
    ### fix for: https://github.com/aws/aws-cli/issues/4685#issuecomment-651039956
    rm /usr/glibc-compat/lib/ld-linux-x86-64.so.2 && \
    ln -s /usr/glibc-compat/lib/ld-$(echo ${GLIBC_VER} | cut -d'-' -f1).so /usr/glibc-compat/lib/ld-linux-x86-64.so.2 && \
    ###
    apk add --no-cache glibc-bin-${GLIBC_VER}.apk && \
    wget -q -O awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip && \
    unzip -q awscliv2.zip && \
    ./aws/install && \
    ln -s /usr/local/bin/aws /usr/bin/aws && \
    rm -rf aws awscliv2.zip glibc-${GLIBC_VER}.apk glibc-bin-${GLIBC_VER}.apk /tmp/* && \
    ### cleanup
    rm -f /var/cache/apk/*

COPY .bashrc /root/.bashrc
COPY motd /etc/motd

ENTRYPOINT [ "/bin/bash" ]
