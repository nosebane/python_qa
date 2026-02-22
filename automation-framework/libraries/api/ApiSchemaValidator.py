"""
Robot Framework library for API schema validation using jsonschema.

Provides keywords to validate API responses against JSON schemas.
"""

from robot.api.deco import keyword
from robot.libraries.BuiltIn import BuiltIn
from jsonschema import validate, ValidationError, Draft7Validator
import json


class ApiSchemaValidator:
    """Robot Framework library for API response schema validation."""
    
    ROBOT_LIBRARY_SCOPE = 'SUITE'
    
    def __init__(self):
        self.builtin = BuiltIn()
        self.schemas = {}
    
    @keyword('Validate Response Against Schema')
    def validate_response(self, response_dict, schema_dict):
        """
        Validate API response against JSON schema.
        
        Args:
            response_dict: Response data (dict/JSON)
            schema_dict: JSON schema definition (dict)
        
        Returns:
            True if validation passes
            
        Raises:
            AssertionError if validation fails with detailed error message
        """
        try:
            validate(instance=response_dict, schema=schema_dict)
            self.builtin.log('✓ Response schema validation passed', 'INFO')
            return True
        except ValidationError as e:
            error_path = ' -> '.join(str(p) for p in e.path) if e.path else 'root'
            error_msg = f"""
Schema validation failed:
  Path: {error_path}
  Message: {e.message}
  Validator: {e.validator}
  Schema: {e.schema}
            """
            raise AssertionError(error_msg.strip())
    
    @keyword('Validate Field In Response')
    def validate_field(self, response_dict, field_path, field_schema):
        """
        Validate specific field in response against schema.
        
        Args:
            response_dict: Response data (dict)
            field_path: Dot-separated path to field (e.g., 'ticker.buy')
            field_schema: Schema for the field
            
        Raises:
            AssertionError if field doesn't match schema or doesn't exist
        """
        try:
            # Navigate to the field
            value = response_dict
            for key in field_path.split('.'):
                value = value[key]
            
            # Validate the field
            validate(instance=value, schema=field_schema)
            self.builtin.log(f'✓ Field "{field_path}" schema validation passed', 'INFO')
            return True
        except (KeyError, TypeError) as e:
            raise AssertionError(f'Field "{field_path}" not found in response: {e}')
        except ValidationError as e:
            raise AssertionError(f'Field "{field_path}" validation failed: {e.message}')
    
    @keyword('Get Schema Validation Errors')
    def get_validation_errors(self, response_dict, schema_dict):
        """
        Get all validation errors without raising exception.
        
        Args:
            response_dict: Response data
            schema_dict: JSON schema
            
        Returns:
            List of error messages, empty if valid
        """
        validator = Draft7Validator(schema_dict)
        errors = []
        
        for error in validator.iter_errors(response_dict):
            path = ' -> '.join(str(p) for p in error.path) if error.path else 'root'
            errors.append(f'{path}: {error.message}')
        
        if errors:
            self.builtin.log(f'Found {len(errors)} schema validation error(s):', 'WARN')
            for error in errors:
                self.builtin.log(f'  • {error}', 'WARN')
        
        return errors
    
    @keyword('Store Schema')
    def store_schema(self, schema_name, schema_dict):
        """
        Store schema for later use.
        
        Args:
            schema_name: Name to store schema under
            schema_dict: JSON schema definition
        """
        self.schemas[schema_name] = schema_dict
        self.builtin.log(f'Schema "{schema_name}" stored', 'DEBUG')
    
    @keyword('Get Stored Schema')
    def get_stored_schema(self, schema_name):
        """
        Retrieve previously stored schema.
        
        Args:
            schema_name: Name of stored schema
            
        Returns:
            Schema definition
            
        Raises:
            AssertionError if schema not found
        """
        if schema_name not in self.schemas:
            raise AssertionError(f'Schema "{schema_name}" not found. Available schemas: {list(self.schemas.keys())}')
        return self.schemas[schema_name]
    
    @keyword('Compare Response Field Types')
    def compare_field_types(self, response_dict, expected_types_dict):
        """
        Validate response field types match expected types.
        
        Args:
            response_dict: Response data
            expected_types_dict: Dict with field paths and expected types
                Example: {'ticker.buy': 'number', 'ticker.pair': 'string'}
            
        Raises:
            AssertionError if type mismatch found
        """
        errors = []
        
        for field_path, expected_type in expected_types_dict.items():
            try:
                value = response_dict
                for key in field_path.split('.'):
                    value = value[key]
                
                actual_type = self._get_json_type(value)
                
                if actual_type != expected_type:
                    errors.append(f'{field_path}: expected {expected_type}, got {actual_type}')
            except (KeyError, TypeError) as e:
                errors.append(f'{field_path}: field not found')
        
        if errors:
            error_msg = 'Type validation failed:\n' + '\n'.join(f'  • {e}' for e in errors)
            raise AssertionError(error_msg)
        
        self.builtin.log('✓ All field types match expected types', 'INFO')
        return True
    
    @staticmethod
    def _get_json_type(value):
        """Map Python type to JSON schema type."""
        if isinstance(value, bool):
            return 'boolean'
        elif isinstance(value, int):
            return 'integer'
        elif isinstance(value, float):
            return 'number'
        elif isinstance(value, str):
            return 'string'
        elif isinstance(value, list):
            return 'array'
        elif isinstance(value, dict):
            return 'object'
        elif value is None:
            return 'null'
        else:
            return 'unknown'
