*** Settings ***
Documentation       Indodax Private API Test Suite
...                 Feature: Authenticated Account and Order Endpoints
...                 Tests private API endpoints in BDD (Gherkin) style:
...                 - Authentication (valid and invalid credentials)
...                 - Account balance
...                 - Order placement (buy and sell)
...                 - Order validation (negative cases: negative price, zero amount)
...                 - Order management (open orders, cancel, history)
...                 - Data-driven order scenarios
...
...                 NOTE: Tests tagged 'skip' require valid INDODAX_API_KEY and
...                 INDODAX_API_SECRET in .env.${TEST_ENV}. Remove the 'skip' tag
...                 once valid credentials are configured.

Resource            ../../resources/keywords/api/api_settings.robot

Suite Setup         Initialize Private API Test Environment
Suite Teardown      Cleanup Private API Environment

Test Tags           api    indodax    private    authentication


*** Test Cases ***
Private API - Authentication - Valid Credentials Should Succeed
    [Documentation]    Scenario: User authenticates with valid API credentials
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response contains account data (return field)
    ...    - Response matches account info JSON schema
    [Tags]    authentication    positive_case    smoke    critical    skip
    [Setup]    Skip If No Valid Credentials

    Given the private API session is initialized with valid credentials
    When the user requests their account information
    Then the response should be 200 OK
    And the account response should contain account data
    And the account info should match the expected schema

Private API - Authentication - Invalid API Key Should Fail
    [Documentation]    Scenario: User attempts to authenticate with invalid API credentials
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200 (Indodax encodes rejections in JSON body)
    ...    - Response is a valid dictionary
    [Tags]    authentication    negative_case    security
    [Setup]    Setup Dummy Signer For Testing

    Given the private API session is initialized with invalid credentials
    When the user requests their account information
    Then the response should be 200 OK
    And the response should be a valid dictionary

Private API - Get Account Balance
    [Documentation]    Scenario: User retrieves account balance for all assets
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response contains return and server_time fields
    ...    - Balance data is non-empty
    [Tags]    account    balance    positive_case    smoke    skip
    [Setup]    Skip If No Valid Credentials

    Given the private API session is initialized with valid credentials
    When the user requests their account balance
    Then the response should be 200 OK
    And the balance response should contain balance data

Private API - Place Buy Order - Valid Parameters
    [Documentation]    Scenario: User places a valid buy order
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Order response confirms a buy order was created
    [Tags]    order    buy    positive_case    data_driven    critical    skip
    [Setup]    Skip If No Valid Credentials

    Given the private API session is initialized with valid credentials
    And the "buy_order_btc_standard" buy order data is loaded from test data
    When the user places a buy order for the resolved pair
    Then the response should be 200 OK
    And the order should be confirmed as a "buy" order for the resolved pair

Private API - Place Sell Order - Valid Parameters
    [Documentation]    Scenario: User places a valid sell order
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Order response confirms a sell order was created
    [Tags]    order    sell    positive_case    data_driven    skip
    [Setup]    Skip If No Valid Credentials

    Given the private API session is initialized with valid credentials
    And the "sell_order_eth_standard" sell order data is loaded from test data
    When the user places a sell order for the resolved pair
    Then the response should be 200 OK
    And the order should be confirmed as a "sell" order for the resolved pair

Private API - Place Order - Negative Price Should Fail
    [Documentation]    Scenario: User attempts to place an order with a negative price
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200 (validation error encoded in JSON body)
    ...    - Response is non-empty
    [Tags]    order    validation    negative_case    data_driven
    [Setup]    Setup Dummy Signer For Testing

    Given the private API session is initialized with dummy credentials
    And the "negative_price" order validation data is loaded
    When the user places a buy order for the resolved pair
    Then the response should be 200 OK
    And the validation error response should not be empty

Private API - Place Order - Zero Amount Should Fail
    [Documentation]    Scenario: User attempts to place an order with zero amount
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200 (validation error encoded in JSON body)
    ...    - Response is non-empty
    [Tags]    order    validation    negative_case    data_driven
    [Setup]    Setup Dummy Signer For Testing

    Given the private API session is initialized with dummy credentials
    And the "zero_amount" order validation data is loaded
    When the user places a buy order for the resolved pair
    Then the response should be 200 OK
    And the validation error response should not be empty

Private API - Get Open Orders
    [Documentation]    Scenario: User retrieves all open orders
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response contains return and server_time fields
    [Tags]    order    list    positive_case    smoke    skip
    [Setup]    Skip If No Valid Credentials

    Given the private API session is initialized with valid credentials
    When the user requests all open orders
    Then the response should be 200 OK
    And the open orders response should contain order list data

Private API - Get Open Orders For Specific Pair
    [Documentation]    Scenario: User retrieves open orders filtered by a specific trading pair
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response contains return field (filtered by pair)
    [Tags]    order    list    positive_case    skip
    [Setup]    Skip If No Valid Credentials

    Given the private API session is initialized with valid credentials
    And the test uses the "get_open_orders_btc" management pair
    When the user requests open orders for the resolved pair
    Then the response should be 200 OK
    And the open orders response should contain order list data

Private API - Cancel Order - Valid Order ID
    [Documentation]    Scenario: User cancels an existing order by order ID
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200 (auth error expected with dummy credentials)
    ...    - Response is non-empty
    [Tags]    order    cancel    positive_case
    [Setup]    Setup Dummy Signer For Testing

    Given the private API session is initialized with dummy credentials
    And the "cancel_order" management data is loaded
    When the user cancels the order
    Then the response should be 200 OK
    And the cancel response should not be empty

Private API - Get Order History
    [Documentation]    Scenario: User retrieves completed order history
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response contains return field with order history
    [Tags]    order    history    positive_case    skip
    [Setup]    Skip If No Valid Credentials

    Given the private API session is initialized with valid credentials
    When the user requests order history
    Then the response should be 200 OK
    And the order history response should contain history data

Private API - Data-Driven Order Testing
    [Documentation]    Scenario: User executes multiple order scenarios from test data
    ...
    ...    Criteria:
    ...    - All configured buy and sell order scenarios execute without errors
    [Tags]    order    data_driven    parameterized    skip
    [Setup]    Skip If No Valid Credentials

    Given the private API session is initialized with valid credentials
    When the user runs data-driven order tests for all configured scenarios
    Then all data-driven order tests should complete successfully

