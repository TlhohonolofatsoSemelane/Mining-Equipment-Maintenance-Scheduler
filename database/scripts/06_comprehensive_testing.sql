SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;

-- Clear old audit entries for clean test
DELETE FROM audit_log WHERE table_name IN ('EQUIPMENT', 'EQUIPMENT_ASSIGNMENT', 'TEST_TABLE');
COMMIT;

-- ============================================================================
-- TEST 1: INSERT Operation on WEEKDAY (Should be DENIED)
-- ============================================================================
DECLARE
    v_error_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Attempting to INSERT new equipment...');
    DBMS_OUTPUT.PUT_LINE('Current Day: ' || TRIM(TO_CHAR(SYSDATE, 'DAY')));
    DBMS_OUTPUT.PUT_LINE('');
    
    INSERT INTO equipment (
        equipment_id,
        equipment_type,
        model,
        serial_number,
        purchase_date,
        capacity,
        status,
        department_id
    ) VALUES (
        999,
        'Test Equipment',
        'Test Model X1',
        'TEST-999',
        SYSDATE,
        100.00,
        'Available',
        1
    );
    
    DBMS_OUTPUT.PUT_LINE('✗ UNEXPECTED: INSERT successful on weekday!');
    ROLLBACK;
    
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('✓ EXPECTED: INSERT DENIED');
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        DBMS_OUTPUT.PUT_LINE('');
        ROLLBACK;
END;
/

-- ============================================================================
-- TEST 2: UPDATE Operation on WEEKDAY (Should be DENIED)
-- ============================================================================
DECLARE
    v_error_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Attempting to UPDATE existing equipment...');
    DBMS_OUTPUT.PUT_LINE('');
    
    UPDATE equipment
    SET status = 'Maintenance',
        last_maintenance_date = SYSDATE
    WHERE equipment_id = 1;
    
    DBMS_OUTPUT.PUT_LINE('✗ UNEXPECTED: UPDATE successful on weekday!');
    ROLLBACK;
    
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('✓ EXPECTED: UPDATE DENIED');
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        DBMS_OUTPUT.PUT_LINE('');
        ROLLBACK;
END;
/

-- ============================================================================
-- TEST 3: DELETE Operation on WEEKDAY (Should be DENIED)
-- ============================================================================

DECLARE
    v_error_message VARCHAR2(500);
    v_count NUMBER;
BEGIN
    -- Check if record exists first
    SELECT COUNT(*) INTO v_count FROM equipment WHERE equipment_id = 1;
    
    DBMS_OUTPUT.PUT_LINE('Attempting to DELETE equipment (ID=1)...');
    DBMS_OUTPUT.PUT_LINE('Record exists: ' || CASE WHEN v_count > 0 THEN 'YES' ELSE 'NO' END);
    DBMS_OUTPUT.PUT_LINE('');
    
    DELETE FROM equipment
    WHERE equipment_id = 1;
    
    DBMS_OUTPUT.PUT_LINE('✗ UNEXPECTED: DELETE successful on weekday!');
    DBMS_OUTPUT.PUT_LINE('Rows affected: ' || SQL%ROWCOUNT);
    ROLLBACK;
    
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('✓ EXPECTED: DELETE DENIED');
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        DBMS_OUTPUT.PUT_LINE('');
        ROLLBACK;
END;
/

-- ============================================================================
-- TEST 4: Compound Trigger Test
-- ============================================================================

DECLARE
    v_error_message VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Attempting to INSERT into equipment_assignment...');
    DBMS_OUTPUT.PUT_LINE('');
    
    INSERT INTO equipment_assignment (
        assignment_id,
        equipment_id,
        operator_id,
        site_id,
        start_time
    ) VALUES (
        9999,
        1,
        1,
        1,
        SYSTIMESTAMP
    );
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('✗ UNEXPECTED: INSERT successful on weekday!');
    ROLLBACK;
    
EXCEPTION
    WHEN OTHERS THEN
        v_error_message := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('✓ EXPECTED: INSERT DENIED');
        DBMS_OUTPUT.PUT_LINE('Error: ' || v_error_message);
        DBMS_OUTPUT.PUT_LINE('');
        ROLLBACK;
END;
/

-- ============================================================================
-- TEST 5: Verify Audit Log
-- ============================================================================

SELECT 
    audit_id,
    table_name,
    operation_type,
    operation_status,
    TO_CHAR(operation_date, 'HH24:MI:SS') as time,
    day_of_week,
    is_weekend,
    is_holiday,
    SUBSTR(denial_reason, 1, 50) as denial_reason
FROM audit_log
ORDER BY audit_id DESC;

SELECT 
    operation_status,
    COUNT(*) as total,
    LISTAGG(table_name, ', ') WITHIN GROUP (ORDER BY table_name) as tables
FROM audit_log
GROUP BY operation_status;
