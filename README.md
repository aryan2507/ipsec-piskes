# IPSec using PISKES

Project for Aryan Gupta about IPSec connection establishment
using PISKES keys

The code in this repository can be used for any topology in general.
The docker/scion_app.bzl and gen/scion-dc.yml have to be changed according to the topology. These changed files for the tiny.topo topology are in the repository.

The script connect.sh is the main script which uses the other scripts.
When "./connect.sh establish" command is given, it starts cron and fills in the ipsec.conf and ipsec.secrets file for the first time.
After this cron runs "./connect.sh" which rekeys the IPsec tunnels in each border router.
connect.sh parses the /share/topology.json file and scrapes information of the links available to the border router docker container. It also calls the drkeymockup binary ("/app/drkeymockup")
to derivee the PISKES key.

install-strongswan.sh installs the required files, and drives connect.sh. 
