#!/usr/bin/python

from sqlalchemy import (
    create_engine,
    MetaData,
    Table,
    Column,
    ForeignKey,
    BigInteger,
    Integer,
    String,
    Enum, DefaultClause
)

engine = create_engine('sqlite:///cmdb_core.sqlite')

metadata = MetaData()

#
# DATA CENTRE
#
# Every device is connected to location (address, building) and defined by position (floor and rack number)
#
location = Table('location', metadata,
                 Column('id', BigInteger, primary_key=True),
                 Column('description', String(150)),
                 Column('country', String(60), nullable=False),
                 Column('town', String(20), nullable=False),
                 Column('street', String(20)),
                 Column('zipcode', String(20), nullable=False)
                 )

position = Table('position', metadata,
                 Column('id', BigInteger, primary_key=True),
                 Column('loc_id', BigInteger, ForeignKey(
                     "location.id"), nullable=False),
                 Column('floor', Integer, nullable=False),
                 Column('room', String(10), nullable=False),
                 Column('rack', String(10), nullable=False)
                 )


manufacturer = Table('manufacturer', metadata,
               Column('id', BigInteger, primary_key=True),
               Column('name', String(50)),
               Column('description', String(250))
               )

os = Table('os', metadata,
           Column('id', BigInteger, primary_key=True),
           Column('name', String(10), nullable=False),
           Column('manufacturer_id', BigInteger, ForeignKey("manufacturer.id"), nullable=False),
           Column('major_version', String(10), nullable=False),
           Column('minor_version', String(10), nullable=False),
           Column('build_number', String(10), nullable=False),
           Column('license', String(10), nullable=False),
           Column('distributor', String(10), nullable=False),
           Column('codename', String(10), nullable=False),
           Column('arch', String(10), nullable=False),
           Column('kernel_version', String(10), nullable=False)
           )


#
# HARDWARE
#
hardware = Table('hardware', metadata,
                 Column('id', BigInteger, primary_key=True),
                 Column('pos_id', BigInteger, ForeignKey("position.id"), nullable=False),
                 Column('type', Enum('workstation', 'server', 'storage', 'network', 'pdu', 'ups', 'printer', 'ilo','screen'), nullable=False), # TODO
                 Column('status', Enum('in_stock', 'activated', 'to_be_decommisioned', 'decommisioned'), nullable=False), # TODO
                 Column('serial_num', BigInteger),
                 Column('model_name', BigInteger),
                 Column('model_num', BigInteger),
                 Column('warranty', BigInteger),
                 Column('id', BigInteger, primary_key=True)
                 )

service = Table('service', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('hw_id', BigInteger, ForeignKey(
                    "hardware.id"), nullable=False),
                Column('type', Enum('dhcp', 'dns', 'ntp', 'hypervisor', 'database',
                                    'application_server' 'storage', 'compute', 'network', 'message_broker', 'orchestrator', 
                                    'monitoring', 'logging', 'service_mesh',
                                    'printing', 'cache', 'cluster'))
                )





#
# NTP
#
ntp = Table('ntp', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('name', String(50)),
                Column('service_id', BigInteger, ForeignKey(
                    "service.id"), nullable=False)
                )

ntp_server = Table('ntp_server', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('server_name', String(50)),
                Column('ntp_id', BigInteger, ForeignKey(
                    "ntp.id"), nullable=False)
                )


#
# DHCP
#
dhcp = Table('dhcp', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('name', String(50)),
                Column('service_id', BigInteger, ForeignKey(
                    "service.id"), nullable=False)
                )

dhcp_group = Table('dhcp_group', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('name', String(250))
)

# group {
#    option routers                  192.168.1.254;
#    option subnet-mask              255.255.255.0;
#    option domain-search              "example.com";
#    option domain-name-servers       192.168.1.1;
#    option time-offset              -18000;     # Eastern Standard Time
#    host apex {
#       option host-name "apex.example.com";
#       hardware ethernet 00:A0:78:8E:9E:AA;
#       fixed-address 192.168.1.4;
#    }
#    host raleigh {
#       option host-name "raleigh.example.com";
#       hardware ethernet 00:A1:DD:74:C3:F2;
#       fixed-address 192.168.1.6;
#    }
# }



#STATIC
# host apex {
#    option host-name "apex.example.com";
#    hardware ethernet 00:A0:78:8E:9E:AA;
#    fixed-address 192.168.1.4;
# }
dhcp_static_host = Table('dhcp_static_host', metadata,
                Column('host_name', String(250)),
                Column('mac', String(250)),
                Column('fixed_address', String(250)),
                Column('dhcp_id', BigInteger, ForeignKey(
                    "dhcp.id"), nullable=False),
                Column('dhcp_group_id', BigInteger, ForeignKey(
                    "dhcp_group.id"), nullable=False)
)

