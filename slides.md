# Kafka Connect

- High-Level Kafka Arch
- The most common use case was "I want to put data from here and then send it there"
- Kafka Connect wraps up that use case in to a simple tool

## Connectors

### Sources

### Sinks
- Databases
- Files
- Message Queues

## Available Connectors

https://www.confluent.io/hub/

## Possible (and real) combinations

## Demo of Actual Usage

- Oracle to Oracle
  - Application DB on Dev
  - Application DB on Tst
  - Show table in Dev 
  - Show schema in Tst, table does not exist
  - Add connector
  - Show schema in Tst, with table and data
  - Add new row in Dev
  - Show new row in Tst


- No DB links
- Near-live replication

- External db to Kafka to Oracle

- From SQS
- To SQS
- To Splunk

## Constraints
- No Hard Deletes
- Timestamps or reliable incrementation

## But what if there are hard deletes? Or no timestamps

- CDC Layer Tool

## Other

- Transforms
- ksqlDB

---

# Docker

- Kafka Cluster w/ Connect


# Other

- Connection to a Oracle DB in Dev
- Connection to an Oracle DB in Tst
- Table in Dev
  - Primary Key
  - Name
  - Timestamp
- Data in table



