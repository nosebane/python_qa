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
