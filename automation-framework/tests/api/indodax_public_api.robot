*** Settings ***
Documentation       Indodax Public API Test Suite
...                 Feature: Public Market Data Endpoints
...                 Tests public API endpoints in BDD (Gherkin) style:
...                 - Ticker data (Bitcoin, Ethereum, BTC/IDR)
...                 - Order book depth
...                 - Recent trades
...                 - Negative cases (invalid pair)

Resource            ../../resources/keywords/api/api_settings.robot

Suite Setup         Initialize API Test Environment
Suite Teardown      Cleanup API Test Environment

Test Tags           api    indodax    public    smoke

*** Test Cases ***
Public API - Get Bitcoin Ticker
    [Documentation]    Scenario: User requests the Bitcoin ticker from the public API
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response contains a ticker field
    ...    - Ticker has all required price fields (buy, sell, high, low, last)
    ...    - Ticker values are valid (buy <= sell, last > 0)
    ...    - Response matches the ticker JSON schema
    [Tags]    smoke    ticker    positive_case    critical

    Given the public API session is initialized
    And the test uses the "ethereum" ticker pair
    When the user requests the ticker for the resolved pair
    Then the response should be 200 OK
    And the response should contain a ticker field
    And the ticker should have all required price fields
    And all ticker price values should be valid
    And the ticker response should match the schema

Public API - Get Ethereum Ticker
    [Documentation]    Scenario: User requests the Ethereum ticker from the public API
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response contains ticker with required price fields
    ...    - Ticker values are valid
    ...    - Response matches the ticker JSON schema
    [Tags]    smoke    ticker    positive_case

    Given the public API session is initialized
    And the test uses the "ethereum" ticker pair
    When the user requests the ticker for the resolved pair
    Then the response should be 200 OK
    And the response should contain a ticker field
    And the ticker should have all required price fields
    And all ticker price values should be valid
    And the ticker response should match the schema

Public API - Get All Tickers
    [Documentation]    Scenario: User requests ticker data for the BTC/IDR pair
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response is non-empty and parseable
    [Tags]    regression    ticker    positive_case

    Given the public API session is initialized
    And the test uses the BTC/IDR trading pair directly
    When the user requests the ticker for the resolved pair
    Then the response should be 200 OK
    And the ticker response should not be empty

Public API - Invalid Pair Ticker Should Return Error
    [Documentation]    Scenario: User requests ticker for an invalid/non-existent trading pair
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200 (Indodax encodes errors in JSON body)
    ...    - Response contains an error field
    ...    - Error message is "invalid_pair"
    ...    - Response matches the error JSON schema
    [Tags]    regression    negative_case    ticker

    Given the public API session is initialized
    And the test uses the "invalid_pair_ticker" negative pair
    When the user requests the ticker for the resolved pair
    Then the response should be 200 OK
    And the response should contain an error field
    And the error message should be "invalid_pair"
    And the error response should match the schema

Public API - Get Order Book Depth
    [Documentation]    Scenario: User requests the BTC order book depth
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response contains buy and sell levels, or an API restriction message
    ...    - Depth schema is valid when buy/sell data is present
    [Tags]    regression    depth    positive_case

    Given the public API session is initialized
    And the test uses the "btc_depth" depth pair
    When the user requests the order book depth for the resolved pair
    Then the response should be 200 OK
    And the depth response should contain order book data or an API restriction message

Public API - Get Recent Trades
    [Documentation]    Scenario: User requests the BTC recent trade history
    ...
    ...    Criteria:
    ...    - Endpoint returns HTTP 200
    ...    - Response is non-empty
    ...    - Response matches the trades JSON schema
    [Tags]    regression    trades    positive_case

    Given the public API session is initialized
    And the test uses the "btc_trades" trades pair
    When the user requests recent trades for the resolved pair
    Then the response should be 200 OK
    And the trades response should not be empty
    And the trades response should match the schema
