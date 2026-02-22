"""
Indodax Private API HMAC-SHA512 Signer

Implements the signing mechanism for Indodax private API requests.
Based on Indodax Private-RestAPI.md documentation.

Reference:
- Authentication: HMAC-SHA512
- Headers required: Key, Sign
- Request format: POST with nonce and timestamp
"""

import hashlib
import hmac
import json
import time
import urllib.parse
from typing import Dict, Any, Tuple


class IndodaxSigner:
    """HMAC-SHA512 signer for Indodax Private API requests."""

    def __init__(self, api_key: str, api_secret: str):
        """
        Initialize signer with API credentials.
        
        Args:
            api_key: Indodax API Key
            api_secret: Indodax API Secret
        """
        self.api_key = api_key
        self.api_secret = api_secret

    def get_nonce(self) -> int:
        """
        Generate a nonce (number used once).
        
        Indodax requires nonce to be unique and increasing.
        Using millisecond timestamp ensures uniqueness.
        
        Returns:
            Nonce value (millisecond timestamp)
        """
        return int(time.time() * 1000)

    def get_timestamp(self) -> int:
        """
        Generate a timestamp.
        
        Returns:
            Current Unix timestamp in seconds
        """
        return int(time.time())

    def create_request_body(
        self,
        method: str,
        params: Dict[str, Any] = None,
        include_nonce: bool = True,
        include_timestamp: bool = False
    ) -> Tuple[str, Dict[str, str]]:
        """
        Create request body and headers for Indodax API.
        
        Args:
            method: API method name (e.g., 'getInfo', 'trade', 'cancelOrder')
            params: Additional parameters for the API call
            include_nonce: Whether to include nonce (default: True)
            include_timestamp: Whether to include timestamp (default: False)
        
        Returns:
            Tuple of (request_body_string, headers_dict)
        """
        # Build request body
        body_params = {'method': method}
        
        if include_nonce:
            body_params['nonce'] = self.get_nonce()
        
        if include_timestamp:
            body_params['timestamp'] = self.get_timestamp()
        
        # Add additional parameters
        if params:
            body_params.update(params)
        
        # Convert body to URL-encoded format (required by Indodax)
        request_body = urllib.parse.urlencode(body_params)
        
        # Calculate HMAC-SHA512 signature
        sign = hmac.new(
            self.api_secret.encode('utf-8'),
            request_body.encode('utf-8'),
            hashlib.sha512
        ).hexdigest()
        
        # Create headers
        headers = {
            'Key': self.api_key,
            'Sign': sign,
            'Content-Type': 'application/x-www-form-urlencoded'
        }
        
        return request_body, headers

    def sign_request(
        self,
        method: str,
        params: Dict[str, Any] = None
    ) -> Tuple[str, Dict[str, str]]:
        """
        Sign a request for Indodax Private API.
        
        Convenience method that wraps create_request_body with standard options.
        
        Args:
            method: API method name
            params: Additional parameters
        
        Returns:
            Tuple of (signed_body, headers)
        """
        return self.create_request_body(method, params, include_nonce=True)

    def verify_signature(self, message: str, signature: str) -> bool:
        """
        Verify a signature (for validation purposes).
        
        Args:
            message: The original message
            signature: The signature to verify
        
        Returns:
            True if signature is valid, False otherwise
        """
        expected_sig = hmac.new(
            self.api_secret.encode('utf-8'),
            message.encode('utf-8'),
            hashlib.sha512
        ).hexdigest()
        
        return hmac.compare_digest(signature, expected_sig)

