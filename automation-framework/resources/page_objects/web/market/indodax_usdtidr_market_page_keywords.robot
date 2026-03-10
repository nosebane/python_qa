*** Settings ***
Documentation       Web automation keywords for Indodax USDT/IDR market page
...                 Provides low-level action keywords and BDD step keywords.
...
...                 BDD steps follow Robot Framework's Gherkin convention:
...                 Given/When/Then/And prefixes are stripped before keyword lookup,
...                 so "Given the USDT/IDR market page is open" resolves to
...                 "The USDT/IDR Market Page Is Open".

Library             Browser
Library             JSONLibrary
Library             Collections
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

Verify Price Is Positive
    [Documentation]    Assert current price is a non-empty positive number

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

    ${is_jsonpath}=    Run Keyword And Return Status    Should Start With    ${expected_text}    $
    IF    ${is_jsonpath}
        ${resolved_list}=    Get Value From Json    ${WEB_TEST_DATA}    ${expected_text}
        ${search_term}=      Set Variable    ${resolved_list}[0]
        Log    [JSONPath] '${search_term}'    INFO
    ELSE
        ${search_term}=    Set Variable    ${expected_text}
        Log    [Plain] search term: '${search_term}'    INFO
    END

    # Assert the top result row contains the expected text
    ${first_result}=    Get Text    ${FIRST_MARKET_SEARCH_RESULT}
    ${first_lower}=     Convert To Lower Case    ${first_result}
    ${expected_lower}=  Convert To Lower Case    ${search_term}
    Should Contain    ${first_lower}    ${expected_lower}
    ...    msg=Expected '${search_term}' not found in first search result: '${first_result}'

    Log    ✓ First search result contains: ${search_term}    INFO
    RETURN    ${first_result}

Get First Search Result Text
    [Documentation]    Return the raw text of the first search result row.
    ...    Atomic read (Layer 1) — used by composite keywords to avoid duplicating Get Text calls.

    ${text}=    Get Text    ${FIRST_MARKET_SEARCH_RESULT}
    RETURN    ${text}

Collect Live Market Snapshot
    [Documentation]    Collect live market data from page and return as a dictionary.
    ...    Keys: price, change_24h, volume_24h, bid, ask

    Log    Collecting live market snapshot from page    INFO
    ${price}=      Get Current Price
    ${change}=     Get Price Change 24h
    ${volume}=     Get Volume 24h
    ${bid}=        Get Bid Price
    ${ask}=        Get Ask Price
    ${snapshot}=   Create Dictionary
    ...    price=${price}
    ...    change_24h=${change}
    ...    volume_24h=${volume}
    ...    bid=${bid}
    ...    ask=${ask}
    Log    Live snapshot: ${snapshot}    INFO
    RETURN    ${snapshot}

Search And Get First Result
    [Documentation]    Search for a term and return the first result text.
    ...    Composite (Layer 2): accepts TWO forms of input —
    ...
    ...    1. Plain value  — used directly as the search term.
    ...       Search And Get First Result    BTC
    ...       Search And Get First Result    USDT/IDR
    ...
    ...    2. JSONPath     — resolved from \${WEB_TEST_DATA} via JSONLibrary (starts with "$").
    ...       Search And Get First Result    \$.market_pairs.usdtidr.base_currency
    ...       Search And Get First Result    \$.market_pairs.btcidr.name
    ...
    ...    Resolution: if \${search_input} starts with "$", the keyword calls
    ...    Get Value From Json and uses the first list item as the actual search term.
    [Arguments]    ${search_input}

    ${is_jsonpath}=    Run Keyword And Return Status    Should Start With    ${search_input}    $
    IF    ${is_jsonpath}
        ${resolved_list}=    Get Value From Json    ${WEB_TEST_DATA}    ${search_input}
        ${search_term}=      Set Variable    ${resolved_list}[0]
        Log    [JSONPath] '${search_input}' → '${search_term}'    INFO
    ELSE
        ${search_term}=    Set Variable    ${search_input}
        Log    [Plain] search term: '${search_term}'    INFO
    END
    Search Market By Pair Name    ${search_term}
    ${result}=    Get First Search Result Text
    RETURN    ${result}

