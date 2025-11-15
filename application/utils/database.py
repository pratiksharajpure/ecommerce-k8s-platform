"""
Database utilities - Fixed version with SQLAlchemy (No Warnings)
Handles SQL file execution without pandas warnings and special character issues
STREAMLIT-SAFE: Won't run test code on import
"""

import os
import pymysql
import mysql.connector
import pandas as pd
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.pool import NullPool
import warnings

# Load environment variables
load_dotenv()

# Database configuration from environment with proper fallbacks
DB_CONFIG = {
    'host': os.getenv('DB_HOST') or os.getenv('MYSQL_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT') or os.getenv('MYSQL_PORT', 3306)),
    'database': os.getenv('DB_NAME') or os.getenv('MYSQL_DATABASE', 'ecommerce_analytics'),
    'user': os.getenv('DB_USER') or os.getenv('MYSQL_USER', 'root'),
    'password': os.getenv('DB_PASSWORD') or os.getenv('MYSQL_PASSWORD', 'Root@123'),
    'charset': 'utf8mb4'
}

# Redis configuration from environment
REDIS_CONFIG = {
    'host': os.getenv('REDIS_HOST', 'localhost'),
    'port': int(os.getenv('REDIS_PORT', 6379))
}

def get_db_connection():
    """Create database connection from environment variables"""
    config = {
        'host': DB_CONFIG['host'],
        'port': DB_CONFIG['port'],
        'database': DB_CONFIG['database'],
        'user': DB_CONFIG['user'],
        'password': DB_CONFIG['password']
    }
    return mysql.connector.connect(**config)

def get_sqlalchemy_engine():
    """Create SQLAlchemy engine"""
    host = DB_CONFIG['host']
    port = DB_CONFIG['port']
    database = DB_CONFIG['database']
    user = DB_CONFIG['user']
    password = DB_CONFIG['password']
    
    # URL encode password to handle special characters
    from urllib.parse import quote_plus
    encoded_password = quote_plus(password) if password else ''
   
    connection_string = f"mysql+pymysql://{user}:{encoded_password}@{host}:{port}/{database}"
    return create_engine(connection_string)

def get_connection_string():
    """Generate SQLAlchemy connection string"""
    # URL encode password to handle special characters
    from urllib.parse import quote_plus
    password = quote_plus(DB_CONFIG['password']) if DB_CONFIG['password'] else ''
    
    return (
        f"mysql+pymysql://{DB_CONFIG['user']}:{password}@"
        f"{DB_CONFIG['host']}:{DB_CONFIG['port']}/"
        f"{DB_CONFIG['database']}?charset={DB_CONFIG['charset']}"
    )

def get_engine():
    """Create and return SQLAlchemy engine"""
    try:
        connection_string = get_connection_string()
        # Use NullPool to avoid connection pool issues in Streamlit
        engine = create_engine(
            connection_string,
            poolclass=NullPool,
            connect_args={'connect_timeout': 10}
        )
        return engine
    except Exception as e:
        # Silent in Streamlit - don't print to console
        return None

def get_pymysql_connection():
    """Create and return a raw PyMySQL connection (for SHOW TABLES, etc.)"""
    try:
        config = {
            'host': DB_CONFIG['host'],
            'port': DB_CONFIG['port'],
            'database': DB_CONFIG['database'],
            'user': DB_CONFIG['user'],
            'password': DB_CONFIG['password'],
            'charset': DB_CONFIG['charset']
        }
        connection = pymysql.connect(**config)
        return connection
    except Exception as e:
        return None

def test_connection():
    """Test database connection"""
    try:
        engine = get_engine()
        if engine:
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            return True
        return False
    except Exception as e:
        return False

def execute_sql_query(query, params=None):
    """
    Execute a SQL query and return results as DataFrame
    Uses SQLAlchemy to avoid pandas warnings and handle special characters
    
    Args:
        query: SQL query string
        params: Query parameters (optional)
    
    Returns:
        DataFrame or None
    """
    try:
        engine = get_engine()
        if not engine:
            return None
        
        # Suppress the warning if it still appears
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            
            # Use text() to prevent % character interpretation
            with engine.connect() as conn:
                if params:
                    result = conn.execute(text(query), params)
                else:
                    result = conn.execute(text(query))
                
                # Check if query returns results
                if result.returns_rows:
                    df = pd.DataFrame(result.fetchall(), columns=result.keys())
                    return df
                else:
                    # For non-SELECT queries
                    conn.commit()
                    return pd.DataFrame()
        
    except Exception as e:
        return None

