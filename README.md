# IPSec using PISKES

Project for Aryan Gupta about IPSec connection establishment
using PISKES keys

The code in this repository can be used for any topology in general.

Before the run:

1. Make a dockerized topology (for e.g. "./scion.sh topology -c topology/tiny.topo **--docker**")
2. The "docker/scion_app.bzl" and "gen/scion-dc.yml" have to be changed according to the topology. These changed files for the tiny.topo topology are in the repository.
3. **Put all the bash scripts inside "docker/files" directory. Also copy the drkeymockup folder to the "go" directory.**
4. Execute "make -C docker debug"

Run the SCION infrastructure using "./scion.sh run"

For testing the run, make the tester containers. Wait for a while before using "./bin/end2end__interation **-d**" to test the run.

Use "docker exec -it <border_router_container_name> bash" go into a border router container. Use "ipsec status" to check the active IPsec tunnels.

**Information about the scripts:**

The script connect.sh is the main script which uses the other scripts.

When "./connect.sh establish" command is given, it starts cron and fills in the "/etc/ipsec.conf" and "/etc/ipsec.secrets" file for the first time.
After this cron runs "./connect.sh" which rekeys the IPsec tunnels in each border router.

connect.sh parses the "/share/topology.json" file and scrapes information of the links available to the border router docker container. It also calls the drkeymockup binary ("/app/drkeymockup")
to derive the PISKES key.

install-strongswan.sh installs the required files, and drives connect.sh. 
