*** Keywords ***
# Base Response Verification Keywords (Shared)

Extract JSON From Response
    [Arguments]    ${response}
    [Documentation]    Extract JSON body from response object
    ...    Handles both response objects and plain dictionaries
    
    # Check if it's a response object or already a dict
    ${response_type}=    Evaluate    type(${response}).__name__
    Log    Response type: ${response_type}    DEBUG
    
    IF    '${response_type}' == 'dict'
        # Already a dictionary, return as-is
        RETURN    ${response}
    ELSE
        # Response object, extract JSON
        ${json_body}=    Evaluate    ${response}.json()
        RETURN    ${json_body}
    END


Verify Response Contains Key
    [Arguments]    ${response}    ${key}
    [Documentation]    Verify response dict contains specific key
    ...    Extracts JSON from response if needed
    
    ${response_data}=    Extract JSON From Response    ${response}
    Should Contain    ${response_data}    ${key}
    Log    ✓ Response contains key: ${key}    INFO


Should Contain Key
    [Arguments]    ${dictionary}    ${key}
    [Documentation]    Verify dictionary contains key
    
    Should Contain    ${dictionary}    ${key}
    Log    Key '${key}' found in dictionary


# Response Code Validation Keywords

Verify Response Status Code
    [Arguments]    ${response}    ${expected_status_code}=200
    [Documentation]    Verify HTTP response status code
    ...    
    ...    Args:
    ...        response: Response object with status_code attribute or parsed JSON dict
    ...        expected_status_code: Expected HTTP status code (default: 200)
    ...    
    ...    Returns:
    ...        Response JSON body for further assertions
    
    # Check if response is a dict by checking the string representation
    ${response_str}=    Convert To String    ${response}
    ${is_dict}=    Run Keyword And Return Status    Should Start With    ${response_str}    {
    
    IF    ${is_dict}
        # Already parsed to dict - return as-is
        Log    Response is already parsed (dict). Assuming HTTP 200 OK.    INFO
        RETURN    ${response}
    ELSE
        # Response object - extract status code and JSON
        # The response_str looks like "<Response [200]>" so extract the code
        ${matches}=    Get Regexp Matches    ${response_str}    \\[(\\d+)\\]    1
        ${status_code}=    Get From List    ${matches}    0
        
        Log    HTTP Status Code: ${status_code}    INFO
        Should Be Equal As Integers    ${status_code}    ${expected_status_code}    
        ...    Expected status code ${expected_status_code} but got ${status_code}
        Log    ✓ HTTP Status Code ${status_code} is valid    INFO
        
        # Extract JSON using Call Method
        ${json_body}=    Call Method    ${response}    json
        RETURN    ${json_body}
    END


Verify Response Status Code OK
    [Arguments]    ${response}
    [Documentation]    Verify response has 200 OK status
    ...    Shorthand for Verify Response Status Code with default 200
    
    ${body}=    Verify Response Status Code    ${response}    200
    RETURN    ${body}


Verify Response Status Code Created
    [Arguments]    ${response}
    [Documentation]    Verify response has 201 Created status
    
    ${body}=    Verify Response Status Code    ${response}    201
    RETURN    ${body}


Verify Response Status Code Bad Request
    [Arguments]    ${response}
    [Documentation]    Verify response has 400 Bad Request status
    
    ${body}=    Verify Response Status Code    ${response}    400
    RETURN    ${body}


Verify Response Status Code Unauthorized
    [Arguments]    ${response}
    [Documentation]    Verify response has 401 Unauthorized status
    
    ${body}=    Verify Response Status Code    ${response}    401
    RETURN    ${body}


Verify Response Status Code Forbidden
    [Arguments]    ${response}
    [Documentation]    Verify response has 403 Forbidden status
    
    ${body}=    Verify Response Status Code    ${response}    403
    RETURN    ${body}


Verify Response Status Code Not Found
    [Arguments]    ${response}
    [Documentation]    Verify response has 404 Not Found status
    
    ${body}=    Verify Response Status Code    ${response}    404
    RETURN    ${body}


Verify Response Status Code Server Error
    [Arguments]    ${response}
    [Documentation]    Verify response has 500 Internal Server Error status
    
    ${body}=    Verify Response Status Code    ${response}    500
    RETURN    ${body}


# Shared API Session Keywords

Create Indodax Public API Session
    [Arguments]    ${base_url}=${API_BASE_URL}
    [Documentation]    Create session for Indodax public API
    
    Log    Creating Indodax Public API session: ${base_url}    INFO
    
    # Import the service
    Run Keyword And Ignore Error    Evaluate    import sys; sys.path.insert(0, '${CURDIR}')
    
    # Service will be instantiated in test setup
    Set Global Variable    ${PUBLIC_API_BASE_URL}    ${base_url}


Create Indodax Private API Session
    [Arguments]    ${api_key}    ${api_secret}    ${base_url}=${API_BASE_URL}
    [Documentation]    Create session for Indodax private API
    
    Log    Creating Indodax Private API session with authentication    INFO
    
    Set Global Variable    ${PRIVATE_API_KEY}    ${api_key}
    Set Global Variable    ${PRIVATE_API_SECRET}    ${api_secret}
    Set Global Variable    ${PRIVATE_API_BASE_URL}    ${base_url}


Close API Session
    [Documentation]    Close API session and cleanup
    
    Log    Closing API session    INFO
    # Session cleanup handled by service context manager


# Schema Validation Keywords (Shared)

Validate Ticker Response Schema
    [Arguments]    ${response}
    [Documentation]    Validate ticker response matches schema
    ...    Checks response structure, required fields, and field types
    
    Log    Validating ticker response schema    INFO
    ${ticker_schema}=    Get Stored Schema    ticker
    Validate Response Against Schema    ${response}    ${ticker_schema}


Validate Depth Response Schema
    [Arguments]    ${response}
    [Documentation]    Validate depth response matches schema
    ...    Checks buy/sell arrays, price/amount pairs
    
    Log    Validating depth response schema    INFO
    ${depth_schema}=    Get Stored Schema    depth
    Validate Response Against Schema    ${response}    ${depth_schema}


Validate Trades Response Schema
    [Arguments]    ${response}
    [Documentation]    Validate trades response matches schema
    ...    Checks trade array, required fields, and field types
    
    Log    Validating trades response schema    INFO
    ${trades_schema}=    Get Stored Schema    trades
    Validate Response Against Schema    ${response}    ${trades_schema}


Validate Error Response Schema
    [Arguments]    ${response}
    [Documentation]    Validate error response matches schema
    ...    Checks error field is present
    
    Log    Validating error response schema    INFO
    ${error_schema}=    Get Stored Schema    error
    Validate Response Against Schema    ${response}    ${error_schema}


Validate Trade Order Response Schema
    [Arguments]    ${response}
    [Documentation]    Validate trade order response matches schema
    ...    Checks return object with order_id, type, pair, price, amount
    
    Log    Validating trade order response schema    INFO
    ${trade_schema}=    Get Stored Schema    trade_response
    Validate Response Against Schema    ${response}    ${trade_schema}


Validate Account Info Response Schema
    [Arguments]    ${response}
    [Documentation]    Validate account info response matches schema
    ...    Checks return object with balance, balance_hold
    
    Log    Validating account info response schema    INFO
    ${account_schema}=    Get Stored Schema    account_info
    Validate Response Against Schema    ${response}    ${account_schema}


Validate Open Orders Response Schema
    [Arguments]    ${response}
    [Documentation]    Validate open orders response matches schema
    ...    Checks return object with order details
    
    Log    Validating open orders response schema    INFO
    ${open_orders_schema}=    Get Stored Schema    open_orders
    Validate Response Against Schema    ${response}    ${open_orders_schema}

# Centralized Configuration Integration Keywords

Validate Response Using Endpoint Config
    [Arguments]    ${response}    ${endpoint}    ${api_type}=public_api_endpoints
    [Documentation]    Validate response against endpoint configuration from base.json
    ...    
    ...    Uses centralized response_validation configuration to determine
    ...    expected HTTP status code and validate the response.
    ...    
    ...    Args:
    ...        response: Response object or parsed JSON dict
    ...        endpoint: Endpoint name (e.g., 'ticker', 'trade', 'getInfo')
    ...        api_type: 'public_api_endpoints' (default) or 'private_api_endpoints'
    ...    
    ...    Returns:
    ...        Response JSON body (validated)
    ...    
    ...    Example:
    ...        ${response}=    Send GET Request    ...
    ...        ${body}=    Validate Response Using Endpoint Config    ${response}    ticker
    
    ${expected_status}=    Get Expected Status Code For Endpoint    ${api_type}    ${endpoint}
    Log    Validating ${api_type}/${endpoint} with expected status ${expected_status}    INFO
    
    ${body}=    Verify Response Status Code    ${response}    ${expected_status}
    Log    ✓ ${endpoint} response validated against config    INFO
    
    RETURN    ${body}


Validate Error Response Using Config
    [Arguments]    ${response}    ${error_scenario}
    [Documentation]    Validate error response against error scenario configuration
    ...    
    ...    Uses centralized error_scenarios configuration to validate
    ...    error responses for specific failure scenarios.
    ...    
    ...    Args:
    ...        response: Response object or parsed JSON dict
    ...        error_scenario: Scenario name (e.g., 'invalid_pair', 'unauthorized')
    ...    
    ...    Returns:
    ...        Response JSON body (validated)
    
    ${config}=    Get Error Scenario Config    ${error_scenario}
    ${expected_status}=    Get From Dictionary    ${config}    expected_status
    ${contains_error}=    Get From Dictionary    ${config}    contains_error
    
    # Validate HTTP status
    ${body}=    Verify Response Status Code    ${response}    ${expected_status}
    Log    ✓ Error scenario '${error_scenario}' - HTTP ${expected_status} validated    INFO
    
    # Validate error presence if required
    IF    ${contains_error}
        Should Contain    ${body}    error
        Log    ✓ Response contains expected error field    INFO
    END
    
    RETURN    ${body}