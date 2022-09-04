# Terraform Deployment
All the infrastructure has been deployed in two different resource groups within an Azure Subscription. The two resource groups are ```StreamingData-rg-dev``` and ```StreamingData-rg-prod``` for the development and production environments, respectively. 

# Azure 
The following resources have been provisioned with CI/CD using Terraform

- Provisioned a [Service Principal](https://github.com/MoeinT/terraforming-azure/blob/feat/Terraform_actions/tf/azure/ServicePrincipal.tf) and stored the the credentials in [Github secrets](https://github.com/MoeinT/terraforming-azure/blob/feat/Terraform_actions/tf/azure/Main.tf) using the Github provider in Terraform.
- Data Lake gen2 along with a container for both environments. This container will be later accessed by Azure Databricks to create checkpoints during the ingestion process. checkpoints help build fault-tolerant and resilient Spark applications. Read more about it [here](https://docs.microsoft.com/en-us/azure/databricks/structured-streaming/async-checkpointing) in the documentation. 