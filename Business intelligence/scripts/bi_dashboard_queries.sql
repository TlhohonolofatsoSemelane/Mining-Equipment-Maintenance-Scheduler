SET LINESIZE 200
SET PAGESIZE 100

-- ============================================
-- DASHBOARD 1: EXECUTIVE SUMMARY
-- ============================================
COLUMN kpi_name FORMAT A30
COLUMN kpi_value FORMAT A25
COLUMN target FORMAT A20
COLUMN status FORMAT A15

SELECT 'Total Equipment' as kpi_name, 
       TO_CHAR(total_equipment) as kpi_value,
       'N/A (Baseline)' as target,
       '✓ INFO' as status
FROM v_executive_kpi_cards
UNION ALL
SELECT 'Available Equipment', 
       TO_CHAR(available_equipment) || ' (' || 
       TO_CHAR(ROUND(available_equipment*100.0/NULLIF(total_equipment,0),1)) || '%)',
       '≥30%',
       CASE WHEN available_equipment*100.0/NULLIF(total_equipment,0) >= 30 
            THEN '✓ GOOD' ELSE '⚠ LOW' END
FROM v_executive_kpi_cards
UNION ALL
SELECT 'Equipment In Use', 
       TO_CHAR(equipment_in_use) || ' (' || 
       TO_CHAR(equipment_utilization_rate) || '%)',
       '60-80%',
       CASE WHEN equipment_utilization_rate >= 60 
            THEN '✓ GOOD' ELSE '✗ POOR' END
FROM v_executive_kpi_cards
UNION ALL
SELECT 'Active Operators', 
       TO_CHAR(active_operators),
       '≥80%',
       '✓ GOOD'
FROM v_executive_kpi_cards
UNION ALL
SELECT 'Utilization Rate', 
       TO_CHAR(equipment_utilization_rate) || '%',
       '≥70%',
       CASE WHEN equipment_utilization_rate >= 70 THEN '✓ EXCELLENT'
            WHEN equipment_utilization_rate >= 50 THEN '⚠ GOOD'
            ELSE '✗ POOR' END
FROM v_executive_kpi_cards
UNION ALL
SELECT 'Total Fuel Cost', 
       '$' || TO_CHAR(total_fuel_cost, '999,999.99'),
       'Within Budget',
       '✓ TRACKED'
FROM v_executive_kpi_cards
UNION ALL
SELECT 'Total Downtime', 
       TO_CHAR(total_downtime_hours) || ' hrs',
       '<100 hrs',
       CASE WHEN total_downtime_hours < 100 THEN '✓ EXCELLENT'
            WHEN total_downtime_hours < 150 THEN '⚠ ACCEPTABLE'
            ELSE '✗ WARNING' END
FROM v_executive_kpi_cards
UNION ALL
SELECT 'System Health', 
       system_health_status,
       'GOOD/EXCELLENT',
       CASE system_health_status
            WHEN 'EXCELLENT' THEN '✓ EXCELLENT'
            WHEN 'GOOD' THEN '✓ GOOD'
            WHEN 'FAIR' THEN '⚠ FAIR'
            ELSE '✗ POOR' END
FROM v_executive_kpi_cards;

COLUMN metric FORMAT A30
COLUMN value FORMAT 999

SELECT 'Total Assignments' as metric, COUNT(*) as value FROM equipment_assignment
UNION ALL SELECT 'Equipment Used', COUNT(DISTINCT equipment_id) FROM equipment_assignment
UNION ALL SELECT 'Active Operators', COUNT(DISTINCT operator_id) FROM equipment_assignment
UNION ALL SELECT 'Sites Active', COUNT(DISTINCT site_id) FROM equipment_assignment
UNION ALL SELECT 'Ongoing', COUNT(CASE WHEN end_time IS NULL THEN 1 END) FROM equipment_assignment;

COLUMN department FORMAT A25
COLUMN equip_count FORMAT 999
COLUMN oper_count FORMAT 999

SELECT 
    d.department_name as department,
    COUNT(DISTINCT e.equipment_id) as equip_count,
    COUNT(DISTINCT o.operator_id) as oper_count
FROM departments d
LEFT JOIN equipment e ON d.department_id = e.department_id
LEFT JOIN operators o ON d.department_id = o.department_id
GROUP BY d.department_name
ORDER BY equip_count DESC;

-- ============================================
-- DASHBOARD 2: AUDIT & COMPLIANCE
-- ============================================

COLUMN metric FORMAT A30
COLUMN value FORMAT A20
COLUMN status FORMAT A15

SELECT 'Total Operations' as metric,
       TO_CHAR(total_operations) as value,
       '✓ TRACKED' as status
