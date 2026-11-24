# SQL Analysis for Hotel Booking Cancellations

This directory contains the SQL implementation for the **Hotel Booking Cancellation Analysis** project. 

The queries in [`hotel_analysis.sql`](hotel_analysis.sql) answer the core business questions and reproduce the KPIs displayed on the Power BI dashboard using clean, standard SQL.

---

## File Included

- **[`hotel_analysis.sql`](hotel_analysis.sql)**: Complete, self-contained SQL script compatible with **MySQL, PostgreSQL, SQL Server, and SQLite**.

---

## How to Run the SQL Script in 2 Easy Steps

### Step 1: Create the Table & Import the Data
Open your favorite SQL client (**MySQL Workbench**, **pgAdmin**, **DBeaver**, or **DB Browser for SQLite**):

1. Run the `CREATE TABLE` statement at the top of `hotel_analysis.sql`.
2. Import the CSV dataset:
   - **In MySQL Workbench / DBeaver / pgAdmin:** Right-click the `hotel_bookings` table -> select **Import Data** -> choose `data/booking.csv`.
   - **Or in PostgreSQL command line (`psql`):**
     ```sql
     \copy hotel_bookings FROM 'data/booking.csv' WITH (FORMAT csv, HEADER true);
     ```

### Step 2: Run the Analytical Queries
Execute the queries in `hotel_analysis.sql` to investigate:
- **Executive KPIs:** Total bookings (36,285) & overall cancellation rate (32.8%).
- **Revenue Exposure:** €4.30M lost to cancellations vs. €7.05M confirmed.
- **Lead Time Progression:** Why cancellations increase from 8.9% (0–7 days) to 73.9% (>180 days).
- **Market Segments:** Online OTAs (36.5% cancellation) vs. Corporate (10.9%).
- **Guest Commitment Signals:** Impact of special requests (43.2% to <15%) and parking requests.
- **Repeat Guest Loyalty:** 1.7% cancellation rate for repeat guests vs. 33.6% for new guests.

---

## Summary of SQL Findings

| Business Question | SQL Metric / Insight | Key Finding |
| :--- | :--- | :--- |
| **Overall Cancellation Rate** | `32.8%` | ~1 in 3 hotel reservations gets cancelled |
| **Financial Exposure** | `€4.30 Million` | Revenue lost to cancellations (~37.9% of portfolio) |
| **Lead Time Risk** | `8.9%` up to `73.9%` | Bookings made >180 days out cancel nearly 3 out of 4 times |
| **Channel Risk** | `36.5%` vs `10.9%` | Online OTAs have high cancellation rates; Corporate is very reliable |
| **Special Requests** | `43.2%` vs `<15%` | Personalization significantly lowers cancellations |
| **Customer Retention** | `1.7%` | Repeat guests almost never cancel |
