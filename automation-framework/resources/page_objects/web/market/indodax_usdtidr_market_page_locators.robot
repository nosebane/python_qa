*** Settings ***
Documentation    Web element locators for Indodax USDT/IDR market page
...             Centralized location for all CSS selectors and element identifiers
...             Uses CSS selectors for better performance and maintainability
...             
...             NOTE: Indodax uses dynamic content loaded via AJAX/API calls
...             Most data is rendered client-side via JavaScript

*** Variables ***

# Page Elements
${PAGE_TITLE}                         Indodax
${PAGE_HEADING_H1}                    css=h1

# Price Elements - Specific to USDT/IDR pair (CSS selectors)
${CURRENT_PRICE_LOCATOR}              css=strong.price_usdtidr_val[data-sort]
${CURRENT_PRICE_CONTAINER}            css=.market-price-box

# 24h Change Elements - Specific class for USDT/IDR (CSS selectors)
${PRICE_CHANGE_24H_LOCATOR}           css=strong.price_change_usdtidr

# Volume Elements - Specific vol_val class (CSS selectors)
${VOLUME_24H_LOCATOR}                 css=strong.vol_val
${VOLUME_LABEL}                       css=strong.vol_val

# High/Low Elements (CSS selectors)
${HIGH_PRICE_LOCATOR}                 css=span.high_val
${LOW_PRICE_LOCATOR}                  css=span.low_val

# Order Book Containers - Specific first row only (CSS selectors)
${ORDER_BOOK_BUY_TABLE}               css=#buy_orders
${ORDER_BOOK_SELL_TABLE}              css=#sell_orders

# Order Book Prices - First row only to avoid strict mode (CSS selectors)
${BID_PRICE_LOCATOR}                  css=#buy_orders tbody tr:first-child td:first-child
${ASK_PRICE_LOCATOR}                  css=#sell_orders tbody tr:first-child td:first-child

# Trading Pair Header (CSS selector)
${TRADING_PAIR_HEADER_LOCATOR}        css=h1

# Page Structure Elements (CSS selectors)
${MAIN_CONTENT_AREA}                  css=main
${MARKET_DATA_SECTION}                css=.datainfo

# Data Container (CSS selector)
${MARKET_SUMMARY_CONTAINER}           css=.datainfo

# Navigation & Reload Elements (CSS selectors)
${RELOAD_BUTTON}                      css=button.reload-spot-data
${MARKET_PAIR_NAV_LINK}               css=a[href*="/market/"]

# Search Elements (CSS selectors)
${SEARCH_BOX_MARKET}                  css=#searchbox_market
${MARKET_ROW_SEARCH_DATA}             css=tr[class*="market-row"] td[data-search]
${FIRST_MARKET_SEARCH_RESULT}         css=#marketbox-table-all tr[class*="market-row"]:first-child td[data-search]

# Last Trades Table (CSS selectors)
${LAST_TRADES_TABLE}                  css=#last_trades
${LAST_TRADES_ROW}                    css=#last_trades tbody tr:first-child

