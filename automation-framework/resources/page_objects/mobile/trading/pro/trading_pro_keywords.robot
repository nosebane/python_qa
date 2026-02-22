*** Settings ***
Documentation    Trading PRO page keywords for Indodax mobile app
...             Handles interactions on the PRO mode trading page
...             PRO mode features: Advanced chart, Limit Order, Market Order, Stop Limit Order
...             Supports both IDR and USDT pairs

Library    AppiumLibrary


*** Keywords ***

Wait For ETH Page Load
    [Documentation]    Wait for ETH/IDR trading page to fully load
    ...    Waits for ETH page to be visible

    Log    Waiting for ETH trading page to load...    INFO

    TRY
        Wait Until Page Contains    ETH    timeout=20s
        Log    ✓ ETH trading page loaded    INFO
    EXCEPT
        # If ETH text not found, log page structure for debugging
        ${source}=    Get Source
        Log    Page source length: ${source.__len__()} characters    DEBUG
        Log    Could not find ETH text on page, checking what's displayed...    DEBUG

        # Try checking for any cryptocurrency-related content
        TRY
            @{all_text}=    Get Webelements    //android.widget.TextView
            ${found_eth}=    Set Variable    False
            ${found_any}=    Set Variable    False
            FOR    ${elem}    IN    @{all_text}
                TRY
                    ${text}=    Get Text    ${elem}
                    IF    'ETH' in '${text}'
                        ${found_eth}=    Set Variable    True
                        Log    Found ETH in: ${text}    INFO
                    END
                    IF    '${text}' != '' and ${found_any} == False
                        Log    First visible text: ${text}    DEBUG
                        ${found_any}=    Set Variable    True
                    END
                EXCEPT
                    Continue For Loop
                END
            END

            IF    ${found_eth} == True
                Log    ✓ ETH found in page elements    INFO
                RETURN
            END
        EXCEPT
            Log    Could not check page elements    DEBUG
        END

        Fail    ETH trading page did not load within timeout
    END


Validate ETH Page Is Displayed
    [Documentation]    Validate that the ETH/IDR trading page is displayed
    ...    Checks for ETH text and page content

    Log    Validating ETH/IDR page...    INFO

    # First check: Make sure we DON'T have a "No result" message
    TRY
        Page Should Not Contain Text    No result for the keyword you're searching
        Log    ✓ No "no result" message found    INFO
    EXCEPT
        Fail    ETH search failed - "No result for the keyword you're searching" message found
    END

    TRY
        Page Should Contain Text    ETH
        Log    ✓ ETH text found on page    INFO
    EXCEPT
        Fail    ETH page not displayed - 'ETH' text not found
    END

    TRY
        Page Should Contain Text    Ethereum Price (ETH)
        Log    ✓ Ethereum Price (ETH) text found on page    INFO
    EXCEPT
        Fail    Ethereum Price (ETH) text not found on page - ETH/IDR pair page not loaded
    END

    Log    ✓ ETH/IDR trading page validated successfully    INFO
