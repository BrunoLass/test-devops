# Desafio Técnico Asaptech

## Importante ter instalados e configurados:

- Terraform
- Helm Chart
- Kubernetes
- Minikube 

### Passo a Passo:

- Clone o repositório
> Rode o comando: `git clone `

### Estrutura de arquivos:

`Deployment.yaml`: Arquivo de template Helm que define o Deployment do Kubernetes para o Nginx. A imagem do Nginx, o número de réplicas e a porta de serviço são configuráveis através das variáveis definidas no arquivo values.yaml.

`Chart.yaml`: Arquivo de metadados do Helm que define o nome, versão e a descrição do gráfico. Este gráfico é utilizado para implementar o nginx-app no Kubernetes.

`values.yaml`: Arquivo de configuração onde são definidos os valores para o número de réplicas, imagem do container (repositório e tag), configurações de serviço e recursos (limites e solicitações de CPU e memória). As configurações neste arquivo são usadas pelo template Helm para gerar o deployment.

`backend.tf`: Arquivo de configuração Terraform que cria os seguintes recursos na AWS:

Um bucket S3 para armazenar o estado do Terraform com versionamento e configuração de ciclo de vida para excluir versões antigas após 30 dias.
Uma instância EC2 no AWS para executar o Minikube, com configurações para instalar Docker, Minikube e kubectl automaticamente durante a inicialização da instância.
Um grupo de segurança que permite acesso SSH à instância EC2 e permite tráfego no Kubernetes (porta 6443), além de permitir tráfego HTTP e HTTPS de saída.

### Para iniciar o ambiente:

- **Terraform:**

```
terraform init
terraform plan
terraform apply
```

- **Minikube:**

```
minikube start

helm install test-devops ./test-devops
```

> Se estiver usando um cluster do Kubernetes, basta rodar os apply usando `kubectl apply <nome-do-arquivo>`.

### Conferir se foi aplicado corretamente:

```
minikube kubectl -- get pods
```
> Se quiser ver as configurações do pod, basta rodar `minikube kubectl describe pod test-devops<nome-completo-do-pod>`

> Caso esteja usando um cluster do Kubernetes, é só rodar o `kubernetes get <workload>` e `kubectl describe pod <nome-do-pod>`.
