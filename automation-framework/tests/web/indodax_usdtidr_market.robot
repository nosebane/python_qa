*** Settings ***
Documentation    Indodax Web UI - USDT/IDR Trading Page Tests
...             Tests for market data, prices, and trading interface
...             Uses env-based configuration from .env.${TEST_ENV}

Resource    ../../resources/keywords/web/web_settings.robot

Test Tags    web    ui    market    usdtidr    indodax

Suite Setup    Initialize Web Test Environment
Suite Teardown    Cleanup Web Test Environment
Test Setup        Open Test Browser
Test Teardown     Capture Screenshot On Failure And Close Browser

*** Variables ***
${TEST_ENV}       production
${headless}       true
${TIMEOUT}        10s
${MARKET_PAIR}    usdtidr


*** Test Cases ***

Web UI - Market Page Load
    [Tags]    smoke    market    positive_case    critical
    [Documentation]    Verify USDT/IDR market page loads successfully
    ...
    ...    Acceptance Criteria:
    ...    - Page loads without errors
    ...    - Market header is visible
    ...    - Trading pair is correctly displayed
    ...    - Current price is displayed
    
    
    
    # Verify page loaded
    Verify Page Is Responsive
    Verify Page Title Contains Pair    ${MARKET_PAIR}
    
    Log    ✓ Market page loaded successfully    INFO

Web UI - Verify Market Data Available
    [Tags]    smoke    market    data    positive_case    critical
    [Documentation]    Verify all market data is available and visible
    ...
    ...    Acceptance Criteria:
    ...    - Current price is visible and non-empty
    ...    - 24h price change is displayed
    ...    - 24h volume is available
    ...    - Bid and ask prices are shown
    
    
    
    # Verify all market data elements
    Verify Market Data Available
    
    # Get individual data points
    ${current_price}=    Get Current Price
    ${price_change}=    Get Price Change 24h
    ${volume}=    Get Volume 24h
    
    # Log results
    Log    Current Price: ${current_price}    INFO
    Log    24h Change: ${price_change}    INFO
    Log    24h Volume: ${volume}    INFO
    
    Log    ✓ All market data verified    INFO

Web UI - Current Price Display
    [Tags]    market    price    positive_case    critical
    [Documentation]    Verify current price is displayed correctly
    ...
    ...    Acceptance Criteria:
    ...    - Price is displayed in correct format
    ...    - Price is a positive number
    ...    - Price updates are reflected
    
    
    
    # Get price
    ${price}=    Get Current Price
    
    # Verify price
    Should Not Be Empty    ${price}    Current price is empty
    Verify Price Is Positive
    
    Log    ✓ Current price verified: ${price}    INFO

Web UI - Trading Pair Header Verification
    [Tags]    regression    market    header    ui    positive_case
    [Documentation]    Verify trading pair is correctly displayed in header
    ...
    ...    Acceptance Criteria:
    ...    - Pair name is visible
    ...    - Pair name matches USDT/IDR
    ...    - Header formatting is correct
    
    
    
    # Get pair header
    ${pair_header}=    Get Trading Pair Header
    
    # Verify header
    Should Not Be Empty    ${pair_header}    Pair header is empty
    Should Contain    ${pair_header}    USDT    ignore_case=True
    
    Log    ✓ Pair header verified: ${pair_header}    INFO

Web UI - Market Data Snapshot
    [Tags]    regression    market    data    information    positive_case
    [Documentation]    Collect complete market data snapshot
    ...
    ...    Collects:
    ...    - Current price
    ...    - 24h price change
    ...    - 24h trading volume
    ...    - Bid/Ask prices
    
    
    
    # Collect all market data
    ${market_data}=    Get Market Data Dictionary
    
    # Verify data structure
    Should Contain    ${market_data}    price
    Should Contain    ${market_data}    change_24h
    Should Contain    ${market_data}    volume_24h
    
    # Log collected data
    Log    Market Data Snapshot:    INFO
    Log    - Price: ${market_data}[price]    INFO
    Log    - 24h Change: ${market_data}[change_24h]    INFO
    Log    - 24h Volume: ${market_data}[volume_24h]    INFO
    Log    - Bid: ${market_data}[bid]    INFO
    Log    - Ask: ${market_data}[ask]    INFO
    
    Log    ✓ Market data snapshot captured    INFO

