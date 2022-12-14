create table people (
    id number(8,0) GENERATED BY DEFAULT ON NULL AS IDENTITY,
    name varchar(30) not null,
    deleted char(1) default 'N',
    created_at timestamp default systimestamp,
    updated_at timestamp default systimestamp,
    CONSTRAINT deleted_boolean CHECK (deleted in ('Y', 'N'))
);

CREATE OR REPLACE TRIGGER updated_at_timestamp
  BEFORE UPDATE ON people
  FOR EACH ROW
BEGIN
  :new.updated_at := systimestamp;
END;
/

insert into people (name) values ('Zachary Maynard');
insert into people (name) values ('Dorian Warren');
insert into people (name) values ('Riley Mosley');
insert into people (name) values ('Jacques Ibarra');
insert into people (name) values ('Odell Alvarado');
commit;
