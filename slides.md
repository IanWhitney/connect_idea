theme: Letters from Sweden, 4

# [fit] Kafka Connect

---

# [fit] Kafka

---

# Kafka
- Data integration platform
- Open Source (Apache)
- Highly scalable, reliable and available

---

# Kafka (cont.)
- Stores data in Topics
  - Retain for as long as you want
  - High-throughput writes
  - Immutable and data order is guaranteed

---

# [fit] Connect

---

# Connect
There is a very common use case for Kafka

> I want to take data from here and move it there

---

# Connect

- These all looked pretty much the same
  - How to connect to Kafka
  - How to get the data
  - Where to put the data
  - How to find new data
  - How often to check for new data
  - Etc.

---

# Connect

- Connect wraps up that use case in to a simple tool
- Boiler plate is handled by Connect, all you provide is a small configuration file
- Connect then spins up a worker that does the work

---

# [fit] Data
## Sources and Sinks

---

# Sources

[.column]

In Connect terminology, a 'Source' is a worker that gets data from somewhere and puts it in Kafka.

[.column]

- Databases
- Key/Value stores (e.g., Redis)
- Message queues (e.g., SQS or RabbitMQ)
- Files
- More!

---

# Sinks

[.column]

Workers that take data from Kafka and put it somewhere else are called Sinks.

You can have as many sinks as you want for a single set of data. 

Reading the data does not delete it.

[.column]

- Another database
- A key/value cache
- A message queue
- A file
- An external system (e.g. Splunk)
- Another Kafka topic

---

# Actual Usage

Some examples of Connect in current use at UMN

- Source data from a vendor's MSSQL database
- Sink application log data to Splunk
- Sink event stream data to Amazon SQS
- Source Amazon SQS data as a work queue

---

# Available Connectors

https://www.confluent.io/hub/

---

# [fit] Demo
## Move data <br />From `hoteldev` <br />Into `hoteltst`

---

_demo movie here_

---

# Real World Considerations

- As with most demos, that looked really easy.

- But as you watched it, you probably though of lots of real world complications

---

# Real World Considerations
## Different Databases

[.column]

- What if I want to move data from Oracle to MySQL, which has different datatypes

[.column]

- The Kafka Sink worker does a pretty good job of converting between databases
- Or, you could `cast` in your Source query to get things in to a datatype that both database share 

---

# Real World Considerations
## Table Structure Changes

[.column]

- What if the structure of the `people` table changes in `hoteldev`?

[.column]

- In some cases Kafka will just handle it
- Select specific columns, not `select *`
- If these don't solve the problem then there are other ways of handling this

---

# Real World Considerations
## No Timestamps and Hard Deletes

[.column]

- My source database doesn't have timestamps. And we hard delete records.

[.column]

- Ah! You're using PeopleSoft
- This is where things get interesting

---

# No Timestamps and Hard Deletes
## Why Is This A Problem?

[.column]

### Your Source Query
```sql
SELECT
  *
FROM
  people
```

[.column]

### What Connect Executes
```sql
SELECT
  *
FROM
  people
WHERE 
  updated_at > cutoff_timestamp
  OR
  id > cutoff_id
```

^ - How does the Source work? If you dig in to it, it's pretty simple
^ - If that query returns anything, the data is added to Kafka.
^ - But how can that work if your database table doesn't have an incrementing primary key or timestamp?
^ - There are different answers depending on what you need?

---

# No Timestamp Columns?
## Use ROWSCN
- Oracle identifies transactions with a monotonically increasing number
- Can be used to identify new and changed rows

---

# ROWSCN

[.column]

### Your Source Query

```sql
SELECT
  ora_rowscn AS source_rowscn,
  people.*
FROM
  people
```

[.column]

### What Connect Executes

```sql
SELECT
  ora_rowscn AS source_rowscn,
  people.*
FROM
  people
WHERE
  ora_rowscn > last_rowscn
```

---

# ROWSCN

[.column]

## Pros
- Gets updates and inserts

[.column]

## Cons
- Won't get hard deletes
- You'll still need a primary key to update records in your Sink
- Not all RDBMS have this kind of column

---

# No Primary Key?
## Use Bulk Imports

- Bring in all table data on a schedule
- Use an automated job to remove old imports

--- 

# Bulk Imports

[.column]

### Your Source Query

```sql
SELECT
  systimestamp AS version,
  people.*
FROM
  people
```

[.column]

### What Connect Executes

```sql
SELECT
  systimestamp AS version,
  people.*
FROM
  people
```

---

# Bulk Imports

[.column]

## Pros
- Does get all inserts, updates, _and hard deletes_
- Congratulations, you've now recreated PS Snap!

[.column]

## Cons
- Not a good near-live solution
- Might miss transactions that are occurring while it's extracting data
- Congratulations, you've now recreated PS Snap!

---

# No primary key or timestamps?
# Use CDC 

- Databases logs every insert, update, and delete
- We can create a Source that ingests these logs in to Kafka
- And then use Sink(s) to replicate those changes

--- 

# CDC

[.column]

## Pros
- Near-live
- Includes all inserts, updates, _and hard deletes_


[.column]

## Cons
- Requires access to database replication logs
- Harder to setup than a query-based Source/Sink

---

## Resources

- https://www.confluent.io/blog/kafka-connect-deep-dive-jdbc-source-connector
- https://docs.confluent.io/kafka-connect-jdbc/current/source-connector/
- https://dzone.com/articles/kafka-connect-strategies-to-handle-updates-and-del
- https://rmoff.net/2018/12/12/streaming-data-from-oracle-into-kafka/
- https://talks.rmoff.net/ixPL5r/integrating-oracle-and-kafka
- https://talks.rmoff.net/ScGJTe

- https://docs.confluent.io/kafka-connect-jdbc/current/sink-connector/index.html
