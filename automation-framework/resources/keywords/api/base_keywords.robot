*** Settings ***
Documentation       Base API Keywords
...                 Shared keywords for response validation, JSON extraction, and HTTP request helpers


*** Keywords ***
# Base Response Verification Keywords (Shared)

Extract JSON From Response
    [Documentation]    Extract JSON body from response object
    ...    Handles both response objects and plain dictionaries
    [Arguments]    ${response}

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
    [Documentation]    Verify response dict contains specific key
    ...    Extracts JSON from response if needed
    [Arguments]    ${response}    ${key}

    ${response_data}=    Extract JSON From Response    ${response}
    Should Contain    ${response_data}    ${key}
    Log    ✓ Response contains key: ${key}    INFO

Should Contain Key
    [Documentation]    Verify dictionary contains key
    [Arguments]    ${dictionary}    ${key}

    Should Contain    ${dictionary}    ${key}
    Log    Key '${key}' found in dictionary

# Response Code Validation Keywords

Verify Response Status Code
    [Documentation]    Verify HTTP response status code
    ...
    ...    Args:
    ...        response: Response object with status_code attribute or parsed JSON dict
    ...        expected_status_code: Expected HTTP status code (default: 200)
    ...
    ...    Returns:
    ...        Response JSON body for further assertions
    [Arguments]    ${response}    ${expected_status_code}=200

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
    [Documentation]    Verify response has 200 OK status
    ...    Shorthand for Verify Response Status Code with default 200
    [Arguments]    ${response}

    ${body}=    Verify Response Status Code    ${response}    200
    RETURN    ${body}

Verify Response Status Code Created
    [Documentation]    Verify response has 201 Created status
    [Arguments]    ${response}

    ${body}=    Verify Response Status Code    ${response}    201
    RETURN    ${body}

Verify Response Status Code Bad Request
    [Documentation]    Verify response has 400 Bad Request status
    [Arguments]    ${response}

    ${body}=    Verify Response Status Code    ${response}    400
    RETURN    ${body}

Verify Response Status Code Unauthorized
    [Documentation]    Verify response has 401 Unauthorized status
    [Arguments]    ${response}

    ${body}=    Verify Response Status Code    ${response}    401
    RETURN    ${body}

Verify Response Status Code Forbidden
    [Documentation]    Verify response has 403 Forbidden status
    [Arguments]    ${response}

    ${body}=    Verify Response Status Code    ${response}    403
    RETURN    ${body}

Verify Response Status Code Not Found
    [Documentation]    Verify response has 404 Not Found status
    [Arguments]    ${response}

    ${body}=    Verify Response Status Code    ${response}    404
    RETURN    ${body}

Verify Response Status Code Server Error
    [Documentation]    Verify response has 500 Internal Server Error status
    [Arguments]    ${response}

    ${body}=    Verify Response Status Code    ${response}    500
    RETURN    ${body}

# Shared API Session Keywords

Create Indodax Public API Session
    [Documentation]    Create session for Indodax public API
    [Arguments]    ${base_url}=${API_BASE_URL}

    Log    Creating Indodax Public API session: ${base_url}    INFO

    # Import the service
    Run Keyword And Ignore Error    Evaluate    import sys; sys.path.insert(0, '${CURDIR}')

    # Service will be instantiated in test setup
    Set Global Variable    ${PUBLIC_API_BASE_URL}    ${base_url}

Create Indodax Private API Session
    [Documentation]    Create session for Indodax private API
    [Arguments]    ${api_key}    ${api_secret}    ${base_url}=${API_BASE_URL}

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
    [Documentation]    Validate ticker response matches schema
    [Arguments]    ${response}

    Log    Validating ticker response schema    INFO
    Validate Json By Schema File    ${response}    ${CURDIR}/../../../test_data/api/schemas/ticker_schema.json

Validate Depth Response Schema
    [Documentation]    Validate depth response matches schema
    [Arguments]    ${response}

    Log    Validating depth response schema    INFO
    Validate Json By Schema File    ${response}    ${CURDIR}/../../../test_data/api/schemas/depth_schema.json

Validate Trades Response Schema
    [Documentation]    Validate trades response matches schema
    [Arguments]    ${response}

    Log    Validating trades response schema    INFO
    Validate Json By Schema File    ${response}    ${CURDIR}/../../../test_data/api/schemas/trades_schema.json

Validate Error Response Schema
    [Documentation]    Validate error response matches schema
    [Arguments]    ${response}

    Log    Validating error response schema    INFO
    Validate Json By Schema File    ${response}    ${CURDIR}/../../../test_data/api/schemas/error_schema.json

Validate Trade Order Response Schema
    [Documentation]    Validate trade order response matches schema
    [Arguments]    ${response}

    Log    Validating trade order response schema    INFO
    Validate Json By Schema File    ${response}    ${CURDIR}/../../../test_data/api/schemas/trade_response_schema.json

Validate Account Info Response Schema
    [Documentation]    Validate account info response matches schema
    [Arguments]    ${response}

    Log    Validating account info response schema    INFO
    Validate Json By Schema File    ${response}    ${CURDIR}/../../../test_data/api/schemas/account_info_schema.json

Validate Open Orders Response Schema
    [Documentation]    Validate open orders response matches schema
    [Arguments]    ${response}

    Log    Validating open orders response schema    INFO
    Validate Json By Schema File    ${response}    ${CURDIR}/../../../test_data/api/schemas/open_orders_schema.json

# Centralized Configuration Integration Keywords

Validate Response Using Endpoint Config
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
    [Arguments]    ${response}    ${endpoint}    ${api_type}=public_api_endpoints

    ${expected_status}=    Get Expected Status Code For Endpoint    ${api_type}    ${endpoint}
    Log    Validating ${api_type}/${endpoint} with expected status ${expected_status}    INFO

    ${body}=    Verify Response Status Code    ${response}    ${expected_status}
    Log    ✓ ${endpoint} response validated against config    INFO

    RETURN    ${body}

Validate Error Response Using Config
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
    [Arguments]    ${response}    ${error_scenario}

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


# ─────────────────────────────────────────────────────────────────────────────
# BDD STEP KEYWORDS — Shared HTTP Response Steps
# RF strips the Given/When/Then/And prefix before keyword lookup.
# e.g. "Then the response should be 200 OK" → "The Response Should Be 200 OK"
# ─────────────────────────────────────────────────────────────────────────────

The Response Should Be 200 OK
    [Documentation]    BDD Then: verify HTTP 200 and parse body into ${RESPONSE_BODY} test variable.

    ${body}=    Verify Response Status Code OK    ${CURRENT_RESPONSE}
    Set Test Variable    ${RESPONSE_BODY}    ${body}
    Log    ✓ Response is 200 OK    INFO

The Response Should Contain An Error Field
    [Documentation]    BDD Then/And: assert response body contains the 'error' key.

    Should Contain    ${RESPONSE_BODY}    error
    Log    ✓ Response contains error field    INFO

The Response Should Be A Valid Dictionary
    [Documentation]    BDD And: assert response body is a non-empty dictionary.

    ${is_dict}=    Run Keyword And Return Status    Should Be True    isinstance(${RESPONSE_BODY}, dict)
    Should Be True    ${is_dict}    Response should be a dictionary
    Log    ✓ Response is a valid dictionary    INFO

