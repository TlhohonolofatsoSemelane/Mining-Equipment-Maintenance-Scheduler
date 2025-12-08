SET SERVEROUTPUT ON SIZE UNLIMITED;
-- ============================================================================
-- FUNCTION 1: log_audit_event
-- Purpose: Log all database operations to audit table
-- ============================================================================

CREATE OR REPLACE FUNCTION log_audit_event(
    p_table_name VARCHAR2,
    p_operation_type VARCHAR2,
    p_operation_status VARCHAR2,
    p_record_id NUMBER DEFAULT NULL,
    p_old_values CLOB DEFAULT NULL,
    p_new_values CLOB DEFAULT NULL,
    p_denial_reason VARCHAR2 DEFAULT NULL
) RETURN NUMBER
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    
    v_audit_id NUMBER;
    v_day_of_week VARCHAR2(20);
    v_is_weekend CHAR(1);
    v_is_holiday CHAR(1);
    v_session_id NUMBER;
BEGIN
    -- Get next audit ID
    SELECT audit_log_seq.NEXTVAL INTO v_audit_id FROM DUAL;
    
    -- Get session ID
    v_session_id := SYS_CONTEXT('USERENV', 'SESSIONID');
    
    -- Determine day of week
    v_day_of_week := TRIM(TO_CHAR(SYSDATE, 'DAY'));
    
    -- Check if weekend
    IF TO_CHAR(SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
        v_is_weekend := 'Y';
    ELSE
        v_is_weekend := 'N';
    END IF;
    
    -- Check if holiday
    BEGIN
        SELECT CASE WHEN COUNT(*) > 0 THEN 'Y' ELSE 'N' END
        INTO v_is_holiday
        FROM public_holidays
        WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
          AND is_active = 'Y';
    EXCEPTION
        WHEN OTHERS THEN
            v_is_holiday := 'N';
    END;
    
    -- Insert audit record
    INSERT INTO audit_log (
        audit_id,
        table_name,
        operation_type,
        operation_status,
        record_id,
        old_values,
        new_values,
        denial_reason,
        username,
        session_id,
        operation_date,
        operation_timestamp,
        day_of_week,
        is_weekend,
        is_holiday
    ) VALUES (
        v_audit_id,
        p_table_name,
        p_operation_type,
        p_operation_status,
        p_record_id,
        p_old_values,
        p_new_values,
        p_denial_reason,
        USER,
        v_session_id,
        SYSDATE,
        SYSTIMESTAMP,
        v_day_of_week,
        v_is_weekend,
        v_is_holiday
    );
    
    COMMIT;
    
    RETURN v_audit_id;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RETURN -1;
END log_audit_event;
/
-- ============================================================================
-- FUNCTION 2: check_operation_allowed
-- Purpose: Check if database operation is allowed based on business rules
-- Returns: 'ALLOWED' or denial reason
-- Business Rules:
--   1. DENY on weekdays (Monday-Friday)
--   2. DENY on public holidays
--   3. ALLOW on weekends (Saturday-Sunday)
-- ============================================================================

CREATE OR REPLACE FUNCTION check_operation_allowed
RETURN VARCHAR2
IS
    v_day_of_week VARCHAR2(10);
    v_is_holiday NUMBER;
    v_holiday_name VARCHAR2(100);
BEGIN
    -- Get current day of week
    v_day_of_week := TO_CHAR(SYSDATE, 'DY');
    
    -- Check if today is a public holiday
    BEGIN
        SELECT COUNT(*), MAX(holiday_name)
        INTO v_is_holiday, v_holiday_name
        FROM public_holidays
        WHERE TRUNC(holiday_date) = TRUNC(SYSDATE)
          AND is_active = 'Y';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_is_holiday := 0;
    END;
    
    -- Rule 1: Block on public holidays (highest priority)
    IF v_is_holiday > 0 THEN
        RETURN 'DENIED: Operations not allowed on public holiday (' || v_holiday_name || ')';
    END IF;
    
    -- Rule 2: Block on weekdays (Monday-Friday)
    IF v_day_of_week IN ('MON', 'TUE', 'WED', 'THU', 'FRI') THEN
        RETURN 'DENIED: Operations not allowed on weekdays (Monday-Friday). Today is ' || 
               TRIM(TO_CHAR(SYSDATE, 'DAY')) || '. Please try on weekend.';
    END IF;
    
    -- Rule 3: Allow on weekends (Saturday-Sunday)
    IF v_day_of_week IN ('SAT', 'SUN') THEN
        RETURN 'ALLOWED';
    END IF;
    
    -- Default: Deny
    RETURN 'DENIED: Unknown day restriction';
    
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END check_operation_allowed;
/
-- ============================================================================
-- Test the functions
-- ============================================================================
DECLARE
    v_audit_id NUMBER;
    v_check_result VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('Current Date/Time Information:');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY DAY'));
    DBMS_OUTPUT.PUT_LINE('Time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE('Day of Week: ' || TRIM(TO_CHAR(SYSDATE, 'DAY')));
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test restriction check
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('Restriction Check Result:');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    v_check_result := check_operation_allowed();
    DBMS_OUTPUT.PUT_LINE(v_check_result);
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Test audit logging
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('Audit Logging Test:');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    v_audit_id := log_audit_event(
        p_table_name => 'TEST_TABLE',
        p_operation_type => 'INSERT',
        p_operation_status => 'ALLOWED',
        p_record_id => 999,
        p_new_values => '{"test": "data"}',
        p_denial_reason => NULL
    );
    
    DBMS_OUTPUT.PUT_LINE('Audit ID Created: ' || v_audit_id);
    DBMS_OUTPUT.PUT_LINE('✓ Audit log entry created successfully');
    DBMS_OUTPUT.PUT_LINE('');
END;
/
-- Display recent audit log
SELECT 
    audit_id,
    table_name,
    operation_type,
    operation_status,
    TO_CHAR(operation_date, 'DD-MON-YYYY HH24:MI:SS') as operation_time,
    day_of_week,
    is_weekend,
    is_holiday,
    username
FROM audit_log
ORDER BY audit_id DESC
FETCH FIRST 5 ROWS ONLY;