# subnet 192.168.1.0 netmask 255.255.255.0 {
#         option routers                  192.168.1.254;
#         option subnet-mask              255.255.255.0;
#         option domain-search              "example.com";
#         option domain-name-servers       192.168.1.1;
#         option time-offset              -18000;     # Eastern Standard Time
# 	range 192.168.1.10 192.168.1.100;
# }

dhcp_subnet = Table('dhcp_subnet', metadata,
                Column('routers', String(250)),
                Column('subnet-mask', String(250)),
                Column('domain-search', String(250)),
                Column('domain-name-servers', String(250)),
                Column('time-offset', String(250)),
                Column('range', String(250)),
                Column('dhcp_id', BigInteger, ForeignKey(
                    "dhcp.id"), nullable=False),
                Column('dhcp_shared_net', BigInteger, ForeignKey(
                    "dhcp_shared_network.id"), nullable=False)
)


# default-lease-time 600;
# max-lease-time 7200;
# option subnet-mask 255.255.255.0;
# option broadcast-address 192.168.1.255;
# option routers 192.168.1.254;
# option domain-name-servers 192.168.1.1, 192.168.1.2;
# option domain-search "example.com";
# subnet 192.168.1.0 netmask 255.255.255.0 {
#    range 192.168.1.10 192.168.1.100;
# }

dhcp_shared_network = Table('dhcp_shared_network', metadata,
                        Column('id', BigInteger, primary_key=True),
                        Column('name', String(250))
)


# shared-network name {
#     option domain-search            "test.redhat.com";
#     option domain-name-servers      ns1.redhat.com, ns2.redhat.com;
#     option routers                  192.168.0.254;
#     #more parameters for EXAMPLE shared-network
#     subnet 192.168.1.0 netmask 255.255.252.0 {
#         #parameters for subnet
#         range 192.168.1.1 192.168.1.254;
#     }
#     subnet 192.168.2.0 netmask 255.255.252.0 {
#         #parameters for subnet
#         range 192.168.2.1 192.168.2.254;
#     }
# }



dns = Table('dns', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('type', Enum('top_level_domain', 'caching', 'reverse_caching', 'forwarding')),
                Column('service_id', BigInteger, ForeignKey(
                    "service.id"), nullable=False)
                )

# primary entry for the domain without any subdomains. The NAME field typically remains blank as this would define a subdomain.
# This type of record should usually be an A record, with the value set to the destination IP address. Using a CNAME for the root domain can cause other DNS functions,
# such as MX records, to route incorrectly. It is standard practice to set the A record for the root domain to that of the "www." subdomain.
root_domain = Table('root_domain', metadata,
                Column('record', String(250)),
                Column('dns_id', BigInteger, ForeignKey(
                    "dns.id"), nullable=False)
                )


#CNAME Records are used to define an alias hostname. A CNAME record takes this format:
#alias.domain.name      IN     CNAME   otherhost.domain.name.
#This defines alias.domain.name as an alias for the host whose canonical (standard) name is otherhost.domain.name.
cname = Table('cname', metadata,
                Column('record', String(250)),
                Column('dns_id', BigInteger, ForeignKey(
                    "dns.id"), nullable=False)
                )


#An A record gives you the IP address of a domain. That way, users that try to go to www.example.com will get to the right IP address.
#  An A record or "Address Record" maps a hostname to a 32-bit IPv4 address. An "A" Record takes this format (example):

#Name             TTL     TYPE    DATA
#ftp.domain.com   43200   A       IP Address
#Media Temple DNS Zone files are written with a "wildcard" entry, that looks like this:

#*.domain.com   IN   A   xxx.xxx.xxx.xxx
#The x's represnt your particular IP address. The star takes "anything" .domain.com and points it to your server's IP address. This way, if someone mistakenly types too many or too few w's, they'll still see your website. This is also useful for setting up subdomains on your server, relieving you of the duty of adding an additional "A" record for the subdomain.
a_record = Table('a_record', metadata,
                Column('record', String(250)),
                Column('dns_id', BigInteger, ForeignKey(
                    "dns.id"), nullable=False)
                )




