SET SERVEROUTPUT ON SIZE UNLIMITED;
-- ============================================================================
-- TRIGGER 1: BEFORE INSERT Trigger on EQUIPMENT table 
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_equipment_before_insert
BEFORE INSERT ON equipment
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(500);
    v_audit_id NUMBER;
BEGIN
    -- Check if operation is allowed
    v_check_result := check_operation_allowed();
    
    -- Log the attempt
    v_audit_id := log_audit_event(
        p_table_name => 'EQUIPMENT',
        p_operation_type => 'INSERT',
        p_operation_status => CASE 
            WHEN v_check_result = 'ALLOWED' THEN 'ALLOWED'
            ELSE 'DENIED'
        END,
        p_record_id => :NEW.equipment_id,
        p_new_values => 'Type: ' || :NEW.equipment_type || 
                       ', Model: ' || :NEW.model ||
                       ', Serial: ' || :NEW.serial_number ||
                       ', Status: ' || :NEW.status,
        p_denial_reason => CASE 
            WHEN v_check_result = 'ALLOWED' THEN NULL
            ELSE v_check_result
        END
    );
    
    -- If denied, raise error
    IF v_check_result != 'ALLOWED' THEN
        RAISE_APPLICATION_ERROR(-20001, v_check_result);
    END IF;
    
END trg_equipment_before_insert;
/
-- ============================================================================
-- TRIGGER 2: BEFORE UPDATE Trigger on EQUIPMENT table 
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_equipment_before_update
BEFORE UPDATE ON equipment
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(500);
    v_audit_id NUMBER;
    v_old_values VARCHAR2(1000);
    v_new_values VARCHAR2(1000);
BEGIN
    -- Check if operation is allowed
    v_check_result := check_operation_allowed();
    
    -- Build old and new values strings
    v_old_values := 'Type: ' || :OLD.equipment_type || 
                   ', Model: ' || :OLD.model ||
                   ', Status: ' || :OLD.status ||
                   ', Dept: ' || :OLD.department_id;
                   
    v_new_values := 'Type: ' || :NEW.equipment_type || 
                   ', Model: ' || :NEW.model ||
                   ', Status: ' || :NEW.status ||
                   ', Dept: ' || :NEW.department_id;
    
    -- Log the attempt
    v_audit_id := log_audit_event(
        p_table_name => 'EQUIPMENT',
        p_operation_type => 'UPDATE',
        p_operation_status => CASE 
            WHEN v_check_result = 'ALLOWED' THEN 'ALLOWED'
            ELSE 'DENIED'
        END,
        p_record_id => :OLD.equipment_id,
        p_old_values => v_old_values,
        p_new_values => v_new_values,
        p_denial_reason => CASE 
            WHEN v_check_result = 'ALLOWED' THEN NULL
            ELSE v_check_result
        END
    );
    
    -- If denied, raise error
    IF v_check_result != 'ALLOWED' THEN
        RAISE_APPLICATION_ERROR(-20002, v_check_result);
    END IF;
    
END trg_equipment_before_update;
/
-- ============================================================================
-- TRIGGER 3: BEFORE DELETE Trigger on EQUIPMENT table 
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_equipment_before_delete
BEFORE DELETE ON equipment
FOR EACH ROW
DECLARE
    v_check_result VARCHAR2(500);
    v_audit_id NUMBER;
BEGIN
    -- Check if operation is allowed
    v_check_result := check_operation_allowed();
    
    -- Log the attempt
    v_audit_id := log_audit_event(
        p_table_name => 'EQUIPMENT',
        p_operation_type => 'DELETE',
        p_operation_status => CASE 
            WHEN v_check_result = 'ALLOWED' THEN 'ALLOWED'
            ELSE 'DENIED'
        END,
        p_record_id => :OLD.equipment_id,
        p_old_values => 'Type: ' || :OLD.equipment_type || 
                       ', Model: ' || :OLD.model ||
                       ', Serial: ' || :OLD.serial_number ||
                       ', Status: ' || :OLD.status,
        p_denial_reason => CASE 
            WHEN v_check_result = 'ALLOWED' THEN NULL
            ELSE v_check_result
        END
    );
    
    -- If denied, raise error
    IF v_check_result != 'ALLOWED' THEN
        RAISE_APPLICATION_ERROR(-20003, v_check_result);
    END IF;
    
END trg_equipment_before_delete;
/
SELECT 
    trigger_name,
    trigger_type,
    triggering_event,
    status
FROM user_triggers
WHERE trigger_name LIKE 'TRG_EQUIPMENT%'
  AND table_name = 'EQUIPMENT'
ORDER BY trigger_name;