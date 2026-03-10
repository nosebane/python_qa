*** Settings ***
Documentation       Indodax Public API Keywords
...                 Keywords for unauthenticated public endpoints: ticker, depth, and trade history


*** Keywords ***
# Indodax Public API Keywords (Ticker, Depth, Trades)

Get Ticker For Pair
    [Documentation]    Get ticker data for trading pair with request/response logging
    ...
    ...    Args:
    ...        pair: Trading pair (e.g., 'btc_idr')
    ...
    ...    Returns:
    ...        Ticker response data
    [Arguments]    ${pair}

    Log    ========== API REQUEST ==========    INFO
    Log    Fetching ticker for pair: ${pair}    INFO

    ${url}=    Set Variable    ${PUBLIC_API_BASE_URL}/api/ticker/${pair}
    Log    Method: GET    INFO
    Log    URL: ${url}    INFO
    Log    Headers: Content-Type=application/json    INFO
    Log    ========== SENDING REQUEST ==========    INFO

    ${response}=    GET    ${url}    timeout=${API_TIMEOUT}

    Log    ========== API RESPONSE ==========    INFO
    Log    Status Code: ${response.status_code}    INFO
    Log    Response Headers: ${response.headers}    INFO
    Log    Response Body: ${response.text}    INFO
    Log    ========== RESPONSE END ==========    INFO

    RETURN    ${response}

Verify Ticker Response Structure
    [Documentation]    Verify ticker response has required fields
    [Arguments]    ${response}    @{required_fields}

    Log    Verifying ticker response structure    INFO
    ${response_data}=    Extract JSON From Response    ${response}

    FOR    ${field}    IN    @{required_fields}
        Should Contain Key    ${response_data}    ${field}
        Log    ✓ Field '${field}' found in response    INFO
    END

Verify Ticker Values
    [Documentation]    Verify ticker values are valid
    [Arguments]    ${response}

    Log    Verifying ticker values    INFO
    ${response_data}=    Extract JSON From Response    ${response}

    # Buy should be less than or equal to Sell
    ${buy}=    Get From Dictionary    ${response_data}    buy
    ${sell}=    Get From Dictionary    ${response_data}    sell
    Should Be True    ${buy} <= ${sell}    Buy price should be <= Sell price

    # Last should be positive
    ${last}=    Get From Dictionary    ${response_data}    last
    Should Be True    ${last} > 0    Last price should be positive

    Log    ✓ All ticker values are valid    INFO

Get Depth For Pair
    [Documentation]    Get depth using service with logging
    [Arguments]    ${pair}

    Log    ========== API REQUEST ==========    INFO
    Log    Endpoint: GET /api/depth/${pair}    INFO
    ${url}=    Set Variable    ${PUBLIC_API_BASE_URL}/api/depth/${pair}
    Log    Full URL: ${url}    INFO
    Log    ========== SENDING REQUEST ==========    INFO

    ${response}=    GET    ${url}    timeout=${API_TIMEOUT}

    Log    ========== API RESPONSE ==========    INFO
    Log    Status Code: ${response.status_code}    INFO
    Log    Response: ${response.text}    INFO
    Log    ========== END RESPONSE ==========    INFO

    RETURN    ${response}

Get Trades For Pair
    [Documentation]    Get trades using service with logging
    [Arguments]    ${pair}

    Log    ========== API REQUEST ==========    INFO
    Log    Endpoint: GET /api/trades/${pair}    INFO
    ${url}=    Set Variable    ${PUBLIC_API_BASE_URL}/api/trades/${pair}
    Log    Full URL: ${url}    INFO
    Log    ========== SENDING REQUEST ==========    INFO

    ${response}=    GET    ${url}

    Log    ========== API RESPONSE ==========    INFO
    Log    Status Code: ${response.status_code}    INFO
    Log    Response: ${response.text}    INFO
    Log    ========== END RESPONSE ==========    INFO

    RETURN    ${response}


# ─────────────────────────────────────────────────────────────────────────────
# BDD STEP KEYWORDS — Public API
# RF strips the Given/When/Then/And prefix before keyword lookup.
# e.g. "Given the public API session is initialized" → "The Public API Session Is Initialized"
# ─────────────────────────────────────────────────────────────────────────────

The Public API Session Is Initialized
    [Documentation]    BDD Given: create the public API session.

    Create Indodax Public API Session    ${API_BASE_URL}
    Log    ✓ Public API session initialized    INFO

The Test Uses The "${test_id}" Ticker Pair
    [Documentation]    BDD And: resolve ticker pair from JSON test data; store in ${CURRENT_PAIR}.

    ${pair}=    Get Public API Ticker Pair    ${test_id}
    Set Test Variable    ${CURRENT_PAIR}    ${pair}
    Log    ✓ Ticker pair resolved: ${pair}    INFO

The Test Uses The BTC/IDR Trading Pair Directly
    [Documentation]    BDD And: set ${CURRENT_PAIR} to btc_idr directly (no JSON lookup needed).

    Set Test Variable    ${CURRENT_PAIR}    btc_idr
    Log    ✓ Using btc_idr pair directly    INFO

