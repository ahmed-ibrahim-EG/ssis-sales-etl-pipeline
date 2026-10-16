# End-to-End Sales ETL Pipeline using SSIS & SQL Server

An enterprise-grade ETL (Extract, Transform, Load) data pipeline developed using **SQL Server Integration Services (SSIS)** and **Microsoft SQL Server**. The pipeline automates the ingestion of raw transaction flat files, enforces rigorous data type sanitization, computes business KPIs, enriches data via reference database lookups, conditionally routes records based on business rules, and loads transformed data into specialized SQL Server fact tables.

## 📸 Architecture & Pipeline Visuals

### 1. Data Flow Architecture & Component Pipeline
Below is the architectural layout and transformation logic configured across the pipeline:

<p align="center">
  <img src="./screenshots/ETL%20.png" alt="Data Flow Architecture" width="100%" />
</p>

### 2. Successful Pipeline Execution
Demonstration of full end-to-end execution with all buffers processed and validation passed across all components:

<p align="center">
  <img src="./screenshots/ETL%20SUC.png" alt="Pipeline Execution Success" width="100%" />
</p>

## 🚀 Key Pipeline Stages

### 1. Extraction (Source Layer)
- **Flat File Source (`Sales_Data.csv`)**: Reads raw delimited sales records containing order IDs, quantities, prices, regions, and product details.

### 2. Data Cleansing & Type Casting
- **Data Conversion Transformation**:
  - `Conv_OrderID`: Explicitly cast to Signed 4-byte Integer `[DT_I4]`.
  - `Conv_Quantity`: Standardized to 4-byte Integer `[DT_I4]`.
  - `Conv_UnitPrice`: Cast to high-precision Decimal `[DT_NUMERIC(10, 2)]`.
  - Solves file-system implicit conversion errors and guarantees buffer type compatibility.

### 3. Business Logic Computation
- **Derived Column Transformation**:
  - **`TotalAmount`**: Computed line-item value using explicit casting:
    ```sql
    (DT_NUMERIC, 10, 2)(Conv_Quantity * Conv_UnitPrice)
    ```
  - **`OrderDescription`**: Dynamic formatted string concatenation:
    ```sql
    [ProductName] + " - " + [Region]
    ```

### 4. Enterprise Data Enrichment
- **Lookup Transformation (OLE DB)**:
  - Performs an inner join against `SalesDB.dbo.Orders` using `Conv_OrderID == OrderID`.
  - Enriches stream with `CustomerName` and `PaymentMethod`.
  - **Error Handling**: Configured with `Redirect rows to no match output` to prevent package crashes on orphan records.

### 5. Conditional Splitting & Rule Routing
- **Conditional Split Transformation**:
  - **`VIP_Orders`**:
    ```sql
    [TotalAmount] >= 1000
    ```
  - **`Visa_Orders`**:
    ```sql
    [PaymentMethod] == "Visa" && [TotalAmount] < 1000
    ```
  - **`Other_Orders`**: Default fallback output for standard/other payment channels.

### 6. Fan-Out & Target Loading (Destination Layer)
- **Multicast Transformations**: Enables zero-overhead stream replication for multi-destination downstream consumption.
- **OLE DB Destinations (`Fast Load`)**:
  - `[dbo].[Fact_HighValue_Orders]` — Stores high-value VIP transactions.
  - `[dbo].[Fact_Standard_Orders]` — Stores operational retail/standard orders.

## 🛠️ Tech Stack & Tools
- **ETL Engine:** SQL Server Integration Services (SSIS)
- **IDE:** Visual Studio (SQL Server Data Tools / SSIS Integration Extension)
- **Database Engine:** Microsoft SQL Server
- **RDBMS Management:** SQL Server Management Studio (SSMS)
- **Source Format:** Comma-Separated Values (CSV)

## 📂 Project Repository Structure
```text
ssis-sales-etl-pipeline/
│
├── SSIS_Project/
│   ├── Package.dtsx               # Main SSIS package pipeline
│   └── SalesETL.dtproj            # SSIS Visual Studio project file
│
├── sql/
│   ├── 01_setup_database.sql      # Schema definitions for SalesDB and tables
│   └── 02_seed_data.sql           # Reference lookup orders data
│
├── data/
│   └── Sales_Data.csv             # Raw source transaction file
│
├── screenshots/
│   ├── ETL .png                   # Data Flow layout screenshot
│   └── ETL SUC.png               # Execution completion screenshot
│
├── .gitignore
└── README.md
```

## ⚙️ How to Set Up & Run

### Prerequisites
1. Microsoft SQL Server (2019/2022 or LocalDB).
2. SQL Server Management Studio (SSMS).
3. Visual Studio with **SQL Server Integration Services Projects** extension installed.

### Setup Instructions
1. **Clone the repository:**
   ```bash
   git clone https://github.com/<your-username>/ssis-sales-etl-pipeline.git
   cd ssis-sales-etl-pipeline
   ```

2. **Initialize Database Tables:**
   Execute the following script in SSMS to create the database schema:
   ```sql
   CREATE DATABASE SalesDB;
   GO
   USE SalesDB;
   GO

   -- Reference table for Lookup
   CREATE TABLE dbo.Orders (
       OrderID INT PRIMARY KEY,
       CustomerName VARCHAR(50),
       PaymentMethod VARCHAR(20)
   );

   -- Target tables
   CREATE TABLE dbo.Fact_HighValue_Orders (
       OrderID INT,
       CustomerName VARCHAR(50),
       OrderDescription VARCHAR(100),
       PaymentMethod VARCHAR(20),
       TotalAmount DECIMAL(10, 2)
   );

   CREATE TABLE dbo.Fact_Standard_Orders (
       OrderID INT,
       CustomerName VARCHAR(50),
       OrderDescription VARCHAR(100),
       PaymentMethod VARCHAR(20),
       TotalAmount DECIMAL(10, 2)
   );
   GO
   ```

3. **Open & Configure the SSIS Solution:**
   - Open `SalesETL.dtproj` in Visual Studio.
   - In the **Connection Managers** pane, update:
     - **Flat File Connection**: Point to your local path of `data/Sales_Data.csv`.
     - **OLE DB Connection**: Point your server connection to `(local)` or your SQL Server instance name targeting `SalesDB`.

4. **Execute Package:**
   - Press **F5** or click **Start** in Visual Studio.
   - Verify rows routed into `Fact_HighValue_Orders` and `Fact_Standard_Orders`.
