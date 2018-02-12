


--- export PGPASSWORD=<password>
--- psql -h <host> -d <database> -U <user_name> -p <port> -a -w -f <file>.sql

--- CREATE INDEX test2_mm_idx ON test2 (major, minor);

--- Currently, only the B-tree, GiST, GIN, and BRIN index types support multicolumn indexes. 
--- Up to 32 columns can be specified. (This limit can be altered when building PostgreSQL; see the file pg_config_manual.h.)


DROP SCHEMA  IF exists aidb;

--- CREATE SCHEMA aidb;
CREATE SCHEMA IF NOT EXISTS aidb;

---
--- LOCATION or address
---
CREATE TABLE aidb.location (
    id integer PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    country         text NOT NULL,
    state           text NOT NULL,
    town            text NOT NULL,
    street          text NOT NULL,
    zipcode         text NOT NULL
);
COMMENT ON TABLE aidb.location IS 'Location or address of asset/person/company';

CREATE index location_idx  ON aidb.location (id);

CREATE TABLE aidb.room (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    room_name text not null,
    rack            text NOT NULL,
    rack_position   text NOT NULL
);
---
--- POSITION of hw at certain location
---
CREATE TABLE aidb.position (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    building        INTEGER REFERENCES aidb.location (id),
    floor           INTEGER NOT NULL,
    fire_compartment           INTEGER REFERENCES aidb.room (id)
);



CREATE INDEX position_id_index ON aidb.position (id);

--- CREATE VIEW comedies AS
---    SELECT *
---    FROM films
---    WHERE kind = 'Comedy';

---
--- COMPANY
---
CREATE TABLE aidb.contact (
    id integer      PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name            text NOT NULL,
    phone           text NOT NULL,
    phone2          text NOT NULL,
    email           text NOT NULL,
    other           text NOT NULL ---fax and others
);

CREATE INDEX contact_id_index ON aidb.contact (name, phone, email);

CREATE TABLE aidb.corporation (
    id integer      PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    name            text NOT NULL,
    tax_id          text NOT NULL,
    bank_acc        text NOT NULL,
    corp_address    INTEGER REFERENCES aidb.location (id),
    corp_contact    INTEGER REFERENCES aidb.contact (id),
    descr           text NOT NULL
);

CREATE TABLE aidb.department (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    corp_id         INTEGER REFERENCES aidb.corporation (id),
    dept_contact    INTEGER REFERENCES aidb.contact (id),
    dept_name       text NOT NULL,
    dept_descr      text NOT NULL
);

CREATE TABLE aidb.project (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    corp_id         INTEGER REFERENCES aidb.corporation (id),
    proj_contact    INTEGER REFERENCES aidb.contact (id),
    proj_name       text NOT NULL,
    proj_descr      text NOT NULL
);

CREATE TABLE aidb.employee (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    dept_id         INTEGER REFERENCES aidb.department (id),
    dept_contact    INTEGER REFERENCES aidb.contact (id),
    descr           text NOT NULL
);

CREATE TABLE aidb.proj_member (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    proj_id         INTEGER REFERENCES aidb.project (id),
    member          INTEGER REFERENCES aidb.employee (id),
    descr           text NOT NULL
);

---
--- HOST
---
CREATE TABLE aidb.network_interface (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    --- ip_addr         inet NOT NULL,   PUT TO STACK, one NIC can have several ports
    --- mac       macaddr,
    model    text not null
);

CREATE TABLE aidb.network_port (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    nic         INTEGER REFERENCES aidb.network_interface (id),
    --- ip_addr         inet NOT NULL,   PUT TO STACK, one NIC can have several ports
    mac       macaddr  NOT null,
    mtu        integer
);

CREATE TABLE aidb.bond (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    bond_name       text not null,
    nic_port         INTEGER REFERENCES aidb.network_port (id)
);

CREATE TYPE aidb.host_type AS ENUM ('physical', 'virtual','not_specified');

CREATE TYPE aidb.host_category AS ENUM ('server','hypervisor', 'router','switch', 'ups','firewall');    --- zalozne zdroje

CREATE TABLE aidb.hw (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    fire_compartment        INTEGER REFERENCES aidb.room (id),
    manufacturer text,
    model   text,
    serial_number text,
    cpus   integer,
    ram_gb  integer,
    --- storage instead of HDDs???
    purchase_order text
);

CREATE TABLE aidb.host (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    --- nic            INTEGER REFERENCES aidb.network_interface (id),
    hostname        text NOT NULL,
    host_t          aidb.host_type NOT NULL DEFAULT 'not_specified',
    physical_host            INTEGER REFERENCES aidb.hw (id),
    fqdn    text NOT NULL DEFAULT 'localhost.localdomain'
);

CREATE INDEX host_id_index ON aidb.host (id);


CREATE TABLE aidb.virtual_host (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
---    building        INTEGER REFERENCES aidb.position (id),
    host            INTEGER REFERENCES aidb.host (id)
);

CREATE TABLE aidb.container (
    id              INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    container_name text,
    image                  text,
    host            INTEGER REFERENCES aidb.host (id)
);


--- cidr 	7 or 19 bytes 	IPv4 and IPv6 networks
--- inet 	7 or 19 bytes 	IPv4 and IPv6 hosts and networks
--- macaddr 	6 bytes 	MAC addresses
--- macaddr8 	8 bytes 	MAC addresses (EUI-64 format)

--- The essential difference between inet and cidr data types is that inet accepts values 
--- with nonzero bits to the right of the netmask, whereas cidr does not. For example, 192.168.0.1/24 is valid for inet but not for cidr.