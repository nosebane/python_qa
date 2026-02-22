"""
Web Page Objects Package
Contains page object models for web UI automation
"""

from resources.page_objects.web.base_page import BasePage
from resources.page_objects.web.indodax_market_page import IndodaxMarketPage

__all__ = [
    'BasePage',
    'IndodaxMarketPage',
]
