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

### Para iniciar o Provisionamento:

- Abra o AWS Console
- Entre em EC2, Instance
- Na barra lateral esquerda, terá uma opção `Network & Security`, clique em `Key Pairs`
- Crie uma nova Key Pair chamada `minha-chave-ssh` em `Create key pair`, estará no canto superior direito.
- Basta adicionar o nome `minha-chave-ssh`, mantendo as configurações padrão e no canto inferior direito `Create key pair`
- Após fazer o download, dê permissão para que só você possa ver a chave, rodando `chmod 400 <path-para-sua-chave>minha-chave-ssh.pem`
> Essa chave é necessária para manter a segurança da Instancia EC2.
+ Rode o comando: `ssh -i <path-para-sua-chave>/minha-chave-ssh.pem ec2-user@<ec2_public_ip>
- Essa `ec2_public_ip` estará visível no terminal após a finalização do `terraform apply`, mas caso haja algum problema, basta: 
 - No Console AWS, clique em `Instances`
 - Depois clique no `instance ID` 
 - Você terá a opção de copiar o `ec2_public_ip` que estará no canto superior esquerdo.

### Para iniciar o ambiente:

### Criação bucket

- precisamos criar um bucket antes do nosso terraform, pois como usamos o tf.state no codigo, não podemos criar um bucket e configurar o tf.state juntos
- rode o comando
`aws s3api create-bucket --bucket bruno-lassakoski-bucket-325 --region us-east-1`

- **Terraform:**

```
terraform init
terraform plan
terraform apply
```

- **Minikube:**

```
minikube start

cd /test-devops

helm install test-devops ./test-devops
```

> Se estiver usando um cluster do Kubernetes, basta rodar os apply usando `kubectl apply <nome-do-arquivo>`.

### Conferir se foi aplicado corretamente:

```
minikube kubectl -- get pods
```
> Se quiser ver as configurações do pod, basta rodar `minikube kubectl describe pod test-devops<nome-completo-do-pod>`

> Caso esteja usando um cluster do Kubernetes, é só rodar o `kubernetes get <workload>` e `kubectl describe pod <nome-do-pod>`.
