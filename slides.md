# Kafka Connect

## Big Picture

- Written as an integration platform to gather data from a wide variety of sources
- Stores each set of data in a Topic
- Data is guaranteed to be in order it was received, and can be retained for as long as you want

## Connect

- The most common use case was "I want to put data from here and then send it there"
- These all looked pretty much the same
  - How to get the data
  - Where to put the data
  - How to find new data
  - How often to check
  - Etc.

- Kafka Connect wraps up that use case in to a simple tool
- Boiler plate is handled by Connect, all you provide is a small configuration file

## Sources

In Kafka terminology, a 'Source' is a place you get data from. 

Today I'll be using an Oracle database as my Source, but there are lots of other types of sources

- Databases
- Key/Value stores (e.g., Redis)
- Message queues (e.g., SQS or RabbitMQ)
- Files
- Other Kafka topics

### Sinks

The place that you're sending data too is called a Sink.

You don't have to have a sink. Maybe you're just keeping the data in Kafka until you figure out what to do with it.

You can have as many sinks as you want for a single set of data. So, you could get one set of data from a Source and then send it to

- Another database
- A key/value cache
- A message queue
- Splunk
- Another Kafka topic

- Each Sink is independent and has no impact on the other sinks.
  - This is different from something like Amazon SQS, where data is removed when it is read

## Actual combinations

Some examples of Connect combinations in current use at UMN

- Source data from a vendor's MSSQL database
- Sink application log data to Splunk
- Sink event stream data to Amazon SQS
- Source Amazon SQS data as a work queue

## Available Connectors

https://www.confluent.io/hub/

## Demo of Actual Usage

- We're going to move data from hoteldev to hoteltst

- First, here's our hoteldev table, `people`
  - Pretty basic, it has an id, name column and timestamps to show when each row was created and updated
  - It also implements soft deletion, so there's a y/n value to show if the record is deleted
    - We'll talk more about that in a minute

- Here's our hoteltst database.
  - It has no `people` table

- First we want to get this data in to Kafka, we need a Source

- Here's a Kafka connect configuration file for our Source
  - Name to identify our worker
  - What kind of Source it is
  - How to connect to the database
  - A very simple query
  - How to identify new or updated records
  - How often to check

- We add this configuration to Connect via a REST API

- If we then look at Kafka we can see a topic and it contains all our data

- If I add a new row to the database, it appears in Kafka

- Now we want to use a Sink to move this data in to hoteldev

- Here's our Sink configuration file

- We add that via the same REST API

- Now if we look at the hoteltst database we see there's a `person` table

- And if I add a new row in `hoteldev` it appears in `hoteltst`

- And if I update a row in `hoteldev` that update appears in `hoteltst`

## Real World Considerations

- The source table structure is changing
  - Use `select [columns]` instead of `select *`
  - Kafka supports the evolution of data sets, as long as you follow certain rules

- My source and sink databases are not the same type
  - The JDBC connectors do a pretty good job of converting between DBMS

- Hard record deletion
- No timestamps

## But what if there are hard deletes? Or no timestamps

- CDC Layer Tool

- Retrieves Inserts/Updates/Deletes directly from the database logs
- Stores them in Kafka
- Then you apply those same changes to your sink database

## Other

- Transforms
- ksqlDB


## Resources

- https://www.confluent.io/blog/kafka-connect-deep-dive-jdbc-source-connector
- https://docs.confluent.io/kafka-connect-jdbc/current/source-connector/
- https://dzone.com/articles/kafka-connect-strategies-to-handle-updates-and-del
- https://rmoff.net/2018/12/12/streaming-data-from-oracle-into-kafka/
- https://talks.rmoff.net/ixPL5r/integrating-oracle-and-kafka
- https://talks.rmoff.net/ScGJTe
