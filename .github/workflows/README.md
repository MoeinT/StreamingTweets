# CI/CD pipeline

<p align="center">
  <img width="800" height="300" src=./assets/TfPipeline.PNG>
</p>

Figure above shows how the Terraform pipeline has been designed; here are the steps: 

- On a push to the branch, feat/Terraform_actions, an initial test will run on the development environment. In this step the ```terraform init -backend-config backend/dev.tfvars``` command will run to initialize the development backend. Once the backend has been initialized, the command  ```terraform fmt -check -recursive``` and ```terraform validate``` will run to check the formatting and validate the configuration files, respectively. In this step the ```terraform plan -var-file vars/dev.tfvars``` command will also run to preview the resources that are going to be deployed on dev. 

- Once the development environment has been initialized and the configuration files have been validated, a pull request will trigger the next stage. Our infrastructure gets deployed on dev by running ```terraform apply -auto-approve -var-file vars/dev.tfvars``` and the production environment gets tested by running ```terraform plan -var-file vars/prod.tfvars```.

- Once everything has been successfully tested and deployed on dev without any issue, it's time to move to prod. This stage get trigger once the merge is complete. The command ```terraform apply -auto-approve -var-file vars/prod.tfvars``` will run to deploy inftrastructue to the production environment.