#Mail Exchange Record: Maps a domain name to a list of mail exchange servers for that domain. A zone can have one or more Mail Exchange (MX) records. These records point to hosts that accept mail messages on behalf of the host. A host can be an 'MX' for itself. MX records need not point to a host in the same zone. An 'MX' record takes this format:
#host.domain.name       IN     MX      10 otherhost.domain.name.
#IN     MX      20 otherhost2.domain.name.
#The 'MX' preference numbers nn (value 0 to 65535) signify the order in which mailers select 'MX' records when they attempt mail delivery to the host. The lower the 'MX' number, the higher the host is in priority.
mx_record = Table('mx_record', metadata,
                Column('record', String(250)),
                Column('dns_id', BigInteger, ForeignKey(
                    "dns.id"), nullable=False)
                )


#PTR Record / Pointer Record
#Maps an IPv4 address to the canonical name for that host. Setting up a PTR record for a hostname in the in-addr.arpa. domain that corresponds to an IP address implements reverse DNS lookup for that address. For example, at the time of writing, www.icann.net has the IP address 192.0.34.164, but a PTR record maps 164.34.0.192.in-addr.arpa to its canonical name.
ptr_record = Table('ptr_record', metadata,
                Column('record', String(250)),
                Column('dns_id', BigInteger, ForeignKey(
                    "dns.id"), nullable=False)
                )



#NS Record or "Name Server Record"
#Maps a domain name to a list of DNS servers authoritative for that domain. In this case, for (mt) Media Temple purposes would be:
#ns1.mediatemple.net
#ns2.mediatemple.net
#SOA Record or "Start of Authority Record"
#Specifies the DNS server providing authoritative information about an Internet domain, the email of the domain administrator, the domain serial number, and several timers relating to refreshing the zone.
ns_record = Table('ns_record', metadata,
                Column('record', String(250)),
                Column('dns_id', BigInteger, ForeignKey("dns.id"), nullable=False)
                )


#TXT Record
#The TXT Record allows an administrator to insert arbitrary text into a DNS record. For example, this record is used to implement the Sender Policy Framework and DomainKeys specifications.
txt_record = Table('txt_record', metadata,
                Column('record', String(250), primary_key=True),
                Column('dns_id', BigInteger, ForeignKey("dns.id"), nullable=False)
                )

#
# NETWORK STACK
#
bridge = Table('bridge', metadata,
               Column('id', BigInteger, primary_key=True),
               Column('name', String(32), nullable=False),
               Column('stp_enabled', String(32))
               )

network_interface = Table('network_interface', metadata,
                          Column('id', BigInteger, primary_key=True),
                          Column('serial_number', String(20), nullable=False),
                          Column('model', String(20), nullable=False),
                          Column('manufacturer_id', BigInteger, ForeignKey("manufacturer.id"), nullable=False),
                          Column('bond', String(20), nullable=False),
                          Column('description', String(50), nullable=False),
                          Column('ipv4', Integer, nullable=False),
                          Column('ipv6', Integer, nullable=False),
                          Column('netmask', Integer),
                          Column('mac_address', Integer),
                          Column('mtu', Integer),
                          Column('speed', Integer),
                          Column('mtu', Integer),
                          Column('bond', String(20), nullable=False),
                          Column('bridge_id', BigInteger,ForeignKey("bridge.id")),
                          Column('dhcp_server', Integer, nullable=False),
                          Column('dns_server', Integer, nullable=False)
                          )

routing_table = Table('routing_table', metadata,
                      Column('id', BigInteger, primary_key=True),
                      Column('destination', Integer, nullable=False),
                      Column('netmask', Integer),
                      Column('gateway', Integer),
                      Column('interface', String(20), nullable=False),
                      Column('metric', String(20), nullable=False)
                      )

ospf_table = Table('ospf_table', metadata,
                   Column('id', BigInteger, primary_key=True),
                   Column('network', Integer, nullable=False),
                   Column('area', Integer),
                   Column('gateway', Integer),
                   Column('interface', String(20), nullable=False),
                   Column('metric', String(20), nullable=False)
                   )

# Group of NICs
nic_stack = Table('nic_stack', metadata,
                  Column('id', BigInteger, primary_key=True),
                  Column('nic_id', BigInteger, ForeignKey(
                      "network_interface.id"))
                  )

#
# FIREWALL RULE
#
firewall_rule = Table('firewall_rule', metadata,
                      Column('id', BigInteger, primary_key=True),
                      Column('net_device_id', BigInteger, ForeignKey("network_device.id")),
                      Column('name', String(32), nullable=False),
                      Column('chain', Enum('input', 'forward', 'output')),
                      Column('action', Enum('drop', 'block', 'allow')),
                      Column('port', String(20), nullable=False),
                      Column('protocol', Enum('tcp', 'udp'), nullable=False),
                      #Column('source', String(20), nullable=False),
                      #Column('destination', String(20), nullable=False),
                      Column('icmp', String(20), nullable=False)
                      )


