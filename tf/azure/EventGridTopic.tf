resource "azurerm_eventgrid_topic" "EventGridTopic" {
  name                = "22Eventgrid-${var.env}"
  location            = azurerm_resource_group.TerraformingAzureRg.location
  resource_group_name = azurerm_resource_group.TerraformingAzureRg.name
  input_schema        = "EventGridSchema"
}

resource "azurerm_eventgrid_event_subscription" "EventHubsSubs" {
  name                 = "TweetsEventHubsSubs-${var.env}"
  scope                = azurerm_eventgrid_topic.EventGridTopic.id
  eventhub_endpoint_id = azurerm_eventhub.AllEventHubs["StreamingTweets-${var.env}"].id
}