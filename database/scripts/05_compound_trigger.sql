SET SERVEROUTPUT ON SIZE UNLIMITED;
-- ============================================================================
-- COMPOUND TRIGGER: 
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_equipment_assignment_compound
FOR INSERT OR UPDATE OR DELETE ON equipment_assignment
COMPOUND TRIGGER

    -- Package-level variables (shared across all timing points)
    g_operation_count PLS_INTEGER := 0;
    g_allowed_count PLS_INTEGER := 0;
    g_denied_count PLS_INTEGER := 0;
    g_check_result VARCHAR2(500);

    -- ========================================================================
    -- BEFORE STATEMENT: Initialize counters and check overall permission
    -- ========================================================================
    BEFORE STATEMENT IS
    BEGIN
        -- Reset counters
        g_operation_count := 0;
        g_allowed_count := 0;
        g_denied_count := 0;
        
        -- Check if operations are allowed
        g_check_result := check_operation_allowed();
        
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
        DBMS_OUTPUT.PUT_LINE('COMPOUND TRIGGER: BEFORE STATEMENT');
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
        DBMS_OUTPUT.PUT_LINE('Operation Check: ' || g_check_result);
        DBMS_OUTPUT.PUT_LINE('Time: ' || TO_CHAR(SYSTIMESTAMP, 'DD-MON-YYYY HH24:MI:SS'));
        
    END BEFORE STATEMENT;

    -- ========================================================================
    -- BEFORE EACH ROW: Validate and log individual row operations
    -- ========================================================================
    BEFORE EACH ROW IS
        v_audit_id NUMBER;
        v_operation_type VARCHAR2(10);
        v_assignment_id NUMBER;
    BEGIN
        -- Determine operation type
        IF INSERTING THEN
            v_operation_type := 'INSERT';
            v_assignment_id := :NEW.assignment_id;
        ELSIF UPDATING THEN
            v_operation_type := 'UPDATE';
            v_assignment_id := :OLD.assignment_id;
        ELSIF DELETING THEN
            v_operation_type := 'DELETE';
            v_assignment_id := :OLD.assignment_id;
        END IF;
        
        g_operation_count := g_operation_count + 1;
        
        -- Log the operation attempt
        v_audit_id := log_audit_event(
            p_table_name => 'EQUIPMENT_ASSIGNMENT',
            p_operation_type => v_operation_type,
            p_operation_status => CASE 
                WHEN g_check_result = 'ALLOWED' THEN 'ALLOWED'
                ELSE 'DENIED'
            END,
            p_record_id => v_assignment_id,
            p_old_values => CASE 
                WHEN DELETING OR UPDATING THEN 
                    'Equipment: ' || :OLD.equipment_id || 
                    ', Operator: ' || :OLD.operator_id ||
                    ', Site: ' || :OLD.site_id
                ELSE NULL
            END,
            p_new_values => CASE 
                WHEN INSERTING OR UPDATING THEN 
                    'Equipment: ' || :NEW.equipment_id || 
                    ', Operator: ' || :NEW.operator_id ||
                    ', Site: ' || :NEW.site_id
                ELSE NULL
            END,
            p_denial_reason => CASE 
                WHEN g_check_result = 'ALLOWED' THEN NULL
                ELSE g_check_result
            END
        );
        
        -- If denied, raise error
        IF g_check_result != 'ALLOWED' THEN
            g_denied_count := g_denied_count + 1;
            RAISE_APPLICATION_ERROR(-20004, g_check_result);
        ELSE
            g_allowed_count := g_allowed_count + 1;
        END IF;
        
    END BEFORE EACH ROW;

    -- ========================================================================
    -- AFTER EACH ROW: Track successful operations
    -- ========================================================================
    AFTER EACH ROW IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('  ✓ Row operation completed successfully');
    END AFTER EACH ROW;

    -- ========================================================================
    -- AFTER STATEMENT: Generate summary report
    -- ========================================================================
    AFTER STATEMENT IS
    BEGIN
        DBMS_OUTPUT.PUT_LINE('');
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
        DBMS_OUTPUT.PUT_LINE('COMPOUND TRIGGER: AFTER STATEMENT - SUMMARY');
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
        DBMS_OUTPUT.PUT_LINE('Total Operations Attempted: ' || g_operation_count);
        DBMS_OUTPUT.PUT_LINE('Operations Allowed: ' || g_allowed_count);
        DBMS_OUTPUT.PUT_LINE('Operations Denied: ' || g_denied_count);
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
        
    END AFTER STATEMENT;

END trg_equipment_assignment_compound;
/
SELECT 
    trigger_name,
    trigger_type,
    status
FROM user_triggers
WHERE trigger_name = 'TRG_EQUIPMENT_ASSIGNMENT_COMPOUND';

SHOW ERRORS TRIGGER trg_equipment_assignment_compound;