storage = Table('storage', metadata,
                     Column('id', BigInteger, primary_key=True),
                     Column('name', Integer, nullable=False),
                     Column('description', Integer)
                     )
                     
#
# iSCSI
#

# Storage server
iscsi_target = Table('iscsi_target', metadata,
                     Column('id', BigInteger, primary_key=True),
                     Column('storage_id', BigInteger, ForeignKey("storage.id")),
                     Column('initiator-address', Integer, nullable=False),
                     Column('backing-store', Integer),
                     Column('target ', Integer)
                     )

# Client
iscsi_initiator = Table('iscsi_initiator', metadata,
                        Column('id', BigInteger, primary_key=True),
                        Column('storage_id', BigInteger, ForeignKey("storage.id")),
                        Column('www_id', Integer, nullable=False),
                        Column('remote_ipv4', Integer),
                        Column('remote_ipv6', Integer),
                        Column('channel_number', String(20), nullable=False),
                        Column('LUN', String(20), nullable=False)
                        )


#
# HW TYPES
#
workstation = Table('workstation', metadata,
                 Column('id', BigInteger, primary_key=True),
                 Column('hw_id', BigInteger, ForeignKey("hardware.id"), nullable=False),
                 Column('os_id', BigInteger, ForeignKey("os.id"), nullable=False),
                 Column('room', String(10), nullable=False),
                 Column('nic_stack_id', BigInteger,ForeignKey("nic_stack.id")),
                 Column('route', BigInteger, ForeignKey("routing_table.id"))
                 )

server = Table('server', metadata,
                 Column('id', BigInteger, primary_key=True),
                 Column('hw_id', BigInteger, ForeignKey("hardware.id"), nullable=False),
                 Column('floor', Integer, nullable=False),
                 Column('os_id', BigInteger, ForeignKey("os.id"), nullable=False),
                 Column('room', String(10), nullable=False),
                 Column('rack', String(10), nullable=False),
                 Column('nic_stack_id', BigInteger,
                        ForeignKey("nic_stack.id")),
                 Column('route', BigInteger, ForeignKey("routing_table.id"))
                 )

virtual_machine = Table('virtual_machine', metadata,
                 Column('id', BigInteger, primary_key=True),
                 Column('hypervisor_id', BigInteger, ForeignKey("server.id")),
                 Column('nic_stack_id', BigInteger,
                        ForeignKey("nic_stack.id")),
                 Column('route', BigInteger, ForeignKey("routing_table.id"))
                 )

storage_area_network = Table('storage_area_network', metadata,
                             Column('id', BigInteger, primary_key=True),
                             Column('hw_id', BigInteger, ForeignKey(
                                 "hardware.id"), nullable=False),
                             Column('os_id', BigInteger, ForeignKey(
                                 "os.id"), nullable=False),
                             Column('floor', Integer, nullable=False),
                             Column('room', String(10), nullable=False),
                             Column('rack', String(10), nullable=False),
                             Column('nic_stack_id', BigInteger,
                                    ForeignKey("nic_stack.id"))
                             )


# storage pool is a network of storage servers.
storage_pool = Table('storage_pool', metadata,
                             Column('id', BigInteger, primary_key=True),
                             Column('hw_id', BigInteger, ForeignKey("hardware.id"), nullable=False)  # OR HOST? TODO
)


# storage pool is a network of storage servers.
cluster = Table('cluster', metadata,
                             Column('id', BigInteger, primary_key=True),
                             Column('host_type', Enum('master','slave','universal_node')),
                             Column('net_device_id', BigInteger, ForeignKey("network_device.id"), nullable=False)  
)



network_device = Table('network_device', metadata,
                       Column('id', BigInteger, primary_key=True),
                       Column('hw_id', BigInteger, ForeignKey(
                           "hardware.id"), nullable=False),
                       Column('os_id', BigInteger, ForeignKey("os.id"), nullable=False),
                       Column('nic_stack_id', BigInteger, ForeignKey("nic_stack.id"))
                       )

switch = Table('switch', metadata,
               Column('id', BigInteger, primary_key=True),
               Column('hw_id', BigInteger, ForeignKey(
                   "network_device.id"), nullable=False),
               Column('nic_stack_id', BigInteger, ForeignKey("nic_stack.id"))
               )

vswitch = Table('vswitch', metadata,
               Column('id', BigInteger, primary_key=True),
               Column('nic_stack_id', BigInteger, ForeignKey("nic_stack.id"))
               )

