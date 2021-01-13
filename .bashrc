cat /etc/motd

alias a=aws
alias h=helm
alias k=kubectl

source /usr/share/bash-completion/bash_completion
source <(helm completion bash)
source <(kubectl completion bash)

complete -F __start_kubectl k
complete -C '/usr/local/bin/aws_completer' aws

export PS1='k8s-tools# '