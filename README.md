---
title: Demo Stack
author: Nic Jackson
slug: demo-stack
---
This blueprint create the necessary components for the Demo app for HashiConf 2022, the various components can be 
disabled by configuring the environment variables in `main.hcl`.

# Components
* Vault (container)
* Consul (container)
* Docker Registry (container)
* Nomad (single node)
* Waypoint (nomad)
* Release Controller (nomad)
* Prometheus (nomad)
* Grafana (nomad)
* Example App (nomad)

# Todo
* Boundary
* Minecraft server

# Nomad
A single node nomad cluster has been provisioned, the API is running on a dynamic port, the connection details
for the API can be found in the Shipyard output.

```
shipyard output NOMAD_ADDR
```

# Consul
Consul server is running as a container with HTTPS and ACLs disabled, the connection
details for the API can be found in the Shipyard output.

Nomad has been connected to the Consul server and Consul agents are running on each Nomad node at port 8500.

```
shipyard output CONSUL_HTTP_ADDR
```

# Vault
A dev version of Vault is running in a container, it is unsealed and can be accessed using the following information.

```
http://localhost:8200
token: root
```

# Docker Registry
A local Docker registry is provisioned and running to allow Waypoint to store built artifacts.

The registry has been provisioned using a self signed certificate, however a custom runner image has been
created for Waypoint that has the CA for the self signed certificate allowing images to be pushed using TLS 
without error. In addition, the Nomad node has been configured to accept this registry as an insecure registry
so there should be no issue of Nomad pulling from this source.

The IP address for the registry as accessible from Nomad is `10.5.0.100`, the registry is also accessible
from the local machine on `localhost`.

# Waypoint
Waypoint has been installed and configured on Nomad with on-demand-runners. A custom ODR image has been built for
the Waypoint runners that contains the self signed certificate for the registry and also custom Waypoint plugins.

The Waypoint token can be found at the following location:

```
$HOME/.shipyard/data/waypoint/waypoint.token
```

The Waypoint API and UI are accessible from `localhost` on ports `9701` and `9702`, to use the waypoint CLI from 
the host machine the following script can be used to create a context.

```
$HOME/.shipyard/data/waypoint/create_context.sh
```

# Monitoring
Prometheus and Grafana have been installed and configured on Nomad, they are accessible with the following details.

## Grafana

```
http://localhost:3000
user: admin
pass: admin
```

## Prometheus
```
http://localhost:9090
```

## Example Application
A simple two tier application API -> Payments has been deployed to Nomad. The application uses Consul service mesh for 
communication and access to the API is provided through Consul Ingress Gateway.

The ingress gateway expects that a HOST header with the value `api.default` is set for any call.

```
curl http://localhost:18081 -H "HOST: api.default"
```