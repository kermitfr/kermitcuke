Feature: MCollective check
  In order to ensure that my MCollective installation works
  As an Operator
  I want to run a quick MCollective check

  @actions
  Scenario: Mco Ping
    When I use rpcutil ping
    And the target is random
    And I call MCollective
    Then the StatusMsg is OK

  @actions
  Scenario: Mco Package
    When I use package status
    And the Parameters are
      | package |
      | bash    |
    And the target is random
    And I call MCollective
    Then the StatusMsg is OK

  @scheduler
  Scenario Outline: Mco Schedule Now
    When I use scheduler schedule
    And the Parameters are
      | agentname | actionname |
      | rpcutil   | ping       |
    And the Identity of the target is <nodeid>
    And I call MCollective
    Then I should get an hexadecimal jobid
    And I should get a task in one of those states :
       | running   |
       | scheduled |
       | finished  |
    And I should eventually get a good task result

    Examples: 
      | nodeid           |
      | el5.labolinux.fr |
      | el6.labolinux.fr |

  @scheduler
  Scenario Outline: Mco Schedule in any distant future
    When I use scheduler schedule
    And the Parameters are
      | agentname | actionname | schedtype | schedarg |
      | rpcutil   | ping       | in        | 600s     |
    And the Identity of the target is <nodeid>
    And I call MCollective
    Then I should get an hexadecimal jobid
    And I should get a task in one of those states :
       | scheduled |

    Examples: 
      | nodeid           |
      | el5.labolinux.fr |
      | el6.labolinux.fr |

  @scheduler
  Scenario Outline: Mco Schedule a task with arguments
    When I use scheduler schedule
    And the Parameters are
      | agentname | actionname | schedtype | schedarg | package | params  |
      | package   | status     | in        | 0s       | ruby    | package |
    And the Identity of the target is <nodeid>
    And I call MCollective
    Then I should get an hexadecimal jobid
    And I should eventually get a good task result
    Examples: 
      | nodeid           |
      | el5.labolinux.fr |
      | el6.labolinux.fr |

  @inventories
  Scenario Outline: Trigger a postgreSQL inventory
    When I use postgresql inventory
    And the Identity of the target is <nodeid>
    And I call MCollective
    Then I should eventually get an inventory
    Examples: 
      | nodeid           |
      | el5.labolinux.fr |

  @inventories
  Scenario Outline: Trigger a JBoss inventory
    When I use jboss inventory
    And the Identity of the target is <nodeid>
    And I call MCollective
    Then I should eventually get an inventory
    Examples: 
      | nodeid            |
      | el6a.labolinux.fr |

  @logs
  Scenario Outline: Trigger a JBoss log collection 
    When I use jboss get_log 
    And the Parameters are
      | instancename |
      | default      |
    And the Identity of the target is <nodeid>
    And I call MCollective
    Then I should eventually get a log
    Examples: 
      | nodeid            |
      | el6a.labolinux.fr |

