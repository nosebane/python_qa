*** Settings ***
Documentation    Onboarding page keywords for Indodax mobile app
...             Handles onboarding dialogs that appear on various screens

Library    AppiumLibrary

Resource    ./onboarding_locators.robot


*** Keywords ***

Handle Learn More Modal
    [Documentation]    Handle Learn More promo modal if present at app startup
    ...    Silently continues if modal not found (app may have already skipped it)

    TRY
        Wait Until Element Is Visible    ${LEARN_MORE_BUTTON}    timeout=3s
        Click Element    ${LEARN_MORE_BUTTON}
        Log    ✓ Learn More modal dismissed    INFO
    EXCEPT
        Log    Learn More modal not present (may be skipped)    DEBUG
    END


Skip Onboarding If Present
    [Documentation]    Skip onboarding flow if it appears on screen
    ...    Based on Maestro flow:
    ...    1. Wait for and click "Learn More" button
    ...    2. Click "Next" button multiple times to dismiss onboarding dialogs

    Log    Checking for onboarding screen...    INFO

    # Step 1: Try to click "Learn More" button (first onboarding screen)
    TRY
        Wait Until Element Is Visible    ${LEARN_MORE_BUTTON}    timeout=5s
        Log    ✓ Found "Learn More" button - clicking it    INFO
        Click Element    ${LEARN_MORE_BUTTON}
        Wait Until Element Is Visible    ${ONBOARDING_NEXT_BUTTON}    timeout=5s
    EXCEPT
        Log    Learn More button not found - continuing    INFO
    END

    # Step 2: Click Next button(s) to progress through onboarding dialogs
    # Repeat up to 5 times to handle multiple onboarding screens
    FOR    ${i}    IN RANGE    1    6
        TRY
            Wait Until Element Is Visible    ${ONBOARDING_NEXT_BUTTON}    timeout=3s
            Log    ✓ Found Next button - clicking (attempt ${i})    INFO
            Click Element    ${ONBOARDING_NEXT_BUTTON}
            Wait Until Element Is Visible    ${ONBOARDING_NEXT_BUTTON}    timeout=2s
        EXCEPT
            Log    Next button not found - onboarding may be complete    INFO
            BREAK
        END
    END

    Log    ✓ Onboarding skip sequence completed    INFO
