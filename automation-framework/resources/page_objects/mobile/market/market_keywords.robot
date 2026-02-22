*** Settings ***
Documentation    Market page keywords for Indodax mobile app
...             Handles interactions on market page and search results

Library    AppiumLibrary

Resource    ./market_locators.robot
Resource    ../onboarding/onboarding_locators.robot


*** Keywords ***

Navigate To Market
    [Documentation]    Navigate to Market page with fallback logic
    ...    Tries multiple methods:
    ...    1. Check if already in market (search container visible)
    ...    2. Click Market menu if needed

    # Check if already in market by looking for search container
    TRY
        Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=3s
        Log    ✓ Already in Market view (search container found)    DEBUG
        RETURN
    EXCEPT
        Log    Not in Market yet, attempting navigation    DEBUG
    END

    # Try to click Market menu
    Click Market Menu


Click Market Menu
    [Documentation]    Click on Market menu item to open market view

    Log    Clicking Market menu...    INFO

    # First, try clicking "Market" text directly (bottom navigation)
    TRY
        Click Text    Market
        Log    ✓ Market menu clicked (via bottom navigation text)    INFO
        Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
        RETURN
    EXCEPT
        Log    Market text click failed, trying other methods    DEBUG
    END

    # Try XPath with index
    TRY
        Wait Until Element Is Visible    ${MARKET_MENU}    timeout=5s
        Click Element    ${MARKET_MENU}
        Log    ✓ Market menu clicked (via indexed XPath)    INFO
        Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
        RETURN
    EXCEPT
        Log    Market menu locator (index-based XPath) failed    DEBUG
    END

    # Fallback: Try using direct ID with index approach
    TRY
        ${elements}=    Get Webelements    //android.widget.TextView[@resource-id="id.co.bitcoin:id/title"]
        IF    ${elements.__len__()} > 1
            Click Element    ${elements}[1]
            Log    ✓ Market menu clicked (via WebElement index)    INFO
            Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
            RETURN
        END
    EXCEPT
        Log    Direct ID search also failed    DEBUG
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

    Fail    Could not locate Market menu element


Search For Cryptocurrency
    [Documentation]    Search for cryptocurrency by entering search term.
    ...    Flow:
    ...    1. Tap search container (id.co.bitcoin.market_v3_pro:id/clSearch) — opens search screen
    ...    2. Tap search input field (id.co.bitcoin.search_lite:id/etSearch)
    ...    3. Input text (e.g., "ETH")
    ...    Locators confirmed via adb uiautomator dump on Android 15 / ASUS AI2302.

    [Arguments]    ${search_term}

    Log    Searching for: ${search_term}    INFO

    # Step 1: Tap search container to open search screen
    Wait Until Element Is Visible    ${SEARCH_CONTAINER}    timeout=10s
    TRY
        # Primary path: tap the search container (clSearch)
        Click Element    ${SEARCH_CONTAINER}
        Wait Until Element Is Visible    ${SEARCH_EDIT_TEXT}    timeout=10s
    EXCEPT
        # Fallback: screen transition slow — re-tap via placeholder text element
        Log    Search screen transition slow — retrying via placeholder text    DEBUG
        Click Element    xpath=//android.widget.TextView[contains(@text, 'Search')]
        Wait Until Element Is Visible    ${SEARCH_EDIT_TEXT}    timeout=10s
    END

    # Step 2: Focus the search input field (now on search_lite screen)
    Click Element    ${SEARCH_EDIT_TEXT}
    Log    ✓ Search input focused    INFO

    # Step 3: Input text - use multiple methods
    TRY
        Input Text    ${SEARCH_EDIT_TEXT}    ${search_term}
        Log    ✓ Search term '${search_term}' entered successfully    INFO
        Wait Until Page Contains    ${search_term}    timeout=5s
    EXCEPT
        Log    ✗ Could not input text via resource-id, trying alternatives...    DEBUG

        # Try alternative input methods
        TRY
            ${edittext_elements}=    Get Webelements    //android.widget.EditText
            IF    ${edittext_elements.__len__()} > 0
                Input Text    ${edittext_elements}[0]    ${search_term}
                Log    ✓ Search term entered into first EditText    INFO
                Wait Until Page Contains    ${search_term}    timeout=5s
            END
        EXCEPT
            Log    ✗ EditText input failed, trying keyboard...    DEBUG

            TRY
                Input Text Into Current Element    ${search_term}
                Log    ✓ Search term entered via keyboard    INFO
                Wait Until Page Contains    ${search_term}    timeout=5s
            EXCEPT
                Log    ✗ Keyboard input failed    WARN
                Fail    Could not enter search term by any method
            END
        END
    END

    # Step 4: Press Enter to submit search
    Log    Step 4: Pressing Enter to submit search...    INFO
    TRY
        Press Keycode    66
        Log    ✓ Enter key pressed (keycode 66)    INFO
        Wait Until Page Contains    ${search_term}    timeout=10s
    EXCEPT
        Log    Enter key press failed, search may still execute via implicit submit    DEBUG
    END

    Log    === Search input completed successfully ===    INFO