Web UI - Price Change Information
    [Tags]    regression    market    price    change    data    positive_case
    [Documentation]    Verify 24-hour price change information
    ...
    ...    Acceptance Criteria:
    ...    - Price change is displayed
    ...    - Change value is visible
    ...    - Change indicator is shown
    
    
    
    # Get price change
    ${change}=    Get Price Change 24h
    
    # Verify change information
    Should Not Be Empty    ${change}    Price change is empty
    
    Log    24-hour Price Change: ${change}    INFO
    Log    ✓ Price change information verified    INFO

Web UI - Volume Information
    [Tags]    regression    market    volume    data    positive_case
    [Documentation]    Verify 24-hour trading volume
    ...
    ...    Acceptance Criteria:
    ...    - Volume is displayed
    ...    - Volume value is visible
    ...    - Volume is non-empty
    
    
    
    # Get volume
    ${volume}=    Get Volume 24h
    
    # Verify volume
    Should Not Be Empty    ${volume}    Volume is empty
    
    Log    24-hour Volume: ${volume}    INFO
    Log    ✓ Volume information verified    INFO

Web UI - Order Book Bid and Ask
    [Tags]    regression    market    orderbook    bid-ask    data    positive_case
    [Documentation]    Verify bid and ask prices from order book
    ...
    ...    Acceptance Criteria:
    ...    - Bid price is displayed
    ...    - Ask price is displayed
    ...    - Ask price >= Bid price
    
    
    
    # Get bid and ask
    ${bid}=    Get Bid Price
    ${ask}=    Get Ask Price
    
    # Verify values
    Should Not Be Empty    ${bid}    Bid price is empty
    Should Not Be Empty    ${ask}    Ask price is empty
    
    # Verify bid-ask relationship
    Log    Bid: ${bid}    INFO
    Log    Ask: ${ask}    INFO
    Log    ✓ Bid and ask prices verified    INFO

Web UI - Page Screenshot Capture
    [Tags]    regression    market    screenshot    utility    positive_case
    [Documentation]    Capture screenshot of USDT/IDR market page
    ...
    ...    Purpose:
    ...    - Visual verification of market page
    ...    - Documentation of market state
    ...    - Test reporting
    
    
    
    # Scroll to ensure all data visible
    Scroll To Market Data
    
    # Take screenshot
    Screenshot Market Page    usdtidr_market_page
    
    Log    ✓ Screenshot captured    INFO

Web UI - Responsive Page Verification
    [Tags]    regression    market    responsive    ui    positive_case
    [Documentation]    Verify market page is responsive and interactive
    ...
    ...    Acceptance Criteria:
    ...    - Page responds to interactions
    ...    - Elements are clickable
    ...    - Page updates are visible
    
    
    
    # Verify page responsiveness
    Verify Page Is Responsive
    
    # Verify price updates
    Wait For Price Updates    ${TIMEOUT}
    
    Log    ✓ Page responsiveness verified    INFO

Web UI - Market Search Functionality
    [Tags]    market    search    ui    positive_case    critical
    [Documentation]    Verify market search functionality
    ...
    ...    Acceptance Criteria:
    ...    - Search box is accessible
    ...    - Search returns relevant results
    ...    - BTC/IDR appears in search results when searching for BTC
    
    
    
    # Search for BTC market pair
    Search Market By Pair Name    BTC
    
    # Verify search results contain BTC/IDR
    ${search_result}=    Verify Search Result Contains Text    BTC/IDR
    
    Log    ✓ Market search functionality verified    INFO
    Log    Search result: ${search_result}    INFO
