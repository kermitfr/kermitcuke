Feature: REST Mco check
  In order to ensure that my REST server for MCollective works
  As an Operator
  I want to run a quick REST server check

  @actions @first
  Scenario: Mco Ping all nodes
    When I call rpcutil ping
    And I query the REST server
    Then the StatusMsg is OK

  @actions
  Scenario: Mco random Ping
    When I call rpcutil ping
    And the target is random
    And I query the REST server
    Then the StatusMsg is OK

  @actions @id
  Scenario Outline: mco ping a specific node
    When I call rpcutil ping
    And the Identity of the target is <nodeid>
    And I query the REST server
    Then the StatusMsg is OK
    Examples:
      | nodeid           |
      | el5.labolinux.fr |
      | el6.labolinux.fr |
  
  @actions @fact
  Scenario: mco ping with a fact filter
    When I call rpcutil ping
    And a Fact criteria is rubyversion=1.8.7 
    And I query the REST server
    Then the StatusMsg is OK 
  
  @actions @class
  Scenario: mco package with a class filter
    When I call package status
    And a Class criteria is postgresql-server 
    And the Parameters are
      | package    |
      | postgresql |
    And I query the REST server
    Then the StatusMsg is OK 
  
  @actions @compound
  Scenario: mco package with a compound filter 
    When I call package status
    And a Compound criteria is (operatingsystem=CentOS and !operatingsystemrelease=6.3)
    And the Parameters are
      | package |
      | bash    |
    And I query the REST server
    Then the StatusMsg is OK 
 
  @actions
  Scenario: Mco Package
    When I call package status
    And the target is random
    And the Parameters are
      | package | foo |
      | bash    | bar |
    And I query the REST server
    Then the StatusMsg is OK

  @actions
  Scenario: Mco Service 
    When I call service status
    And the target is random
    And the Parameters are
      | service       |
      | postgresql    |
    And I query the REST server
    Then the StatusMsg is OK


  @actions
  Scenario Outline: Mco Service with multiple filters 
    When I call service status
    And a Class criteria is postgresql-server 
    And the Identity of the target is <nodeid>
    And the Parameters are
      | service       |
      | postgresql    |
    And I query the REST server
    Then the StatusMsg is OK
    Examples:
      | nodeid           |
      | el5.labolinux.fr |
      | el6.labolinux.fr |

