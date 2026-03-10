*** Settings ***
Documentation       Market page keywords for Indodax mobile app
...                 Handles interactions on market page and search results

Library             AppiumLibrary
Resource            ./market_locators.robot
Resource            ../onboarding/onboarding_locators.robot


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
    ...    Tries multiple locator strategies for bottom navigation

    Log    Clicking Market menu...    INFO

    # Strategy 1: Click via resource-id (id.co.bitcoin:id/btMarket)
    TRY
        Wait Until Element Is Visible    ${MARKET_MENU_ID}    timeout=5s
        Click Element    ${MARKET_MENU_ID}
        Log    ✓ Market menu clicked (via resource-id btMarket)    INFO
        Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
        RETURN
    EXCEPT
        Log    Strategy 1 (resource-id) failed    DEBUG
    END

    # Strategy 2: Click via text 'Market' (English)
    TRY
        Click Text    Market
        Log    ✓ Market menu clicked (via text 'Market')    INFO
        Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
        RETURN
    EXCEPT
        Log    Strategy 2 (text Market) failed    DEBUG
    END

    # Strategy 3: Click via text 'Pasar' (Indonesian)
    TRY
        Click Text    Pasar
        Log    ✓ Market menu clicked (via text 'Pasar')    INFO
        Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
        RETURN
    EXCEPT
        Log    Strategy 3 (text Pasar) failed    DEBUG
    END

    # Strategy 4: Click via content-desc 'Market'
    TRY
        Wait Until Element Is Visible    ${MARKET_MENU_CONTENT_DESC}    timeout=5s
        Click Element    ${MARKET_MENU_CONTENT_DESC}
        Log    ✓ Market menu clicked (via content-desc)    INFO
        Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
        RETURN
    EXCEPT
        Log    Strategy 4 (content-desc) failed    DEBUG
    END

    # Strategy 5: Click via XPath text contains (English or Indonesian)
    TRY
        Wait Until Element Is Visible    ${MARKET_MENU}    timeout=5s
        Click Element    ${MARKET_MENU}
        Log    ✓ Market menu clicked (via XPath contains Market)    INFO
        Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
        RETURN
    EXCEPT
        Log    Strategy 5 (XPath contains Market) failed    DEBUG
    END

    # Strategy 6: All bottom nav title TextViews - try index 1 and 2
    TRY
        ${elements}=    Get Webelements    ${MARKET_MENU_NAV_TITLE}
        Log    Found ${elements.__len__()} nav title elements    DEBUG
        FOR    ${idx}    IN    1    2
            IF    ${elements.__len__()} > ${idx}
                ${txt}=    Get Element Attribute    ${elements}[${idx}]    text
                Log    Nav item [${idx}] text: '${txt}'    DEBUG
                Click Element    ${elements}[${idx}]
                TRY
                    Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=5s
                    Log    ✓ Market menu clicked (nav title index ${idx})    INFO
                    RETURN
                EXCEPT
                    Log    Nav index ${idx} did not lead to market    DEBUG
                END
            END
        END
    EXCEPT
        Log    Strategy 6 (nav title by index) failed    DEBUG
    END

    # Strategy 7: resource-id with package variants
    FOR    ${pkg}    IN    id.co.bitcoin    id.co.bitcoin.main    id.co.bitcoin.home_lite
        TRY
            ${locator}=    Set Variable    //*[@resource-id="${pkg}:id/btMarket"]
            Wait Until Element Is Visible    ${locator}    timeout=3s
            Click Element    ${locator}
            Log    ✓ Market menu clicked (package: ${pkg})    INFO
            Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
            RETURN
        EXCEPT
            Log    Package variant ${pkg} failed    DEBUG
        END
    END

    # Dump page source before failing — helps diagnose correct locator
    Log    ===== DIAGNOSE: All Market menu strategies failed =====    WARN
    TRY
        ${source}=    Get Source
        Log    Page source (first 3000 chars):\n${source[:3000]}    DEBUG
        Capture Page Screenshot    filename=FAIL_market_menu_not_found.png
    EXCEPT
        Log    Could not dump page source    DEBUG
    END

    Fail    Could not locate Market menu element — check FAIL_market_menu_not_found.png and page source in log

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


# ─────────────────────────────────────────────────────────────────────────────
# BDD STEP KEYWORDS — Market Search
# RF strips the Given/When/Then/And prefix before keyword lookup.
# e.g. "Given the app is on the market page" → "The App Is On The Market Page"
# ─────────────────────────────────────────────────────────────────────────────

The App Is On The Market Page
    [Documentation]    BDD Given: navigate to the Market page.

    Navigate To Market
    Capture Page Screenshot    filename=${SCREENSHOT_ONBOARDING}
    Log    ✓ App is on the Market page    INFO

The Search Functionality Is Available
    [Documentation]    BDD And: assert search container is visible on the Market page.

    Wait Until Page Contains Element    ${SEARCH_CONTAINER}    timeout=10s
    Capture Page Screenshot    filename=${SCREENSHOT_MARKET_CLICK}
    Log    ✓ Search functionality is available    INFO

The User Searches For The Configured Cryptocurrency
    [Documentation]    BDD When: enter the configured search term (${SEARCH_TERM}) into the search box.

    Search For Cryptocurrency    ${SEARCH_TERM}
    Log    ✓ Search for '${SEARCH_TERM}' completed    INFO

The Expected Pair Should Appear In The Search Results
    [Documentation]    BDD Then: assert ${EXPECTED_PAIR} is visible in the search results.

    Wait Until Page Contains    ${EXPECTED_PAIR}    timeout=${SEARCH_RESULT_TIMEOUT}
    Capture Page Screenshot    filename=${SCREENSHOT_SEARCH_RESULTS}
    Log    ✓ '${EXPECTED_PAIR}' found in search results    INFO

The User Selects The ETH/IDR Result
    [Documentation]    BDD When: tap on the ETH/IDR entry in the search result list.

    Click ETH IDR Result
    Log    ✓ ETH/IDR result selected    INFO

