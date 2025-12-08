SET SERVEROUTPUT ON SIZE UNLIMITED;
-- ============================================================================
-- CURSOR PROCEDURE 1: Process Overdue Maintenance ✅ (This one is correct)
-- ============================================================================

CREATE OR REPLACE PROCEDURE process_overdue_maintenance (
    p_days_overdue IN NUMBER DEFAULT 90
) AS
    CURSOR c_overdue_equipment IS
        SELECT 
            e.equipment_id,
            e.equipment_type,
            e.model,
            e.status,
            e.last_maintenance_date,
            TRUNC(SYSDATE - NVL(e.last_maintenance_date, e.purchase_date)) as days_since_maintenance
        FROM equipment e
        WHERE TRUNC(SYSDATE - NVL(e.last_maintenance_date, e.purchase_date)) > p_days_overdue
        AND e.status != 'Retired'
        ORDER BY days_since_maintenance DESC;
    
    v_count NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('OVERDUE MAINTENANCE REPORT');
    DBMS_OUTPUT.PUT_LINE('Threshold: ' || p_days_overdue || ' days');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('');
    
    FOR rec IN c_overdue_equipment LOOP
        v_count := v_count + 1;
        
        DBMS_OUTPUT.PUT_LINE('Equipment ID: ' || rec.equipment_id);
        DBMS_OUTPUT.PUT_LINE('  Type/Model: ' || rec.equipment_type || ' - ' || rec.model);
        DBMS_OUTPUT.PUT_LINE('  Status: ' || rec.status);
        DBMS_OUTPUT.PUT_LINE('  Last Maintenance: ' || 
                            NVL(TO_CHAR(rec.last_maintenance_date, 'DD-MON-YYYY'), 'Never'));
        DBMS_OUTPUT.PUT_LINE('  Days Overdue: ' || rec.days_since_maintenance);
        DBMS_OUTPUT.PUT_LINE('  ⚠ ACTION REQUIRED: Schedule maintenance immediately');
        DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────────');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Total equipment requiring maintenance: ' || v_count);
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        log_error(SQLCODE, SQLERRM, 'process_overdue_maintenance',
                 'Days overdue: ' || p_days_overdue);
END process_overdue_maintenance;
/

-- ============================================================================
-- CURSOR PROCEDURE 2: Bulk Update Equipment Metrics
-- ============================================================================

CREATE OR REPLACE PROCEDURE bulk_update_equipment_metrics (
    p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -1),
    p_end_date IN DATE DEFAULT SYSDATE
) AS
    -- Cursor with parameters
    CURSOR c_equipment_metrics IS
        SELECT 
            e.equipment_id,
            NVL(SUM(eu.hours_operated), 0) as total_hours,
            NVL(SUM(eu.fuel_consumed_liters), 0) as total_fuel,
            COUNT(eu.usage_id) as usage_count
        FROM equipment e
        LEFT JOIN equipment_usage_log eu ON e.equipment_id = eu.equipment_id
            AND eu.log_date BETWEEN p_start_date AND p_end_date
        GROUP BY e.equipment_id;
    
    -- Collection types for bulk operations (FIXED: Added usage_count)
    TYPE t_equipment_ids IS TABLE OF equipment.equipment_id%TYPE;
    TYPE t_hours IS TABLE OF NUMBER;
    TYPE t_fuel IS TABLE OF NUMBER;
    TYPE t_usage_count IS TABLE OF NUMBER;
    
    v_equipment_ids t_equipment_ids;
    v_total_hours t_hours;
    v_total_fuel t_fuel;
    v_usage_counts t_usage_count;  -- ADDED THIS
    
    v_records_processed NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('BULK UPDATING EQUIPMENT METRICS');
    DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || 
                        ' to ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    
    -- Bulk collect data (FIXED: Added 4th variable)
    OPEN c_equipment_metrics;
    FETCH c_equipment_metrics BULK COLLECT INTO 
        v_equipment_ids, v_total_hours, v_total_fuel, v_usage_counts;
    CLOSE c_equipment_metrics;
    
    v_records_processed := v_equipment_ids.COUNT;
    
    DBMS_OUTPUT.PUT_LINE('Records fetched: ' || v_records_processed);
    
    -- Display sample of collected data
    IF v_records_processed > 0 THEN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('Sample metrics (first 5 records):');
        FOR i IN 1..LEAST(5, v_records_processed) LOOP
            DBMS_OUTPUT.PUT_LINE('  Equipment ' || v_equipment_ids(i) || 
                                ': Hours=' || v_total_hours(i) || 
                                ', Fuel=' || v_total_fuel(i) || 'L' ||
                                ', Usage Count=' || v_usage_counts(i));
        END LOOP;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('✓ Bulk operation completed successfully');
    DBMS_OUTPUT.PUT_LINE('Total records processed: ' || v_records_processed);
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        log_error(SQLCODE, SQLERRM, 'bulk_update_equipment_metrics',
                 'Date range: ' || p_start_date || ' to ' || p_end_date);
