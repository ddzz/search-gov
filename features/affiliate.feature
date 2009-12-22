Feature: Affiliate clients
  In order to give my searchers a custom search experience
  As an affiliate
  I want to see and manage my affiliate settings

  Scenario: Visiting the affiliate welcome/list page as a un-authenticated Affiliate
    When I go to the affiliate welcome page
    Then I should see "FAQs"

  Scenario: Visiting the account page as a logged-in affiliate
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | multi1           | two@bar.gov           | Two Bar             |
    | multi2           | two@bar.gov           | Two Bar             |
    And I am logged in with email "two@bar.gov" and password "random_string"
    When I go to the user account page
    Then I should see "multi1"
    And I should see "multi2"
    And I should see "FAQ"

  Scenario: Staging changes to an affiliate's look and feel
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | aff.gov          | aff@bar.gov           | John Bar            |
    And I am logged in with email "aff@bar.gov" and password "random_string"
    When I go to the user account page
    And I follow "Edit"
    And I fill in "Name" with "newname"
    And I fill in "Header" with "My header"
    And I fill in "Footer" with "My footer"
    And I fill in "Domains" with "foo.com bar.com"
    And I press "Save for preview"
    Then I should see "Staged changes to your affiliate successfully."
    And I should be on the user account page
    And I should see "newname"
    When I follow "View staged"
    Then I should see "My header"
    And I should see "My footer"
    When I go to the user account page
    And I press "Push Changes"
    Then I should be on the user account page
    And I should see "Staged content is now visible"
    And I should not see "Push Changes"
    And I should not see "View staged"
    When I follow "View current"
    Then I should see "My header"
    And I should see "My footer"

  Scenario: Site visitor sees boosted results in affiliate search
    Given the following Affiliates exist:
    | name             | contact_email         | contact_name        |
    | aff.gov          | aff@bar.gov           | John Bar            |
    And the following Boosted Sites exist for the affiliate "aff.gov"
    | title               | url                     | description                               |
    | Our Emergency Page  | http://www.aff.gov/911  | Updated information on the emergency      |
    | FAQ Emergency Page  | http://www.aff.gov/faq  | More information on the emergency         |
    | Our Tourism Page    | http://www.aff.gov/tou  | Tourism information                       |
    When I go to aff.gov's search page
    And I fill in "query" with "emergency"
    And I submit the search form
    Then I should see "Our Emergency Page" within "#boosted"
    And I should see "FAQ Emergency Page" within "#boosted"
    And I should not see "Our Tourism Page" within "#boosted"

