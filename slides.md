theme: work, 7
footer: https://z.umn.edu/connect_ideaa

# [fit] Kafka<br />Connect

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
  - Can be read multiple times
  - Immutable and data order is guaranteed

---

# [fit] Connect

---

# Connect

> I want to take data from here and move it there

[.column]
  - How to connect to Kafka
  - How to get the data

[.column]
  - Where to put the data
  - How to find new data
  - How often to check for new data

---

# Connect

- Connect wraps up that use case in to a simple tool
- Boiler plate is handled by Connect, all you provide is a small configuration file
- Connect then spins up a worker that does the work

---

# [fit] Workers
## Sources and Sinks

---

# Sources

[.column]

In Connect terminology, a 'Source' is a worker that gets data from somewhere and puts it in Kafka.

[.column]

- Databases
- Key/Value stores
  - e.g., Redis
- Message queues 
  - e.g., SQS
- Files
- More!

---

# Sinks

[.column]

Workers that take data from Kafka and put it somewhere else are called Sinks.

You can have as many sinks as you want for a single set of data. 

[.column]

- Database
- key/value store
- Message queue
- File
- External system 
  - e.g. Splunk
- More!

---

# Actual Usage

Some examples of Connect in current use at UMN

- Source data from a vendor's MSSQL database
- Sink application log data to Splunk
- Sink event stream data to Amazon SQS
- Source Amazon SQS data as a work queue

---

# Connect Worker Options

- Lots!
- We're going to demo JDBC Source and Sink

https://www.confluent.io/hub/

---

# [fit] Demo
## Move data <br />From `hoteldev` <br />Into `hoteltst`

---

[.hide-footer]
[.slidecount: false]

![autoplay](demo.mp4)

---

# Real World Considerations

- As with most demos, that looked really easy.

- But as you watched it, you probably though of lots of real world complications

- It will help if we understand what our Source and Sink workers are doing.

---

# What Our Source Worker Does

[.column]

## Our Source Query

```sql
SELECT
  *
FROM
  people
```

## What Connect Executes

```sql
SELECT
  *
FROM
  people
WHERE
  updated_at > last_time_i_checked
  OR
  id > biggest_id_i_have_seen
```

[.column]

- Any rows returned by the query are written to Kafka topic
- Won't return hard deletes
- `updated_at` needed to find changed records
- `id` needed to find new records

---

# What Our Sink Worker Does

[.column]

## Our Sink Command

```sql
MERGE INTO PEOPLE USING dual on ( id=21 )
WHEN MATCHED THEN
  UPDATE SET name='updated',
    created_at=1659533399130,
    updated_at=1659533399130,
WHEN NOT MATCHED THEN
  INSERT
    (id, name, created_at, updated_at)
  VALUES
    (21, 'updated', 1659533399130, 1659533399130)
```

[.column]

- Requires a way to uniquely identify a row

---

# Some possible solutions

- Use `ora_rowscn`
- Do bulk imports
- CDC
- Roll your own

---

# Use `ora_rowscn`

- Oracle identifies transactions with a unique number
- Used by Connect to identify Inserts and Updates

[.column]

## Pros

- Get updates and inserts without primary key or timestamp columns

[.column]

## Cons

- Won't get hard deletes
- Still need a primary key to use `upsert`
- Oracle specific

--- 

# Bulk imports

- Connect can get all records at once -- "Bulk" import
- Sink does a "Bulk" write of all records to the target 

[.column]

## Pros

- Get updates and inserts **and deletes**
- You have recreated PS Snap! 🎊

[.column]

## Cons

- Not a near-live solution
- You have recreated PS Snap! 🎊

--- 

# CDC

- Uses DB replication logs, not the tables, as the Source
- Sink replays those logs against your targets

[.column]

## Pros

- Get updates and inserts **and deletes**
- Near-live

[.column]

## Cons

- Requires escalated database access
- Config is more complex

---

# Roll Your Own

- Connect was meant to make 80% of common tasks easier
- But for special cases you can bypass Connect and write your own

[.column]

## Pros

- Implements exactly the logic you need

[.column]

## Cons

- Writing and maintenance is on you

---

# Datatypes

[.column]

What if I want to move data from Oracle to MySQL, which has different datatypes?

[.column]

- The Kafka Sink worker does a pretty good job of converting between databases
- Or, you could `cast` in your Source query to get things in to a datatype that both database share 

---

# Schema Evolution

[.column]

What if the structure of the `people` table changes in `hoteldev`?

[.column]

- In some cases Kafka will just handle it
- Select specific columns, not `select *`

---

## Resources

- [Kafka Connect Deep Dive – JDBC Source Connector](https://www.confluent.io/blog/kafka-connect-deep-dive-jdbc-source-connector)
- [Kafka Connect: Strategies To Handle Updates and Deletes](https://dzone.com/articles/kafka-connect-strategies-to-handle-updates-and-del)
- [Streaming data from Oracle into Kafka](https://rmoff.net/2018/12/12/streaming-data-from-oracle-into-kafka/)
- [Kafka Connect 101: Introduction to Kafka Connect](https://www.youtube.com/watch?v=lRBpR5td2nc&list=PLa7VYi0yPIH0uIC2F0M1_FsVUsx8j3ekm)
- [JDBC Source Connector: What could go wrong?](https://www.confluent.io/en-gb/events/kafka-summit-london-2022/jdbc-source-connector-what-could-go-wrong/)
- [Integrating Oracle and Kafka](https://talks.rmoff.net/ixPL5r/integrating-oracle-and-kafka)
- [From Zero to Hero with Kafka Connect](https://talks.rmoff.net/ScGJTe)

--- 

## Presentation Links

- [These slides](https://z.umn.edu/connect_ideaa) 
  - `https://z.umn.edu/connect_ideaa`
- [The demo video](https://z.umn.edu/connect_ideaa_demo)
  - `https://z.umn.edu/connect_ideaa_demo`
- Me
  - whit0694@umn.edu/Ian Whitney on OIT and Tech People Slacks
  - It is literally my job to talk about Kafka
