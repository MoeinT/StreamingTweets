import pyspark.sql.types as t
import pyspark.sql.functions as f
# COMMAND ----------
%scala
Class.forName("org.apache.spark.sql.eventhubs.EventHubsSource")
# COMMAND ----------
dbutils.secrets.list("secret-scopes")
# COMMAND ----------
# MAGIC %md
# MAGIC ### Eventhub Configuration

# COMMAND ----------
namespaceConnectionString = dbutils.secrets.get(scope = "secret-scopes", key = "Eventhub-ns-conn-str")
TweetsEventhubName = "StreamingTweets-dev"

EventhubConnectionString = namespaceConnectionString + ";EntityPath=" + TweetsEventhubName

EventHubConfiguration = {
    'eventhubs.connectionString' :
    sc._jvm.org.apache.spark.eventhubs.EventHubsUtils.encrypt(EventhubConnectionString)
}
# COMMAND ----------
# MAGIC %md
# MAGIC ### Raw streams

# COMMAND ----------

TweetSchema = t.StructType(
    [
        t.StructField("created_at", t.TimestampType(), True),
        t.StructField("hashtags", t.StringType(), True),
        t.StructField("lang", t.StringType(), True),
        t.StructField("tweet", t.StringType(), True),
        t.StructField("tweet_type", t.StringType(), True),
        t.StructField("user_id", t.LongType(), True)
    ]
)

EventGridSchema = t.ArrayType(
  t.StructType(
      [
    t.StructField('id', t.StringType(), nullable=True),
    t.StructField('subject', t.StringType(), nullable=True),
    t.StructField('data', t.StringType(), nullable=True),
    t.StructField('eventType', t.StringType(), nullable=True),
    t.StructField('dataVersion', t.StringType(), nullable=True),
    t.StructField('metadataVersion', t.StringType(), nullable=True),   
    t.StructField('eventTime', t.StringType(), nullable=True),
    t.StructField('topic', t.StringType(), nullable=True) 
      ]
  )
)

startInputDF = (
    spark
    .readStream
    .format("eventhubs")
    .options(**EventHubConfiguration)
    .load()
    
    .select(f.col("body").cast(t.StringType()))
    .select(f.from_json(f.col("body"), EventGridSchema).alias("event"))
    .select(f.explode(f.col("event")).alias("event"))
    .select("event.*")
    .select("data")
    .select(f.from_json(f.col("data"), TweetSchema).alias("Tweet"))
    .select("Tweet.*")
)

# COMMAND ----------
# MAGIC %md
# MAGIC ### Debugging

# COMMAND ----------
display(
    startInputDF, 
    streamName = "DisplayMemoryQuery", 
    processingTime = "10 seconds"
)
# COMMAND ----------
# MAGIC %md
# MAGIC ### SQL Database configuration

# COMMAND ----------
SQLServerName = dbutils.secrets.get(scope = "secret-scopes", key = "sql-server-name")
SQLDatabase = dbutils.secrets.get(scope = "secret-scopes", key = "sql-database")
sqlPort = 1433

username = dbutils.secrets.get(scope = "secret-scopes", key = "sql-login-username")
password = dbutils.secrets.get(scope = "secret-scopes", key = "sql-login-password")

SQLServerUrl = f"jdbc:sqlserver://{SQLServerName}:{sqlPort};database={SQLDatabase}"
connectionProperties = {
    "user": username,
    "password": password, 
    "driver": "com.microsoft.sqlserver.jdbc.SQLServerDriver"
}

# COMMAND ----------

# MAGIC %md
# MAGIC ### Write to SQL

# COMMAND ----------

containername  = "commonfiles-dev"
mountpoint     = f"/mnt/{containername}"

# COMMAND ----------

def WriteToSQLdb(batchDF, batchID):
    (
        batchDF
        .write
        .jdbc(SQLServerUrl, "RawCovidStreams", "append", connectionProperties)
    )

    pass

aggregatedStreamingQuery = (
    startInputDF
    .writeStream
    .foreachBatch(WriteToSQLdb)
    .queryName("TweetQuerySQL")
    .option("checkpointLocation", f"{mountpoint}/CovidTweets/Checkpoints/SqlCheckpoints")
    .trigger(processingTime= "10 seconds")
    .start()
)

# COMMAND ----------
# MAGIC %md
# MAGIC ### Write to a Datalake in parquet format
# COMMAND ----------
(
    startInputDF
    .writeStream
    .queryName("TweetQueryParquet")
    .format("parquet")
    .option("path", f"{mountpoint}/CovidTweets/CovidStreams.parquet")
    .option("checkpointLocation", f"{mountpoint}/CovidTweets/Checkpoints/parquetCheckpoints")
    .trigger(processingTime= "10 seconds")
    .start()
)
# COMMAND ----------

# MAGIC %md
# MAGIC ### Write to a Datalake in Deltalake format

# COMMAND ----------
(
    startInputDF
    .writeStream
    .queryName("TweetQueryDeltaLake")
    .format("delta")
    .option("path", f"{mountpoint}/CovidTweets/CovidStreams.delta")
    .option("checkpointLocation", f"{mountpoint}/CovidTweets/Checkpoints/DeltaLakeCheckpoints")
    .trigger(processingTime= "10 seconds")
    .start()
)
# COMMAND ----------

# MAGIC %md
# MAGIC - ### Create a Database and a Delta Table

# COMMAND ----------

%sql
CREATE DATABASE IF NOT EXISTS tweetsDB;

CREATE OR REPLACE TABLE tweetsDB.CovidTweets
(
  created_at TIMESTAMP,
  hashtags STRING, 
  lang STRING,
  tweet STRING,
  tweet_type STRING,
  user_id BIGINT
)
  USING DELTA

# COMMAND ----------

# MAGIC %md
# MAGIC ### Write into a delta Table
# COMMAND ----------

(
    startInputDF
    .writeStream
    .format("delta")
    .outputMode("append")
    .option("checkpointLocation", f"{mountpoint}/CovidTweets/Checkpoints/DeltaTableCheckpoints")
    .trigger(processingTime= "5 seconds")
    .table("tweetsDB.CovidTweets")
)

# COMMAND ----------
# MAGIC %md
# MAGIC ### Check the counts
# COMMAND ----------

%sql
select count(*) as n_tweets from tweetsDB.CovidTweets

# COMMAND ----------

# MAGIC %md
# MAGIC ### Check the history

# COMMAND ----------
%sql
describe history tweetsDB.CovidTweets
# COMMAND ----------