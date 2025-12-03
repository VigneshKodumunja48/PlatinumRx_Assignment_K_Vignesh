

-- Note: All queries assume YEAR = '2021' and MONTH = '10' (October)

-- 1. Find the revenue we got from each sales channel in a given year
SELECT
    sales_channel,
    SUM(amount) AS total_revenue
FROM
    clinic_sales
WHERE
    STRFTIME('%Y', datetime) = '2021' 
GROUP BY
    sales_channel;

---
-- 2. Find top 10 the most valuable customers for a given year
SELECT
    cs.uid,
    c.name,
    SUM(cs.amount) AS total_spent
FROM
    clinic_sales cs
JOIN
    customer c ON cs.uid = c.uid
WHERE
    STRFTIME('%Y', cs.datetime) = '2021' -- Parameter: Given year
GROUP BY
    cs.uid, c.name
ORDER BY
    total_spent DESC
LIMIT 10;

---
-- 3. Find month wise revenue, expense, profit, status (profitable / not-profitable) for a given year
WITH MonthlyRevenue AS (
    SELECT
        STRFTIME('%Y-%m', datetime) AS month,
        SUM(amount) AS total_revenue
    FROM
        clinic_sales
    WHERE
        STRFTIME('%Y', datetime) = '2021'
    GROUP BY
        month
),
MonthlyExpense AS (
    SELECT
        STRFTIME('%Y-%m', datetime) AS month,
        SUM(amount) AS total_expense
    FROM
        expenses
    WHERE
        STRFTIME('%Y', datetime) = '2021'
    GROUP BY
        month
)
SELECT
    COALESCE(r.month, e.month) AS report_month,
    COALESCE(r.total_revenue, 0) AS revenue,
    COALESCE(e.total_expense, 0) AS expense,
    (COALESCE(r.total_revenue, 0) - COALESCE(e.total_expense, 0)) AS profit,
    CASE
        WHEN (COALESCE(r.total_revenue, 0) - COALESCE(e.total_expense, 0)) > 0 THEN 'Profitable'
        ELSE 'Not-Profitable'
    END AS status
FROM
    MonthlyRevenue r
LEFT JOIN -- Use LEFT JOIN to ensure all revenue months are included
    MonthlyExpense e ON r.month = e.month
ORDER BY
    report_month;

---
-- 4. For each city find the most profitable clinic for a given month
WITH ClinicProfit AS (
    SELECT
        STRFTIME('%Y-%m', cs.datetime) AS sales_month,
        c.city,
        c.clinic_name,
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit,
        RANK() OVER (PARTITION BY c.city, STRFTIME('%Y-%m', cs.datetime) ORDER BY (SUM(cs.amount) - COALESCE(SUM(e.amount), 0)) DESC) AS profit_rank
    FROM
        clinic_sales cs
    JOIN
        clinics c ON cs.cid = c.cid
    LEFT JOIN
        expenses e ON cs.cid = e.cid AND STRFTIME('%Y-%m', cs.datetime) = STRFTIME('%Y-%m', e.datetime)
    WHERE
        STRFTIME('%Y-%m', cs.datetime) = '2021-10' -- Parameter: Given month
    GROUP BY
        sales_month, c.city, c.clinic_name
)
SELECT
    city,
    clinic_name,
    profit
FROM
    ClinicProfit
WHERE
    profit_rank = 1;

---
-- 5. For each state find the second least profitable clinic for a given month
WITH ClinicProfitRanked AS (
    SELECT
        STRFTIME('%Y-%m', cs.datetime) AS sales_month,
        c.state,
        c.clinic_name,
        -- Calculate Profit (Revenue - Expense), COALESCE handles clinics with no expenses
        SUM(cs.amount) - COALESCE(SUM(e.amount), 0) AS profit,
        -- Rank profit ascending (1 is LEAST profitable)
        DENSE_RANK() OVER (PARTITION BY c.state, STRFTIME('%Y-%m', cs.datetime) ORDER BY (SUM(cs.amount) - COALESCE(SUM(e.amount), 0)) ASC) AS least_profit_rank
    FROM
        clinic_sales cs
    JOIN
        clinics c ON cs.cid = c.cid
    LEFT JOIN
        expenses e ON cs.cid = e.cid AND STRFTIME('%Y-%m', cs.datetime) = STRFTIME('%Y-%m', e.datetime)
    WHERE
        STRFTIME('%Y-%m', cs.datetime) = '2021-10' -- Parameter: Given month
    GROUP BY
        sales_month, c.state, c.clinic_name
)
SELECT
    state,
    clinic_name,
    profit
FROM
    ClinicProfitRanked
WHERE
    least_profit_rank = 2; -- Filter for the second least profitable