*** Settings ***
Documentation    Shared API Test Settings and Configuration
...             Common libraries, resources, and setup/teardown for all API tests

Library    Collections
Library    String
Library    OperatingSystem
Library    RequestsLibrary
Library    ../../../libraries/api/IndodaxSignerLibrary.py
Library    ../../../libraries/api/ApiSchemaValidator.py
Library    ../../../libraries/api/ResponseValidator.py
Library    ${CURDIR}/../../../libraries/base/config_manager.py    WITH NAME    ConfigManager

Resource    ./base_keywords.robot
Resource    ./indodax_public_api.robot
Resource    ./indodax_private_api.robot
Resource    ./test_data_loader.robot


*** Keywords ***

Initialize API Test Environment
    [Documentation]    Setup for public API tests using hybrid .env + YAML approach
    ...
    ...    Loads:
    ...    - YAML env config → API_TIMEOUT, API_MAX_RETRIES, API_RETRY_DELAY, API_VERIFY_SSL, API_CONNECT_TIMEOUT
    ...    - API_BASE_URL from .env.${TEST_ENV}
    ...    - Centralized test data from resources/test_data/api/{base,indodax_public_api}.json
    ...    - Response schemas from resources/test_data/api/schemas/

    # Load YAML environment config — extract and apply non-secret timeout/retry policy
    ${yaml_config}=     Get Environment Config    ${TEST_ENV}
    ${api_cfg}=         Get From Dictionary    ${yaml_config}    api
    ${timeout_cfg}=     Get From Dictionary    ${yaml_config}    timeouts
    ${api_timeout}=     Get From Dictionary    ${api_cfg}        timeout
    ${api_timeout}=     Convert To Number      ${api_timeout}
    ${max_retries}=     Get From Dictionary    ${api_cfg}        max_retries
    ${retry_delay}=     Get From Dictionary    ${api_cfg}        retry_delay
    ${verify_ssl}=      Get From Dictionary    ${api_cfg}        verify_ssl
    ${connect_timeout}=    Get From Dictionary    ${timeout_cfg}    connect_timeout
    Set Suite Variable    ${API_TIMEOUT}          ${api_timeout}
    Set Suite Variable    ${API_MAX_RETRIES}      ${max_retries}
    Set Suite Variable    ${API_RETRY_DELAY}      ${retry_delay}
    Set Suite Variable    ${API_VERIFY_SSL}       ${verify_ssl}
    Set Suite Variable    ${API_CONNECT_TIMEOUT}  ${connect_timeout}
    Log    ✓ YAML config — timeout=${api_timeout}s | retries=${max_retries} | delay=${retry_delay}s | ssl=${verify_ssl}    INFO
    # Load centralized test data
    Load Test Data
    
    # Load response schemas for validation
    Load Response Schemas
    
    # Determine environment (default: dev)
    # TEST_ENV can be set via: robot --variable TEST_ENV:prod
    ${env_name}=    Set Variable    ${TEST_ENV}
    Set Suite Variable    ${TEST_ENV}    ${env_name}
    
    # Read API_BASE_URL from .env file — anchored regex prevents matching commented lines
    ${env_file}=    Get File    ${CURDIR}/../../../.env.${env_name}
    ${api_url_list}=    Get Regexp Matches    ${env_file}    (?m)^API_BASE_URL=([^\n\r]+)    1
    ${api_base_url}=    Get From List    ${api_url_list}    0
    ${api_base_url}=    Strip String    ${api_base_url}
    Set Suite Variable    ${API_BASE_URL}    ${api_base_url}
    
    Log    Environment: ${TEST_ENV}    INFO
    Log    Base URL: ${API_BASE_URL}    INFO
    Log    Config loaded from: .env.${TEST_ENV}    INFO


Cleanup API Test Environment
    [Documentation]    Cleanup after tests
    
    Log    Cleaning up test environment    INFO
    Close API Session


