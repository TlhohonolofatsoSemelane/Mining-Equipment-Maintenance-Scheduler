SET SERVEROUTPUT ON SIZE UNLIMITED;
-- TEST 1: assign_equipment_to_operator 
DECLARE
    v_assignment_id NUMBER;
    v_status VARCHAR2(500);
BEGIN
    assign_equipment_to_operator(
        p_equipment_id => 61,
        p_operator_id => 1,  -- CHANGED: Using valid operator ID
        p_site_id => 1,
        p_start_time => SYSTIMESTAMP,
        p_assignment_id => v_assignment_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Assignment ID: ' || NVL(TO_CHAR(v_assignment_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 2: record_maintenance
DECLARE
    v_cost NUMBER := 75.00;  -- Below $100 to trigger markup
    v_history_id NUMBER;
    v_status VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Original Cost: $' || v_cost);
    
    -- Get next sequence value first
    SELECT maintenance_history_seq.NEXTVAL INTO v_history_id FROM DUAL;
    
    record_maintenance(
        p_equipment_id => 61,
        p_notes => 'Oil change and filter replacement',
        p_cost => v_cost,
        p_duration_hours => 2,
        p_performed_by => 1,
        p_history_id => v_history_id,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Final Cost (after markup): $' || v_cost);
    DBMS_OUTPUT.PUT_LINE('History ID: ' || NVL(TO_CHAR(v_history_id), 'NULL'));
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 3: update_equipment_status
DECLARE
    v_old_status VARCHAR2(50);
    v_status VARCHAR2(500);
BEGIN
    update_equipment_status(
        p_equipment_id => 61,
        p_new_status => 'Available',
        p_reason => 'Maintenance completed',
        p_old_status => v_old_status,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Old Status: ' || v_old_status);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 4: bulk_update_equipment_status
DECLARE
    v_records_updated NUMBER;
    v_status VARCHAR2(500);
BEGIN
    bulk_update_equipment_status(
        p_equipment_type => 'Excavator',
        p_old_status => 'Available',
        p_new_status => 'Available',  -- Same to avoid actual changes
        p_records_updated => v_records_updated,
        p_status => v_status
    );
    
    DBMS_OUTPUT.PUT_LINE('Status: ' || v_status);
    DBMS_OUTPUT.PUT_LINE('Records Updated: ' || v_records_updated);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 5: generate_utilization_report
BEGIN
    generate_utilization_report(
        p_start_date => ADD_MONTHS(SYSDATE, -1),
        p_end_date => SYSDATE,
        p_equipment_type => NULL
    );
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 6: process_overdue_maintenance
BEGIN
    process_overdue_maintenance(p_days_overdue => 30);
    DBMS_OUTPUT.PUT_LINE('');
END;
/

-- TEST 7: bulk_update_equipment_metrics
BEGIN
    bulk_update_equipment_metrics(
        p_start_date => ADD_MONTHS(SYSDATE, -1),
        p_end_date => SYSDATE
    );
    DBMS_OUTPUT.PUT_LINE('');
END;
/