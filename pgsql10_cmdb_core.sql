--- export PGPASSWORD=
--- psql -h  -d  -U  -p  -a -w -f .sql
--- DOCKER: sudo docker run -it --name pg10 -p 5432:5432 -e POSTGRES_PASSWORD=post123 -d postgres
DROP SCHEMA IF EXISTS aidb;

--- CREATE SCHEMA aidb;
CREATE SCHEMA IF NOT EXISTS aidb;

---
--- LOCATION or address
---
CREATE TABLE aidb.location (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
country TEXT NOT NULL,
STATE TEXT NOT NULL,
town TEXT NOT NULL,
street TEXT NOT NULL,
zipcode TEXT NOT NULL);

COMMENT ON TABLE aidb.location IS 'Location or address of asset/person/company';

CREATE INDEX location_idx ON aidb.location (id);

CREATE TABLE aidb.room (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
room_name TEXT NOT NULL,
rack TEXT NOT NULL,
rack_position TEXT NOT NULL);

---
--- POSITION of hw at certain location
---
CREATE TABLE aidb.position(
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
building INTEGER REFERENCES aidb.location (id),
floor INTEGER NOT NULL,
fire_compartment INTEGER REFERENCES aidb.room (id));

CREATE INDEX position_id_index ON aidb.position(id);

--- CREATE VIEW comedies AS
---    SELECT *
---    FROM films
---    WHERE kind = 'Comedy';
---
--- LICENSE of hw and sw
---
CREATE TABLE aidb.license (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
license_name TEXT NOT NULL,
description TEXT,
purchase_order TEXT,
expire_on DATE);

---
--- COMPANY
---
CREATE TABLE aidb.contact (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
name TEXT NOT NULL,
phone TEXT NOT NULL,
phone2 TEXT NOT NULL,
email TEXT NOT NULL,
other TEXT NOT NULL ---fax and others
);

CREATE INDEX contact_id_index ON aidb.contact (name, phone, email);

CREATE TABLE aidb.corporation (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
name TEXT NOT NULL,
tax_id TEXT NOT NULL,
bank_acc TEXT NOT NULL,
corp_address INTEGER REFERENCES aidb.location (id),
corp_contact INTEGER REFERENCES aidb.contact (id),
descr TEXT NOT NULL);

CREATE TABLE aidb.department (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
corp_id INTEGER REFERENCES aidb.corporation (id),
dept_contact INTEGER REFERENCES aidb.contact (id),
dept_name TEXT NOT NULL,
dept_descr TEXT NOT NULL);

CREATE TABLE aidb.project (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
corp_id INTEGER REFERENCES aidb.corporation (id),
proj_contact INTEGER REFERENCES aidb.contact (id),
proj_name TEXT NOT NULL,
proj_descr TEXT NOT NULL);

CREATE TABLE aidb.employee (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
dept_id INTEGER REFERENCES aidb.department (id),
dept_contact INTEGER REFERENCES aidb.contact (id),
descr TEXT NOT NULL);

CREATE TABLE aidb.proj_member (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
proj_id INTEGER REFERENCES aidb.project (id),
MEMBER INTEGER REFERENCES aidb.employee (id),
descr TEXT NOT NULL);









---
--- HOST type
---
CREATE TYPE aidb.host_type AS ENUM ('physical',
    'virtual',
    'not_specified'
);

---
--- HOST category
---
CREATE TYPE aidb.host_category AS ENUM ('server',
    'hypervisor',
    'router',
    'switch',
    'ups',
    'firewall'
);

---
--- HARDWARE
---
CREATE TABLE aidb.hw (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
fire_compartment INTEGER REFERENCES aidb.room (id),
manufacturer TEXT,
model TEXT,
serial_number TEXT,
cpus INTEGER,
purchase_order TEXT);


---
--- HDD type
---
CREATE TYPE aidb.storage_type AS ENUM ('hdd',
    'ssd'
);

---
--- HDD
---
CREATE TABLE aidb.motherboard (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
vendor INTEGER REFERENCES aidb.hw (id),  --- either it belongs to storage/server or it's single hdd in stock
model TEXT, -- product
serial_num INTEGER,
purchase_order TEXT);