Initialize Private API Test Environment
    [Documentation]    Setup for private API tests using .env configuration
    ...
    ...    Loads credentials and endpoint from .env.${TEST_ENV}:
    ...    - PRIVATE_API_BASE_URL
    ...    - INDODAX_API_KEY
    ...    - INDODAX_API_SECRET
    ...    - Centralized test data from resources/test_data/api/{base,indodax_private_api}.json
    ...    - Response schemas from resources/test_data/api/schemas/
    ...
    ...    Usage: robot --variable TEST_ENV:production tests/api/02_indodax_private_api.robot
    
    Log    ==========================================    INFO
    Log    Initializing Private API Test Environment    INFO
    Log    ==========================================    INFO

    # Load YAML environment config — extract and apply non-secret timeout/retry policy
    ${yaml_config}=     Get Environment Config    ${TEST_ENV}
    ${api_cfg}=         Get From Dictionary    ${yaml_config}    api
    ${timeout_cfg}=     Get From Dictionary    ${yaml_config}    timeouts
    ${api_timeout}=     Get From Dictionary    ${api_cfg}        timeout
    ${api_timeout}=     Convert To Number      ${api_timeout}
    ${max_retries}=     Get From Dictionary    ${api_cfg}        max_retries
    ${retry_delay}=     Get From Dictionary    ${api_cfg}        retry_delay
    ${verify_ssl}=      Get From Dictionary    ${api_cfg}        verify_ssl
    ${connect_timeout}=    Get From Dictionary    ${timeout_cfg}    connect_timeout
    Set Suite Variable    ${API_TIMEOUT}          ${api_timeout}
    Set Suite Variable    ${API_MAX_RETRIES}      ${max_retries}
    Set Suite Variable    ${API_RETRY_DELAY}      ${retry_delay}
    Set Suite Variable    ${API_VERIFY_SSL}       ${verify_ssl}
    Set Suite Variable    ${API_CONNECT_TIMEOUT}  ${connect_timeout}
    Log    ✓ YAML config — timeout=${api_timeout}s | retries=${max_retries} | delay=${retry_delay}s | ssl=${verify_ssl}    INFO

    # Load centralized test data
    Load Test Data
    
    # Load response schemas for validation
    Load Response Schemas
    
    # Determine environment
    ${env_name}=    Set Variable    ${TEST_ENV}
    Set Suite Variable    ${TEST_ENV}    ${env_name}
    
    # Read configuration from .env file
    ${env_file}=    Get File    ${CURDIR}/../../../.env.${env_name}
    
    # Extract PRIVATE_API_BASE_URL — anchored regex + strip whitespace
    ${private_url_list}=    Get Regexp Matches    ${env_file}    (?m)^PRIVATE_API_BASE_URL=([^\n\r]+)    1
    ${private_api_url}=    Set Variable If    len(${private_url_list}) > 0    ${private_url_list}[0]    https://indodax.com/tapi
    ${private_api_url}=    Strip String    ${private_api_url}
    Set Suite Variable    ${API_BASE_URL}    ${private_api_url}

    # Extract INDODAX_API_KEY — anchored regex + strip whitespace
    ${api_key_list}=    Get Regexp Matches    ${env_file}    (?m)^INDODAX_API_KEY=([^\n\r]*)    1
    ${api_key}=    Set Variable If    len(${api_key_list}) > 0    ${api_key_list}[0]    ${EMPTY}
    ${api_key}=    Strip String    ${api_key}

    # Extract INDODAX_API_SECRET — anchored regex + strip whitespace
    ${api_secret_list}=    Get Regexp Matches    ${env_file}    (?m)^INDODAX_API_SECRET=([^\n\r]*)    1
    ${api_secret}=    Set Variable If    len(${api_secret_list}) > 0    ${api_secret_list}[0]    ${EMPTY}
    ${api_secret}=    Strip String    ${api_secret}
    
    Set Suite Variable    ${API_KEY}    ${api_key}
    Set Suite Variable    ${API_SECRET}    ${api_secret}
    
    # Check if credentials are provided
    ${has_credentials}=    Run Keyword And Return Status
    ...    Should Not Be Empty    ${api_key}
    
    Log    Environment: ${TEST_ENV}    INFO
    Log    Base URL: ${API_BASE_URL}    INFO
    Log    Config loaded from: .env.${TEST_ENV}    INFO
    
    IF    ${has_credentials}
        Log    [OK] Private API Credentials found    INFO
    ELSE
        Log    [WARNING] Private API Credentials NOT found (tests will be skipped)    WARN
    END


Cleanup Private API Environment
    [Documentation]    Cleanup after private API tests
    
    Log    Cleaning up private API environment    INFO
    Close API Session
    Log    ✓ Cleanup completed    INFO



