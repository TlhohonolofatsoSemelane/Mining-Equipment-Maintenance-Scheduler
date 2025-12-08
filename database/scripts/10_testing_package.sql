SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;
-- TEST 1: Package Constants
DECLARE
BEGIN
    DBMS_OUTPUT.PUT_LINE('Package Constants:');
    DBMS_OUTPUT.PUT_LINE('  Minimum Cost: $' || equipment_management_pkg.c_min_cost);
    DBMS_OUTPUT.PUT_LINE('  Markup Rate: ' || equipment_management_pkg.c_markup_rate);
    DBMS_OUTPUT.PUT_LINE('  Max Utilization: ' || equipment_management_pkg.c_max_utilization || '%');
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 2: Package Procedure - assign_equipment_to_operator
DECLARE
    v_assignment_id NUMBER;
    v_status VARCHAR2(500);
BEGIN
    equipment_management_pkg.assign_equipment_to_operator(
        p_equipment_id => 65,
        p_operator_id => 5,
        p_site_id => 2,
        p_start_time => SYSTIMESTAMP,
        p_assignment_id => v_assignment_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Assignment ID: ' || NVL(TO_CHAR(v_assignment_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 3: Package Procedure - record_maintenance
DECLARE
    v_cost NUMBER := 50.00;  -- Below minimum to test markup
    v_history_id NUMBER;
    v_status VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Original Cost: $' || v_cost);
    DBMS_OUTPUT.PUT_LINE('Minimum Cost Threshold: $' || equipment_management_pkg.c_min_cost);
    DBMS_OUTPUT.PUT_LINE('Markup Rate: ' || equipment_management_pkg.c_markup_rate);
    
    -- Get next ID from table (no sequence needed)
    SELECT NVL(MAX(history_id), 0) + 1 INTO v_history_id FROM maintenance_history;
    
    equipment_management_pkg.record_maintenance(
        p_equipment_id => 65,
        p_notes => 'Routine inspection and minor repairs',
        p_cost => v_cost,
        p_duration_hours => 1.5,
        p_performed_by => 1,
        p_history_id => v_history_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Cost After Markup: $' || v_cost);
    DBMS_OUTPUT.PUT_LINE('History ID: ' || NVL(TO_CHAR(v_history_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 4: Package Procedure - update_equipment_status
DECLARE
    v_old_status VARCHAR2(50);
    v_status VARCHAR2(500);
BEGIN
    equipment_management_pkg.update_equipment_status(
        p_equipment_id => 65,
        p_new_status => 'Available',
        p_reason => 'Maintenance completed successfully',
        p_old_status => v_old_status,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Previous Status: ' || v_old_status);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 5: Package Functions - Individual Tests
DECLARE
    v_utilization NUMBER;
    v_cost NUMBER;
    v_availability VARCHAR2(50);
    v_summary VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing Package Functions for Equipment ID 1:');
    DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────');
    
    -- Test calculate_utilization_rate
    v_utilization := equipment_management_pkg.calculate_utilization_rate(1);
    DBMS_OUTPUT.PUT_LINE('1. Utilization Rate: ' || NVL(TO_CHAR(v_utilization), 'NULL') || '%');
    
    -- Test get_total_maintenance_cost
    v_cost := equipment_management_pkg.get_total_maintenance_cost(1);
    DBMS_OUTPUT.PUT_LINE('2. Total Maintenance Cost: $' || NVL(TO_CHAR(v_cost), '0'));
    
    -- Test get_equipment_status_summary
    v_summary := equipment_management_pkg.get_equipment_status_summary(1);
    DBMS_OUTPUT.PUT_LINE('3. Status Summary: ' || v_summary);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Testing Operator Availability:');
    DBMS_OUTPUT.PUT_LINE('──────────────────────────────────────────────');
    
    -- Test validate_operator_availability
    v_availability := equipment_management_pkg.validate_operator_availability(1);
    DBMS_OUTPUT.PUT_LINE('4. Operator 1: ' || v_availability);
    
    v_availability := equipment_management_pkg.validate_operator_availability(2);
    DBMS_OUTPUT.PUT_LINE('5. Operator 2: ' || v_availability);
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 6: Package Functions in SQL Query
SELECT 
    e.equipment_id,
    e.equipment_type,
    e.model,
    equipment_management_pkg.calculate_utilization_rate(e.equipment_id) as utilization_pct,
    equipment_management_pkg.get_total_maintenance_cost(e.equipment_id) as total_cost,
    equipment_management_pkg.get_equipment_status_summary(e.equipment_id) as status_summary
FROM equipment e
WHERE ROWNUM <= 5
ORDER BY e.equipment_id;

-- TEST 7: Package Procedure - process_overdue_maintenance
BEGIN
    equipment_management_pkg.process_overdue_maintenance(p_days_overdue => 60);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 8: Operator Availability Check via SQL
SELECT 
    o.operator_id,
    o.first_name || ' ' || o.last_name as operator_name,
    o.status,
    equipment_management_pkg.validate_operator_availability(o.operator_id, SYSDATE) as availability_status
FROM operators o
WHERE ROWNUM <= 5
ORDER BY o.operator_id;

-- TEST 9: Error Handling Test - Invalid Equipment
DECLARE
    v_assignment_id NUMBER;
    v_status VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing error handling with invalid equipment ID 99999:');
    
    equipment_management_pkg.assign_equipment_to_operator(
        p_equipment_id => 99999,  -- Invalid ID
        p_operator_id => 1,
        p_site_id => 1,
        p_start_time => SYSTIMESTAMP,
        p_assignment_id => v_assignment_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Assignment ID: ' || NVL(TO_CHAR(v_assignment_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 10: Error Handling Test - Invalid Operator
DECLARE
    v_assignment_id NUMBER;
    v_status VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing error handling with invalid operator ID 99999:');
    
    equipment_management_pkg.assign_equipment_to_operator(
        p_equipment_id => 1,
        p_operator_id => 99999,  -- Invalid ID
        p_site_id => 1,
        p_start_time => SYSTIMESTAMP,
        p_assignment_id => v_assignment_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 11: IN OUT Parameter Test - Cost Markup
DECLARE
    v_cost1 NUMBER := 50.00;   -- Below threshold
    v_cost2 NUMBER := 150.00;  -- Above threshold
    v_history_id NUMBER;
    v_status VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Test 1: Cost below threshold ($50)');
    DBMS_OUTPUT.PUT_LINE('  Before: $' || v_cost1);
    
    -- Get next ID from table
    SELECT NVL(MAX(history_id), 0) + 1 INTO v_history_id FROM maintenance_history;
    
    equipment_management_pkg.record_maintenance(
        p_equipment_id => 1,
        p_notes => 'Test maintenance 1',
        p_cost => v_cost1,
        p_duration_hours => 1,
        p_performed_by => 1,
        p_history_id => v_history_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('  After: $' || v_cost1);
    DBMS_OUTPUT.PUT_LINE('  Markup Applied: ' || 
        CASE WHEN v_cost1 > 50 THEN 'YES' ELSE 'NO' END);
    DBMS_OUTPUT.PUT_LINE('');
    
    DBMS_OUTPUT.PUT_LINE('Test 2: Cost above threshold ($150)');
    DBMS_OUTPUT.PUT_LINE('  Before: $' || v_cost2);
    
    -- Get next ID from table
    SELECT NVL(MAX(history_id), 0) + 1 INTO v_history_id FROM maintenance_history;
    
    equipment_management_pkg.record_maintenance(
        p_equipment_id => 5,
        p_notes => 'Test maintenance 2',
        p_cost => v_cost2,
        p_duration_hours => 1,
        p_performed_by => 1,
        p_history_id => v_history_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('  After: $' || v_cost2);
    DBMS_OUTPUT.PUT_LINE('  Markup Applied: ' || 
        CASE WHEN v_cost2 > 150 THEN 'YES' ELSE 'NO' END);
    DBMS_OUTPUT.PUT_LINE('');
END;
/