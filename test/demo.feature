Feature: Consul Nomad Module
  In order to test the Consul Nomad blueprint
  I should apply a blueprint which defines the setup
  and test the resources are created correctly

Scenario: Nomad cluster
  Given I have a running blueprint
  Then the following resources should be running
    | name                      | type          |
    | server.local              | nomad_cluster |
    | consul                    | container     |
    | vault                     | container     |
    | registry                  | container     |
  And a HTTP call to "http://consul.container.shipyard.run:18500/" should result in status 200
  And a HTTP call to "http://vault.container.shipyard.run:8200/v1/sys/health" should result in status 200