Search All Pairs From Test Data
    [Documentation]    Iterate all pairs in ${WEB_TEST_DATA}[market_pairs], search each by
    ...    base_currency, and store a result list in the ${SEARCH_RESULTS} test variable.
    ...    Composite (Layer 2): reusable whenever test data follows the market_pairs schema.
    ...    Each result entry dict: {pair_id, search_term, expected, actual}

    ${pair_ids}=        Get Dictionary Keys    ${WEB_TEST_DATA}[market_pairs]    sort_keys=False
    ${results}=         Create List
    FOR    ${pair_id}    IN    @{pair_ids}
        ${term_list}=      Get Value From Json    ${WEB_TEST_DATA}    $.market_pairs.${pair_id}.base_currency
        ${exp_list}=       Get Value From Json    ${WEB_TEST_DATA}    $.market_pairs.${pair_id}.name
        ${search_term}=    Set Variable    ${term_list}[0]
        ${expected}=       Set Variable    ${exp_list}[0]
        Log    [${pair_id}] Searching: '${search_term}' | Expecting: '${expected}'    INFO
        ${actual}=    Search And Get First Result    ${search_term}
        ${entry}=    Create Dictionary
        ...    pair_id=${pair_id}
        ...    search_term=${search_term}
        ...    expected=${expected}
        ...    actual=${actual}
        Append To List    ${results}    ${entry}
    END
    Set Test Variable    ${SEARCH_RESULTS}    ${results}


# ─────────────────────────────────────────────────────────────────────────────
# BDD STEP KEYWORDS  (Given / When / Then / And)
# RF strips the Given/When/Then/And prefix before keyword lookup.
# e.g. "Given the USDT/IDR market page is open" → "The USDT/IDR Market Page Is Open"
# ─────────────────────────────────────────────────────────────────────────────

The USDT/IDR Market Page Is Open
    [Documentation]    BDD Given: confirms the market page session is active.
    ...    Browser navigation is already done by Test Setup → Open Test Browser.

    Log    USDT/IDR market page is active    INFO

The Page Has Fully Loaded
    [Documentation]    BDD When: wait for the market page to be fully rendered.

    Wait For Page Load

The Page Title Should Contain The Expected Pair Name
    [Documentation]    BDD Then: assert page title contains expected pair text from test data.

    Verify Page Title Contains Pair    ${WEB_TEST_DATA}[test_expectations][page_title_expected]

The Market Page Should Be Responsive
    [Documentation]    BDD And: assert page is interactive (title is non-blank).

    Verify Page Is Responsive

The Current Price Should Be Visible
    [Documentation]    BDD Then/And: assert current price element is displayed and non-empty.

    ${price}=    Get Current Price
    Should Not Be Empty    ${price}    Current price is empty
    Log    ✓ Current price visible: ${price}    INFO

The 24-Hour Price Change Should Be Visible
    [Documentation]    BDD Then/And: assert 24h price change element is displayed and non-empty.

    ${change}=    Get Price Change 24h
    Should Not Be Empty    ${change}    24h price change is empty
    Log    ✓ 24h price change visible: ${change}    INFO

The 24-Hour Volume Should Be Visible
    [Documentation]    BDD Then/And: assert 24h volume element is displayed and non-empty.

    ${volume}=    Get Volume 24h
    Should Not Be Empty    ${volume}    24h volume is empty
    Log    ✓ 24h volume visible: ${volume}    INFO

The Current Price Should Be A Positive Value
    [Documentation]    BDD And: assert current price is a non-empty positive number.

    Verify Price Is Positive

The Trading Pair Header Should Not Be Empty
    [Documentation]    BDD Then: assert the trading pair header text is present.

    ${header}=    Get Trading Pair Header
    Should Not Be Empty    ${header}    Trading pair header is empty
    Log    ✓ Header present: ${header}    INFO

The Trading Pair Header Should Display USDT
    [Documentation]    BDD And: assert the trading pair header contains the USDT identifier.

    ${header}=    Get Trading Pair Header
    Should Contain    ${header}    USDT    ignore_case=True
    Log    ✓ Header contains USDT: ${header}    INFO

The User Collects Live Market Data From The Page
    [Documentation]    BDD When: collect a live market snapshot and store as a test variable.

    ${snapshot}=    Collect Live Market Snapshot
    Set Test Variable    ${LIVE_SNAPSHOT}    ${snapshot}

The Snapshot Should Contain Price Information
    [Documentation]    BDD Then: assert snapshot has price and 24h change fields.

    Should Not Be Empty    ${LIVE_SNAPSHOT}[price]       Price missing from snapshot
    Should Not Be Empty    ${LIVE_SNAPSHOT}[change_24h]  24h change missing from snapshot
    Log    ✓ Price: ${LIVE_SNAPSHOT}[price] | Change: ${LIVE_SNAPSHOT}[change_24h]    INFO

The Snapshot Should Contain Volume Information
    [Documentation]    BDD And: assert snapshot has volume_24h field.

    Should Not Be Empty    ${LIVE_SNAPSHOT}[volume_24h]  Volume missing from snapshot
    Log    ✓ Volume: ${LIVE_SNAPSHOT}[volume_24h]    INFO

