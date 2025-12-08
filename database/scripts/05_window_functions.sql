SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;
SET PAGESIZE 100;
-- ============================================================================
-- QUERY 1: Equipment Ranking with ROW_NUMBER
-- Window Functions: ROW_NUMBER()
-- ============================================================================
SELECT 
    equipment_id,
    equipment_type,
    model,
    status,
    ROW_NUMBER() OVER (ORDER BY equipment_id) as row_number
FROM equipment
WHERE ROWNUM <= 10;

-- ============================================================================
-- QUERY 2: Equipment Ranking by Type with RANK
-- Window Functions: RANK() and PARTITION BY
-- ============================================================================
SELECT 
    equipment_type,
    equipment_id,
    model,
    purchase_date,
    RANK() OVER (PARTITION BY equipment_type ORDER BY purchase_date) as rank_by_purchase
FROM equipment
WHERE ROWNUM <= 20
ORDER BY equipment_type, rank_by_purchase;

-- ============================================================================
-- QUERY 3: Running Total of Equipment by Type
-- Window Functions: COUNT() OVER with PARTITION BY
-- ============================================================================
SELECT 
    equipment_type,
    equipment_id,
    model,
    COUNT(*) OVER (PARTITION BY equipment_type) as total_in_type,
    ROW_NUMBER() OVER (PARTITION BY equipment_type ORDER BY equipment_id) as sequence_in_type
FROM equipment
WHERE ROWNUM <= 20
ORDER BY equipment_type, equipment_id;

-- ============================================================================
-- QUERY 4: Operator Assignment Analysis with LAG
-- Window Functions: LAG() to compare with previous row
-- ============================================================================
SELECT 
    operator_id,
    assignment_id,
    equipment_id,
    assignment_date,
    LAG(assignment_date, 1) OVER (PARTITION BY operator_id ORDER BY assignment_date) as previous_assignment_date,
    LAG(equipment_id, 1) OVER (PARTITION BY operator_id ORDER BY assignment_date) as previous_equipment
FROM equipment_assignment
WHERE ROWNUM <= 15
ORDER BY operator_id, assignment_date;

-- ============================================================================
-- QUERY 5: Maintenance Cost Analysis with LEAD
-- Window Functions: LEAD() to look at next row
-- ============================================================================
SELECT 
    equipment_id,
    history_id,
    TRUNC(CAST(start_date AS DATE)) as maintenance_date,
    cost,
    LEAD(cost, 1) OVER (PARTITION BY equipment_id ORDER BY start_date) as next_maintenance_cost,
    LEAD(TRUNC(CAST(start_date AS DATE)), 1) OVER (PARTITION BY equipment_id ORDER BY start_date) as next_maintenance_date
FROM maintenance_history
WHERE ROWNUM <= 15
ORDER BY equipment_id, start_date;

-- ============================================================================
-- QUERY 6: Equipment Distribution with NTILE
-- Window Functions: NTILE() to divide into groups
-- ============================================================================
SELECT 
    equipment_id,
    equipment_type,
    model,
    NTILE(4) OVER (ORDER BY equipment_id) as quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY equipment_id) = 1 THEN 'Group 1'
        WHEN NTILE(4) OVER (ORDER BY equipment_id) = 2 THEN 'Group 2'
        WHEN NTILE(4) OVER (ORDER BY equipment_id) = 3 THEN 'Group 3'
        ELSE 'Group 4'
    END as group_name
FROM equipment
WHERE ROWNUM <= 20
ORDER BY equipment_id;

-- ============================================================================
-- QUERY 7: Cumulative Count of Assignments
-- Window Functions: COUNT() OVER with ORDER BY (running count)
-- ============================================================================
SELECT 
    assignment_id,
    equipment_id,
    operator_id,
    assignment_date,
    COUNT(*) OVER (ORDER BY assignment_date) as cumulative_assignments,
    ROW_NUMBER() OVER (ORDER BY assignment_date) as assignment_sequence
FROM equipment_assignment
WHERE ROWNUM <= 15
ORDER BY assignment_date;

-- ============================================================================
-- QUERY 8: Dense Rank Example
-- Window Functions: DENSE_RANK()
-- ============================================================================
SELECT 
    equipment_type,
    equipment_id,
    model,
    status,
    DENSE_RANK() OVER (ORDER BY equipment_type) as type_dense_rank,
    ROW_NUMBER() OVER (PARTITION BY equipment_type ORDER BY equipment_id) as row_in_type
FROM equipment
WHERE ROWNUM <= 20
ORDER BY equipment_type, equipment_id;