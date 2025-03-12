# Desafio Técnico Asaptech

## Importante ter instalados e configurados:

- Terraform
- Helm Chart
- Kubernetes
- Minikube 

### Passo a Passo:

- Clone o repositório
> Rode o comando: `git clone https://github.com/BrunoLass/test-devops `

### Estrutura de arquivos:

`Deployment.yaml`: Arquivo de template Helm que define o Deployment do Kubernetes para o Nginx. A imagem do Nginx, o número de réplicas e a porta de serviço são configuráveis através das variáveis definidas no arquivo values.yaml.

`Chart.yaml`: Arquivo de metadados do Helm que define o nome, versão e a descrição do gráfico. Este gráfico é utilizado para implementar o nginx-app no Kubernetes.

`values.yaml`: Arquivo de configuração onde são definidos os valores para o número de réplicas, imagem do container (repositório e tag), configurações de serviço e recursos (limites e solicitações de CPU e memória). As configurações neste arquivo são usadas pelo template Helm para gerar o deployment.

`backend.tf`: Arquivo de configuração Terraform que cria os seguintes recursos na AWS:

Um bucket S3 para armazenar o estado do Terraform com versionamento e configuração de ciclo de vida para excluir versões antigas após 30 dias.
Uma instância EC2 no AWS para executar o Minikube, com configurações para instalar Docker, Minikube e kubectl automaticamente durante a inicialização da instância.
Um grupo de segurança que permite acesso SSH à instância EC2 e permite tráfego no Kubernetes (porta 6443), além de permitir tráfego de saída.

### Para iniciar o Provisionamento:

### Conectar no aws cli

 - Baixe e instale o AWS CLI
 `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"`
 `unzip awscliv2.zip`
 `sudo ./aws/install`
 - Após instalar o AWS CLI, você precisa configurar suas credenciais para acessar a AWS.
 - Rode o comando: `aws configure`
 - Vá ate onde esta seu login, clique em cima do seu login e depois clique em Credenciais de segurança>Chaves de acesso> Criar chave de acesso
 - Guarde sua chave de acesso e a Chave de acesso secreta
 - Digite suas credenciais quando solicitado:
    AWS Access Key ID [None]: chave de acesso
    AWS Secret Access Key [None]: Chave de acesso secreta
    Default region name [None]: us-east-1  # Ou outra região da AWS
    Default output format [None]: json     # Pode ser json, table ou text

 

### Criação bucket

- Precisamos criar um bucket antes do nosso terraform, pois como usamos o tf.state no codigo, não podemos criar um bucket e configurar o tf.state juntos
- Rode o comando:
`aws s3api create-bucket --bucket bruno-lassakoski-bucket-325 --region us-east-1`

- **Terraform:**

```
terraform init
terraform plan
terraform apply
terraform output -raw private_key_pem > minha-chave-ssh.pem
chmod 400 minha-chave-ssh.pem

```
### Conectar na instancia

 - Rode o comando: `ssh -i <path-para-sua-chave>/minha-chave-ssh.pem ec2-user@<ec2_public_ip>
 - Essa `ec2_public_ip` estará visível no terminal após a finalização do `terraform apply`, mas caso haja algum problema, basta: 
 - No Console AWS, clique em `Instances`
 - Depois clique no `instance ID` 
 - Você terá a opção de copiar o `ec2_public_ip` que estará no canto superior esquerdo.


- **Minikube:**

```
minikube start

 Clone o repositório
 Rode o comando: `git clone https://github.com/BrunoLass/test-devops `

cd /test-devops

helm install test-devops ./test-devops
```

> Se estiver usando um cluster do Kubernetes, basta rodar os apply usando `kubectl apply <nome-do-arquivo>`.

### Conferir se foi aplicado corretamente:

```
minikube kubectl -- get pods
```
> Se quiser ver as configurações do pod, basta rodar `minikube kubectl describe pod test-devops<nome-completo-do-pod>`

> Caso esteja usando um cluster do Kubernetes, é só rodar o `kubectl get pod` e `kubectl describe pod <nome-do-pod>`.
