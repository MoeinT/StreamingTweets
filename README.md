# Terraforming Azure
Real-time ingestion of tweets into Databricks Delta table with a CI/CD pipeline to provision infrastructure in Azure. Shows how Terraform can be used to set up the resources.

# General
This project shows how we can manage the flow of data on a real-time basis into Azure. We've created a real-time pipeline of tweets into Azure using the Twitter API; see my codes [here](https://github.com/MoeinT/terraforming-azure/blob/main/scripts/Tweets/SendTweetsEventGridTopic.py). We have used Infrastructure as Code with Terraform to deploy our resources in both development and production environments using CI/CD actions.

# Cloud Architecture
- Provisioned the required resources and environments using Terraform
- Ingested tweets into an Event Grid Topic on a real-time basis using the Twitter API
- Suscribed an Event Hubs to the topic as the main consumer of the streams
- Processed the incoming streams using Databricks Structured Streaming
- Stored the processed streams into Databricks Delta Table, a next generation storage solution in the cloud


<p align="center">
  <img width="600" height="170" src=./assets/Architecture.png>
</p>

# Contact
- moin.torabi@gmail.com
- [LinkedIn](https://www.linkedin.com/in/moein-torabi-5339b288/)