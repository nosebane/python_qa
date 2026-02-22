*** Settings ***
Documentation    Shared Mobile Test Settings and Configuration
...             Common libraries, resources, and setup/teardown for all mobile tests
...             Appium + Robot Framework integration
...             NOTE: Requires AppiumLibrary: pip install robotframework-appiumlibrary
...
...             Config strategy:
...             - .env.mobile.${TEST_ENV}                   → device secrets (APPIUM_SERVER, ANDROID_DEVICE_NAME, etc.)
...             - mobile_${TEST_ENV}.yaml                   → non-secret config (timeouts, capabilities)

Library    AppiumLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    Process
Library    ${CURDIR}/../../../libraries/base/config_manager.py    WITH NAME    ConfigManager


*** Keywords ***

Load Mobile Environment Variables
    [Documentation]    Load mobile test environment variables.
    ...
    ...    Two-layer config strategy:
    ...    1. .env.mobile.${TEST_ENV}        — device secrets read via Get File + Regexp
    ...    2. mobile_${TEST_ENV}.yaml        — non-secret config loaded via ConfigManager
    ...
    ...    Suite variables set:
    ...    Secrets: APPIUM_SERVER, ANDROID_DEVICE_NAME, ANDROID_PLATFORM_VERSION,
    ...             ANDROID_APP_PACKAGE, ANDROID_APP_ACTIVITY, ANDROID_AUTOMATION_NAME,
    ...             AUTO_GRANT_PERMISSIONS, RESET_KEYBOARD, NO_RESET, DISABLE_WINDOW_ANIMATION
    ...    YAML:    MOBILE_NEW_CMD_TIMEOUT, MOBILE_APP_WAIT_TIMEOUT,
    ...             MOBILE_IMPLICIT_WAIT, MOBILE_EXPLICIT_WAIT

    ${env_name}=    Set Variable If    '${TEST_ENV}' != ''    ${TEST_ENV}    production
    ${env_file}=    Set Variable    ${CURDIR}/../../../.env.mobile.${env_name}

    # --- Load device secrets from .env.mobile.${TEST_ENV} ---
    ${appium_content}=    Get File    ${env_file}

    # Read Appium server
    ${appium_match}=    Get Regexp Matches    ${appium_content}    APPIUM_SERVER=([^\n]+)    1
    ${appium_server}=    Get From List    ${appium_match}    0
    Set Suite Variable    ${APPIUM_SERVER}    ${appium_server}

    # Read Android device configuration
    ${device_match}=    Get Regexp Matches    ${appium_content}    ANDROID_DEVICE_NAME=([^\n]+)    1
    ${device_name}=    Get From List    ${device_match}    0
    Set Suite Variable    ${ANDROID_DEVICE_NAME}    ${device_name}

    ${platform_match}=    Get Regexp Matches    ${appium_content}    ANDROID_PLATFORM_VERSION=([^\n]+)    1
    ${platform_version}=    Get From List    ${platform_match}    0
    Set Suite Variable    ${ANDROID_PLATFORM_VERSION}    ${platform_version}

    # Read Android app configuration
    ${package_match}=    Get Regexp Matches    ${appium_content}    ANDROID_APP_PACKAGE=([^\n]+)    1
    ${app_package}=    Get From List    ${package_match}    0
    Set Suite Variable    ${ANDROID_APP_PACKAGE}    ${app_package}

    ${activity_match}=    Get Regexp Matches    ${appium_content}    ANDROID_APP_ACTIVITY=([^\n]+)    1
    ${app_activity}=    Get From List    ${activity_match}    0
    Set Suite Variable    ${ANDROID_APP_ACTIVITY}    ${app_activity}

    # Read Appium capabilities
    ${automation_match}=    Get Regexp Matches    ${appium_content}    ANDROID_AUTOMATION_NAME=([^\n]+)    1
    ${automation_name}=    Get From List    ${automation_match}    0
    Set Suite Variable    ${ANDROID_AUTOMATION_NAME}    ${automation_name}

    ${grant_match}=    Get Regexp Matches    ${appium_content}    AUTO_GRANT_PERMISSIONS=([^\n]+)    1
    ${grant_str}=    Get From List    ${grant_match}    0
    ${grant_permissions}=    Set Variable If    '${grant_str.lower()}' == 'true'    ${TRUE}    ${FALSE}
    Set Suite Variable    ${AUTO_GRANT_PERMISSIONS}    ${grant_permissions}

    ${keyboard_match}=    Get Regexp Matches    ${appium_content}    RESET_KEYBOARD=([^\n]+)    1
    ${keyboard_str}=    Run Keyword If    ${keyboard_match}    Get From List    ${keyboard_match}    0    ELSE    Set Variable    false
    ${reset_keyboard}=    Set Variable If    '${keyboard_str.lower()}' == 'true'    ${TRUE}    ${FALSE}
    Set Suite Variable    ${RESET_KEYBOARD}    ${reset_keyboard}

    ${noreset_match}=    Get Regexp Matches    ${appium_content}    NO_RESET=([^\n]+)    1
    ${noreset_str}=    Run Keyword If    ${noreset_match}    Get From List    ${noreset_match}    0    ELSE    Set Variable    false
    ${no_reset}=    Set Variable If    '${noreset_str.lower()}' == 'true'    ${TRUE}    ${FALSE}
    Set Suite Variable    ${NO_RESET}    ${no_reset}

    ${animation_match}=    Get Regexp Matches    ${appium_content}    DISABLE_WINDOW_ANIMATION=([^\n]+)    1
    ${animation_str}=    Run Keyword If    ${animation_match}    Get From List    ${animation_match}    0    ELSE    Set Variable    false
    ${disable_animation}=    Set Variable If    '${animation_str.lower()}' == 'true'    ${TRUE}    ${FALSE}
    Set Suite Variable    ${DISABLE_WINDOW_ANIMATION}    ${disable_animation}

    # --- Load non-secret config from mobile_${TEST_ENV}.yaml ---
    ${yaml_config}=    Get Environment Config    mobile_${env_name}
    ${appium_cfg}=     Get From Dictionary    ${yaml_config}    appium
    ${timeout_cfg}=    Get From Dictionary    ${yaml_config}    timeouts
    ${new_cmd_timeout}=     Get From Dictionary    ${appium_cfg}    new_command_timeout
    ${app_wait_timeout}=    Get From Dictionary    ${timeout_cfg}    app_wait_timeout
    ${implicit_wait}=       Get From Dictionary    ${timeout_cfg}    implicit_wait
    ${explicit_wait}=       Get From Dictionary    ${timeout_cfg}    explicit_wait
    Set Suite Variable    ${MOBILE_NEW_CMD_TIMEOUT}    ${new_cmd_timeout}
    Set Suite Variable    ${MOBILE_APP_WAIT_TIMEOUT}    ${app_wait_timeout}
    Set Suite Variable    ${MOBILE_IMPLICIT_WAIT}    ${implicit_wait}
    Set Suite Variable    ${MOBILE_EXPLICIT_WAIT}    ${explicit_wait}
    
    Log    ✓ Mobile environment variables loaded    INFO
    Log    Environment: ${env_name}    INFO
    Log    Appium Server: ${APPIUM_SERVER}    INFO
    Log    Device: ${ANDROID_DEVICE_NAME} (${ANDROID_PLATFORM_VERSION})    INFO
    Log    App: ${ANDROID_APP_PACKAGE}/${ANDROID_APP_ACTIVITY}    INFO
    Log    Capabilities: noReset=${NO_RESET}, autoGrant=${AUTO_GRANT_PERMISSIONS}, disableAnimation=${DISABLE_WINDOW_ANIMATION}    INFO
    Log    YAML timeouts: newCmd=${MOBILE_NEW_CMD_TIMEOUT}s, appWait=${MOBILE_APP_WAIT_TIMEOUT}ms, implicit=${MOBILE_IMPLICIT_WAIT}s, explicit=${MOBILE_EXPLICIT_WAIT}s    INFO


