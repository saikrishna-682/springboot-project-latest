# Deploy Springboot Application using Nginx Ingress Controller and Hostname


# Individual Installation or Install all at once using Shell Script
 
Install aws-cli Install Kubectl Install Eksctl Install helm assuming you have your own
Domain

## Install aws-cli - v2

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 

unzip awscliv2.zip 

sudo ./aws/install 

aws --version
```

## Install Kubectl

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo ./aws/install 

echo "$(cat kubectl.sha256) kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client
```
## Install Eksctl

```bash
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname - s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version
```
## Install HELM
```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh
```

## Installing all at once using Shell Script

> vi installation_script.sh
```bash
#paste the following commands
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 

unzip awscliv2.zip 

sudo ./aws/install 

aws --version

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
sudo ./aws/install 

echo "$(cat kubectl.sha256) kubectl" | sha256sum --check

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

kubectl version --client

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname - s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv /tmp/eksctl /usr/local/bin

eksctl version

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3

chmod 700 get_helm.sh

./get_helm.sh
```
> chmod +x installation_script.sh

> ./installation_script.sh
# Steps

> Create a EC2 instance with amazon linux 2 AMI with type t2.medium

> Create IAM Role which has AdministratorAccess and attach that role to the EC2
instance.

> To attach that role to your ec2 instance - Select your instance - Click on Actions
- Select Security and select Modify IAM Role - Attach your role

## SSH
- Now that we have our instance ready and running : connect to the ec2 instance using
ssh

```
ssh -i <your_.pem_file_path> ec2-user@<your_public_ip>
```

## Eksctl cluster creation

- once you are connected to your instance
> Create a eks cluster using the following command

Example:
```
aws eks create cluster --name <some-cluster-name> --region <your-region> -- nodegroup-name <some-nodegp-name> --node-type <which-type> --managed --nodes <no.of nodes by default 2>


aws eks create cluster --name demo-eks --region us-east-1 --nodegroup-name demo- node --node-type t3.small --managed --nodes 2

```
- Cluster creation takes about 15 - 20 minutes meanwhile we can have a look at
the cluster creation within aws console navigate to "Elastic Kubernetes
Service" will have our cluster.


## Commands to deploy your springboot application using kubectl

- Once the cluster is ready

> command to show how manny nodes are available since we have mentioned 2 we have two nodes:
```
kubectl get nodes
```
- Meanwhile using Helm install Nginx ingress controller using following command:

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 

helm repo update 

helm install my-ingress-controller ingress-nginx/ingress-nginx
```
## Now create a yaml files for deployiong your Springboot Application:

> Deployment.yaml

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-name
spec:
  replicas: 1
  selector:
    matchLabels:
      app: app-name
  template:
    metadata:
     labels:
       app: app-name
    spec:
      containers:
      - name: app-name
        image: yourapplication-dockerImage
        ports:
        - containerPort: 8080
```

> Service.yaml

```
apiVersion: v1
kind: Deployment
metadata:
  name: app-name
spec:
  selector:
      app: app-name
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

> Ingress.yaml

```
apiVersion: v1
kind: Ingress
metadata:
  name: app-name-ingress
  annotations: 
    Kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - http:
      paths:
      - path: /
      pathType: Prefix
      backend:
        service:
          name: app-name
          port: 
            number: 80
```

- Now to deploy your application
```kubectl apply -f deployment.yaml```
- Check your pods 
```kubectl get pods```
- To check the deployments
```kubectl get deployments```


- If our deployment is running fine, now deploy our service.yaml file ```kubectl apply - f service.yaml``` Check your services ```kubectl get svc```


-  Since out service has allocated a load balancer. So, we can access our application
using that loadbalaner In my case I used this docker image ```saikrishna682/spring- maven:v1``` at this address ```/course-svc/getAllDevopsTools```

- We should be ale to access the same using the service loadbalancer ```a8358d0f3a37a4edcb09589556a263ce-1955544823.us-east-1.elb.amazonaws.com/course- svc/getAllDevopsTools```

>> Output : ["git","maven","sonar","nexus","jenkins"]

. Now deploy your ingress as well using ```kubectl apply -f ingress.yaml``` - Access ingress
using ```kubectl get ingress```

## Create ACM and a Hosted Zone in Route 53

- Create a public certificate with domian name which will generate a cname and
cname value enter these values within your domain dns for certificate
verification
- once the certificate is verified by acm then navigate to Route 53 and create a
hosted zone
- Enter domain name and click on create hosted zone

## Once the Hosted zone is set create a record by giving a name and a value in our case it is the ACM CNAME value

> i.e name : spring.randomthat.com

- Within our domain dns create a cname and add host as spring.randomthat.com adn the
value as ingress loadbalancer i.e a7a9128add3234fa0b173e661bd2a165-1602558847.us-east- 1.elb.amazonaws.com

- Now you should be able to get the same output using this url as well
```spring.randomthat.com/course-svc/getAllDevopsTools``` 
> Output :
["git","maven","sonar","nexus","jenkins"]
