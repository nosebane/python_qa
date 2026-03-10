*** Settings ***
Documentation       Indodax Web UI - USDT/IDR Trading Page Tests
...                 Feature: USDT/IDR Market Page Verification
...                 Tests market data, prices, and trading interface in BDD (Gherkin) style.

Resource            ../../resources/keywords/web/web_settings.robot

Suite Setup         Initialize Web Test Environment
Suite Teardown      Cleanup Web Test Environment
Test Setup          Open Test Browser
Test Teardown       Capture Screenshot On Failure And Close Browser

Test Tags           web    ui    market    usdtidr    indodax


*** Test Cases ***
Web UI - Market Page Load
    [Documentation]    Scenario: User opens the USDT/IDR market page
    ...
    ...    Criteria:
    ...    - Page loads without errors
    ...    - Page title contains the expected pair name
    ...    - Market page is responsive and interactive
    [Tags]    smoke    market    positive_case    critical

    Given the USDT/IDR market page is open
    When the page has fully loaded
    Then the page title should contain the expected pair name
    And the market page should be responsive

Web UI - Verify Market Data Available
    [Documentation]    Scenario: User views market data on the USDT/IDR page
    ...
    ...    Criteria:
    ...    - Current price is visible and non-empty
    ...    - 24-hour price change is displayed
    ...    - 24-hour volume is displayed
    [Tags]    smoke    market    data    positive_case    critical

    Given the USDT/IDR market page is open
    When the page has fully loaded
    Then the current price should be visible
    And the 24-hour price change should be visible
    And the 24-hour volume should be visible

Web UI - Current Price Display
    [Documentation]    Scenario: User verifies the current USDT/IDR price is correctly shown
    ...
    ...    Criteria:
    ...    - Price is displayed and non-empty
    ...    - Price is a positive numeric value
    [Tags]    market    price    positive_case    critical

    Given the USDT/IDR market page is open
    When the page has fully loaded
    Then the current price should be visible
    And the current price should be a positive value

Web UI - Trading Pair Header Verification
    [Documentation]    Scenario: User sees the correct trading pair in the page header
    ...
    ...    Criteria:
    ...    - Header is visible and non-empty
    ...    - Header contains the USDT identifier
    [Tags]    regression    market    header    ui    positive_case

    Given the USDT/IDR market page is open
    When the page has fully loaded
    Then the trading pair header should not be empty
    And the trading pair header should display USDT

Web UI - Market Data Snapshot
    [Documentation]    Scenario: User collects a complete live market data snapshot
    ...
    ...    Criteria:
    ...    - Live price and 24h change are captured
    ...    - Volume data is present
    ...    - Order book bid and ask are included
    [Tags]    regression    market    data    information    positive_case

    Given the USDT/IDR market page is open
    When the user collects live market data from the page
    Then the snapshot should contain price information
    And the snapshot should contain volume information
    And the snapshot should contain order book information

Web UI - Price Change Information
    [Documentation]    Scenario: User views the 24-hour price change indicator
    ...
    ...    Criteria:
    ...    - Price change element is displayed
    ...    - Price change value is non-empty
    [Tags]    regression    market    price    change    data    positive_case

    Given the USDT/IDR market page is open
    When the page has fully loaded
    Then the 24-hour price change should be visible
    And the price change value should not be empty

Web UI - Volume Information
    [Documentation]    Scenario: User views the 24-hour trading volume
    ...
    ...    Criteria:
    ...    - Volume element is displayed
    ...    - Volume value is non-empty
    [Tags]    regression    market    volume    data    positive_case

    Given the USDT/IDR market page is open
    When the page has fully loaded
    Then the 24-hour volume should be visible
    And the volume value should not be empty

Web UI - Order Book Bid and Ask
    [Documentation]    Scenario: User views bid and ask prices in the order book
    ...
    ...    Criteria:
    ...    - Bid price is visible in the order book
    ...    - Ask price is visible in the order book
    [Tags]    regression    market    orderbook    bid-ask    data    positive_case

    Given the USDT/IDR market page is open
    When the page has fully loaded
    Then the bid price should be visible in the order book
    And the ask price should be visible in the order book

Web UI - Page Screenshot Capture
    [Documentation]    Scenario: Screenshot of the market page is captured for reporting
    ...
    ...    Criteria:
    ...    - Market data section is scrolled into view
    ...    - Screenshot is saved successfully
    [Tags]    regression    market    screenshot    utility    positive_case

    Given the USDT/IDR market page is open
    When the market data section is scrolled into view
    Then a screenshot of the market page should be captured

Web UI - Responsive Page Verification
    [Documentation]    Scenario: User interacts with the page and it responds correctly
    ...
    ...    Criteria:
    ...    - Page is responsive and interactive
    ...    - Page is ready for live price updates
    [Tags]    regression    market    responsive    ui    positive_case

    Given the USDT/IDR market page is open
    When the page has fully loaded
    Then the page should be responsive and interactive
    And the page should be ready for price updates

Web UI - Market Search Functionality
    [Documentation]    Scenario: User searches for market pairs and finds correct results
    ...
    ...    Criteria:
    ...    - Each pair defined in test data is searched by base currency name
    ...    - The expected trading pair appears as the first search result
    [Tags]    market    search    ui    positive_case    critical

    Given the USDT/IDR market page is open
    And the market pairs are defined in test data
    #When the user searches for each market pair by currency name
    #Then all search results should display the expected trading pairs
    #When Search And Get First Result        USDT/IDR
    #Then Verify Search Result Contains Text        USDT/IDR
    When Search And Get First Result        $.market_pairs.ethidr.base_currency
    Then Verify Search Result Contains Text        $.market_pairs.ethidr.name        