Initialize Test Environment
    [Documentation]    Initialize test environment based on TEST_ENV variable
    ...    Loads environment configuration and setup mobile test prerequisites
    ...    
    ...    Supports environments:
    ...    - dev: Development environment
    ...    - staging: Staging environment
    ...    - production: Production environment (default)
    ...    
    ...    Usage:
    ...    Suite Setup    Initialize Test Environment
    ...    Or with variable override:
    ...    robot -v TEST_ENV:staging tests/mobile/search_and_validate_eth.robot
    
    # Set TEST_ENV if passed, otherwise use default from test file
    Log    Initializing test environment: ${TEST_ENV}    INFO
    
    # Load environment variables from .env file
    Load Mobile Environment Variables
    
    Log    ✓ Test environment initialized for: ${TEST_ENV}    INFO


Open Indodax App
    [Documentation]    Launch Indodax app on connected Android device using environment variables
    ...    Requires Load Mobile Environment Variables to be called first (via Initialize Test Environment)
    ...    Uses: APPIUM_SERVER, ANDROID_PLATFORM_VERSION, ANDROID_AUTOMATION_NAME,
    ...          ANDROID_APP_PACKAGE, ANDROID_APP_ACTIVITY,
    ...          AUTO_GRANT_PERMISSIONS, NO_RESET, DISABLE_WINDOW_ANIMATION
    
    Log    Launching Indodax app on ${ANDROID_APP_PACKAGE}...    INFO
    Open Application    ${APPIUM_SERVER}
    ...    platformName=Android
    ...    deviceName=${ANDROID_DEVICE_NAME}
    ...    platformVersion=${ANDROID_PLATFORM_VERSION}
    ...    automationName=${ANDROID_AUTOMATION_NAME}
    ...    appPackage=${ANDROID_APP_PACKAGE}
    ...    appActivity=${ANDROID_APP_ACTIVITY}
    ...    autoGrantPermissions=${AUTO_GRANT_PERMISSIONS}
    ...    resetKeyboard=${RESET_KEYBOARD}
    ...    noReset=${NO_RESET}
    ...    disableWindowAnimation=${DISABLE_WINDOW_ANIMATION}
    ...    newCommandTimeout=${MOBILE_NEW_CMD_TIMEOUT}
    Log    ✓ Indodax app launched successfully    INFO


