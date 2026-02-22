*** Settings ***
Documentation    Market page element locators for Indodax mobile app
...             Locators for market page and search results elements
...             Based on Maestro flow recording for Indodax crypto app


*** Variables ***
${MARKET_MENU}=                        //*[contains(@text, "Market")]
# Confirmed resource-ids from live device (adb uiautomator dump, Android 15 / ASUS AI2302)
${SEARCH_CONTAINER}=                   id=id.co.bitcoin.market_v3_pro:id/clSearch
${SEARCH_EDIT_TEXT}=                   id=id.co.bitcoin.search_lite:id/etSearch