FROM v_compliance_overview
UNION ALL
SELECT 'Compliance Rate',
       TO_CHAR(compliance_rate_percentage) || '%',
       CASE WHEN compliance_rate_percentage = 100 THEN '✓ PERFECT'
            WHEN compliance_rate_percentage >= 95 THEN '✓ GOOD'
            ELSE '✗ VIOLATIONS' END
FROM v_compliance_overview
UNION ALL
SELECT 'Violation Rate',
       TO_CHAR(violation_rate_percentage) || '%',
       CASE WHEN violation_rate_percentage = 0 THEN '✓ PERFECT'
            ELSE '✗ VIOLATIONS' END
FROM v_compliance_overview
UNION ALL
SELECT 'Weekend Violations',
       TO_CHAR(weekend_violations),
       CASE WHEN weekend_violations = 0 THEN '✓ PERFECT' ELSE '✗ ALERT' END
FROM v_compliance_overview
UNION ALL
SELECT 'Compliance Status',
       compliance_status,
       CASE compliance_status
            WHEN 'PERFECT COMPLIANCE' THEN '✓ EXCELLENT'
            WHEN 'GOOD COMPLIANCE' THEN '✓ GOOD'
            ELSE '⚠ REVIEW' END
FROM v_compliance_overview;

COLUMN table_name FORMAT A25
COLUMN total_ops FORMAT 999
COLUMN denied FORMAT 999
COLUMN comp_rate FORMAT 999.99

SELECT 
    table_name,
    total_operations as total_ops,
    denied_operations as denied,
    compliance_rate_percentage as comp_rate
FROM v_compliance_by_table
ORDER BY compliance_rate_percentage ASC;

-- ============================================
-- DASHBOARD 3: PERFORMANCE & RESOURCES
-- ============================================

COLUMN equipment_id FORMAT A15
COLUMN model FORMAT A20
COLUMN status FORMAT A15

SELECT 
    equipment_id,
    model,
    status
FROM equipment
WHERE ROWNUM <= 10
ORDER BY equipment_id;

COLUMN metric FORMAT A30
COLUMN value FORMAT 999

SELECT 'Total Assignments' as metric, COUNT(*) as value FROM equipment_assignment
UNION ALL
SELECT 'Unique Equipment', COUNT(DISTINCT equipment_id) FROM equipment_assignment
UNION ALL
SELECT 'Unique Operators', COUNT(DISTINCT operator_id) FROM equipment_assignment
UNION ALL
SELECT 'Unique Sites', COUNT(DISTINCT site_id) FROM equipment_assignment
UNION ALL
SELECT 'Active Assignments', COUNT(*) FROM equipment_assignment WHERE end_time IS NULL;

COLUMN operator_name FORMAT A30
COLUMN license FORMAT A20

SELECT 
    first_name || ' ' || last_name as operator_name,
    license_number as license
FROM operators
WHERE ROWNUM <= 10
ORDER BY operator_id;

COLUMN site_name FORMAT A30
COLUMN location FORMAT A25

SELECT 
    site_name,
    location
FROM mining_sites
ORDER BY site_id;

COLUMN metric FORMAT A30
COLUMN count FORMAT 999

SELECT 'Total Scheduled' as metric, COUNT(*) as count FROM maintenance_schedule
UNION ALL
SELECT 'Completed', COUNT(*) FROM maintenance_schedule WHERE status = 'Completed'
UNION ALL
SELECT 'Pending', COUNT(*) FROM maintenance_schedule WHERE status = 'Scheduled'
UNION ALL
SELECT 'Overdue', COUNT(*) FROM maintenance_schedule WHERE status = 'Overdue';

PROMPT
PROMPT ━━━ Downtime Summary ━━━
PROMPT

COLUMN metric FORMAT A30
COLUMN hours FORMAT 999,999.99

SELECT 
    'Total Downtime Hours' as metric,
    SUM(duration_hours) as hours
FROM downtime_records
UNION ALL
SELECT 
    'Average per Event',
    AVG(duration_hours)
FROM downtime_records;

COLUMN metric FORMAT A30
COLUMN amount FORMAT 999,999.99

SELECT 
    'Total Liters' as metric,
    SUM(quantity_liters) as amount
FROM fuel_consumption
UNION ALL
SELECT 
    'Total Cost ($)',
    SUM(total_cost)
FROM fuel_consumption
UNION ALL
SELECT 
    'Average Cost per Liter',
    AVG(cost_per_liter)
FROM fuel_consumption;

PROMPT
PROMPT ━━━ Equipment by Status ━━━
PROMPT

COLUMN status FORMAT A20
COLUMN count FORMAT 999

SELECT 
    status,
    COUNT(*) as count
FROM equipment
GROUP BY status
ORDER BY COUNT(*) DESC;