Load iOS Environment Variables
    [Documentation]    Load iOS mobile test environment variables from .env.mobile.ios.${TEST_ENV}
    ...    Sets suite variables for Appium server, iOS device, and XCUITest capabilities
    ...    
    ...    Usage:
    ...    robot -v MOBILE_OS:ios tests/mobile/...
    ...    Requires .env.mobile.ios.production (or staging/dev) to exist
    
    ${env_name}=    Set Variable If    '${TEST_ENV}' != ''    ${TEST_ENV}    production
    ${env_file}=    Set Variable    ${CURDIR}/../../../.env.mobile.ios.${env_name}
    ${ios_content}=    Get File    ${env_file}
    
    # Appium Server
    ${match}=    Get Regexp Matches    ${ios_content}    APPIUM_SERVER=([^\n]+)    1
    Set Suite Variable    ${APPIUM_SERVER}    ${match}[0]
    
    # iOS Device
    ${match}=    Get Regexp Matches    ${ios_content}    IOS_DEVICE_NAME=([^\n]+)    1
    Set Suite Variable    ${IOS_DEVICE_NAME}    ${match}[0]
    
    ${match}=    Get Regexp Matches    ${ios_content}    IOS_UDID=([^\n]+)    1
    Set Suite Variable    ${IOS_UDID}    ${match}[0]
    
    ${match}=    Get Regexp Matches    ${ios_content}    IOS_PLATFORM_VERSION=([^\n]+)    1
    Set Suite Variable    ${IOS_PLATFORM_VERSION}    ${match}[0]
    
    ${match}=    Get Regexp Matches    ${ios_content}    IOS_AUTOMATION_NAME=([^\n]+)    1
    Set Suite Variable    ${IOS_AUTOMATION_NAME}    ${match}[0]
    
    # iOS App
    ${match}=    Get Regexp Matches    ${ios_content}    IOS_BUNDLE_ID=([^\n]+)    1
    Set Suite Variable    ${IOS_BUNDLE_ID}    ${match}[0]
    
    # WDA Config
    ${match}=    Get Regexp Matches    ${ios_content}    WDA_BUNDLE_ID=([^\n]+)    1
    Set Suite Variable    ${WDA_BUNDLE_ID}    ${match}[0]
    
    ${match}=    Get Regexp Matches    ${ios_content}    WDA_LAUNCH_TIMEOUT=([^\n]+)    1
    Set Suite Variable    ${WDA_LAUNCH_TIMEOUT}    ${match}[0]
    
    ${match}=    Get Regexp Matches    ${ios_content}    WDA_CONNECTION_TIMEOUT=([^\n]+)    1
    Set Suite Variable    ${WDA_CONNECTION_TIMEOUT}    ${match}[0]
    
    # Capabilities
    ${match}=    Get Regexp Matches    ${ios_content}    IOS_NO_RESET=([^\n]+)    1
    Set Suite Variable    ${IOS_NO_RESET}    ${match}[0]
    
    ${match}=    Get Regexp Matches    ${ios_content}    IOS_AUTO_ACCEPT_ALERTS=([^\n]+)    1
    Set Suite Variable    ${IOS_AUTO_ACCEPT_ALERTS}    ${match}[0]
    
    ${match}=    Get Regexp Matches    ${ios_content}    IOS_NEW_COMMAND_TIMEOUT=([^\n]+)    1
    Set Suite Variable    ${IOS_NEW_COMMAND_TIMEOUT}    ${match}[0]
    
    Log    ✓ iOS environment variables loaded    INFO
    Log    Environment: ${env_name}    INFO
    Log    Appium Server: ${APPIUM_SERVER}    INFO
    Log    Device: ${IOS_DEVICE_NAME} (UDID: ${IOS_UDID}, iOS ${IOS_PLATFORM_VERSION})    INFO
    Log    App Bundle: ${IOS_BUNDLE_ID}    INFO
    Log    Capabilities: noReset=${IOS_NO_RESET}, autoAcceptAlerts=${IOS_AUTO_ACCEPT_ALERTS}    INFO


