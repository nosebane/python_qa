"""
Robot Framework library for Indodax Private API HMAC-SHA512 signing.

Provides keywords to sign and verify Indodax API requests.
"""

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from indodax_signer import IndodaxSigner
import json


class IndodaxSignerLibrary:
    """Robot Framework library for Indodax API signing."""
    
    ROBOT_LIBRARY_SCOPE = 'SUITE'
    
    def __init__(self):
        self.signer = None
        self.builtin = BuiltIn()
    
    @keyword('Create Indodax Signer')
    def create_signer(self, api_key, api_secret):
        """
        Create an Indodax signer instance.
        
        Args:
            api_key: Indodax API Key
            api_secret: Indodax API Secret
        
        Returns:
            Signer instance stored in self.signer
        """
        self.signer = IndodaxSigner(api_key, api_secret)
        self.builtin.log('Created Indodax signer with API key: {}...'.format(api_key[:10]), 'DEBUG')
        return self.signer
    
    @keyword('Sign Indodax Request')
    def sign_request(self, method, params_dict=None):
        """
        Sign an Indodax request with HMAC-SHA512.
        
        Args:
            method: API method (e.g., 'getInfo', 'trade', 'cancelOrder')
            params_dict: Dictionary of additional parameters (optional)
        
        Returns:
            Dictionary with 'body' and 'headers' keys
            
        Example:
            ${signed}=    Sign Indodax Request    trade    ${params}
            ${body}=      Get From Dictionary    ${signed}    body
            ${headers}=   Get From Dictionary    ${signed}    headers
        """
        if not self.signer:
            raise Exception('Signer not initialized. Call "Create Indodax Signer" first.')
        
        self.builtin.log('Signing request for method: {}'.format(method), 'DEBUG')
        
        params = params_dict if isinstance(params_dict, dict) else None
        body, headers = self.signer.sign_request(method, params)
        
        self.builtin.log('Generated signature - Headers: {}'.format(headers.keys()), 'DEBUG')
        
        return {
            'body': body,
            'headers': headers
        }
    
    @keyword('Get Indodax Nonce')
    def get_nonce(self):
        """
        Get a new nonce value.
        
        Returns:
            Nonce (millisecond timestamp)
        """
        if not self.signer:
            raise Exception('Signer not initialized. Call "Create Indodax Signer" first.')
        
        nonce = self.signer.get_nonce()
        self.builtin.log('Generated nonce: {}'.format(nonce), 'DEBUG')
        return nonce
    
    @keyword('Get Indodax Timestamp')
    def get_timestamp(self):
        """
        Get current timestamp.
        
        Returns:
            Unix timestamp (seconds)
        """
        if not self.signer:
            raise Exception('Signer not initialized. Call "Create Indodax Signer" first.')
        
        timestamp = self.signer.get_timestamp()
        self.builtin.log('Generated timestamp: {}'.format(timestamp), 'DEBUG')
        return timestamp
    
    @keyword('Verify Indodax Signature')
    def verify_signature(self, message, signature):
        """
        Verify an Indodax signature.
        
        Args:
            message: Original message
            signature: Signature to verify
        
        Returns:
            True if valid, False otherwise
        """
        if not self.signer:
            raise Exception('Signer not initialized. Call "Create Indodax Signer" first.')
        
        is_valid = self.signer.verify_signature(message, signature)
        self.builtin.log('Signature verification: {}'.format('PASS' if is_valid else 'FAIL'), 'DEBUG')
        return is_valid