---
--- HDD
---
CREATE TABLE aidb.hdd (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
host INTEGER REFERENCES aidb.hw (id),  --- either it belongs to storage/server or it's single hdd in stock
serial_num TEXT,
manufacturer TEXT,
hdd_type aidb.storage_type,
size_gb INTEGER,
hdd_slot INTEGER,
purchase_order TEXT);

---
--- CPU
---
CREATE TABLE aidb.cpu (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
vendor INTEGER REFERENCES aidb.hw (id),  --- either it belongs to storage/server or it's single hdd in stock
model TEXT, --product
slot INTEGER,
purchase_order TEXT);

---
--- MEMORY
---
CREATE TABLE aidb.ram (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
hw_host INTEGER REFERENCES aidb.hw (id),
model TEXT, -- product
vendor TEXT,
module_description INTEGER,
size text,
slot text,
purchase_order TEXT);

---
--- PSU
---
CREATE TABLE aidb.power_supply (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
hw_host INTEGER REFERENCES aidb.hw (id),
model TEXT, -- product
vendor TEXT,
module_description INTEGER,
purchase_order TEXT);

---
--- FAN
---
CREATE TABLE aidb.fan (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    hw_host INTEGER REFERENCES aidb.hw (id),
    model TEXT, -- product
    vendor TEXT,
    module_description INTEGER,
    purchase_order TEXT);

---
--- NIC type
---
CREATE TYPE aidb.nic_type AS ENUM ('ether',
    'fibre',
    'management_module',
    'infiniband'
);

---
--- NIC
---
CREATE TABLE aidb.network_interface (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,  --- ip_addr         inet NOT NULL,   PUT TO STACK, one NIC can have several ports
    nic_t aidb.nic_type NOT NULL DEFAULT 'ether',
    hw_host INTEGER REFERENCES aidb.hw (id),
    model TEXT NOT NULL,
    vendor TEXT,
    purchase_order TEXT);


---
--- Network PORT (physical port on NIC)
---
CREATE TABLE aidb.network_port (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    nic INTEGER REFERENCES aidb.network_interface (id), --- ip_addr         inet NOT NULL,   PUT TO STACK, one NIC can have several ports
    mac macaddr NOT NULL,
    mtu INTEGER);

---
--- Network BOND
---
CREATE TABLE aidb.bond (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    bond_name TEXT NOT NULL,
    nic_port INTEGER REFERENCES aidb.network_port (id));



---
--- FAN
---
CREATE TABLE aidb.operating_system (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    hw_host INTEGER REFERENCES aidb.hw (id),
    vendor TEXT, --- canonical,ubuntu
    os_name TEXT, -- uname -o
    kernel_version TEXT,   --- uname -r / 4.14.18-300.fc27.x86_64
    arch text, --- uname -m/-p
    purchase_order TEXT);


---
--- HOST
---
CREATE TABLE aidb.host(
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    hostname TEXT NOT NULL,
    host_t aidb.host_type NOT NULL DEFAULT 'not_specified',
    physical_host INTEGER REFERENCES aidb.hw (id),
    fqdn TEXT NOT NULL DEFAULT 'localhost.localdomain');

CREATE INDEX host_id_index ON aidb.host(id);

---
--- ROUTER
---
CREATE TABLE aidb.router (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT NOT NULL,
    host_t aidb.host_type NOT NULL DEFAULT 'not_specified',
    physical_host INTEGER REFERENCES aidb.hw (id),
    fqdn TEXT NOT NULL DEFAULT 'localhost.localdomain');

CREATE INDEX router_id_index ON aidb.router (id);

---
--- FIREWALL
---
CREATE TABLE aidb.firewall (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT NOT NULL,
    host_t aidb.host_type NOT NULL DEFAULT 'not_specified',
    physical_host INTEGER REFERENCES aidb.hw (id),
    fqdn TEXT NOT NULL DEFAULT 'localhost.localdomain');

CREATE INDEX fw_id_index ON aidb.firewall (id);


---
--- SWITCH
---
CREATE TABLE aidb.switch (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT NOT NULL,
    host_t aidb.host_type NOT NULL DEFAULT 'not_specified',
    physical_host INTEGER REFERENCES aidb.hw (id),
    fqdn TEXT NOT NULL DEFAULT 'localhost.localdomain');