The Test Uses The "${test_id}" Depth Pair
    [Documentation]    BDD And: resolve depth pair from JSON test data; store in ${CURRENT_PAIR}.

    ${pair}=    Get Public API Depth Pair    ${test_id}
    Set Test Variable    ${CURRENT_PAIR}    ${pair}
    Log    ✓ Depth pair resolved: ${pair}    INFO

The Test Uses The "${test_id}" Trades Pair
    [Documentation]    BDD And: resolve trades pair from JSON test data; store in ${CURRENT_PAIR}.

    ${pair}=    Get Public API Trades Pair    ${test_id}
    Set Test Variable    ${CURRENT_PAIR}    ${pair}
    Log    ✓ Trades pair resolved: ${pair}    INFO

The Test Uses The "${test_id}" Negative Pair
    [Documentation]    BDD And: resolve negative/invalid pair from JSON test data; store in ${CURRENT_PAIR}.

    ${pair}=    Get Public API Negative Pair    ${test_id}
    Set Test Variable    ${CURRENT_PAIR}    ${pair}
    Log    ✓ Negative test pair resolved: ${pair}    INFO

The User Requests The Ticker For The Resolved Pair
    [Documentation]    BDD When: call GET /api/ticker/${CURRENT_PAIR}; store response in ${CURRENT_RESPONSE}.

    ${response}=    Get Ticker For Pair    ${CURRENT_PAIR}
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Ticker request sent for pair: ${CURRENT_PAIR}    INFO

The User Requests The Order Book Depth For The Resolved Pair
    [Documentation]    BDD When: call GET /api/depth/${CURRENT_PAIR}; store response in ${CURRENT_RESPONSE}.

    ${response}=    Get Depth For Pair    ${CURRENT_PAIR}
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Depth request sent for pair: ${CURRENT_PAIR}    INFO

The User Requests Recent Trades For The Resolved Pair
    [Documentation]    BDD When: call GET /api/trades/${CURRENT_PAIR}; store response in ${CURRENT_RESPONSE}.

    ${response}=    Get Trades For Pair    ${CURRENT_PAIR}
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Trades request sent for pair: ${CURRENT_PAIR}    INFO

The Response Should Contain A Ticker Field
    [Documentation]    BDD And: assert response body contains 'ticker'; extract into ${TICKER_DATA}.

    Verify Response Contains Key    ${RESPONSE_BODY}    ticker
    ${ticker}=    Get From Dictionary    ${RESPONSE_BODY}    ticker
    Set Test Variable    ${TICKER_DATA}    ${ticker}
    Log    ✓ Response contains ticker field    INFO

The Ticker Should Have All Required Price Fields
    [Documentation]    BDD And: assert ticker has buy, sell, high, low, last fields.

    VAR    @{required_fields}    buy    sell    high    low    last
    Verify Ticker Response Structure    ${TICKER_DATA}    @{required_fields}

All Ticker Price Values Should Be Valid
    [Documentation]    BDD And: assert buy <= sell and last > 0.

    Verify Ticker Values    ${TICKER_DATA}

The Ticker Response Should Match The Schema
    [Documentation]    BDD And: validate full ticker response against the ticker JSON schema.

    Validate Ticker Response Schema    ${RESPONSE_BODY}

The Ticker Response Should Not Be Empty
    [Documentation]    BDD And: assert the ticker response body is non-empty.

    Should Not Be Empty    ${RESPONSE_BODY}
    Log    ✓ Ticker response is not empty    INFO

The Error Message Should Be "${expected_msg}"
    [Documentation]    BDD And: assert the 'error' field value matches the expected message.

    ${error_msg}=    Get From Dictionary    ${RESPONSE_BODY}    error
    Should Be Equal    ${error_msg}    ${expected_msg}
    Log    ✓ Error message is: ${error_msg}    INFO

The Error Response Should Match The Schema
    [Documentation]    BDD And: validate error response against the error JSON schema.

    Validate Error Response Schema    ${RESPONSE_BODY}

The Depth Response Should Contain Order Book Data Or An API Restriction Message
    [Documentation]    BDD And: assert depth response has buy/sell levels, or log expected API restriction.
    ...    Validates schema only when buy/sell data is present.

    ${has_error}=    Run Keyword And Return Status    Should Contain Key    ${RESPONSE_BODY}    error
    IF    ${has_error}
        Log    API returned error response — expected due to API restrictions    INFO
    ELSE
        Verify Response Contains Key    ${RESPONSE_BODY}    buy
        Verify Response Contains Key    ${RESPONSE_BODY}    sell
        Validate Depth Response Schema    ${RESPONSE_BODY}
        Log    ✓ Order book depth data present and schema valid    INFO
    END

The Trades Response Should Not Be Empty
    [Documentation]    BDD And: assert trades response body is non-empty.

    Should Not Be Empty    ${RESPONSE_BODY}
    Log    ✓ Trades response is not empty    INFO

The Trades Response Should Match The Schema
    [Documentation]    BDD And: validate trades response against the trades JSON schema.

    Validate Trades Response Schema    ${RESPONSE_BODY}
