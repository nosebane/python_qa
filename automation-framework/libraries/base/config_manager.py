"""
Configuration Manager for loading environment and test data configurations
Supports hybrid approach: YAML + .env files for configuration and secrets
"""

import yaml
import os
from pathlib import Path
from typing import Dict, Any, Optional
import logging


class ConfigManager:
    """
    Manages configuration loading and access with hybrid YAML + .env approach
    
    Features:
    - Load .env files for secrets (dev, staging, production)
    - Load YAML configuration files
    - Environment variable substitution
    - Configuration caching
    - Type-safe access
    
    Hybrid Approach:
    1. .env files store secrets (passwords, tokens, API keys)
    2. YAML files store non-secret configuration with ${VAR} references
    3. ConfigManager loads .env first, then resolves YAML variables
    """
    
    # Cache for loaded configurations
    _config_cache: Dict[str, Any] = {}
    _env_loaded: Dict[str, bool] = {}
    
    def __init__(self, config_dir: Optional[Path] = None, env_file: Optional[str] = None):
        """
        Initialize Config Manager

        Args:
            config_dir: Path to config directory (defaults to automation-framework/).
                       Accepts str or Path — will be coerced to Path.
            env_file: .env file to load (e.g., '.env.dev', '.env.staging')
                     If None, loads from TEST_ENV variable or .env.dev
        """
        if config_dir is None:
            # __file__ = automation-framework/libraries/base/config_manager.py
            # .parent   = automation-framework/libraries/base/
            # .parent   = automation-framework/libraries/
            # .parent   = automation-framework/   ← correct root
            config_dir = Path(__file__).parent.parent.parent
        else:
            config_dir = Path(config_dir)

        self.config_dir = config_dir
        self.base_dir = self.config_dir
        self.env_config_dir = self.base_dir / "config" / "environments"
        
        self.logger = logging.getLogger(self.__class__.__name__)
        
        if not self.config_dir.exists():
            raise FileNotFoundError(f"Config directory not found: {self.config_dir}")
        
        # Determine which .env file to load
        if env_file is None:
            env_file = os.getenv('TEST_ENV', 'dev')
            env_file = f".env.{env_file}"
        
        # Load .env file if not already loaded
        self._load_env_file(env_file)
        
        self.logger.info(f"ConfigManager initialized with config_dir: {self.config_dir}")
    
    def _load_env_file(self, env_file: str) -> None:
        """
        Load environment variables from .env file
        
        Args:
            env_file: .env filename (e.g., '.env.dev', '.env.staging')
        """
        if env_file in self._env_loaded:
            return
        
        env_path = self.base_dir / env_file
        
        if not env_path.exists():
            self.logger.warning(f".env file not found: {env_path}")
            return
        
        try:
            with open(env_path, 'r') as f:
                for line in f:
                    line = line.strip()
                    # Skip comments and empty lines
                    if not line or line.startswith('#'):
                        continue
                    
                    # Parse KEY=VALUE
                    if '=' in line:
                        key, value = line.split('=', 1)
                        key = key.strip()
                        value = value.strip()
                        
                        # Only set if not already in environment
                        if key not in os.environ:
                            os.environ[key] = value
                            self.logger.debug(f"Loaded from {env_file}: {key}")
            
            self._env_loaded[env_file] = True
            self.logger.info(f"Loaded environment file: {env_file}")
        
        except Exception as e:
            self.logger.error(f"Error loading .env file {env_file}: {e}")
    
    def _substitute_env_vars(self, value: Any) -> Any:
        """
        Recursively substitute environment variables in configuration
        
        Supports ${ENV_VAR} or ${ENV_VAR:default_value} syntax
        
        Args:
            value: Configuration value
            
        Returns:
            Value with substituted environment variables
        """
        if isinstance(value, str):
            # Pattern: ${ENV_VAR} or ${ENV_VAR:default}
            import re
            
            def replace_env_var(match):
                env_var = match.group(1)
                
                # Check for default value
                if ':' in env_var:
                    var_name, default_val = env_var.split(':', 1)
                    return os.getenv(var_name, default_val)
                else:
                    env_value = os.getenv(env_var)
                    if env_value is None:
                        self.logger.warning(f"Environment variable not found: {env_var}")
                    return env_value or f"${{{env_var}}}"
            
            return re.sub(r'\$\{([^}]+)\}', replace_env_var, value)
        
        elif isinstance(value, dict):
            return {k: self._substitute_env_vars(v) for k, v in value.items()}
        
        elif isinstance(value, list):
            return [self._substitute_env_vars(item) for item in value]
        
        return value
    
    def load_config(self, config_file: str) -> Dict[str, Any]:
        """
        Load configuration from YAML file
        
        Args:
            config_file: Configuration filename (without .yaml)
                        e.g., 'dev', 'staging', 'api_test_data'
            
        Returns:
            Loaded configuration dictionary
            
        Raises:
            FileNotFoundError: If config file not found
        """
        # Check cache first
        if config_file in self._config_cache:
            self.logger.debug(f"Returning cached config: {config_file}")
            return self._config_cache[config_file]
        
        # Build config path
        config_path = self._find_config_file(config_file)
        
        if not config_path.exists():
            raise FileNotFoundError(f"Config file not found: {config_file}")
        
        # Load YAML
        try:
            with open(config_path, 'r', encoding='utf-8') as f:
                config = yaml.safe_load(f) or {}
        except yaml.YAMLError as e:
            raise ValueError(f"Invalid YAML in {config_file}: {str(e)}")
        
        # Substitute environment variables
        config = self._substitute_env_vars(config)
        
        # Cache the configuration
        self._config_cache[config_file] = config
        
        self.logger.info(f"Configuration loaded: {config_file}")
        return config
    
    def _find_config_file(self, config_file: str) -> Path:
        """
        Find config file in config directory structure.

        Search order:
          1. <config_dir>/<file>.yaml
          2. <config_dir>/config/environments/<file>.yaml   ← primary env configs
          3. <config_dir>/config/test_data/<file>.yaml
          4. <config_dir>/config/devices/<file>.yaml
          5. <config_dir>/environments/<file>.yaml          ← legacy fallback
          6. <config_dir>/test_data/<file>.yaml
          7. <config_dir>/devices/<file>.yaml
        """
        # Exact match at root
        exact_path = self.config_dir / f"{config_file}.yaml"
        if exact_path.exists():
            return exact_path

        # Search under config/ subdirectory first (matches actual project layout)
        for subdir in ['config/environments', 'config/test_data', 'config/devices',
                       'environments', 'test_data', 'devices']:
            candidate = self.config_dir / subdir / f"{config_file}.yaml"
            if candidate.exists():
                return candidate

        # Return default path for error message
        return exact_path
    
    def get_environment_config(self, env: str = None) -> Dict[str, Any]:
        """
        Get environment-specific configuration
        
        Args:
            env: Environment name (dev, staging, production)
                If None, uses TEST_ENV environment variable
            
        Returns:
            Environment configuration
        """
        if env is None:
            env = os.getenv('TEST_ENV', 'dev')
        
        self.logger.debug(f"Loading environment config for: {env}")
        return self.load_config(env)
    
    def get(self, key: str, config: Dict[str, Any], default: Any = None) -> Any:
        """
        Get value from configuration with dot notation
        
        Args:
            key: Configuration key (supports dot notation: 'api.base_url')
            config: Configuration dictionary
            default: Default value if key not found
            
        Returns:
            Configuration value
        """
        keys = key.split('.')
        value = config
        
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return default
        
        return value
    
    def clear_cache(self) -> None:
        """Clear configuration cache"""
        self._config_cache.clear()
        self.logger.debug("Configuration cache cleared")


# Global config manager instance
_config_manager = None


def get_config_manager(config_dir: Optional[Path] = None) -> ConfigManager:
    """Get or create global ConfigManager instance"""
    global _config_manager
    
    if _config_manager is None:
        _config_manager = ConfigManager(config_dir)
    
    return _config_manager


def load_config(config_file: str) -> Dict[str, Any]:
    """Load configuration using global ConfigManager"""
    return get_config_manager().load_config(config_file)


def get_environment_config(env: str = None) -> Dict[str, Any]:
    """Get environment config using global ConfigManager"""
    return get_config_manager().get_environment_config(env)
