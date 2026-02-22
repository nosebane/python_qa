*** Settings ***
Documentation    Home page keywords for Indodax mobile app
...             Handles interactions on the home/main screen

Library    AppiumLibrary

Resource    ./home_locators.robot


*** Keywords ***

Click Home Button Safely
    [Documentation]    Click Home button to navigate to main screen
    ...    Continues silently if button not visible (may already be on home screen)

    TRY
        Wait Until Element Is Visible    ${HOME_BUTTON}    timeout=5s
        Click Element    ${HOME_BUTTON}
        Log    ✓ Home button clicked    INFO
    EXCEPT
        Log    Home button not clickable (may already be on home screen)    DEBUG
    END
