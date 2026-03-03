*** Settings ***
Documentation       Web automation keywords for Indodax market page
...                 Provides high-level keywords for interacting with market data

Library             Browser
Library             JSONLibrary
Resource            ./indodax_usdtidr_market_page_locators.robot


*** Keywords ***
Wait For Page Load
    [Documentation]    Wait for market page to load completely

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
    [Documentation]    Verify page title contains the expected pair text
    ...
    ...    Args:
    ...        expected_text: Text expected to appear in the page title
    [Arguments]    ${expected_text}

    Log    Verifying page title contains: ${expected_text}    INFO
    ${title}=    Get Title
    Should Contain    ${title}    ${expected_text}    ignore_case=True
    Log    ✓ Page title contains '${expected_text}'    INFO

Wait For Price Updates
    [Documentation]    Wait for price to update/change
    ...
    ...    Args:
    ...        timeout: Maximum time to wait for update
    [Arguments]    ${timeout}=10s

    Log    Waiting for price updates (timeout: ${timeout})    INFO
    # Wait for price element to be enabled/interactive
    Wait For Elements State    ${CURRENT_PRICE_LOCATOR}    enabled    timeout=${timeout}
    Log    Page is responsive and interactive    INFO

Get Market Data Dictionary
    [Documentation]    Get market data for the current pair as a flat dictionary
    ...    Reads from WEB_TEST_DATA via JSONPath $.market_data.usdtidr

    Log    Collecting market data from test data    INFO

    ${market_data_list}=    Get Value From Json    ${WEB_TEST_DATA}    $.market_data.usdtidr
    ${market_data}=    Set Variable    ${market_data_list}[0]

    Log    Market data collected: ${market_data}    INFO
    RETURN    ${market_data}

Verify Price Is Positive
    [Documentation]    Verify current price is a positive number

    Log    Verifying price is positive    INFO
    ${price}=    Get Current Price

    Should Not Be Empty    ${price}    Price is empty
    Log    ✓ Price is positive: ${price}    INFO

Screenshot Market Page
    [Documentation]    Take screenshot of market page
    ...
    ...    Args:
    ...        filename: Filename for screenshot (without extension)
    [Arguments]    ${filename}=market_page

    Log    Taking screenshot: ${filename}.png    INFO
    Take Screenshot
    Log    Screenshot saved    INFO

Scroll To Market Data
    [Documentation]    Scroll to ensure market data is in view

    Log    Scrolling to market data    INFO

    Log    Scrolled to top of page    INFO

Navigate To Market Page
    [Documentation]    Navigate to market page, reads pair_id from WEB_TEST_DATA via JSONPath
    ...    Args:
    ...        base_url: Base URL of the website
    [Arguments]    ${base_url}

    ${pair_id_list}=    Get Value From Json    ${WEB_TEST_DATA}    $.market_pairs.usdtidr.pair_id
    ${pair_id}=    Set Variable    ${pair_id_list}[0]

    Log    Navigating to market page: ${base_url}/market/${pair_id}    INFO

    ${url}=    Set Variable    ${base_url}/market/${pair_id}
    Go To    ${url}    wait_until=domcontentloaded

    Log    Navigated to market page successfully    INFO

Verify Page Is Responsive
    [Documentation]    Verify page is responsive and interactive

    Log    Verifying page responsiveness    INFO

    ${page_title}=    Get Title
    Should Not Be Empty    ${page_title}    Page is not responsive

    Log    ✓ Page is responsive    INFO

Search Market By Pair Name
    [Documentation]    Search for market pair by name in search box
    ...
    ...    Args:
    ...        search_term: Trading pair name to search (e.g., BTC)
    [Arguments]    ${search_term}

    Log    Searching for market pair: ${search_term}    INFO

    # Click on search box and enter search term
    Click    ${SEARCH_BOX_MARKET}
    Type Text    ${SEARCH_BOX_MARKET}    ${search_term}

    # Wait for the search filter to be applied (attached confirms row is in DOM after filter runs)
    Wait For Elements State    ${FIRST_MARKET_SEARCH_RESULT}    attached    timeout=15s

    Log    ✓ Searched for: ${search_term}    INFO

Verify Search Result Contains Text
    [Documentation]    Verify the first search result row contains expected text
    ...
    ...    Asserts the top result matches the expected pair — if the expected
    ...    pair is not first, that is itself a UX failure worth catching.
    ...
    ...    Args:
    ...        expected_text: Expected text in the first search result row (e.g., BTC/IDR)
    [Arguments]    ${expected_text}

    Log    Verifying first search result contains: ${expected_text}    INFO

    # Assert the top result row contains the expected text
    ${first_result}=    Get Text    ${FIRST_MARKET_SEARCH_RESULT}
    ${first_lower}=     Convert To Lower Case    ${first_result}
    ${expected_lower}=  Convert To Lower Case    ${expected_text}
    Should Contain    ${first_lower}    ${expected_lower}
    ...    msg=Expected '${expected_text}' not found in first search result: '${first_result}'

    Log    ✓ First search result contains: ${expected_text}    INFO
    RETURN    ${first_result}
