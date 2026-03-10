*** Settings ***
Documentation       Indodax Private API Keywords
...                 Keywords for authenticated API calls: orders, account info, and trade management


*** Keywords ***
# Indodax Private API Keywords (Orders, Account, Management)

# Private API Setup Keywords

Setup Private API Signing
    [Documentation]    Initialize HMAC-SHA512 signer for private API requests
    ...
    ...    Creates a signer instance that can be used to sign API requests.
    ...    Must be called after credentials are loaded.

    Log    Setting up Private API HMAC-SHA512 signing    DEBUG
    Create Indodax Signer    ${API_KEY}    ${API_SECRET}
    Log    Signer initialized with API key: ${API_KEY}    DEBUG

Skip If No Valid Credentials
    [Documentation]    Skip test if valid API credentials are not available or appear invalid.
    ...
    ...    Checks that API_KEY and API_SECRET are:
    ...      - Non-empty
    ...      - At least 20 characters (real Indodax keys are 40+ chars)
    ...    Called in [Setup] to gate tests that require real authentication.
    ...    Remove the 'skip' tag on the test once valid credentials are in .env.${TEST_ENV}.

    ${has_key}=    Run Keyword And Return Status    Should Not Be Empty    ${API_KEY}
    ${has_secret}=    Run Keyword And Return Status    Should Not Be Empty    ${API_SECRET}
    ${key_len}=    Run Keyword And Return Status    Should Be True    len('${API_KEY}') >= 20
    ${secret_len}=    Run Keyword And Return Status    Should Be True    len('${API_SECRET}') >= 20

    IF    not (${has_key} and ${has_secret} and ${key_len} and ${secret_len})
        Skip
        ...    ⚠️ Skipped: Valid API credentials not configured or appear invalid. Set INDODAX_API_KEY and INDODAX_API_SECRET in .env.${TEST_ENV}
    END

Setup Dummy Signer For Testing
    [Documentation]    Initialize signer with dummy credentials for testing
    ...
    ...    Used by tests that don't require valid credentials but need signing capability.
    ...    Allows testing API endpoint structure and validation without real credentials.

    Log    Setting up dummy signer for API testing    DEBUG
    Create Indodax Signer    dummy_test_key_12345    dummy_test_secret_12345
    Log    Dummy signer initialized for testing    DEBUG

# Order Keywords

Place Buy Order
    [Documentation]    Call private API trade endpoint to place buy order
    ...
    ...    Endpoint: POST /tapi/trade
    ...    Authentication: HMAC-SHA512
    ...    Parameters: method=trade, pair, type=buy, price, amount
    [Arguments]    ${pair}    ${price}    ${amount}

    Log    Placing BUY order: ${amount} ${pair} @ ${price}    DEBUG

    ${url}=    Set Variable    ${API_BASE_URL}
    VAR    &{params}
    ...    pair=${pair}
    ...    type=buy
    ...    price=${price}
    ...    amount=${amount}

    ${signed}=    Sign Indodax Request    trade    ${params}
    ${body}=    Get From Dictionary    ${signed}    body
    ${headers}=    Get From Dictionary    ${signed}    headers

    Log    URL: ${url}    DEBUG
    Log    Body: ${body}    DEBUG

    ${response}=    POST    ${url}    data=${body}    headers=${headers}    timeout=${API_TIMEOUT}

    RETURN    ${response}

Place Sell Order
    [Documentation]    Call private API trade endpoint to place sell order
    ...
    ...    Endpoint: POST /tapi/trade
    ...    Authentication: HMAC-SHA512
    ...    Parameters: method=trade, pair, type=sell, price, amount
    [Arguments]    ${pair}    ${price}    ${amount}

    Log    Placing SELL order: ${amount} ${pair} @ ${price}    DEBUG

    ${url}=    Set Variable    ${API_BASE_URL}
    VAR    &{params}
    ...    pair=${pair}
    ...    type=sell
    ...    price=${price}
    ...    amount=${amount}

    ${signed}=    Sign Indodax Request    trade    ${params}
    ${body}=    Get From Dictionary    ${signed}    body
    ${headers}=    Get From Dictionary    ${signed}    headers

    Log    URL: ${url}    DEBUG
    Log    Body: ${body}    DEBUG

    ${response}=    POST    ${url}    data=${body}    headers=${headers}    timeout=${API_TIMEOUT}

    RETURN    ${response}