Initialize iOS Test Environment
    [Documentation]    Initialize test environment for iOS device testing
    ...    Loads iOS environment variables from .env.mobile.ios.${TEST_ENV}
    ...    
    ...    Usage:
    ...    Suite Setup    Initialize iOS Test Environment
    
    Log    Initializing iOS test environment: ${TEST_ENV}    INFO
    Load iOS Environment Variables
    Log    ✓ iOS test environment initialized for: ${TEST_ENV}    INFO


Open Indodax iOS App
    [Documentation]    Launch Indodax app on connected iOS device using environment variables
    ...    Requires Load iOS Environment Variables to be called first (via Initialize iOS Test Environment)
    ...    Uses XCUITest driver — install via: appium driver install xcuitest
    ...    
    ...    Capabilities used:
    ...    - platformName=iOS
    ...    - deviceName, udid, platformVersion
    ...    - automationName=XCUITest
    ...    - bundleId (instead of appPackage for iOS)
    ...    - wdaLaunchTimeout, wdaConnectionTimeout
    ...    - autoAcceptAlerts, noReset, newCommandTimeout
    
    Log    Launching Indodax iOS app (${IOS_BUNDLE_ID})...    INFO
    Open Application    ${APPIUM_SERVER}
    ...    platformName=iOS
    ...    deviceName=${IOS_DEVICE_NAME}
    ...    udid=${IOS_UDID}
    ...    platformVersion=${IOS_PLATFORM_VERSION}
    ...    automationName=${IOS_AUTOMATION_NAME}
    ...    bundleId=${IOS_BUNDLE_ID}
    ...    wdaLaunchTimeout=${WDA_LAUNCH_TIMEOUT}
    ...    wdaConnectionTimeout=${WDA_CONNECTION_TIMEOUT}
    ...    autoAcceptAlerts=${IOS_AUTO_ACCEPT_ALERTS}
    ...    noReset=${IOS_NO_RESET}
    ...    newCommandTimeout=${IOS_NEW_COMMAND_TIMEOUT}
    Log    ✓ Indodax iOS app launched successfully    INFO


Open Test App
    [Documentation]    Test Setup keyword — open the Indodax app and stabilize initial state.
    ...    Handles launch modals, onboarding screens, and ensures the home screen
    ...    is visible and ready before the test body executes.
    ...
    ...    Designed to be used as:
    ...    Test Setup    Open Test App

    Open Indodax App
    Log    ✓ Indodax app opened    INFO
    Capture Page Screenshot    filename=m01_initial_state.png

    # Handle Learn More modal if present (promo modal at startup)
    Handle Learn More Modal

    # Ensure we're on the home screen
    Click Home Button Safely
    TRY
        Wait Until Element Is Visible    ${HOME_BUTTON}    timeout=5s
    EXCEPT
        Log    Home button not immediately visible after click - continuing    DEBUG
    END

    # Handle Learn More again after navigating to home
    Handle Learn More Modal

    # Skip onboarding if present
    Skip Onboarding If Present
    TRY
        Wait Until Element Is Visible    ${HOME_BUTTON}    timeout=10s
    EXCEPT
        Log    Home button not visible after onboarding - app may be in different state    DEBUG
    END

    Log    ✓ App ready — home screen stabilized    INFO


Capture Screenshot On Failure And Close App
    [Documentation]    Test Teardown keyword — capture screenshot on failure then close the app.
    ...    Safe teardown: does not fail if app is already closed or screenshot fails.
    ...
    ...    Designed to be used as:
    ...    Test Teardown    Capture Screenshot On Failure And Close App

    IF    '${TEST STATUS}' == 'FAIL'
        TRY
            Capture Page Screenshot
        EXCEPT
            Log    Could not capture screenshot — app may already be closed    DEBUG
        END
    END
    Close Indodax App If Open