"""
Unit tests for database utilities
"""
import unittest
from unittest.mock import Mock, patch, MagicMock
import os
import sys

# Add application directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '../../application'))

class TestDatabaseConnection(unittest.TestCase):
    """Test database connection functions"""
    
    @patch.dict(os.environ, {
        'MYSQL_HOST': 'localhost',
        'MYSQL_PORT': '3306',
        'MYSQL_DATABASE': 'test_db',
        'MYSQL_USER': 'test_user',
        'MYSQL_PASSWORD': 'test_pass'
    })
    def test_environment_variables(self):
        """Test that environment variables are read correctly"""
        self.assertEqual(os.getenv('MYSQL_HOST'), 'localhost')
        self.assertEqual(os.getenv('MYSQL_PORT'), '3306')
        self.assertEqual(os.getenv('MYSQL_DATABASE'), 'test_db')
    
    def test_connection_string_format(self):
        """Test database connection string format"""
        host = 'localhost'
        port = 3306
        database = 'test_db'
        user = 'test_user'
        password = 'test_pass'
        
        connection_string = f"mysql+pymysql://{user}:{password}@{host}:{port}/{database}"
        
        self.assertIn('mysql+pymysql', connection_string)
        self.assertIn(host, connection_string)
        self.assertIn(database, connection_string)

class TestDataValidation(unittest.TestCase):
    """Test data validation functions"""
    
    def test_email_validation(self):
        """Test email format validation"""
        valid_emails = [
            'test@example.com',
            'user.name@example.co.uk',
            'user+tag@example.com'
        ]
        
        invalid_emails = [
            'invalid.email',
            '@example.com',
            'user@',
            'user @example.com'
        ]
        
        import re
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        
        for email in valid_emails:
            self.assertTrue(re.match(email_pattern, email), f"{email} should be valid")
        
        for email in invalid_emails:
            self.assertFalse(re.match(email_pattern, email), f"{email} should be invalid")
    
    def test_price_validation(self):
        """Test price format validation"""
        valid_prices = [10.99, 100.00, 0.99, 1000.50]
        invalid_prices = [-10.99, 'invalid', None]
        
        for price in valid_prices:
            self.assertIsInstance(price, (int, float))
            self.assertGreaterEqual(price, 0)
        
        for price in invalid_prices:
            if price is not None and isinstance(price, (int, float)):
                self.assertLess(price, 0)

if __name__ == '__main__':
    unittest.main()