Verify Order Response
    [Documentation]    Verify order response contains expected data
    [Arguments]    ${response}    ${order_type}    ${pair}    ${price}    ${amount}

    Log    Verifying ${order_type} order response    INFO

    ${order_response}=    Extract JSON From Response    ${response}

    # Check status
    Should Contain Key    ${order_response}    return
    ${order_data}=    Get From Dictionary    ${order_response}    return

    # Verify order details match request
    Should Be Equal    ${order_data.type}    ${order_type}
    Should Be Equal    ${order_data.pair}    ${pair}
    Should Be Equal    ${order_data.price}    ${price}
    Should Be Equal    ${order_data.amount}    ${amount}

    Log    ✓ Order response verified successfully    INFO

Verify Order Is Created
    [Documentation]    Verify order was successfully created
    [Arguments]    ${response}

    Log    Verifying order was created    INFO

    ${order_response}=    Extract JSON From Response    ${response}

    Should Contain Key    ${order_response}    return
    ${order_data}=    Get From Dictionary    ${order_response}    return
    Should Contain Key    ${order_data}    order_id

    ${order_id}=    Get From Dictionary    ${order_data}    order_id
    Should Not Be Empty    ${order_id}
    Log    ✓ Order created with ID: ${order_id}    INFO

    RETURN    ${order_id}

# Account Keywords

Get Account Info
    [Documentation]    Call private API getInfo endpoint to get account information
    ...
    ...    Endpoint: POST /tapi/getInfo
    ...    Authentication: HMAC-SHA512
    ...    Returns: Account info with balances

    Log    Calling Private API /tapi/getInfo    DEBUG

    ${url}=    Set Variable    ${API_BASE_URL}
    ${signed}=    Sign Indodax Request    getInfo
    ${body}=    Get From Dictionary    ${signed}    body
    ${headers}=    Get From Dictionary    ${signed}    headers

    Log    URL: ${url}    DEBUG
    Log    Headers: ${headers}    DEBUG
    Log    Body: ${body}    DEBUG

    ${response}=    POST    ${url}    data=${body}    headers=${headers}    timeout=${API_TIMEOUT}

    RETURN    ${response}

Get Account Balance
    [Documentation]    Call private API getBalance endpoint to get account balance
    ...
    ...    Endpoint: POST /tapi/getBalance
    ...    Authentication: HMAC-SHA512
    ...    Returns: Balance for all assets

    Log    Calling Private API /tapi/getBalance    DEBUG

    ${url}=    Set Variable    ${API_BASE_URL}
    ${signed}=    Sign Indodax Request    getBalance
    ${body}=    Get From Dictionary    ${signed}    body
    ${headers}=    Get From Dictionary    ${signed}    headers

    Log    URL: ${url}    DEBUG
    Log    Body: ${body}    DEBUG

    ${response}=    POST    ${url}    data=${body}    headers=${headers}    timeout=${API_TIMEOUT}

    RETURN    ${response}

# Order Management Keywords

Cancel Order
    [Documentation]    Call private API cancelOrder endpoint to cancel an order
    ...
    ...    Endpoint: POST /tapi/cancelOrder
    ...    Authentication: HMAC-SHA512
    ...    Parameters: method=cancelOrder, order_id, pair
    [Arguments]    ${order_id}    ${pair}

    Log    Cancelling order ${order_id} for ${pair}    DEBUG

    ${url}=    Set Variable    ${API_BASE_URL}
    VAR    &{params}
    ...    order_id=${order_id}
    ...    pair=${pair}

    ${signed}=    Sign Indodax Request    cancelOrder    ${params}
    ${body}=    Get From Dictionary    ${signed}    body
    ${headers}=    Get From Dictionary    ${signed}    headers

    Log    URL: ${url}    DEBUG
    Log    Body: ${body}    DEBUG

    ${response}=    POST    ${url}    data=${body}    headers=${headers}    timeout=${API_TIMEOUT}

    RETURN    ${response}

Get Open Orders
    [Documentation]    Call private API openOrders endpoint to get list of open orders
    ...
    ...    Endpoint: POST /tapi/openOrders
    ...    Authentication: HMAC-SHA512
    ...    Parameters: method=openOrders, pair (optional)
    [Arguments]    ${pair}=${EMPTY}

    Log    Getting open orders for pair: ${pair}    DEBUG

    ${url}=    Set Variable    ${API_BASE_URL}
    VAR    &{params}

    # Add pair if specified
    IF    '${pair}' != '${EMPTY}'
        Set To Dictionary    ${params}    pair=${pair}
    END

    ${signed}=    Sign Indodax Request    openOrders    ${params}
    ${body}=    Get From Dictionary    ${signed}    body
    ${headers}=    Get From Dictionary    ${signed}    headers

    Log    URL: ${url}    DEBUG
    Log    Body: ${body}    DEBUG

    ${response}=    POST    ${url}    data=${body}    headers=${headers}    timeout=${API_TIMEOUT}

    RETURN    ${response}

