*** Settings ***
Documentation    Trading LITE page element locators for Indodax mobile app
...             LITE mode: Simplified chart, Market Order only, IDR pairs only
...             Designed for beginner users


*** Variables ***
# --- Trading Page Identification ---
${LITE_PAIR_TITLE}=                    //*[contains(@text, "IDR")]
${LITE_CHART_VIEW}=                    id=id.co.bitcoin:id/webViewChartLite

# --- Buy/Sell Form ---
${LITE_BUY_BUTTON}=                    //*[@text="Beli"]
${LITE_SELL_BUTTON}=                   //*[@text="Jual"]
${LITE_AMOUNT_IDR_INPUT}=              id=id.co.bitcoin:id/etAmountIDR
${LITE_AMOUNT_ASSET_INPUT}=            id=id.co.bitcoin:id/etAmountAsset
${LITE_SLIDER_PERCENTAGE}=             id=id.co.bitcoin:id/seekBarLite

# --- Confirmation Page ---
${LITE_NEXT_BUTTON}=                   //*[@text="Selanjutnya"]
${LITE_BUY_NOW_BUTTON}=                //*[@text="Beli Sekarang"]
${LITE_SELL_NOW_BUTTON}=               //*[@text="Jual Sekarang"]
${LITE_CONFIRM_ASSET_LABEL}=           id=id.co.bitcoin:id/tvAssetName
${LITE_CONFIRM_AMOUNT_LABEL}=          id=id.co.bitcoin:id/tvAmount

# --- Success/Error ---
${LITE_SUCCESS_MESSAGE}=               //*[contains(@text, "Transaksi berhasil")]
${LITE_ERROR_MESSAGE}=                 //*[contains(@text, "Transaksi gagal")]
