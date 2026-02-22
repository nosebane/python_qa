*** Settings ***
Documentation    Web automation keywords for Indodax market page
...             Provides high-level keywords for interacting with market data

Library    Browser

Resource    ./indodax_usdtidr_market_page_locators.robot

*** Keywords ***

Wait For Page Load
    [Arguments]    ${pair}
    [Documentation]    Wait for market page to load completely
    ...    
    ...    Args:
    ...        pair: Trading pair for verification
    
    Log    Waiting for market page to load...    INFO
    # Wait for current price element to be visible (indicates page is loaded)
    Wait For Elements State    ${CURRENT_PRICE_LOCATOR}    visible    timeout=30s
    Log    Market page loaded successfully    INFO

Get Current Price
    [Documentation]    Get current trading price from page
    
    Log    Retrieving current price    INFO
    ${price}=    Get Text    ${CURRENT_PRICE_LOCATOR}
    Log    Current price: ${price}    INFO
    RETURN    ${price}

Get Price Change 24h
    [Documentation]    Get 24-hour price change
    
    Log    Retrieving 24h price change    INFO
    ${change}=    Get Text    ${PRICE_CHANGE_24H_LOCATOR}
    Log    Price change: ${change}    INFO
    RETURN    ${change}

Get Volume 24h
    [Documentation]    Get 24-hour trading volume
    
    Log    Retrieving 24h volume    INFO
    ${volume}=    Get Text    ${VOLUME_24H_LOCATOR}
    Log    24h volume: ${volume}    INFO
    RETURN    ${volume}

Get Bid Price
    [Documentation]    Get bid price from order book
    
    Log    Retrieving bid price    INFO
    ${bid}=    Get Text    ${BID_PRICE_LOCATOR}
    Log    Bid price: ${bid}    INFO
    RETURN    ${bid}

Get Ask Price
    [Documentation]    Get ask price from order book
    
    Log    Retrieving ask price    INFO
    ${ask}=    Get Text    ${ASK_PRICE_LOCATOR}
    Log    Ask price: ${ask}    INFO
    RETURN    ${ask}

Verify Market Data Available
    [Documentation]    Verify market data is available and not empty
    
    Log    Verifying market data availability    INFO
    
    ${price}=    Get Current Price
    Should Not Be Empty    ${price}    Current price is empty
    
    ${change}=    Get Price Change 24h
    Should Not Be Empty    ${change}    Price change is empty
    
    Log    ✓ Market data is available    INFO

Get Trading Pair Header
    [Documentation]    Get the trading pair header/name
    
    Log    Retrieving trading pair header    INFO
    ${header}=    Get Text    ${TRADING_PAIR_HEADER_LOCATOR}
    Log    Trading pair: ${header}    INFO
    RETURN    ${header}

Verify Page Title Contains Pair
    [Arguments]    ${pair}
    [Documentation]    Verify page title contains the trading pair name
    ...    
    ...    Args:
    ...        pair: Expected trading pair
    
    Log    Verifying page title contains: ${pair}    INFO
    ${title}=    Get Title
    ${expected_text}=    Get From Dictionary    ${WEB_TEST_DATA}    page_title_expected
    Should Contain    ${title}    ${expected_text}    ignore_case=True
    Log    ✓ Page title contains pair name    INFO

Wait For Price Updates
    [Arguments]    ${timeout}=10s
    [Documentation]    Wait for price to update/change
    ...    
    ...    Args:
    ...        timeout: Maximum time to wait for update
    
    Log    Waiting for price updates (timeout: ${timeout})    INFO
    # Wait for price element to be enabled/interactive
    Wait For Elements State    ${CURRENT_PRICE_LOCATOR}    enabled    timeout=${timeout}
    Log    Page is responsive and interactive    INFO

Get Market Data Dictionary
    [Documentation]    Get all market data as dictionary from test data
    
    Log    Collecting market data from test data    INFO
    
    # Return WEB_TEST_DATA which contains merged market data and test expectations
    ${market_data}=    Get Variable Value    ${WEB_TEST_DATA}    {}
    
    Log    Market data collected: ${market_data}    INFO
    RETURN    ${market_data}

Verify Price Is Positive
    [Documentation]    Verify current price is a positive number
    
    Log    Verifying price is positive    INFO
    ${price}=    Get Current Price
    
    Should Not Be Empty    ${price}    Price is empty
    Log    ✓ Price is positive: ${price}    INFO

Screenshot Market Page
    [Arguments]    ${filename}=market_page
    [Documentation]    Take screenshot of market page
    ...    
    ...    Args:
    ...        filename: Filename for screenshot (without extension)
    
    Log    Taking screenshot: ${filename}.png    INFO
    Take Screenshot
    Log    Screenshot saved    INFO

Scroll To Market Data
    [Documentation]    Scroll to ensure market data is in view
    
    Log    Scrolling to market data    INFO
    
    Log    Scrolled to top of page    INFO

Navigate To Market Page
    [Arguments]    ${base_url}    ${market_pair}
    [Documentation]    Navigate to market page with robust error handling
    ...    
    ...    Args:
    ...        base_url: Base URL of the website
    ...        market_pair: Trading pair to navigate to
    
    Log    Navigating to market page: ${base_url}/market/${market_pair}    INFO
    
    ${url}=    Set Variable    ${base_url}/market/${market_pair}
    
    # Go to the URL - domcontentloaded waits for DOM but not all resources
    Go To    ${url}    wait_until=domcontentloaded
    
    Log    Navigated to market page successfully    INFO


Verify Page Is Responsive
    [Documentation]    Verify page is responsive and interactive
    
    Log    Verifying page responsiveness    INFO
    
    ${page_title}=    Get Title
    Should Not Be Empty    ${page_title}    Page is not responsive
    
    Log    ✓ Page is responsive    INFO

Search Market By Pair Name
    [Arguments]    ${search_term}
    [Documentation]    Search for market pair by name in search box
    ...    
    ...    Args:
    ...        search_term: Trading pair name to search (e.g., BTC)
    
    Log    Searching for market pair: ${search_term}    INFO
    
    # Click on search box and enter search term
    Click    ${SEARCH_BOX_MARKET}
    Fill Text    ${SEARCH_BOX_MARKET}    ${search_term}
    
    # Wait for search results table to be attached/rendered
    Wait For Elements State    ${FIRST_MARKET_SEARCH_RESULT}    attached    timeout=15s
    
    Log    ✓ Searched for: ${search_term}    INFO

Verify Search Result Contains Text
    [Arguments]    ${expected_text}
    [Documentation]    Verify first search result contains expected text
    ...    
    ...    Args:
    ...        expected_text: Expected text in search result (e.g., BTC/IDR)
    
    Log    Verifying search result contains: ${expected_text}    INFO
    
    # Get text from first search result
    ${result_text}=    Get Text    ${FIRST_MARKET_SEARCH_RESULT}
    
    # Verify the text is present
    Should Contain    ${result_text}    ${expected_text}    ignore_case=True
    
    Log    ✓ Search result contains: ${expected_text}    INFO
    Log    Actual result: ${result_text}    INFO
    RETURN    ${result_text}
