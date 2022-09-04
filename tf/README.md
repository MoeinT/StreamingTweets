# Terraform Deployment
All the infrastructure has been deployed in two different resource groups within an Azure Subscription. The two resource groups are ```StreamingData-rg-dev``` and ```StreamingData-rg-prod``` for the development and production environments, respectively. 

# Azure 
The following resources have been provisioned with CI/CD using Terraform:

- Provisioned a [Service Principal](https://github.com/MoeinT/terraforming-azure/blob/feat/Terraform_actions/tf/azure/ServicePrincipal.tf) and stored the the credentials in [Github Secrets](https://github.com/MoeinT/terraforming-azure/blob/feat/Terraform_actions/tf/azure/Main.tf) using the Github provider in Terraform.
- Data Lake gen2 along with a container for both environments. This container will be later accessed by Azure Databricks to create checkpoints during the ingestion process. Checkpoints help build fault-tolerant and resilient Spark applications. Read more about it [here](https://docs.microsoft.com/en-us/azure/databricks/structured-streaming/async-checkpointing) in the documentation. 
- Provisioned an [Azure Key Vault](https://github.com/MoeinT/terraforming-azure/blob/feat/Terraform_actions/tf/azure/KeyVault.tf) to store the credentials and set the required access policies. These credentials will later be used in Databricks notebooks.
- Provisioned an [Event Hubs namespace](https://github.com/MoeinT/terraforming-azure/blob/feat/Terraform_actions/tf/azure/EventHubs.tf) and an Event Hub as our streaming solution in this project.
- Provisioned an [Event Grid Topic](https://github.com/MoeinT/terraforming-azure/blob/feat/Terraform_actions/tf/azure/EventGridTopic.tf) and subscribed the Event Hub to it. This way the events will be automatically routed to the Event Hub, once received by the topic.
- [Databricks](https://github.com/MoeinT/terraforming-azure/blob/feat/Terraform_actions/tf/azure/Databricks.tf) workspace along with a Databricks cluster for processing the incoming streams. Also, installed Event Hubs Maven library on the Databricks clusters using Terraform. This library is required to connect the Event Hub to the Databricks workspace.