router = Table('router', metadata,
               Column('id', BigInteger, primary_key=True),
               Column('hw_id', BigInteger, ForeignKey(
                   "network_device.id"), nullable=False),
               Column('route', BigInteger, ForeignKey("routing_table.id")),
               Column('nic_stack_id', BigInteger, ForeignKey("nic_stack.id"))
               )

vrouter = Table('vrouter', metadata,
               Column('id', BigInteger, primary_key=True),
               Column('route', BigInteger, ForeignKey("routing_table.id")),
               Column('nic_stack_id', BigInteger, ForeignKey("nic_stack.id"))
               )

wireless_access_point = Table('wireless_access_point', metadata,
                              Column('id', BigInteger, primary_key=True),
                              Column('hw_id', BigInteger, ForeignKey(
                                  "network_device.id"), nullable=False),
                              Column('xcxzv', BigInteger)
                              )

printer = Table('printer', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('hw_id', BigInteger, ForeignKey(
                    "hardware.id"), nullable=False),
                Column('floor', Integer, nullable=False)
                )

uninterruptible_power_supply = Table('uninterruptible_power_supply', metadata,
                                     Column('id', BigInteger,
                                            primary_key=True),
                                     Column('hw_id', BigInteger, ForeignKey(
                                         "hardware.id"), nullable=False),
                                     Column('floor', Integer, nullable=False)
                                     )

ilo = Table('ilo', metadata,
            Column('id', BigInteger, primary_key=True),
            Column('server_id', BigInteger, ForeignKey(
                "server.id"), nullable=False)
            )


# HVAC (Heating, Ventilation, and Air Conditioning) systems
# power distribution unit


#
# USERS
#
corporation = Table('corporation', metadata,
                    Column('id', BigInteger, primary_key=True),
                    Column('user_name', String(16), nullable=False),
                    Column('email_address', String(60), key='email'),
                    Column('password', String(20), nullable=False)
                    )

department = Table('department', metadata,
                   Column('id', BigInteger, primary_key=True),
                   Column('corp_id', BigInteger, ForeignKey("corporation.id"), nullable=False),
                   Column('pref_name', String(40), nullable=False),
                   Column('pref_value', String(100))
                   )

team = Table('team', metadata,
             Column('id', BigInteger, primary_key=True),
             Column('dept_id', BigInteger, ForeignKey("department.id"), nullable=False),
             Column('pref_name', String(40), nullable=False),
             Column('pref_value', String(100))
             )

project = Table('project', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('team_id', BigInteger, ForeignKey("team.id"), nullable=False),
                Column('pref_name', String(40), nullable=False),
                Column('pref_value', String(100))
                )

employee = Table('employee', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('corp_id', BigInteger, ForeignKey("corporation.id"), nullable=False),
                Column('title', String(40), nullable=False),
                Column('name', String(40), nullable=False),
                Column('surname', String(40), nullable=False),
                Column('gender', String(40), nullable=False),
                Column('internal_id', String(40), nullable=False),
                Column('address', String(40), nullable=False),
                Column('city', String(40), nullable=False),
                Column('country', String(40), nullable=False),
                Column('zipcode', String(40), nullable=False),
                Column('id_card', String(40), nullable=False),
                Column('birth_date', String(40), nullable=False),
                Column('birth_id', String(100))
                )

project_member = Table('project_member', metadata,
                Column('id', BigInteger, primary_key=True),
                Column('emp_id', BigInteger, ForeignKey("employee.id"), nullable=False),
                Column('pref_value', String(100))
                )

# SLA features

service_level_agreement = Table('sla', metadata,
                                Column('id', BigInteger, primary_key=True),
                                Column('pref_id', BigInteger, primary_key=True),
                                Column('serv_id', BigInteger, ForeignKey('service.id"), nullable=False),
                                Column('name', String(40), nullable=False),
                                Column('status', Enum('inactive', 'active', 'resolved', 'breached'), default='inactive', nullable=False),
                                Column('first_response', String(10), nullable=False),
                                Column('time_to_solve', String(10), nullable=False),
                                Column('description', String(40), nullable=False),
                                Column('last_update', String(40), nullable=False)
                                )


# "tenantId": "tutorial",
# "id": "lesson-02",
# "name": "Lesson 02",
# "type": "STANDARD",
# "eventType": "ALERT",
# "eventCategory": null,
# "eventText": null,
# "severity": "MEDIUM",
# "autoDisable": false,
# "autoEnable": false,
# "autoResolve": false,
# "autoResolveAlerts": true,
# "autoResolveMatch": "ALL",
# "enabled": false,
# "firingMatch": "ALL",
# "source": "_none_"

metadata.create_all(engine)