CREATE INDEX switch_id_index ON aidb.switch (id);

---
--- STORAGE SERVER
---
CREATE TABLE aidb.storage_server (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    hostname TEXT NOT NULL,
    host_t aidb.host_type NOT NULL DEFAULT 'not_specified',
    physical_host INTEGER REFERENCES aidb.hw (id),
    fqdn TEXT NOT NULL DEFAULT 'localhost.localdomain');

CREATE INDEX storage_serv_id_index ON aidb.storage_server (id);

---
--- VIRTUAL HOST
---
CREATE TABLE aidb.virtual_host (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    host INTEGER REFERENCES aidb.host(id));

---
--- CONTAINER    TODO: ????
---
CREATE TABLE aidb.container (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    cont_id TEXT,
    container_name TEXT,
    image TEXT,
    host INTEGER REFERENCES aidb.host(id));

---
--- SERVICES
---
CREATE TYPE aidb.service_type AS ENUM ('ntp',
    'dns',
    'http',
    'ssh',
    'firewall',
    'db',
    'network_storage'
    'not_specified'
);

CREATE TYPE aidb.cloud_service_type AS ENUM ('networking',
    'compute',
    'block_storage',
    'image_storage',
    'object_storage',
    'telemetry',
    'identity',
    'orchestration',
    'dashboard'
);

CREATE TABLE aidb.service (
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY,
    service_name TEXT,
    descr TEXT,
    service_status TEXT,
    host INTEGER REFERENCES aidb.host(id));

--- cidr 	7 or 19 bytes 	IPv4 and IPv6 networks
--- inet 	7 or 19 bytes 	IPv4 and IPv6 hosts and networks
--- macaddr 	6 bytes 	MAC addresses
--- macaddr8 	8 bytes 	MAC addresses (EUI-64 format)
--- The essential difference between inet and cidr data types is that inet accepts values 
--- with nonzero bits to the right of the netmask, whereas cidr does not. For example, 192.168.0.1/24 is valid for inet but not for cidr.
/*
CREATE [ CONSTRAINT ] TRIGGER name { BEFORE | AFTER | INSTEAD OF } { event [ OR ... ] }
    ON table_name
    [ FROM referenced_table_name ]
    [ NOT DEFERRABLE | [ DEFERRABLE ] [ INITIALLY IMMEDIATE | INITIALLY DEFERRED ] ]
    [ REFERENCING { { OLD | NEW } TABLE [ AS ] transition_relation_name } [ ... ] ]
    [ FOR [ EACH ] { ROW | STATEMENT } ]
    [ WHEN ( condition ) ]
    EXECUTE PROCEDURE function_name ( arguments )

where event can be one of:

    INSERT
    UPDATE [ OF column_name [, ... ] ]
    DELETE
    TRUNCATE
*/


---
---
--- OPENSTACK CLOUD
---

---
--- AVAILABILITY ZONE
---
--- An availability zone groups network nodes that run services like DHCP, L3, FW, and others. 
--- It is defined as an agent’s attribute on the network node. This allows users to associate an availability zone with 
--- their resources so that the resources get high availability.




--- Openstack

---
--- availability zone
---
CREATE TABLE aidb.openstack_availability_zone(
    id INTEGER PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY, 
    zone_name TEXT
);


--- JUJU
/*
CREATE TABLE `CLOUD` (
  `idbCloudName` varchar(63) NOT NULL,


  `idbCloudType` varchar(12) NOT NULL,  --- IC/SC
  `idbCloudVersion` varchar(12) DEFAULT NULL,
  `idbDataCenterID` varchar(63) NOT NULL,


  `idbCloudDeploymentManager` varchar(24) NOT NULL,             Juju
  `idbCloudDeploymentManagerVersion` varchar(12) NOT NULL,
  `idbCloudDeploymentModelName` varchar(24) DEFAULT NULL,
  `idbCloudDeploymentModelController` varchar(24) DEFAULT NULL,


  `idbFirstDiscovered` datetime DEFAULT NULL,
  `idbLastDiscovered` datetime DEFAULT NULL,
  `idbLastChanged` datetime DEFAULT NULL,
  */