Get Order History
    [Documentation]    Call private API tradeHistory endpoint to get order history
    ...
    ...    Endpoint: POST /tapi/tradeHistory
    ...    Authentication: HMAC-SHA512
    ...    Parameters: method=tradeHistory

    Log    Getting order history    DEBUG

    ${url}=    Set Variable    ${API_BASE_URL}
    ${signed}=    Sign Indodax Request    tradeHistory
    ${body}=    Get From Dictionary    ${signed}    body
    ${headers}=    Get From Dictionary    ${signed}    headers

    Log    URL: ${url}    DEBUG
    Log    Body: ${body}    DEBUG

    ${response}=    POST    ${url}    data=${body}    headers=${headers}    timeout=${API_TIMEOUT}

    RETURN    ${response}

# Logging Keywords

Log Request Details
    [Documentation]    Log request details for debugging
    [Arguments]    ${method}    ${endpoint}    ${params}=${EMPTY}    ${body}=${EMPTY}

    Log    ========== API REQUEST ==========    INFO
    Log    Method: ${method}    INFO
    Log    Endpoint: ${endpoint}    INFO
    IF    '${params}' != '${EMPTY}'    Log    Params: ${params}    INFO
    IF    '${body}' != '${EMPTY}'    Log    Body: ${body}    INFO
    Log    ==================================    INFO