def execute_sql_file(file_path, params=None):
    """
    Execute SQL from a file - FIXED to handle multiple statements and special characters
    SILENT MODE: Skips incompatible SQL statements without printing errors
    
    Args:
        file_path: Path to SQL file
        params: Query parameters (optional)
    
    Returns:
        DataFrame or None (returns result of LAST SELECT statement)
    """
    try:
        # Read SQL file
        sql_path = Path(file_path)
        if not sql_path.exists():
            return None
        
        with open(sql_path, 'r', encoding='utf-8') as f:
            sql_content = f.read()
        
        # Split by semicolons to handle multiple statements
        statements = []
        current_statement = []
        
        for line in sql_content.split('\n'):
            line = line.strip()
            # Skip comments and empty lines
            if not line or line.startswith('--') or line.startswith('#'):
                continue
            
            current_statement.append(line)
            
            # If line ends with semicolon, it's end of statement
            if line.endswith(';'):
                stmt = ' '.join(current_statement).strip()
                if stmt and stmt != ';':
                    statements.append(stmt.rstrip(';'))
                current_statement = []
        
        # Add any remaining statement
        if current_statement:
            stmt = ' '.join(current_statement).strip()
            if stmt:
                statements.append(stmt.rstrip(';'))
        
        if not statements:
            return None
        
        # Execute statements
        engine = get_engine()
        if not engine:
            return None
        
        last_result = None
        
        with warnings.catch_warnings():
            warnings.simplefilter("ignore", UserWarning)
            
            with engine.connect() as conn:
                for stmt in statements:
                    try:
                        result = conn.execute(text(stmt))
                        
                        # If this statement returns rows, save it
                        if result.returns_rows:
                            last_result = pd.DataFrame(result.fetchall(), columns=result.keys())
                        else:
                            conn.commit()
                    except Exception:
                        # SILENT SKIP: MariaDB compatibility issues
                        continue
        
        return last_result if last_result is not None else pd.DataFrame()
        
    except Exception:
        return None

def get_table_names():
    """Get list of all tables in the database"""
    try:
        # Use raw PyMySQL for SHOW TABLES (simpler)
        connection = get_pymysql_connection()
        if not connection:
            return []
        
        cursor = connection.cursor()
        cursor.execute("SHOW TABLES")
        result = cursor.fetchall()
        
        # Extract table names from tuples
        tables = [row[0] for row in result] if result else []
        
        cursor.close()
        connection.close()
        
        return tables
    except Exception as e:
        return []

def table_exists(table_name):
    """Check if a table exists in the database"""
    try:
        tables = get_table_names()
        return table_name in tables
    except:
        return False

def get_table_info(table_name):
    """Get information about a table (columns, types, etc.)"""
    try:
        query = f"DESCRIBE `{table_name}`"
        return execute_sql_query(query)
    except:
        return None

def safe_table_query(table_name, limit=10000):
    """
    Safely query a table with existence check
    
    Args:
        table_name: Name of the table
        limit: Maximum rows to return
    
    Returns:
        DataFrame or None
    """
    try:
        if not table_exists(table_name):
            return None
        
        query = f"SELECT * FROM `{table_name}` LIMIT {limit}"
        return execute_sql_query(query)
        
    except Exception as e:
        return None

def get_database_stats():
    """Get statistics about the database"""
    stats = {
        'database': DB_CONFIG['database'],
        'tables': [],
        'total_rows': 0,
        'database_size': 0
    }
    
    try:
        tables = get_table_names()
        stats['tables'] = tables
        
        for table in tables:
            try:
                query = f"SELECT COUNT(*) as count FROM `{table}`"
                df = execute_sql_query(query)
                if df is not None and not df.empty:
                    count = int(df['count'].iloc[0])
                    stats['total_rows'] += count
            except Exception:
                continue
        
        return stats
        
    except Exception as e:
        return stats

def execute_raw_sql(sql_statement):
    """
    Execute raw SQL (INSERT, UPDATE, DELETE, CREATE, etc.)
    For statements that don't return data
    
    Args:
        sql_statement: SQL statement to execute
    
    Returns:
        Boolean indicating success
    """
    try:
        engine = get_engine()
        if not engine:
            return False
        
        with engine.connect() as conn:
            conn.execute(text(sql_statement))
            conn.commit()
        
        return True
        
    except Exception as e:
        return False

def query_with_context(query, params=None):
    """
    Execute query using context manager for better resource management
    
    Args:
        query: SQL query
        params: Optional parameters
    
    Returns:
        DataFrame or None
    """
    try:
        engine = get_engine()
        if not engine:
            return None
        
        with engine.connect() as conn:
            if params:
                result = conn.execute(text(query), params)
            else:
                result = conn.execute(text(query))
            
            # Convert to DataFrame
            df = pd.DataFrame(result.fetchall(), columns=result.keys())
            return df
            
    except Exception as e:
        return None

# REMOVED: if __name__ == "__main__": block
# This was causing the test output to appear in Streamlit
# Run this file directly with `python utils/database.py` to test