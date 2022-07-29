- In this demo we're going to get data from Oracle hoteldev
, put it in Kafka and then put it in hoteltst

- So, to start off with here's my table in hoteldev.

- It's pretty simple. An id column, a name column, a soft-delete column and then timestamps to show when the record was created and updated.
  - We'll talk more about that soft-delete column in a second

- And here's my hoteltst database. It currently does not have a people table.

- First we want to get the data from hoteldev and put it in Kafka. This is a "Source"

- Here is our Source config file, with our credentials removed.

- Let's go through this real quick
  - The first three lines tell Connect what kind of worker we're creating and where it should store the data
  - The next 5 lines tell Connect how to get the data
    - A simple query to get everything from people
    - Then we tell it that it can identify new records two ways, either by their timestamp or id values
    - Then we tell it to check for new data once a second
  - Finally, we tell it how to connect to the database

- We create our worker through a REST API. 

- Then we wait a few seconds for the worker to be created.

- Here I'm using a little command line tool that connects to Kafka and shows me any data contained in the `ideaa.people` topic.

- If our worker is working, I should see the same data that we see in hoteldev

- And there it is.

- Let's add a new row to the database

- And there it shows up in Kafka

- Let's update an existing row in the database

- And the change shows up in Kafka

- Note that the change does not remove the first entry in Kafka. It's still there.

- Ok, our Source is working. Now let's look at getting the data in to hoteltst.

- Here is our Sink configuration. 

- Much of it looks the same as our Source configuration. 
  - But these last 5 rows are unique to the Sink
  - They tell Connect what table the data should end up in
  - That it should create the table if it doesn't exist
  - And how records are uniquely identified so that it can handle updates correctly 

- We create our Sink worker the same way, via the REST API

- Now let's take a look at hoteltst.

- It now has a People table. And it has all the rows that are in hoteldev.

- Notice how the row we changed has the current state of the row.

- If I add a new row in hoteldev and change an existing row.

- Those changes appear in hoteltst.
