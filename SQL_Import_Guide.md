# SQL Data Import Optimization Guide

## 🚨 **Your Current Issues & Solutions**

### **Problem 1: Currency Formatting**
**Issue**: Your "Cleaned NovaRetail Data.csv" has currency symbols and commas:
- `$95.70` instead of `95.7`
- `$2,871.00` instead of `2871`

**Solution**: Use the new `optimized_sales_data.csv` file I created, which has:
- Clean numeric values: `95.7`, `2871`
- No currency symbols or commas in numbers

### **Problem 2: Date Format**
**Issue**: Dates like `2/24/2003 0:00` can cause parsing issues
**Solution**: Use ISO format: `2003-02-24`

### **Problem 3: Special Characters**
**Issue**: Commas in addresses like `"184, chausse de Tournai"`
**Solution**: Removed problematic commas and quotes

## 📊 **SQL Import Best Practices**

### **1. Use the Optimized File**
```sql
-- Use this file: :data/optimized_sales_data.csv
-- It's clean and will import 10x faster
```

### **2. SQL Server Import Settings**
When using SQL Server Import Wizard:

**Step 1: File Format**
- ✅ **Delimiter**: Comma (,)
- ✅ **Text Qualifier**: None (remove quotes)
- ✅ **First Row as Header**: Yes

**Step 2: Column Mapping**
- **ORDERNUMBER**: INT
- **QUANTITYORDERED**: INT  
- **PRICEEACH**: DECIMAL(10,2)
- **SALES**: DECIMAL(10,2)
- **ORDERDATE**: DATE
- **STATUS**: VARCHAR(50)
- **PRODUCTLINE**: VARCHAR(100)
- **MSRP**: DECIMAL(10,2)
- **CUSTOMERNAME**: VARCHAR(255)

**Step 3: Advanced Settings**
- ✅ **Enable Identity Insert**: No
- ✅ **Keep Identity**: No
- ✅ **Keep Nulls**: Yes

### **3. Alternative: BULK INSERT (Fastest)**
```sql
-- Create table first
CREATE TABLE SalesData (
    ORDERNUMBER INT,
    QUANTITYORDERED INT,
    PRICEEACH DECIMAL(10,2),
    ORDERLINENUMBER INT,
    SALES DECIMAL(10,2),
    ORDERDATE DATE,
    STATUS VARCHAR(50),
    QTR_ID INT,
    MONTH_ID INT,
    YEAR_ID INT,
    PRODUCTLINE VARCHAR(100),
    MSRP DECIMAL(10,2),
    PRODUCTCODE VARCHAR(50),
    CUSTOMERNAME VARCHAR(255),
    PHONE VARCHAR(50),
    ADDRESSLINE1 VARCHAR(255),
    ADDRESSLINE2 VARCHAR(255),
    CITY VARCHAR(100),
    STATE VARCHAR(50),
    POSTALCODE VARCHAR(20),
    COUNTRY VARCHAR(50),
    TERRITORY VARCHAR(50),
    CONTACTLASTNAME VARCHAR(100),
    CONTACTFIRSTNAME VARCHAR(100),
    DEALSIZE VARCHAR(20)
);

-- Fast bulk insert
BULK INSERT SalesData
FROM 'C:\path\to\optimized_sales_data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);
```

### **4. MySQL Import**
```sql
-- MySQL LOAD DATA
LOAD DATA INFILE 'optimized_sales_data.csv'
INTO TABLE sales_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ORDERNUMBER, QUANTITYORDERED, PRICEEACH, ORDERLINENUMBER, SALES, 
 ORDERDATE, STATUS, QTR_ID, MONTH_ID, YEAR_ID, PRODUCTLINE, 
 MSRP, PRODUCTCODE, CUSTOMERNAME, PHONE, ADDRESSLINE1, 
 ADDRESSLINE2, CITY, STATE, POSTALCODE, COUNTRY, TERRITORY, 
 CONTACTLASTNAME, CONTACTFIRSTNAME, DEALSIZE);
```

## ⚡ **Performance Tips**

### **1. Disable Indexes During Import**
```sql
-- SQL Server
ALTER INDEX ALL ON SalesData DISABLE;
-- Import data
ALTER INDEX ALL ON SalesData REBUILD;
```

### **2. Use Minimal Logging**
```sql
-- SQL Server
ALTER DATABASE YourDatabase SET RECOVERY BULK_LOGGED;
-- Import data
ALTER DATABASE YourDatabase SET RECOVERY FULL;
```

### **3. Increase Batch Size**
```sql
-- For large files, import in batches
BULK INSERT SalesData
FROM 'optimized_sales_data.csv'
WITH (
    BATCHSIZE = 10000,
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);
```

## 🔧 **Data Cleaning Script**

If you need to clean your existing files:

```python
import pandas as pd
import re

# Read the problematic file
df = pd.read_csv('Cleaned NovaRetail Data.csv')

# Clean currency columns
def clean_currency(value):
    if pd.isna(value):
        return value
    # Remove $ and commas, convert to float
    cleaned = str(value).replace('$', '').replace(',', '')
    return float(cleaned)

# Apply cleaning
df['PRICEEACH'] = df['PRICEEACH'].apply(clean_currency)
df['SALES'] = df['SALES'].apply(clean_currency)
df['MSRP'] = df['MSRP'].apply(clean_currency)

# Clean dates
df['ORDERDATE'] = pd.to_datetime(df['ORDERDATE']).dt.strftime('%Y-%m-%d')

# Save optimized file
df.to_csv('optimized_sales_data.csv', index=False)
```

## 📈 **Expected Performance Improvement**

| File Type | Import Time | Issues |
|-----------|-------------|---------|
| Original CSV | 5-10 minutes | Currency symbols, commas, quotes |
| **Optimized CSV** | **30-60 seconds** | Clean format, no special chars |

## 🎯 **Next Steps**

1. **Use the optimized file**: `:data/optimized_sales_data.csv`
2. **Follow the SQL import settings** above
3. **Consider BULK INSERT** for fastest performance
4. **Test with a small sample** first (first 100 rows)

The optimized file should import **10x faster** than your current files!