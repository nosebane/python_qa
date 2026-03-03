*** Settings ***
Documentation       Market page element locators for Indodax mobile app
...                 Locators for market page and search results elements
...                 Based on Maestro flow recording for Indodax crypto app


*** Variables ***
${MARKET_MENU}=                 //*[contains(@text, "Market")]
${MARKET_MENU_ID}=              id=id.co.bitcoin:id/btMarket
${MARKET_MENU_PASAR}=           //*[contains(@text, "Pasar")]
${MARKET_MENU_CONTENT_DESC}=    //*[@content-desc="Market"]
${MARKET_MENU_NAV_TITLE}=       //android.widget.TextView[@resource-id="id.co.bitcoin:id/title"]
# Confirmed resource-ids from live device (adb uiautomator dump, Android 15 / ASUS AI2302)
${SEARCH_CONTAINER}=            id=id.co.bitcoin.market_v3_pro:id/clSearch
${SEARCH_EDIT_TEXT}=            id=id.co.bitcoin.search_lite:id/etSearch