The Snapshot Should Contain Order Book Information
    [Documentation]    BDD And: assert snapshot has bid and ask fields.

    Should Not Be Empty    ${LIVE_SNAPSHOT}[bid]  Bid missing from snapshot
    Should Not Be Empty    ${LIVE_SNAPSHOT}[ask]  Ask missing from snapshot
    Log    ✓ Bid: ${LIVE_SNAPSHOT}[bid] | Ask: ${LIVE_SNAPSHOT}[ask]    INFO

The Price Change Value Should Not Be Empty
    [Documentation]    BDD And: assert 24h price change value is non-empty.

    ${change}=    Get Price Change 24h
    Should Not Be Empty    ${change}    Price change value is empty
    Log    ✓ Price change: ${change}    INFO

The Volume Value Should Not Be Empty
    [Documentation]    BDD And: assert 24h volume value is non-empty.

    ${volume}=    Get Volume 24h
    Should Not Be Empty    ${volume}    Volume value is empty
    Log    ✓ Volume: ${volume}    INFO

The Bid Price Should Be Visible In The Order Book
    [Documentation]    BDD Then: assert bid price is displayed in the order book.

    ${bid}=    Get Bid Price
    Should Not Be Empty    ${bid}    Bid price is empty
    Log    ✓ Bid price: ${bid}    INFO

The Ask Price Should Be Visible In The Order Book
    [Documentation]    BDD And: assert ask price is displayed in the order book.

    ${ask}=    Get Ask Price
    Should Not Be Empty    ${ask}    Ask price is empty
    Log    ✓ Ask price: ${ask}    INFO

The Market Data Section Is Scrolled Into View
    [Documentation]    BDD When: scroll to bring market data into view.

    Scroll To Market Data

A Screenshot Of The Market Page Should Be Captured
    [Documentation]    BDD Then: capture a screenshot of the current market page state.

    Screenshot Market Page    usdtidr_market_page

The Page Should Be Responsive And Interactive
    [Documentation]    BDD Then: assert page is responsive (title is non-blank).

    Verify Page Is Responsive

The Page Should Be Ready For Price Updates
    [Documentation]    BDD And: wait for the price element to reach interactive state.

    Wait For Price Updates    10s

The Market Pairs Are Defined In Test Data
    [Documentation]    BDD And: assert the market_pairs section in test data is non-empty.

    ${pairs}=    Get Dictionary Keys    ${WEB_TEST_DATA}[market_pairs]
    Should Not Be Empty    ${pairs}    No market pairs defined in test data
    Log    ✓ Market pairs defined: ${pairs}    INFO

The User Searches For "${search_term}"
    [Documentation]    BDD When: search using a plain value OR a JSONPath expression.
    ...    Delegates to Search And Get First Result (Layer 2) which auto-detects input type.
    ...    Stores the first result text in \${LAST_SEARCH_RESULT} for subsequent Then steps.
    ...
    ...    Plain value:  When the user searches for "BTC"
    ...    JSONPath:     When the user searches for "$.market_pairs.usdtidr.base_currency"

    ${result}=    Search And Get First Result    ${search_term}
    Set Test Variable    ${LAST_SEARCH_RESULT}    ${result}

The First Search Result Should Contain "${expected_text}"
    [Documentation]    BDD Then: assert \${LAST_SEARCH_RESULT} contains expected text (case-insensitive).
    ...    Pair with "The User Searches For \"${search_term}\"" for single-pair manual scenarios.
    ...    Usage: Then the first search result should contain "BTC/IDR"

    ${actual_lower}=    Convert To Lower Case    ${LAST_SEARCH_RESULT}
    ${expected_lower}=  Convert To Lower Case    ${expected_text}
    Should Contain    ${actual_lower}    ${expected_lower}
    ...    msg=Expected '${expected_text}' not found in first result: '${LAST_SEARCH_RESULT}'
    Log    ✓ First result contains '${expected_text}'    INFO

The User Searches For Each Market Pair By Currency Name
    [Documentation]    BDD When: search for all pairs defined in \${WEB_TEST_DATA} and store results.
    ...    Delegates to Search All Pairs From Test Data (Layer 2 composite).
    ...    Results stored in \${SEARCH_RESULTS} for Then-step verification.

    Search All Pairs From Test Data

All Search Results Should Display The Expected Trading Pairs
    [Documentation]    BDD Then: assert every stored search result matches its expected pair.

    FOR    ${result}    IN    @{SEARCH_RESULTS}
        ${actual_lower}=    Convert To Lower Case    ${result}[actual]
        ${expected_lower}=  Convert To Lower Case    ${result}[expected]
        Should Contain    ${actual_lower}    ${expected_lower}
        ...    msg=Expected '${result}[expected]' not found in first result: '${result}[actual]'
        Log    ✓ [${result}[pair_id]] '${result}[expected]' found    INFO
    END
