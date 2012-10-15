Feature: MCollective check
  In order to ensure that my MCollective installation works
  As an Operator
  I want to run a quick MCollective check

  Scenario: Mco Ping
    Given the Agent is rpcutil
    And the Action is ping
    And the target is random
    When I call MCollective
    Then the StatusMsg is OK

  Scenario: Mco Package
    Given the Agent is package
    And the Action is status
    And the Parameters are
      | package |
      | bash    |
    And the target is random
    When I call MCollective
    Then the StatusMsg is OK

  Scenario Outline: Mco Schedule Now
    Given the Agent is scheduler
    And the Action is schedule
    And the Parameters are
      | agentname | actionname |
      | rpcutil   | ping       |
    And the Identity of the target is <nodeid>
    When I call MCollective
    Then I should get an hexadecimal jobid
    And I should get a task in one of those states :
       | running   |
       | scheduled |
       | finished  |
    Then I should get a good task result within 2 seconds

    Examples: 
      | nodeid           |
      | el5.labolinux.fr |
      | el6.labolinux.fr |

  Scenario Outline: Mco Schedule in any distant future
    Given the Agent is scheduler
    And the Action is schedule
    And the Parameters are
      | agentname | actionname | schedtype | schedarg |
      | rpcutil   | ping       | in        | 600s     |
    And the Identity of the target is <nodeid>
    When I call MCollective
    Then I should get an hexadecimal jobid
    And I should get a task in one of those states :
       | scheduled |

    Examples: 
      | nodeid           |
      | el5.labolinux.fr |
      | el6.labolinux.fr |


