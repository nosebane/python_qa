"""
Response Validation Library for Robot Framework

Provides keywords for validating HTTP response codes from RequestsLibrary.
"""


class ResponseValidator:
    """Robot Framework library for validating HTTP responses."""

    ROBOT_LIBRARY_SCOPE = 'GLOBAL'

    def verify_response_status_code(self, response, expected_status_code=200):
        """
        Verify HTTP response status code.
        
        Args:
            response: Response object from RequestsLibrary or parsed JSON dict
            expected_status_code: Expected HTTP status code (default: 200)
            
        Returns:
            Response JSON body (extracted from response object or returned as-is if dict)
            
        Raises:
            AssertionError: If status code doesn't match expected value
        """
        # Check if response is a dict (already parsed)
        if isinstance(response, dict):
            return response
        
        # It's a Response object
        status_code = response.status_code
        
        if int(status_code) != int(expected_status_code):
            raise AssertionError(
                f"Expected status code {expected_status_code} but got {status_code}"
            )
        
        return response.json()