END bulk_update_equipment_metrics;
/

-- ============================================================================
-- CURSOR PROCEDURE 3: Generate Operator Performance Report
-- ============================================================================

CREATE OR REPLACE PROCEDURE generate_operator_performance_report (
    p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -1),
    p_end_date IN DATE DEFAULT SYSDATE
) AS
    CURSOR c_operator_performance IS
        SELECT 
            o.operator_id,
            o.first_name || ' ' || o.last_name as operator_name,
            o.status,  -- CHANGED: Using status instead of certification_level
            COUNT(DISTINCT ea.assignment_id) as total_assignments,
            NVL(SUM(eu.hours_operated), 0) as total_hours,
            NVL(AVG(eu.hours_operated), 0) as avg_hours_per_shift
        FROM operators o
        LEFT JOIN equipment_assignment ea ON o.operator_id = ea.operator_id
            AND TRUNC(ea.assignment_date) BETWEEN p_start_date AND p_end_date
        LEFT JOIN equipment_usage_log eu ON ea.assignment_id = eu.assignment_id
            AND eu.log_date BETWEEN p_start_date AND p_end_date
        WHERE o.status = 'Active'
        GROUP BY o.operator_id, o.first_name, o.last_name, o.status
        ORDER BY total_hours DESC;
    
    v_rec c_operator_performance%ROWTYPE;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('OPERATOR PERFORMANCE REPORT');
    DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || 
                        ' to ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('');
    
    OPEN c_operator_performance;
    
    LOOP
        FETCH c_operator_performance INTO v_rec;
        EXIT WHEN c_operator_performance%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Operator: ' || v_rec.operator_name || 
                            ' (ID: ' || v_rec.operator_id || ')');
        DBMS_OUTPUT.PUT_LINE('  Status: ' || v_rec.status);  -- CHANGED
        DBMS_OUTPUT.PUT_LINE('  Assignments: ' || v_rec.total_assignments);
        DBMS_OUTPUT.PUT_LINE('  Total Hours: ' || TO_CHAR(v_rec.total_hours, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('  Avg Hours/Shift: ' || TO_CHAR(v_rec.avg_hours_per_shift, '999.99'));
        DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────────');
        
        -- Limit output
        EXIT WHEN c_operator_performance%ROWCOUNT >= 5;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Total operators processed: ' || c_operator_performance%ROWCOUNT);
    
    IF c_operator_performance%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('⚠ No operator data found for the specified period');
    END IF;
    
    CLOSE c_operator_performance;
    
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    
EXCEPTION
    WHEN OTHERS THEN
        IF c_operator_performance%ISOPEN THEN
            CLOSE c_operator_performance;
        END IF;
        DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
        log_error(SQLCODE, SQLERRM, 'generate_operator_performance_report',
                 'Date range: ' || p_start_date || ' to ' || p_end_date);
END generate_operator_performance_report;
/