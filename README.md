## Description
<!-- how the code works, how to deploy the application and how to verify its successful deployment. -->
- Code includes two terraform directories - `terraform/production` and `terraform/staging`. 
- Each `main.tf` deploys common helm chart with different environent specific variables.
- Cluster for the solution should be hosted in AWS (EKS)
- Solution description is focused on cluster level objects, infrastructure level enhancements are described in the "Enhancements" paragraph

### How to deploy

#### Option 1 - simple
- There is a script `deploy.sh` in the root of repository. Execute it by `./deploy.sh` and it will deploy helm chart to the AWS cluster, which is set up for your local kubectl.
- Verification of deployment is written in the script - it will get external IP of service and curl two endpoints: "/" and "/configs"

#### Option 2 - manual

Precondition
- Set up kubectl locally to connect to AWS cluster
- Set up IAM policies allowing creating Load Balanacer from k8s service manifest
- Change values in terraform/production/values-production.yaml if necessary
  
1. Execute terraform scripts
    ```bash
    cd terraform/production
    terraform init
    terraform apply -var="image_tag=1.0.0-prod"
    ```
2. Get external IP and check endpoints
  - 
    ```bash
    kubectl get svc mytomorrows-flask-service -n production -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    ```
  - Open endpoints from browser: http://<external_ip>/ http://<external_ip>/configs


## Details
### Scalability
Scalability of the solution is based on:
- Configurable IaC: helm values, helm helpers for dynamic variables, tf modules and tf vars
- K8S HPA, thath scales in and down pods automatically based on the load
- AWS LB, which distributes traffic across pods

### Availability
Availability of the solution mainly based on:
- Using deployments in k8s, which is providing self-healing of pods, rolling updates
- Terraform state files per env, ensuring consistency of environment deployment
- AWS managed load balancer

### Fault tolerance
- Multiple pods replicas, providing redundancy and reliability
- AWS load balancer will route traffic only on healthy pods
- Deployment self-healing
- Pod health probe, ensuring state of app 

### Security
- Usage of secrets for sensitive credentials, allowing to set up RBAC on them
- One point of access to the cluster using Load balancer in public network 
- nodes in private network with only NAT gateway access
- Docker image with minimum amount of additional libraries, usage of production WSGI engine

### Networking strategy
To comply with security, VPC should have public and private subnets.
Amount of subnets should be at least 2 in each availability zone.
Cluster nodes should be in private subnets, load balancer - in public.
Private nodes should have only NAT gateway, public - Internet gateway
There should be NAT gateway per subnet to avoid cross AZ charges in AWS

Example of network strategy can be found in `terraform/aws_infra/vpc.tf file`

### Granting access
Access of the app for various AWS services mainly can be solved by the same way:
 - creating OIDC
 - IAM policy and role
 - deploying service account and use it in deployment

From network perspective:
- some services like RDS should be deployed in the same private subnets and being accessible 
- some services like S3 could require VPC gateway to keep traffic inside of AWS network
- some services like ECR can be accessed just by using IAM  

### CI/CD
Description of CI/CD will be based on app deployment, excluding infrastructure deployment ( like vpcs, cluster and iam)

For the simple app I would create CI/CD process based on principles:
- fast integration
- security checkers and linters
- using same artifact to deploy across multiple environments

To comply with this, gitflow can be next:
- main branch
- on PR to main branch - autotests, linters, security checkers
- if CI passed:
  - merge
  - On merge executed build on test environment with commit hash of merged PR
  - Conducting manual/auto testing
  - If testing is correct - execute "deploy to production" with the same image but with different variables

Example of rough draft CI/CD can be found in ./github/workflows/depoyment.yaml

## Potential enhancements
Cluster level enhancements:
- #Security Set up RBAC in cluster to control access of sensitive configs like secretes and configMaps, separate access per namespace if necessary
- #Security Set up HTTPS on Load balancer to make API encrypted
- #Security USA AWS API gateway + WAF to protect API from external attacks
- #Security Use AWS KMS to securely store and rotate sensitive values like database password
- #Observability Deploy Grafana + Prometheus into the cluster to monitor resources and app metrics
- #Observability Deploy ELK / Loki into the cluster to have centralized logs management tool
- #Observability Isolate both observability tools servers in separate node to prevent impact of apps deployment on monitoring.
- #Scalabilty Set up Cluster auto scaling by using auto-scaling node groups in EKS or managed EKS nodes
- #Scalability Separate clusters per environment to prevent impact of testing on production cluster
- #CI/CD To enhance experience with deployments, I would use GitOps tool like ArgoCD/Flux, since they provide more flexibility in compare with terraform
- #CI/CD storing terraform state files in S3 backend + dynamodb for locking to prevent parallel changes and configuration draft
