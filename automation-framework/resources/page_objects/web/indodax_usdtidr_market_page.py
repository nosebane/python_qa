"""
Indodax Market Page Object
Represents the Indodax cryptocurrency market trading page
"""

from playwright.sync_api import Page
from typing import Dict, List, Optional, Any
from resources.page_objects.web.base_page import BasePage


class IndodaxMarketPage(BasePage):
    """
    Page Object for Indodax Market/Trading page
    
    URL: https://indodax.com/market/{PAIR}
    Provides interactions with market data, trading pairs, and order placement
    """
    
    # Locators
    MARKET_HEADER = "h1.market-header"
    TRADING_PAIR_NAME = "[class*='pair-name']"
    CURRENT_PRICE = "[class*='current-price']"
    PRICE_CHANGE = "[class*='price-change']"
    MARKET_CAP = "[class*='market-cap']"
    VOLUME_24H = "[class*='volume-24h']"
    
    # Price chart
    CHART_CONTAINER = "#chart-container"
    CHART_TIMEFRAME_BUTTONS = "[class*='timeframe-btn']"
    
    # Trading data
    BID_PRICE = "[class*='bid-price']"
    ASK_PRICE = "[class*='ask-price']"
    LAST_TRADE = "[class*='last-trade']"
    HIGH_24H = "[class*='high-24h']"
    LOW_24H = "[class*='low-24h']"
    
    # Order book
    ORDER_BOOK_TABLE = "[class*='order-book']"
    ORDER_BOOK_ROWS = "[class*='order-book'] tbody tr"
    BUY_ORDERS = "[class*='buy-orders'] tr"
    SELL_ORDERS = "[class*='sell-orders'] tr"
    
    # Trading panel
    BUY_BUTTON = "button:has-text('Buy')"
    SELL_BUTTON = "button:has-text('Sell')"
    PRICE_INPUT = "[name='price']"
    AMOUNT_INPUT = "[name='amount']"
    TOTAL_INPUT = "[name='total']"
    PLACE_ORDER_BUTTON = "button:has-text('Place Order')"
    
    # Trading history
    TRADES_TABLE = "[class*='trades-history']"
    TRADES_ROWS = "[class*='trades-history'] tbody tr"
    
    def __init__(self, page: Page):
        """Initialize Indodax market page"""
        super().__init__(page)
        self.base_url = "https://indodax.com/market"
    
    def navigate_to_pair(self, pair: str) -> None:
        """
        Navigate to trading pair page
        
        Args:
            pair: Trading pair (e.g., 'usdtidr', 'btcidr')
        """
        url = f"{self.base_url}/{pair}"
        self.navigate_to(url)
        self.logger.info(f"Navigated to market pair: {pair}")
    
    def get_current_price(self) -> str:
        """Get current trading price"""
        try:
            price = self.get_text(self.CURRENT_PRICE)
            self.logger.info(f"Current price: {price}")
            return price
        except Exception as e:
            self.logger.warning(f"Could not get current price: {e}")
            return ""
    
    def get_price_change(self) -> str:
        """Get price change (24h)"""
        try:
            change = self.get_text(self.PRICE_CHANGE)
            self.logger.info(f"Price change: {change}")
            return change
        except Exception as e:
            self.logger.warning(f"Could not get price change: {e}")
            return ""
    
    def get_market_cap(self) -> str:
        """Get market capitalization"""
        try:
            market_cap = self.get_text(self.MARKET_CAP)
            self.logger.info(f"Market cap: {market_cap}")
            return market_cap
        except Exception as e:
            self.logger.warning(f"Could not get market cap: {e}")
            return ""
    
    def get_volume_24h(self) -> str:
        """Get 24h volume"""
        try:
            volume = self.get_text(self.VOLUME_24H)
            self.logger.info(f"24h volume: {volume}")
            return volume
        except Exception as e:
            self.logger.warning(f"Could not get 24h volume: {e}")
            return ""
    
    def get_bid_price(self) -> str:
        """Get bid price"""
        try:
            bid = self.get_text(self.BID_PRICE)
            self.logger.info(f"Bid price: {bid}")
            return bid
        except Exception as e:
            self.logger.warning(f"Could not get bid price: {e}")
            return ""
    
    def get_ask_price(self) -> str:
        """Get ask price"""
        try:
            ask = self.get_text(self.ASK_PRICE)
            self.logger.info(f"Ask price: {ask}")
            return ask
        except Exception as e:
            self.logger.warning(f"Could not get ask price: {e}")
            return ""
    
    def get_order_book_data(self) -> Dict[str, Any]:
        """
        Get order book data
        
        Returns:
            Dictionary with buy and sell orders
        """
        try:
            buy_orders = self._extract_orders(self.BUY_ORDERS)
            sell_orders = self._extract_orders(self.SELL_ORDERS)
            
            order_book = {
                'buy_orders': buy_orders,
                'sell_orders': sell_orders,
                'bid_ask_spread': self._calculate_spread(buy_orders, sell_orders)
            }
            
            self.logger.info(f"Order book: {len(buy_orders)} buy orders, {len(sell_orders)} sell orders")
            return order_book
        except Exception as e:
            self.logger.warning(f"Could not get order book: {e}")
            return {'buy_orders': [], 'sell_orders': [], 'bid_ask_spread': None}
    
    def _extract_orders(self, selector: str) -> List[Dict[str, str]]:
        """Extract order data from table rows"""
        orders = []
        try:
            texts = self.get_all_text_contents(selector)
            # Parse order data from text (implementation depends on actual HTML structure)
            self.logger.debug(f"Extracted {len(texts)} orders")
        except Exception as e:
            self.logger.warning(f"Error extracting orders: {e}")
        
        return orders
    
    def _calculate_spread(self, buy_orders: List, sell_orders: List) -> Optional[float]:
        """Calculate bid-ask spread"""
        try:
            if buy_orders and sell_orders:
                bid = float(buy_orders[0].get('price', 0))
                ask = float(sell_orders[0].get('price', 0))
                spread = ask - bid
                self.logger.debug(f"Bid-ask spread: {spread}")
                return spread
        except Exception as e:
            self.logger.warning(f"Error calculating spread: {e}")
        
        return None
    
    def get_recent_trades(self, limit: int = 10) -> List[Dict[str, str]]:
        """
        Get recent trades
        
        Args:
            limit: Number of trades to retrieve
            
        Returns:
            List of recent trades
        """
        try:
            trades = self.get_all_text_contents(self.TRADES_ROWS)
            self.logger.info(f"Retrieved {len(trades)} recent trades (limit: {limit})")
            return trades[:limit]
        except Exception as e:
            self.logger.warning(f"Could not get recent trades: {e}")
            return []
    
    def get_trading_pair_info(self) -> Dict[str, str]:
        """
        Get complete trading pair information
        
        Returns:
            Dictionary with price, change, volume, market cap
        """
        info = {
            'current_price': self.get_current_price(),
            'price_change_24h': self.get_price_change(),
            'volume_24h': self.get_volume_24h(),
            'market_cap': self.get_market_cap(),
            'bid': self.get_bid_price(),
            'ask': self.get_ask_price(),
        }
        
        self.logger.info(f"Trading pair info: {info}")
        return info
    
    def is_page_loaded(self) -> bool:
        """Check if market page is fully loaded"""
        try:
            self.wait_for_selector(self.CURRENT_PRICE, timeout=10000)
            self.logger.info("Market page loaded successfully")
            return True
        except Exception as e:
            self.logger.warning(f"Market page not loaded: {e}")
            return False
    
    def change_timeframe(self, timeframe: str) -> None:
        """
        Change chart timeframe
        
        Args:
            timeframe: Timeframe (1h, 4h, 24h, 7d, etc.)
        """
        try:
            selector = f"[data-timeframe='{timeframe}']"
            self.click(selector)
            self.logger.info(f"Changed timeframe to: {timeframe}")
        except Exception as e:
            self.logger.warning(f"Could not change timeframe: {e}")
