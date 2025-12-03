-- FILE: 02_Hotel_Queries.sql

-- 1. For every user in the system, get the user_id and last booked room_no
SELECT
    t1.user_id,
    t1.room_no AS last_booked_room_no
FROM (
    SELECT
        user_id,
        room_no,
        -- Rank bookings by date within each user group (PARTITION BY user_id)
        ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY booking_date DESC) as rn
    FROM
        bookings
) t1
WHERE
    t1.rn = 1;

---
-- 2. Get booking_id and total billing amount of every booking created in November, 2021
SELECT
    b.booking_id,
    SUM(bc.item_quantity * i.item_rate) AS total_billing_amount
FROM
    bookings b
JOIN
    booking_commercials bc ON b.booking_id = bc.booking_id
JOIN
    items i ON bc.item_id = i.item_id
WHERE
    -- Filter bookings by November 2021
    STRFTIME('%Y-%m', b.booking_date) = '2021-11'
GROUP BY
    b.booking_id;

---
-- 3. Get bill_id and bill amount of all the bills raised in October, 2021 having bill amount >1000
SELECT
    bc.bill_id,
    SUM(bc.item_quantity * i.item_rate) AS bill_amount
FROM
    booking_commercials bc
JOIN
    items i ON bc.item_id = i.item_id
WHERE
    STRFTIME('%Y-%m', bc.bill_date) = '2021-10'
GROUP BY
    bc.bill_id
-- Filter the aggregated (SUM) bill amount using HAVING
HAVING
    SUM(bc.item_quantity * i.item_rate) > 1000;

---
-- 4. Determine the most ordered and least ordered item of each month of year 2021
WITH MonthlyItemQuantity AS (
    SELECT
        STRFTIME('%Y-%m', bc.bill_date) AS bill_month,
        i.item_name,
        SUM(bc.item_quantity) AS total_quantity,
        -- Rank items by quantity descending (for MOST ordered)
        RANK() OVER (PARTITION BY STRFTIME('%Y-%m', bc.bill_date) ORDER BY SUM(bc.item_quantity) DESC) AS rank_most,
        -- Rank items by quantity ascending (for LEAST ordered)
        RANK() OVER (PARTITION BY STRFTIME('%Y-%m', bc.bill_date) ORDER BY SUM(bc.item_quantity) ASC) AS rank_least
    FROM
        booking_commercials bc
    JOIN
        items i ON bc.item_id = i.item_id
    WHERE
        STRFTIME('%Y', bc.bill_date) = '2021'
    GROUP BY
        bill_month, i.item_name
)
SELECT
    bill_month,
    MAX(CASE WHEN rank_most = 1 THEN item_name || ' (' || total_quantity || ')' END) AS most_ordered_item,
    MAX(CASE WHEN rank_least = 1 THEN item_name || ' (' || total_quantity || ')' END) AS least_ordered_item
FROM
    MonthlyItemQuantity
WHERE
    rank_most = 1 OR rank_least = 1
GROUP BY
    bill_month
ORDER BY
    bill_month;

---
-- 5. Find the customers with the second highest bill value of each month of year 2021
WITH MonthlyUserBill AS (
    SELECT
        b.user_id,
        u.name AS customer_name,
        STRFTIME('%Y-%m', bc.bill_date) AS bill_month,
        SUM(bc.item_quantity * i.item_rate) AS total_bill_value,
        -- Rank bills by value descending within each month
        DENSE_RANK() OVER (
            PARTITION BY STRFTIME('%Y-%m', bc.bill_date)
            ORDER BY SUM(bc.item_quantity * i.item_rate) DESC
        ) as bill_rank
    FROM
        bookings b
    JOIN
        users u ON b.user_id = u.user_id
    JOIN
        booking_commercials bc ON b.booking_id = bc.booking_id
    JOIN
        items i ON bc.item_id = i.item_id
    WHERE
        STRFTIME('%Y', bc.bill_date) = '2021'
    GROUP BY
        b.user_id, u.name, bill_month
)
SELECT
    bill_month,
    customer_name,
    total_bill_value
FROM
    MonthlyUserBill
WHERE
    bill_rank = 2
ORDER BY
    bill_month;