-- FILE: 03_Clinic_Schema_Setup.sql & Data Insertion

-- Drop tables if they exist
DROP TABLE IF EXISTS expenses;
DROP TABLE IF EXISTS clinic_sales;
DROP TABLE IF EXISTS customer;
DROP TABLE IF EXISTS clinics;

-- 1. clinics table
CREATE TABLE clinics (
    cid TEXT PRIMARY KEY,
    clinic_name TEXT,
    city TEXT,
    state TEXT,
    country TEXT
);

-- 2. customer table
CREATE TABLE customer (
    uid TEXT PRIMARY KEY,
    name TEXT,
    mobile TEXT
);

-- 3. clinic_sales table (Revenue)
CREATE TABLE clinic_sales (
    oid TEXT PRIMARY KEY,
    uid TEXT,
    cid TEXT,
    amount REAL,
    datetime DATETIME,
    sales_channel TEXT,
    FOREIGN KEY(uid) REFERENCES customer(uid),
    FOREIGN KEY(cid) REFERENCES clinics(cid)
);

-- 4. expenses table
CREATE TABLE expenses (
    eid TEXT PRIMARY KEY,
    cid TEXT,
    description TEXT,
    amount REAL,
    datetime DATETIME,
    FOREIGN KEY(cid) REFERENCES clinics(cid)
);

-- INSERTION: Dummy Data

-- Clinics (1 new clinic in a different state for Q5)
INSERT INTO clinics VALUES
('cnc-01','XYZ clinic','lorem','ipsum','dolor'),
('cnc-02','ABC clinic','lorem','ipsum','dolor'),
('cnc-03','PQR clinic','hyderabad','telangana','India'),
('cnc-04','MNO clinic','vizag','andhra','India'); -- For Q5

-- Customer
INSERT INTO customer VALUES
('cust-a','Jon Doe','97XXXXXXX X'),
('cust-b','Jane Smith','98YYYYYYY Y');

-- Clinic Sales (Revenue - For 2021)
INSERT INTO clinic_sales VALUES
('ord-01','cust-a','cnc-01', 24999, '2021-09-23 12:03:22', 'sodat'), -- Sept, C1
('ord-02','cust-a','cnc-02', 15000, '2021-10-01 10:00:00', 'online'), -- Oct, C2
('ord-03','cust-b','cnc-02', 5000, '2021-10-15 15:00:00', 'walk-in'), -- Oct, C2
('ord-04','cust-b','cnc-03', 10000, '2021-10-20 16:00:00', 'online'), -- Oct, C3
('ord-05','cust-a','cnc-01', 500, '2021-11-01 11:00:00', 'sodat'), -- Nov, C1
('ord-06','cust-b','cnc-04', 20000, '2021-11-10 10:00:00', 'walk-in'); -- Nov, C4

-- Expenses (For 2021)
INSERT INTO expenses VALUES
('exp-01','cnc-01','first-aid supplies', 557, '2021-09-23 07:36:48'), -- Sept, C1
('exp-02','cnc-02','Rent', 1000, '2021-10-05 09:00:00'), -- Oct, C2
('exp-03','cnc-02','Salaries', 5000, '2021-10-05 09:00:00'), -- Oct, C2 (Total Exp: 6000)
('exp-04','cnc-03','Marketing', 5000, '2021-10-10 09:00:00'), -- Oct, C3
('exp-05','cnc-01','Salaries', 100, '2021-11-05 09:00:00'), -- Nov, C1
('exp-06','cnc-04','Rent', 1000, '2021-11-10 09:00:00'); -- Nov, C4