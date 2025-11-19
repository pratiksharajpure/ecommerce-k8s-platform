"""
Unit tests for configuration
"""
import unittest
import os

class TestConfiguration(unittest.TestCase):
    """Test configuration settings"""
    
    def test_required_env_vars(self):
        """Test that required environment variables can be set"""
        required_vars = [
            'MYSQL_HOST',
            'MYSQL_PORT',
            'MYSQL_DATABASE',
            'MYSQL_USER',
            'MYSQL_PASSWORD'
        ]
        
        # Test setting environment variables
        for var in required_vars:
            os.environ[var] = f'test_{var.lower()}'
            self.assertIsNotNone(os.getenv(var))
    
    def test_default_values(self):
        """Test default configuration values"""
        # Clear environment
        for key in list(os.environ.keys()):
            if key.startswith('MYSQL_'):
                del os.environ[key]
        
        # Test defaults
        default_host = os.getenv('MYSQL_HOST', 'localhost')
        default_port = os.getenv('MYSQL_PORT', '3306')
        
        self.assertEqual(default_host, 'localhost')
        self.assertEqual(default_port, '3306')

if __name__ == '__main__':
    unittest.main()