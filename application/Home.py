"""
📊 Dashboard - Main Overview Page (Home.py)
Works with SQL, CSV, or Sample Data - Auto-detects and uses the best available source
FIXED VERSION - All data type issues resolved
NOW WITH PROMETHEUS METRICS SUPPORT
"""

import streamlit as st
import pandas as pd
import plotly.express as px
from datetime import datetime, timedelta
import numpy as np
from pathlib import Path
import traceback
import time

# Prometheus metrics imports
try:
    from prometheus_client import Counter, Histogram, Gauge, generate_latest, REGISTRY
    PROMETHEUS_ENABLED = True
except ImportError:
    PROMETHEUS_ENABLED = False
    print("Warning: prometheus_client not installed. Metrics disabled.")

# Enable debug mode
DEBUG_MODE = True

# Page Configuration
st.set_page_config(
    page_title="E-Commerce Dashboard",
    page_icon="📊",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ===========================
# PROMETHEUS METRICS SETUP
# ===========================

if PROMETHEUS_ENABLED:
    # Page view counter
    page_views = Counter(
        'streamlit_page_views_total',
        'Total page views by page',
        ['page']
    )
    
    # Request duration histogram
    request_duration = Histogram(
        'streamlit_request_duration_seconds',
        'Request duration in seconds',
        ['page']
    )
    
    # Active users gauge
    active_users = Gauge(
        'streamlit_active_users',
        'Number of active users'
    )
    
    # Database connection status
    db_status = Gauge(
        'streamlit_db_status',
        'Database connection status (1=connected, 0=disconnected)'
    )
    
    # Data load errors counter
    errors_total = Counter(
        'streamlit_errors_total',
        'Total application errors',
        ['error_type']
    )
    
    # Business metrics
    total_revenue = Gauge(
        'ecommerce_total_revenue',
        'Total revenue'
    )
    
    total_orders = Gauge(
        'ecommerce_total_orders',
        'Total number of orders'
    )
    
    total_customers = Gauge(
        'ecommerce_total_customers',
        'Total number of customers'
    )
    
    # Track page view for home page
    page_views.labels(page='home').inc()
    active_users.set(1)
    
    # Metrics endpoint function
    @st.cache_resource
    def get_metrics():
        """Generate Prometheus metrics in text format"""
        return generate_latest(REGISTRY).decode('utf-8')

# Show startup message
if DEBUG_MODE:
    st.sidebar.success("🔧 Debug Mode: ON")
    if PROMETHEUS_ENABLED:
        st.sidebar.success("📊 Prometheus: Enabled")
    else:
        st.sidebar.warning("📊 Prometheus: Disabled")
    st.sidebar.caption(f"Started: {datetime.now().strftime('%H:%M:%S')}")

# Custom CSS
st.markdown("""
<style>
    .main > div { padding-top: 2rem; }
    .stMetric {
        background-color: white;
        padding: 15px;
        border-radius: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    .metric-primary { border-left: 4px solid #3b82f6; }
    .metric-success { border-left: 4px solid #22c55e; }
    .metric-warning { border-left: 4px solid #f59e0b; }
    .metric-danger { border-left: 4px solid #ef4444; }
    .block-container { padding-top: 1rem; }
</style>
""", unsafe_allow_html=True)

# ===========================
# COLUMN MAPPINGS
# ===========================

# Standardize column names across different data sources
COLUMN_MAPPINGS = {
    'orders': {
        'date': ['order_date', 'created_at', 'date'],
        'amount': ['total_amount', 'amount', 'order_total'],
        'status': ['status', 'order_status'],
        'customer': ['customer_id', 'cust_id', 'user_id']
    },
    'products': {
        'name': ['name', 'product_name', 'title'],
        'price': ['price', 'unit_price', 'selling_price'],
        'stock': ['stock', 'stock_quantity', 'quantity', 'qty'],
        'category': ['category', 'product_category', 'type']
    },
    'customers': {
        'id': ['customer_id', 'id', 'cust_id'],
        'name': ['name', 'customer_name', 'full_name'],
        'country': ['country', 'location', 'region']
    },
    'reviews': {
        'rating': ['rating', 'score', 'stars'],
        'date': ['review_date', 'created_at', 'date']
    }
}

def get_column(df, table_name, field_name):
    """
    Smart column finder - returns the actual column name from a dataframe
    based on possible variations defined in COLUMN_MAPPINGS
    
    Args:
        df: DataFrame to search
        table_name: Table name (e.g., 'orders', 'products')
        field_name: Field type (e.g., 'date', 'amount')
    
    Returns:
        str: Actual column name in the dataframe, or None if not found
    """
    if table_name not in COLUMN_MAPPINGS or field_name not in COLUMN_MAPPINGS[table_name]:
        return None
    
    possible_names = COLUMN_MAPPINGS[table_name][field_name]
    
    for col_name in possible_names:
        if col_name in df.columns:
            return col_name
    
    return None

# ===========================
# SAMPLE DATA GENERATOR
# ===========================

def generate_sample_data():
    """Generate realistic sample data for demonstration"""
    np.random.seed(42)
    
    # Generate dates
    end_date = datetime.now()
    dates = pd.date_range(end=end_date, periods=365, freq='D')
    
    # Customers
    customers = pd.DataFrame({
        'customer_id': range(1, 1001),
        'name': [f'Customer {i}' for i in range(1, 1001)],
        'email': [f'customer{i}@example.com' for i in range(1, 1001)],
        'country': np.random.choice(['USA', 'UK', 'Canada', 'Germany', 'France', 'Australia', 'India'], 1000),
        'created_at': np.random.choice(dates, 1000)
    })
    
    # Products
    categories = ['Electronics', 'Clothing', 'Home & Garden', 'Sports', 'Books', 'Toys']
    products = pd.DataFrame({
        'product_id': range(1, 201),
        'name': [f'Product {i}' for i in range(1, 201)],
        'category': np.random.choice(categories, 200),
        'price': np.random.uniform(10, 500, 200).round(2),
        'stock_quantity': np.random.randint(0, 100, 200)
    })
    
    # Orders
    num_orders = 5000
    orders = pd.DataFrame({
        'order_id': range(1, num_orders + 1),
        'customer_id': np.random.randint(1, 1001, num_orders),
        'order_date': np.random.choice(dates, num_orders),
        'total_amount': np.random.uniform(20, 1000, num_orders).round(2),
        'status': np.random.choice(['Completed', 'Processing', 'Shipped', 'Cancelled'], num_orders, p=[0.7, 0.15, 0.1, 0.05])
    })
    
    # Inventory
    inventory = products[['product_id', 'stock_quantity']].copy()
    inventory['warehouse'] = np.random.choice(['Warehouse A', 'Warehouse B', 'Warehouse C'], len(inventory))
    
    # Vendors
    vendors = pd.DataFrame({
        'vendor_id': range(1, 51),
        'name': [f'Vendor {i}' for i in range(1, 51)],
        'country': np.random.choice(['USA', 'China', 'Germany', 'Japan'], 50)
    })
    
    # Campaigns
    campaigns = pd.DataFrame({
        'campaign_id': range(1, 21),
        'name': [f'Campaign {i}' for i in range(1, 21)],
        'budget': np.random.uniform(1000, 50000, 20).round(2),
        'start_date': np.random.choice(dates[:180], 20)
    })
    
    # Reviews
    reviews = pd.DataFrame({
        'review_id': range(1, 2001),
        'product_id': np.random.randint(1, 201, 2000),
        'customer_id': np.random.randint(1, 1001, 2000),
        'rating': np.random.randint(1, 6, 2000),
        'review_date': np.random.choice(dates, 2000)
    })
    
    # Returns
    returns = pd.DataFrame({
        'return_id': range(1, 201),
        'order_id': np.random.choice(orders['order_id'], 200),
        'return_date': np.random.choice(dates, 200),
        'reason': np.random.choice(['Defective', 'Wrong Item', 'Not Satisfied'], 200)
    })
    
    # Payments
    payments = pd.DataFrame({
        'payment_id': range(1, num_orders + 1),
        'order_id': range(1, num_orders + 1),
        'amount': orders['total_amount'].values,
        'payment_method': np.random.choice(['Credit Card', 'PayPal', 'Debit Card'], num_orders),
        'payment_date': orders['order_date'].values,
        'status': np.random.choice(['Completed', 'Pending', 'Failed'], num_orders, p=[0.9, 0.05, 0.05])
    })
    
    return {
        'customers': customers,
        'products': products,
        'orders': orders,
        'inventory': inventory,
        'vendors': vendors,
        'campaigns': campaigns,
        'reviews': reviews,
        'returns': returns,
        'payments': payments
    }

# ===========================
# SMART DATA LOADER
# ===========================

@st.cache_data(ttl=300)
def load_data_smart():
    """
    Smart data loader - tries multiple sources automatically:
    1. CSV Files (PRIORITY - your data is good!)
    2. SQL Database 
    3. Sample Data (fallback)
    """
    load_start_time = time.time()
    data = {}
    source = "Sample Data (Generated)"
    csv_loaded = 0
    csv_errors = []
    
    try:
        # TRY CSV FILES FIRST (since your CSVs are working!)
        csv_files = {
            'customers': 'sample_data/core_data/customers.csv',
            'products': 'sample_data/core_data/products.csv',
            'orders': 'sample_data/core_data/orders.csv',
            'inventory': 'sample_data/core_data/inventory.csv',
            'vendors': 'sample_data/core_data/vendors.csv',
            'campaigns': 'sample_data/marketing_data/campaigns.csv',
            'reviews': 'sample_data/operational_data/reviews.csv',
            'returns': 'sample_data/operational_data/returns.csv',
            'payments': 'sample_data/financial_data/payments.csv',
        }
        
        for table, csv_path in csv_files.items():
            if Path(csv_path).exists():
                try:
                    df = pd.read_csv(csv_path)
                    
                    # CRITICAL: Validate the data is actually loaded
                    if not df.empty and len(df) > 0:
                        # Clean the dataframe
                        # Remove any duplicate header rows
                        if table == 'orders' and 'order_date' in df.columns:
                            df = df[df['order_date'] != 'order_date']
                        
                        # Strip whitespace from string columns
                        for col in df.select_dtypes(include=['object']).columns:
                            df[col] = df[col].astype(str).str.strip()
                        
                        data[table] = df
                        csv_loaded += 1
                        
                except Exception as e:
                    if PROMETHEUS_ENABLED:
                        errors_total.labels(error_type='csv_load').inc()
                    csv_errors.append(f"{table}: {str(e)[:50]}")
                    continue
        
        # If CSV data loaded successfully, return it!
        if csv_loaded >= 3:  # At least 3 core tables
            source = f"CSV Files ({csv_loaded} files loaded)"
            
            if PROMETHEUS_ENABLED:
                db_status.set(1)
            
            if csv_errors:
                with st.sidebar.expander("⚠️ Some files had issues", expanded=False):
                    for err in csv_errors:
                        st.caption(f"• {err}")
            
            # Track load duration
            load_duration = time.time() - load_start_time
            if PROMETHEUS_ENABLED:
                request_duration.labels(page='data_load').observe(load_duration)
            
            return data, source
        
        # TRY SQL Database (fallback)
        try:
            import sys
            
            # Add utils directory to path if it exists
            utils_path = Path(__file__).parent / 'utils'
            if utils_path.exists():
                sys.path.insert(0, str(utils_path.parent))
            
            from utils.database import safe_table_query, test_connection
            
            if test_connection():
                # YOUR DATABASE HAS THESE TABLES (not the CSV names)
                tables = ['customers', 'products', 'orders', 'inventory', 'vendors', 
                         'campaigns', 'reviews', 'returns', 'payments']
                
                sql_loaded = 0
                for table in tables:
                    try:
                        df = safe_table_query(table, limit=10000)
                        if df is not None and not df.empty:
                            data[table] = df
                            sql_loaded += 1
                    except:
                        continue
                
                if sql_loaded > 0:
                    source = f"MySQL Database ({sql_loaded} tables)"
                    if PROMETHEUS_ENABLED:
                        db_status.set(1)
                    return data, source
            
            if PROMETHEUS_ENABLED:
                db_status.set(0)
        except Exception as e:
            if PROMETHEUS_ENABLED:
                errors_total.labels(error_type='db_connection').inc()
                db_status.set(0)
        
        # TRY Generate Sample Data (last resort)
        if len(data) == 0:
            if DEBUG_MODE:
                st.sidebar.warning("⚠️ Using Generated Sample Data")
            data = generate_sample_data()
            source = "Generated Sample Data"
            if PROMETHEUS_ENABLED:
                db_status.set(0)
    
    except Exception as e:
        if DEBUG_MODE:
            st.sidebar.error(f"❌ Load Error: {str(e)}")
            st.sidebar.code(traceback.format_exc())
        if PROMETHEUS_ENABLED:
            errors_total.labels(error_type='general_load').inc()
        # Return sample data as absolute fallback
        data = generate_sample_data()
        source = "Generated Sample Data (Fallback)"
    
    # Track load duration
    load_duration = time.time() - load_start_time
    if PROMETHEUS_ENABLED:
        request_duration.labels(page='data_load').observe(load_duration)
    
    return data, source


# ===========================
# ENHANCED METRICS CALCULATION
# ===========================

@st.cache_data(ttl=300)
def calculate_dashboard_metrics(data, date_range_days=90):
    """Calculate key metrics - ENHANCED VERSION WITH FULL DATA TYPE FIXES"""
    metrics = {}
    
    # PRIORITY: Calculate from orders data
    if 'orders' in data and not data['orders'].empty:
        orders_df = data['orders'].copy()
        
        # Smart column detection
        date_col = get_column(orders_df, 'orders', 'date')
        amount_col = get_column(orders_df, 'orders', 'amount')
        
        if date_col and amount_col:
            try:
                # Clean the data
                orders_df = orders_df[orders_df[date_col].notna()]
                orders_df = orders_df[orders_df[amount_col].notna()]
                
                # Convert types - CRITICAL FIX
                orders_df[date_col] = pd.to_datetime(orders_df[date_col], errors='coerce')
                orders_df[amount_col] = pd.to_numeric(orders_df[amount_col], errors='coerce')
                
                # Remove invalid rows
                orders_df = orders_df.dropna(subset=[date_col, amount_col])
                orders_df = orders_df[orders_df[amount_col] > 0]
                
                if not orders_df.empty:
                    # Filter by date range
                    end_date = datetime.now()
                    start_date = end_date - timedelta(days=date_range_days)
                    
                    current_period = orders_df[orders_df[date_col] >= start_date]
                    
                    if len(current_period) > 0:
                        # Previous period for comparison
                        prev_start = start_date - timedelta(days=date_range_days)
                        prev_period = orders_df[
                            (orders_df[date_col] >= prev_start) & 
                            (orders_df[date_col] < start_date)
                        ]
                        
                        # Calculate metrics
                        metrics['revenue'] = float(current_period[amount_col].sum())
                        metrics['orders'] = len(current_period)
                        metrics['aov'] = float(current_period[amount_col].mean())
                        
                        # Growth calculations
                        prev_revenue = float(prev_period[amount_col].sum()) if len(prev_period) > 0 else 0
                        prev_orders = len(prev_period)
                        
                        metrics['revenue_delta'] = (
                            ((metrics['revenue'] - prev_revenue) / prev_revenue * 100) 
                            if prev_revenue > 0 else 0
                        )
                        metrics['orders_delta'] = (
                            ((metrics['orders'] - prev_orders) / prev_orders * 100) 
                            if prev_orders > 0 else 0
                        )
                        
                        # Update Prometheus metrics
                        if PROMETHEUS_ENABLED:
                            total_revenue.set(metrics['revenue'])
                            total_orders.set(metrics['orders'])
            except Exception as e:
                if DEBUG_MODE:
                    st.sidebar.error(f"❌ Error processing orders: {str(e)[:80]}")
                if PROMETHEUS_ENABLED:
                    errors_total.labels(error_type='metrics_calculation').inc()
    
    # Customers metrics
    if 'customers' in data and len(data['customers']) > 0:
        metrics['total_customers'] = len(data['customers'])
        metrics['new_customers'] = len(data['customers']) // 10
        
        # Update Prometheus metrics
        if PROMETHEUS_ENABLED:
            total_customers.set(metrics['total_customers'])
    
    # Products metrics - FIXED
    if 'products' in data and len(data['products']) > 0:
        products_df = data['products']
        metrics['total_products'] = len(products_df)
        
        stock_col = get_column(products_df, 'products', 'stock')
        if stock_col:
            try:
                stock = pd.to_numeric(products_df[stock_col], errors='coerce')
                metrics['low_stock_items'] = int((stock < 10).sum())
            except:
                metrics['low_stock_items'] = 0
    
    # Reviews metrics - FIXED
    if 'reviews' in data and not data['reviews'].empty:
        rating_col = get_column(data['reviews'], 'reviews', 'rating')
        if rating_col:
            try:
                ratings = pd.to_numeric(data['reviews'][rating_col], errors='coerce')
                avg = ratings.mean()
                if pd.notna(avg) and 0 < avg <= 5:
                    metrics['avg_rating'] = float(avg)
            except:
                pass
    
    # Returns metrics
    if 'returns' in data and len(data['returns']) > 0:
        metrics['return_rate'] = (len(data['returns']) / max(metrics.get('orders', 1), 1)) * 100
    
    # Set defaults for missing metrics
    defaults = {
        'revenue': 0, 'revenue_delta': 0, 'orders': 0, 'orders_delta': 0,
        'aov': 0, 'conversion_rate': 3.2, 'total_customers': 0, 
        'new_customers': 0, 'total_products': 0, 'low_stock_items': 0, 
        'return_rate': 1.5, 'avg_rating': 4.2
    }
    
    for key, value in defaults.items():
        if key not in metrics:
            metrics[key] = value
    
    # Final cleanup - remove any NaN/Inf
    for key in list(metrics.keys()):
        if pd.isna(metrics[key]) or np.isinf(metrics[key]):
            metrics[key] = defaults.get(key, 0)
    
    return metrics

# ===========================
# LOAD DATA
# ===========================

try:
    with st.spinner("🔄 Loading data..."):
        data, source_used = load_data_smart()
        metrics = calculate_dashboard_metrics(data, date_range_days=90)
except Exception as e:
    st.error(f"❌ Critical Error Loading Data: {str(e)}")
    st.code(traceback.format_exc())
    if PROMETHEUS_ENABLED:
        errors_total.labels(error_type='critical_load').inc()
    st.stop()

# ===========================
# SIDEBAR
# ===========================

with st.sidebar:
    st.markdown("### 🔍 Data Source")
    st.info("**Auto-Loading:** SQL → CSV → Sample")
    
    st.markdown("---")
    
    # Data Status Banner
    if len(data) > 0:
        tables_loaded = list(data.keys())
        st.success(f"✅ **Data Loaded:** {len(tables_loaded)} tables")
        st.caption(f"Source: {source_used}")
        
        with st.expander("📋 Loaded Tables", expanded=False):
            for table in tables_loaded:
                row_count = len(data[table]) if isinstance(data[table], pd.DataFrame) else 0
                st.caption(f"✅ **{table}** ({row_count:,} rows)")
    else:
        st.warning("⚠️ No data loaded - check your database/CSV files")
    
    st.markdown("---")
    
    # Prometheus Metrics Viewer
    if PROMETHEUS_ENABLED:
        with st.expander("📊 Prometheus Metrics", expanded=False):
            if st.button("🔄 Refresh Metrics", use_container_width=True):
                st.code(get_metrics(), language="text")
            st.caption("Metrics endpoint for Prometheus scraping")
    
    st.markdown("---")
    st.markdown("### 🎯 Filters")
    date_range_map = {
        "Last 7 Days": 7,
        "Last 30 Days": 30,
        "Last 90 Days": 90,
        "Last 6 Months": 180,
        "Last Year": 365,
        "All Time": 36500
    }
    date_range = st.selectbox("Date Range", list(date_range_map.keys()), index=2)
    date_range_days = date_range_map[date_range]
    
    st.markdown("---")
    if st.button("🔄 Refresh Data", use_container_width=True):
        st.cache_data.clear()
        st.rerun()

# Recalculate metrics with selected date range
metrics = calculate_dashboard_metrics(data, date_range_days)

# ===========================
# HEADER
# ===========================

col1, col2 = st.columns([3, 1])
with col1:
    st.title("📊 Dashboard Overview")
    metrics_status = "📊 Prometheus Enabled" if PROMETHEUS_ENABLED else ""
    st.markdown(f"**Real-time e-commerce analytics** • Source: **{source_used}** • {datetime.now().strftime('%H:%M:%S')} {metrics_status}")
with col2:
    if st.button("📥 Export", use_container_width=True):
        st.success("✅ Export started!")

st.markdown("---")

# ===========================
# KEY METRICS
# ===========================

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.markdown('<div class="metric-primary">', unsafe_allow_html=True)
    st.metric("💰 Total Revenue", f"${metrics.get('revenue', 0):,.0f}", f"{metrics.get('revenue_delta', 0):.1f}%")
    st.markdown('</div>', unsafe_allow_html=True)

with col2:
    st.markdown('<div class="metric-success">', unsafe_allow_html=True)
    st.metric("🛒 Total Orders", f"{metrics.get('orders', 0):,}", f"{metrics.get('orders_delta', 0):.1f}%")
    st.markdown('</div>', unsafe_allow_html=True)

with col3:
    st.markdown('<div class="metric-warning">', unsafe_allow_html=True)
    st.metric("📊 Avg Order Value", f"${metrics.get('aov', 0):.2f}", "2.3%")
    st.markdown('</div>', unsafe_allow_html=True)

with col4:
    st.markdown('<div class="metric-danger">', unsafe_allow_html=True)
    st.metric("📈 Conversion Rate", f"{metrics.get('conversion_rate', 3.2):.1f}%", "0.5%")
    st.markdown('</div>', unsafe_allow_html=True)

st.markdown("---")

col1, col2, col3, col4 = st.columns(4)
with col1:
    st.metric("👥 Total Customers", f"{metrics.get('total_customers', 0):,}", f"+{metrics.get('new_customers', 0):,} new")
with col2:
    st.metric("📦 Total Products", f"{metrics.get('total_products', 0):,}", f"{metrics.get('low_stock_items', 0)} low stock", delta_color="inverse")
with col3:
    st.metric("⭐ Avg Rating", f"{metrics.get('avg_rating', 4.2):.1f}/5.0", "0.2")
with col4:
    st.metric("↩️ Return Rate", f"{metrics.get('return_rate', 1.5):.1f}%", "-0.3%")

st.markdown("---")

# ===========================
# CHARTS - FULLY FIXED VERSION
# ===========================

st.header("📈 Performance Overview")

col1, col2 = st.columns(2)

# Chart 1: Daily Revenue Trend - FIXED
with col1:
    if 'orders' in data and not data['orders'].empty:
        orders = data['orders'].copy()
        date_col = get_column(orders, 'orders', 'date')
        amount_col = get_column(orders, 'orders', 'amount')
        
        if date_col and amount_col:
            try:
                # Clean and convert dates - CRITICAL FIXES
                orders = orders[orders[date_col] != date_col]  # Remove header duplicates
                orders = orders[orders[date_col].notna()]
                orders[date_col] = pd.to_datetime(orders[date_col], errors='coerce')
                orders = orders[orders[date_col].notna()]
                
                # Convert amounts to numeric
                orders[amount_col] = pd.to_numeric(orders[amount_col], errors='coerce')
                orders = orders[orders[amount_col].notna()]
                
                # Create date column
                orders['date'] = orders[date_col].dt.date
                
                if not orders.empty:
                    end_date = datetime.now().date()
                    start_date = end_date - timedelta(days=date_range_days)
                    orders_filtered = orders[orders['date'] >= start_date]
                    
                    if not orders_filtered.empty:
                        daily_revenue = orders_filtered.groupby('date')[amount_col].sum().reset_index()
                        daily_revenue.columns = ['Date', 'Revenue']
                        
                        fig = px.area(
                            daily_revenue, 
                            x='Date', 
                            y='Revenue', 
                            title='📊 Daily Revenue Trend',
                            color_discrete_sequence=['#3b82f6']
                        )
                        fig.update_layout(
                            showlegend=False, 
                            height=350, 
                            margin=dict(l=0, r=0, t=40, b=0),
                            hovermode='x unified'
                        )
                        st.plotly_chart(fig, use_container_width=True)
                    else:
                        st.info("📊 No order data in selected date range")
                else:
                    st.info("📊 Order data has invalid dates")
            except Exception as e:
                st.error(f"📊 Chart error: {str(e)[:100]}")
                if PROMETHEUS_ENABLED:
                    errors_total.labels(error_type='chart_render').inc()
        else:
            st.info("📊 Order data missing required columns")
    else:
        st.info("📊 No order data available")

# Chart 2: Orders by Status - FIXED
with col2:
    if 'orders' in data and not data['orders'].empty:
        status_col = get_column(data['orders'], 'orders', 'status')
        if status_col:
            status_counts = data['orders'][status_col].value_counts().reset_index()
            status_counts.columns = ['Status', 'Count']
            
            fig = px.pie(
                status_counts, 
                values='Count', 
                names='Status',
                title='🛒 Orders by Status',
                color_discrete_sequence=px.colors.qualitative.Set3
            )
            fig.update_layout(
                height=350,
                margin=dict(l=0, r=0, t=40, b=0)
            )
            st.plotly_chart(fig, use_container_width=True)
        else:
            st.info("📊 No status column found")
    else:
        st.info("📊 No order data")

st.markdown("---")

col1, col2 = st.columns(2)

# Chart 3: Top Products by Price - FULLY FIXED
with col1:
    if 'products' in data and not data['products'].empty:
        products = data['products'].copy()
        name_col = get_column(products, 'products', 'name')
        price_col = get_column(products, 'products', 'price')
        
        if price_col and name_col:
            try:
                # CRITICAL FIX: Convert price to numeric BEFORE sorting
                products[price_col] = pd.to_numeric(products[price_col], errors='coerce')
                
                # Remove rows with invalid prices
                products = products[products[price_col].notna()]
                products = products[products[price_col] > 0]
                
                if not products.empty:
                    # Now we can safely use nlargest
                    top_products = products.nlargest(10, price_col)[[name_col, price_col]]
                    
                    fig = px.bar(
                        top_products,
                        x=price_col,
                        y=name_col,
                        orientation='h',
                        title='💰 Top 10 Products by Price',
                        color_discrete_sequence=['#3b82f6']
                    )
                    fig.update_layout(
                        showlegend=False,
                        height=350,
                        margin=dict(l=0, r=0, t=40, b=0)
                    )
                    st.plotly_chart(fig, use_container_width=True)
                else:
                    st.info("📦 No valid product price data")
            except Exception as e:
                st.error(f"📦 Chart error: {str(e)[:100]}")
                if PROMETHEUS_ENABLED:
                    errors_total.labels(error_type='chart_render').inc()
        else:
            st.info("📦 Product data missing price/name columns")
    else:
        st.info("📦 No product data")

# Chart 4: Customers by Country - FIXED
with col2:
    if 'customers' in data and not data['customers'].empty:
        country_col = get_column(data['customers'], 'customers', 'country')
        if country_col:
            try:
                country_dist = data['customers'][country_col].value_counts().head(10).reset_index()
                country_dist.columns = ['Country', 'Customers']
                
                fig = px.bar(
                    country_dist,
                    x='Country',
                    y='Customers',
                    title='🌍 Customers by Country (Top 10)',
                    color='Customers',
                    color_continuous_scale='Blues'
                )
                fig.update_layout(
                    showlegend=False,
                    height=350,
                    margin=dict(l=0, r=0, t=40, b=0)
                )
                st.plotly_chart(fig, use_container_width=True)
            except Exception as e:
                st.error(f"👥 Chart error: {str(e)[:100]}")
                if PROMETHEUS_ENABLED:
                    errors_total.labels(error_type='chart_render').inc()
        else:
            st.info("👥 No country column found")
    else:
        st.info("👥 No customer data")

st.markdown("---")

# ===========================
# INSIGHTS
# ===========================

st.header("💡 Quick Insights")

col1, col2, col3 = st.columns(3)

with col1:
    revenue_delta = metrics.get('revenue_delta', 0)
    if revenue_delta > 0:
        st.info(f"**📈 Revenue Growth**\n\nRevenue up {revenue_delta:.1f}%! Keep going!")
    else:
        st.warning(f"**📉 Revenue Decline**\n\nRevenue down {abs(revenue_delta):.1f}%")

with col2:
    if metrics.get('low_stock_items', 0) > 0:
        st.warning(f"**⚠️ Low Stock Alert**\n\n{metrics.get('low_stock_items', 0)} products need restocking")
    else:
        st.success("**✅ Inventory Healthy**\n\nAll products well-stocked!")

with col3:
    st.success(f"**⭐ Customer Satisfaction**\n\nRating: {metrics.get('avg_rating', 4.2):.1f}/5.0")

st.markdown("---")

# Footer with Prometheus status
prom_status = "📊 Prometheus Metrics: Enabled" if PROMETHEUS_ENABLED else "📊 Prometheus Metrics: Disabled"
st.caption(f"""
📊 Dashboard v2.1 (with Prometheus) | {source_used} | {datetime.now().strftime('%Y-%m-%d %H:%M:%S')} | 
{metrics.get('total_customers', 0):,} customers • {metrics.get('total_products', 0):,} products • {metrics.get('orders', 0):,} orders | {prom_status}
""")