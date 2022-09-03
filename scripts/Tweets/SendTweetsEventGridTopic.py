import configparser
import json

import pytz
import tweepy
from azure.core.credentials import AzureKeyCredential
from azure.eventgrid import EventGridEvent, EventGridPublisherClient


class MyStream(tweepy.StreamingClient):
    def __init__(self, bearer_token, **kwargs):
        self.TopicAccessKey = kwargs.pop("TopicAccessKey")
        self.TopicEndpoint = kwargs.pop("TopicEndpoint")
        super(MyStream, self).__init__(bearer_token, **kwargs)

    def on_connect(self):
        print("Connected")

    # Retrieve the tweets
    def on_tweet(self, tweet):
        my_tweet = json.dumps(
            {
                "user_id": tweet.author_id,
                "created_at": tweet.created_at.astimezone(pytz.timezone("Europe/Paris")).strftime("%Y-%m-%d %H:%M:%S"),
                "tweet_type": MyStream.get_tweet_type(tweet.referenced_tweets),
                "lang": tweet.lang,
                "tweet": tweet.text,
                "hashtags": MyStream.get_hashtags(tweet.entities),
            },
            default=str,
        )

        # Get and send Events        
        self.send_event(MyStream.create_EventGridEvent(my_tweet))

    # Send Event to EventGrid Topic
    def send_event(self, event: EventGridEvent):
        try:
            credential = AzureKeyCredential(self.TopicAccessKey)
            client = EventGridPublisherClient(self.TopicEndpoint, credential)
            client.send(event)
            print("An event is successfully sent to EventGridTopic")
        except Exception as e:
            print(e)

    # Create an EventGridEvent object
    @staticmethod
    def create_EventGridEvent(tweet: json) -> EventGridEvent:
        return EventGridEvent(
            data=tweet, 
            subject="Covid19", 
            event_type="Tweets", 
            data_version="1.0"
        )

    @staticmethod
    def get_hashtags(entities: dict) -> str:
        if "hashtags" in entities.keys():
            l_tags = []
            for hashtag in entities["hashtags"]:
                if "tag" in hashtag.keys():
                    l_tags.append(hashtag["tag"])
            return ", ".join(l_tags)
        else:
            return ""

    @staticmethod
    def get_tweet_type(referenced_tweets: list[dict]) -> str:
        l_types = []
        if referenced_tweets != None:
            for item in referenced_tweets:
                if "type" in item.keys():
                    l_types.append(item["type"])
                else:
                    return ""
            return ", ".join(l_types)
        else:
            return "tweeted"


if __name__ == "__main__":

    # Initial config
    config = configparser.ConfigParser(interpolation=None)
    config.read("config.ini")
    TopicEndpoint = config["twitter"]["TopicEndpoint"]
    TopicAccessKey = config["twitter"]["TopicAccessKey"]
    bearer_token = config["twitter"]["bearer_token"]

    # Search terms
    search_terms = [
        "(Covid OR Covid19 OR coronavirus OR pandemic OR virus OR #spread OR #cases)"
    ]

    # Define a stream object
    stream = MyStream(
        bearer_token=bearer_token,
        TopicAccessKey=TopicAccessKey,
        TopicEndpoint=TopicEndpoint,
    )

    # Add rules to the stream
    for term in search_terms:
        stream.add_rules(tweepy.StreamRule(term))

    # Define the filters
    stream.filter(
        tweet_fields=[
            "lang",
            "entities",
            "author_id",
            "created_at",
            "referenced_tweets",
        ]
    )