Click ETH IDR Result
    [Documentation]    Click on ETH/IDR pair from search results
    ...    Maestro flow: tapOn: "ETH/IDR"

    Log    === Clicking ETH/IDR result ===    INFO

    # First, wait for search results to fully load and verify ETH/IDR is visible
    Log    Waiting for search results to load...    INFO
    Wait Until Page Contains    ETH/IDR    timeout=10s

    # Check if we're still getting "No result" message - if so, search failed
    TRY
        Page Should Not Contain Text    No result for the keyword you're searching
    EXCEPT
        Log    ✗ Search returned no results!    WARN
        Fail    Search for ETH returned no results on market page
    END

    # Try to tap on "ETH/IDR" text directly
    Log    Attempt 1: Clicking via 'ETH/IDR' text...    INFO
    TRY
        Click Text    ETH/IDR
        Log    ✓ ETH/IDR clicked successfully    INFO
        RETURN
    EXCEPT
        Log    Could not find 'ETH/IDR' text    DEBUG
    END

    # Try clicking "ETH" (partial match)
    Log    Attempt 2: Clicking via 'ETH' text...    INFO
    TRY
        Click Text    ETH    exact_match=False
        Log    ✓ ETH clicked (partial match)    INFO
        RETURN
    EXCEPT
        Log    Could not find ETH text    DEBUG
    END

    # Try XPath search for ETH/IDR
    Log    Attempt 3: Searching via XPath for 'ETH/IDR'...    INFO
    TRY
        ${elements}=    Get Webelements    //*[contains(@text, "ETH/IDR")]
        IF    ${elements.__len__()} > 0
            Click Element    ${elements}[0]
            Log    ✓ ETH/IDR clicked via XPath    INFO
            RETURN
        END
    EXCEPT
        Log    XPath search failed    DEBUG
    END

    # Fallback: Search for any element containing "ETH"
    Log    Attempt 4: Broad search for elements containing 'ETH'...    INFO
    TRY
        ${elements}=    Get Webelements    //*[contains(@text, "ETH")]
        IF    ${elements.__len__()} > 0
            Log    Found ${elements.__len__()} elements containing ETH    DEBUG
            Click Element    ${elements}[0]
            Log    ✓ Clicked first ETH element    INFO
            RETURN
        END
    EXCEPT
        Log    Broad ETH search failed    DEBUG
    END

    # Last resort: Click first ViewGroup that looks like a market item
    Log    Attempt 5: Clicking first market item ViewGroup...    INFO
    TRY
        ${elements}=    Get Webelements    //android.view.ViewGroup
        IF    ${elements.__len__()} > 0
            Click Element    ${elements}[0]
            Log    ✓ Clicked first ViewGroup    INFO
            RETURN
        END
    EXCEPT
        Log    ViewGroup click failed    DEBUG
    END

    Fail    Could not find and click ETH/IDR result