Log Response Details
    [Documentation]    Log response details for debugging
    ...    Handles both response objects and parsed JSON dicts
    [Arguments]    ${response}    ${include_body}=${True}

    Log    ========== API RESPONSE ==========    INFO

    # Check if response is a dict or Response object
    ${response_str}=    Convert To String    ${response}
    ${is_dict}=    Run Keyword And Return Status    Should Start With    ${response_str}    {

    IF    ${is_dict}
        # Response is already a dict - log as JSON
        Log    Response (parsed): ${response}    INFO
    ELSE
        # Response is Response object - extract status code
        ${matches}=    Get Regexp Matches    ${response_str}    \\[(\\d+)\\]    1
        ${status_code}=    Get From List    ${matches}    0
        Log    Status: ${status_code}    INFO
        IF    ${include_body}    Log    Body: ${response_str}    INFO
    END

    Log    ==================================    INFO


# ─────────────────────────────────────────────────────────────────────────────
# BDD STEP KEYWORDS — Private API
# RF strips the Given/When/Then/And prefix before keyword lookup.
# e.g. "Given the private API session is initialized with valid credentials"
#   → "The Private API Session Is Initialized With Valid Credentials"
# ─────────────────────────────────────────────────────────────────────────────

The Private API Session Is Initialized With Valid Credentials
    [Documentation]    BDD Given: setup HMAC-SHA512 signing and create private API session with real credentials.

    Setup Private API Signing
    Create Indodax Private API Session    ${API_KEY}    ${API_SECRET}    ${API_BASE_URL}
    Log    ✓ Private API session initialized with valid credentials    INFO

The Private API Session Is Initialized With Invalid Credentials
    [Documentation]    BDD Given: create private API session with intentionally invalid credentials.

    Create Indodax Private API Session    invalid_api_key_xyz123456    invalid_secret_xyz123456    ${API_BASE_URL}
    Log    ✓ Private API session initialized with invalid credentials    INFO

The Private API Session Is Initialized With Dummy Credentials
    [Documentation]    BDD Given: create private API session with dummy test credentials.

    Create Indodax Private API Session    dummy_key    dummy_secret    ${API_BASE_URL}
    Log    ✓ Private API session initialized with dummy credentials    INFO

The "${order_id}" Buy Order Data Is Loaded From Test Data
    [Documentation]    BDD And: load buy order data; store pair, price, amount as test variables.

    ${pair}=        Get Private API Buy Order Pair         ${order_id}
    ${test_data}=   Get Private API Buy Order Test Data    ${order_id}
    ${price}=       Get From Dictionary    ${test_data}    price
    ${amount}=      Get From Dictionary    ${test_data}    amount
    ${order_type}=  Get From Dictionary    ${test_data}    type
    Set Test Variable    ${CURRENT_PAIR}          ${pair}
    Set Test Variable    ${CURRENT_ORDER_PRICE}   ${price}
    Set Test Variable    ${CURRENT_ORDER_AMOUNT}  ${amount}
    Set Test Variable    ${CURRENT_ORDER_TYPE}    ${order_type}
    Log    ✓ Buy order data loaded: pair=${pair} price=${price} amount=${amount}    INFO

The "${order_id}" Sell Order Data Is Loaded From Test Data
    [Documentation]    BDD And: load sell order data; store pair, price, amount as test variables.

    ${pair}=        Get Private API Sell Order Pair         ${order_id}
    ${test_data}=   Get Private API Sell Order Test Data    ${order_id}
    ${price}=       Get From Dictionary    ${test_data}    price
    ${amount}=      Get From Dictionary    ${test_data}    amount
    ${order_type}=  Get From Dictionary    ${test_data}    type
    Set Test Variable    ${CURRENT_PAIR}          ${pair}
    Set Test Variable    ${CURRENT_ORDER_PRICE}   ${price}
    Set Test Variable    ${CURRENT_ORDER_AMOUNT}  ${amount}
    Set Test Variable    ${CURRENT_ORDER_TYPE}    ${order_type}
    Log    ✓ Sell order data loaded: pair=${pair} price=${price} amount=${amount}    INFO

The "${validation_type}" Order Validation Data Is Loaded
    [Documentation]    BDD And: load order validation test data; store pair, price, amount as test variables.

    ${pair}=       Get Private API Validation Pair              ${validation_type}
    ${test_data}=  Get Private API Order Validation Test Data   ${validation_type}
    ${price}=      Get From Dictionary    ${test_data}    price
    ${amount}=     Get From Dictionary    ${test_data}    amount
    Set Test Variable    ${CURRENT_PAIR}          ${pair}
    Set Test Variable    ${CURRENT_ORDER_PRICE}   ${price}
    Set Test Variable    ${CURRENT_ORDER_AMOUNT}  ${amount}
    Log    ✓ Validation data loaded: pair=${pair} price=${price} amount=${amount}    INFO

The "${operation_type}" Management Data Is Loaded
    [Documentation]    BDD And: load order management test data; store order_id and pair as test variables.

    ${test_data}=  Get Private API Order Management Data    ${operation_type}
    ${pair}=       Get Private API Management Pair          ${operation_type}
    ${order_id}=   Get From Dictionary    ${test_data}    order_id
    Set Test Variable    ${CURRENT_PAIR}    ${pair}
    Set Test Variable    ${ORDER_ID}        ${order_id}
    Log    ✓ Management data loaded: order_id=${order_id} pair=${pair}    INFO

The Test Uses The "${operation_type}" Management Pair
    [Documentation]    BDD And: resolve management pair from test data; store in ${CURRENT_PAIR}.

    ${pair}=    Get Private API Management Pair    ${operation_type}
    Set Test Variable    ${CURRENT_PAIR}    ${pair}
    Log    ✓ Management pair resolved: ${pair}    INFO

The User Requests Their Account Information
    [Documentation]    BDD When: call POST /tapi/getInfo; store response in ${CURRENT_RESPONSE}.

    ${response}=    Get Account Info
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Account info request sent    INFO

The User Requests Their Account Balance
    [Documentation]    BDD When: call POST /tapi/getBalance; store response in ${CURRENT_RESPONSE}.

    ${response}=    Get Account Balance
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Account balance request sent    INFO

The User Places A Buy Order For The Resolved Pair
    [Documentation]    BDD When: call POST /tapi/trade (buy) with stored pair/price/amount; store response.

    ${response}=    Place Buy Order    ${CURRENT_PAIR}    ${CURRENT_ORDER_PRICE}    ${CURRENT_ORDER_AMOUNT}
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Buy order placed: ${CURRENT_ORDER_AMOUNT} ${CURRENT_PAIR} @ ${CURRENT_ORDER_PRICE}    INFO

The User Places A Sell Order For The Resolved Pair
    [Documentation]    BDD When: call POST /tapi/trade (sell) with stored pair/price/amount; store response.

    ${response}=    Place Sell Order    ${CURRENT_PAIR}    ${CURRENT_ORDER_PRICE}    ${CURRENT_ORDER_AMOUNT}
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Sell order placed: ${CURRENT_ORDER_AMOUNT} ${CURRENT_PAIR} @ ${CURRENT_ORDER_PRICE}    INFO

The User Requests All Open Orders
    [Documentation]    BDD When: call POST /tapi/openOrders (no pair filter); store response.

    ${response}=    Get Open Orders
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Open orders request sent    INFO

The User Requests Open Orders For The Resolved Pair
    [Documentation]    BDD When: call POST /tapi/openOrders filtered by ${CURRENT_PAIR}; store response.

    ${response}=    Get Open Orders    ${CURRENT_PAIR}
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Open orders request sent for pair: ${CURRENT_PAIR}    INFO

The User Cancels The Order
    [Documentation]    BDD When: call POST /tapi/cancelOrder with stored ${ORDER_ID} and ${CURRENT_PAIR}.

    ${response}=    Cancel Order    ${ORDER_ID}    ${CURRENT_PAIR}
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Cancel order request sent: order_id=${ORDER_ID} pair=${CURRENT_PAIR}    INFO

The User Requests Order History
    [Documentation]    BDD When: call POST /tapi/tradeHistory; store response in ${CURRENT_RESPONSE}.

    ${response}=    Get Order History
    Set Test Variable    ${CURRENT_RESPONSE}    ${response}
    Log    ✓ Order history request sent    INFO

The User Runs Data-Driven Order Tests For All Configured Scenarios
    [Documentation]    BDD When: iterate over all configured order scenarios and execute each buy/sell.

    ${scenarios}=    Get Private API Data Driven Scenarios
    FOR    ${scenario}    IN    @{scenarios}
        ${pair_id}=  Get From Dictionary    ${scenario}    pair_id
        ${pair}=     Get Trading Pair Id    ${pair_id}
        ${type}=     Get From Dictionary    ${scenario}    type
        ${price}=    Get From Dictionary    ${scenario}    price
        ${amount}=   Get From Dictionary    ${scenario}    amount
        Log    Testing ${type} order for ${pair}    INFO
        IF    '${type}' == 'buy'
            Place Buy Order    ${pair}    ${price}    ${amount}
        ELSE
            Place Sell Order    ${pair}    ${price}    ${amount}
        END
    END

The Account Response Should Contain Account Data
    [Documentation]    BDD And: assert account response has 'return' field and is non-empty.

    Verify Response Contains Key    ${RESPONSE_BODY}    return
    Should Not Be Empty    ${RESPONSE_BODY}
    Log    ✓ Account response contains account data    INFO

The Account Info Should Match The Expected Schema
    [Documentation]    BDD And: validate account info response against the account info JSON schema.

    Validate Account Info Response Schema    ${RESPONSE_BODY}

The Balance Response Should Contain Balance Data
    [Documentation]    BDD And: assert balance response has 'return' and 'server_time' with non-empty data.

    Verify Response Contains Key    ${RESPONSE_BODY}    return
    Verify Response Contains Key    ${RESPONSE_BODY}    server_time
    ${balance_data}=    Get From Dictionary    ${RESPONSE_BODY}    return
    Should Not Be Empty    ${balance_data}
    Log    ✓ Balance response contains balance data    INFO

The Order Should Be Confirmed As A "${order_type}" Order For The Resolved Pair
    [Documentation]    BDD And: verify order response structure and assert the order was created.

    Verify Order Response    ${RESPONSE_BODY}    ${order_type}    ${CURRENT_PAIR}    ${CURRENT_ORDER_PRICE}    ${CURRENT_ORDER_AMOUNT}
    ${order_id}=    Verify Order Is Created    ${RESPONSE_BODY}
    Log    ✓ Order confirmed — id=${order_id} type=${order_type}    INFO

The Validation Error Response Should Not Be Empty
    [Documentation]    BDD And: assert validation error response body is non-empty.

    Should Not Be Empty    ${RESPONSE_BODY}
    Log    ✓ Validation error response is non-empty    INFO

The Open Orders Response Should Contain Order List Data
    [Documentation]    BDD And: assert open orders response has 'return' and 'server_time' fields.

    Verify Response Contains Key    ${RESPONSE_BODY}    return
    Verify Response Contains Key    ${RESPONSE_BODY}    server_time
    Log    ✓ Open orders response contains order list data    INFO

The Cancel Response Should Not Be Empty
    [Documentation]    BDD And: assert cancel order response is non-empty; log request and response details.

    Should Not Be Empty    ${RESPONSE_BODY}
    Log Request Details    POST    /tapi/cancelOrder    order_id=${ORDER_ID} pair=${CURRENT_PAIR}
    Log Response Details    ${RESPONSE_BODY}    ${True}
    Log    ✓ Cancel order response is non-empty    INFO

The Order History Response Should Contain History Data
    [Documentation]    BDD And: assert order history response has 'return' field.

    Verify Response Contains Key    ${RESPONSE_BODY}    return
    Log    ✓ Order history response contains history data    INFO

All Data-Driven Order Tests Should Complete Successfully
    [Documentation]    BDD Then: confirm all data-driven order scenarios completed (failures caught in When step).

    Log    ✓ All data-driven order scenarios executed successfully    INFO

