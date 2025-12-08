SET SERVEROUTPUT ON SIZE UNLIMITED;
-- ============================================================================
-- PROCEDURE 1: Assign Equipment to Operator
-- Purpose: Create new equipment assignment with validation
-- Parameters: IN, OUT, exception handling
-- ============================================================================

CREATE OR REPLACE PROCEDURE assign_equipment_to_operator (
    p_equipment_id IN NUMBER,
    p_operator_id IN NUMBER,
    p_site_id IN NUMBER,
    p_start_time IN TIMESTAMP DEFAULT SYSTIMESTAMP,
    p_assignment_id OUT NUMBER,
    p_status OUT VARCHAR2
) AS
    -- Local variables
    v_equipment_status VARCHAR2(50);
    v_operator_status VARCHAR2(50);
    v_site_exists NUMBER;
    
    -- Custom exceptions
    equipment_not_available EXCEPTION;
    invalid_operator EXCEPTION;
    invalid_site EXCEPTION;
    
BEGIN
    -- Validate equipment exists and is available
    BEGIN
        SELECT status INTO v_equipment_status
        FROM equipment
        WHERE equipment_id = p_equipment_id;
        
        IF v_equipment_status != 'Available' THEN
            RAISE equipment_not_available;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 'ERROR: Equipment ID ' || p_equipment_id || ' does not exist';
            log_error(SQLCODE, SQLERRM, 'assign_equipment_to_operator', 
                     'Equipment ID: ' || p_equipment_id);
            RETURN;
    END;
    
    -- Validate operator exists and is active
    BEGIN
        SELECT status INTO v_operator_status
        FROM operators
        WHERE operator_id = p_operator_id;
        
        IF v_operator_status != 'Active' THEN
            RAISE invalid_operator;
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 'ERROR: Operator ID ' || p_operator_id || ' does not exist';
            log_error(SQLCODE, SQLERRM, 'assign_equipment_to_operator',
                     'Operator ID: ' || p_operator_id);
            RETURN;
    END;
    
    -- Validate site exists
    SELECT COUNT(*) INTO v_site_exists
    FROM mining_sites
    WHERE site_id = p_site_id;
    
    IF v_site_exists = 0 THEN
        RAISE invalid_site;
    END IF;
    
    -- Create assignment (using your actual column names)
    INSERT INTO equipment_assignment (
        equipment_id,
        operator_id,
        site_id,
        assignment_date,
        start_time,
        end_time,
        status
    ) VALUES (
        p_equipment_id,
        p_operator_id,
        p_site_id,
        TRUNC(SYSDATE),
        p_start_time,
        NULL,
        'Active'
    ) RETURNING assignment_id INTO p_assignment_id;
    
    -- Update equipment status
    UPDATE equipment
    SET status = 'In-Use'
    WHERE equipment_id = p_equipment_id;
    
    COMMIT;
    
    p_status := 'SUCCESS: Assignment created with ID ' || p_assignment_id;
    
    DBMS_OUTPUT.PUT_LINE('✓ Equipment ' || p_equipment_id || 
                        ' assigned to Operator ' || p_operator_id);
    
EXCEPTION
    WHEN equipment_not_available THEN
        ROLLBACK;
        p_status := 'ERROR: Equipment is not available (Status: ' || v_equipment_status || ')';
        log_error(-20001, 'Equipment not available', 'assign_equipment_to_operator',
                 'Equipment ID: ' || p_equipment_id || ', Status: ' || v_equipment_status);
        
    WHEN invalid_operator THEN
        ROLLBACK;
        p_status := 'ERROR: Operator is not active (Status: ' || v_operator_status || ')';
        log_error(-20002, 'Invalid operator', 'assign_equipment_to_operator',
                 'Operator ID: ' || p_operator_id || ', Status: ' || v_operator_status);
        
    WHEN invalid_site THEN
        ROLLBACK;
        p_status := 'ERROR: Site ID ' || p_site_id || ' does not exist';
        log_error(-20003, 'Invalid site', 'assign_equipment_to_operator',
                 'Site ID: ' || p_site_id);
        
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR: ' || SQLERRM;
        log_error(SQLCODE, SQLERRM, 'assign_equipment_to_operator',
                 'Equipment: ' || p_equipment_id || ', Operator: ' || p_operator_id);
END assign_equipment_to_operator;
/

-- ============================================================================
-- PROCEDURE 2: Record Maintenance Activity
-- Purpose: Log maintenance with cost validation
-- Parameters: IN, IN OUT, exception handling
-- ============================================================================

CREATE OR REPLACE PROCEDURE record_maintenance (
    p_equipment_id IN NUMBER,
    p_notes IN VARCHAR2,
    p_cost IN OUT NUMBER,
    p_duration_hours IN NUMBER,
    p_performed_by IN NUMBER,
    p_history_id OUT NUMBER,
    p_status OUT VARCHAR2
) AS
    -- Local variables
    v_equipment_exists NUMBER;
    v_crew_exists NUMBER;
    v_start_date TIMESTAMP := SYSTIMESTAMP;
    v_end_date TIMESTAMP := SYSTIMESTAMP + NUMTODSINTERVAL(p_duration_hours, 'HOUR');
    
    -- Custom exceptions
    invalid_cost EXCEPTION;
    invalid_duration EXCEPTION;
    
BEGIN
    -- Validate cost
    IF p_cost < 0 THEN
        RAISE invalid_cost;
    END IF;
    
    -- Apply 10% markup if cost is too low (business rule)
    IF p_cost < 100 THEN
        p_cost := p_cost * 1.10;
        DBMS_OUTPUT.PUT_LINE('⚠ Cost adjusted with 10% markup: $' || 
                            TO_CHAR(p_cost, '999,999.99'));
    END IF;
    
    -- Validate duration
    IF p_duration_hours < 0 THEN
        RAISE invalid_duration;
    END IF;
    
    -- Validate equipment exists
    SELECT COUNT(*) INTO v_equipment_exists
    FROM equipment
    WHERE equipment_id = p_equipment_id;
    
    IF v_equipment_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Equipment ID does not exist');
    END IF;
    
    -- Validate crew member exists
    SELECT COUNT(*) INTO v_crew_exists
    FROM maintenance_crew
    WHERE crew_id = p_performed_by;
    
    IF v_crew_exists = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Crew member ID does not exist');
    END IF;
    
    INSERT INTO maintenance_history (
        equipment_id,
        start_date,
        end_date,
        actual_duration_hours,
        cost,
        notes,
        performed_by
    ) VALUES (
        p_equipment_id,
        v_start_date,
        v_end_date,
        p_duration_hours,
        p_cost,
        p_notes,
        p_performed_by
    ) RETURNING history_id INTO p_history_id;
    
    -- Update equipment status
    UPDATE equipment
    SET status = 'Maintenance',
        last_maintenance_date = SYSDATE
    WHERE equipment_id = p_equipment_id;
    
    COMMIT;
    
    p_status := 'SUCCESS: Maintenance recorded with ID ' || p_history_id;
    DBMS_OUTPUT.PUT_LINE('✓ Maintenance completed for Equipment ' || p_equipment_id);
    
EXCEPTION
    WHEN invalid_cost THEN
        ROLLBACK;
        p_status := 'ERROR: Cost cannot be negative';
        log_error(-20006, 'Invalid cost', 'record_maintenance',
                 'Cost: ' || p_cost);
        
    WHEN invalid_duration THEN
        ROLLBACK;
        p_status := 'ERROR: Duration cannot be negative';
        log_error(-20007, 'Invalid duration', 'record_maintenance',
                 'Duration: ' || p_duration_hours);
        
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR: ' || SQLERRM;
        log_error(SQLCODE, SQLERRM, 'record_maintenance',
                 'Equipment: ' || p_equipment_id);
END record_maintenance;
/

-- ============================================================================
-- PROCEDURE 3: Update Equipment Status
-- Purpose: Change equipment status with validation
-- Parameters: IN, OUT, business logic
-- ============================================================================

CREATE OR REPLACE PROCEDURE update_equipment_status (
    p_equipment_id IN NUMBER,
    p_new_status IN VARCHAR2,
    p_reason IN VARCHAR2 DEFAULT NULL,
    p_old_status OUT VARCHAR2,
    p_status OUT VARCHAR2
) AS
    v_current_status VARCHAR2(50);
    v_active_assignments NUMBER;
    
    invalid_status_transition EXCEPTION;
    equipment_in_use EXCEPTION;
    
BEGIN
    -- Get current status
    BEGIN
        SELECT status INTO v_current_status
        FROM equipment
        WHERE equipment_id = p_equipment_id;
        
        p_old_status := v_current_status;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 'ERROR: Equipment ID ' || p_equipment_id || ' does not exist';
            RETURN;
    END;
    
    -- Validate status transition
    IF p_new_status NOT IN ('Available', 'In-Use', 'Maintenance', 'Retired') THEN
        RAISE invalid_status_transition;
    END IF;
    
    -- Check if equipment has active assignments when retiring
    IF p_new_status = 'Retired' THEN
        SELECT COUNT(*) INTO v_active_assignments
        FROM equipment_assignment
        WHERE equipment_id = p_equipment_id
        AND end_time IS NULL;
        
        IF v_active_assignments > 0 THEN
            RAISE equipment_in_use;
        END IF;
    END IF;
    
    -- Update status
    UPDATE equipment
    SET status = p_new_status,
        last_maintenance_date = CASE 
            WHEN p_new_status = 'Maintenance' THEN SYSDATE 
            ELSE last_maintenance_date 
        END
    WHERE equipment_id = p_equipment_id;
    
    COMMIT;
    
    p_status := 'SUCCESS: Status updated from ' || v_current_status || ' to ' || p_new_status;
    DBMS_OUTPUT.PUT_LINE('✓ Equipment ' || p_equipment_id || ' status: ' || 
                        v_current_status || ' → ' || p_new_status);
    
EXCEPTION
    WHEN invalid_status_transition THEN
        ROLLBACK;
        p_status := 'ERROR: Invalid status "' || p_new_status || '"';
        log_error(-20008, 'Invalid status transition', 'update_equipment_status',
                 'New status: ' || p_new_status);
        
    WHEN equipment_in_use THEN
        ROLLBACK;
        p_status := 'ERROR: Cannot retire equipment with active assignments';
        log_error(-20009, 'Equipment in use', 'update_equipment_status',
                 'Equipment ID: ' || p_equipment_id);
        
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR: ' || SQLERRM;
        log_error(SQLCODE, SQLERRM, 'update_equipment_status',
                 'Equipment ID: ' || p_equipment_id);
END update_equipment_status;
/

-- ============================================================================
-- PROCEDURE 4: Bulk Equipment Status Update
-- Purpose: Update multiple equipment statuses efficiently
-- Parameters: Bulk operations, cursor processing
-- ============================================================================

CREATE OR REPLACE PROCEDURE bulk_update_equipment_status (
    p_equipment_type IN VARCHAR2,
    p_old_status IN VARCHAR2,
    p_new_status IN VARCHAR2,
    p_records_updated OUT NUMBER,
    p_status OUT VARCHAR2
) AS
    -- Cursor for equipment to update
    CURSOR c_equipment IS
        SELECT equipment_id
        FROM equipment
        WHERE equipment_type = p_equipment_type
        AND status = p_old_status
        FOR UPDATE OF status NOWAIT;
    
    -- Bulk collection variables
    TYPE t_equipment_ids IS TABLE OF equipment.equipment_id%TYPE;
    v_equipment_ids t_equipment_ids;
    
    v_count NUMBER := 0;
    resource_busy EXCEPTION;
    PRAGMA EXCEPTION_INIT(resource_busy, -54);
    
BEGIN
    -- Open cursor and fetch all matching records
    OPEN c_equipment;
    FETCH c_equipment BULK COLLECT INTO v_equipment_ids;
    CLOSE c_equipment;
    
    -- Update in bulk
    FORALL i IN 1..v_equipment_ids.COUNT
        UPDATE equipment
        SET status = p_new_status,
            last_maintenance_date = CASE 
                WHEN p_new_status = 'Maintenance' THEN SYSDATE 
                ELSE last_maintenance_date 
            END
        WHERE equipment_id = v_equipment_ids(i);
    
    v_count := SQL%ROWCOUNT;
    p_records_updated := v_count;
    
    COMMIT;
    
    p_status := 'SUCCESS: Updated ' || v_count || ' equipment records';
    DBMS_OUTPUT.PUT_LINE('✓ Bulk update complete: ' || v_count || ' records');
    
EXCEPTION
    WHEN resource_busy THEN
        ROLLBACK;
        p_status := 'ERROR: Records locked by another user';
        log_error(-54, 'Resource busy', 'bulk_update_equipment_status',
                 'Type: ' || p_equipment_type);
        
    WHEN OTHERS THEN
        ROLLBACK;
        p_status := 'ERROR: ' || SQLERRM;
        log_error(SQLCODE, SQLERRM, 'bulk_update_equipment_status',
                 'Type: ' || p_equipment_type);
END bulk_update_equipment_status;
/

-- ============================================================================
-- PROCEDURE 5: Generate Equipment Utilization Report
-- Purpose: Calculate and display equipment utilization metrics
-- Parameters: IN, cursor processing, calculations
-- ============================================================================

CREATE OR REPLACE PROCEDURE generate_utilization_report (
    p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -1),
    p_end_date IN DATE DEFAULT SYSDATE,
    p_equipment_type IN VARCHAR2 DEFAULT NULL
) AS
    -- Cursor for equipment utilization (CORRECTED COLUMN NAMES)
    CURSOR c_utilization IS
        SELECT 
            e.equipment_id,
            e.equipment_type,
            e.model,
            e.status,
            COUNT(DISTINCT ea.assignment_id) as assignment_count,
            SUM(NVL(eu.hours_operated, 0)) as total_hours,
            SUM(NVL(eu.fuel_consumed_liters, 0)) as total_fuel,
            COUNT(DISTINCT mh.history_id) as maintenance_count,
            SUM(NVL(mh.cost, 0)) as total_maintenance_cost
        FROM equipment e
        LEFT JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
            AND TRUNC(ea.assignment_date) BETWEEN p_start_date AND p_end_date
        LEFT JOIN equipment_usage_log eu ON e.equipment_id = eu.equipment_id
            AND eu.log_date BETWEEN p_start_date AND p_end_date
        LEFT JOIN maintenance_history mh ON e.equipment_id = mh.equipment_id
            AND TRUNC(CAST(mh.start_date AS DATE)) BETWEEN p_start_date AND p_end_date
        WHERE (p_equipment_type IS NULL OR e.equipment_type = p_equipment_type)
        GROUP BY e.equipment_id, e.equipment_type, e.model, e.status
        ORDER BY total_hours DESC NULLS LAST;
    
    v_rec c_utilization%ROWTYPE;
    v_total_equipment NUMBER := 0;
    v_total_hours NUMBER := 0;
    v_total_cost NUMBER := 0;
    
BEGIN
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('   EQUIPMENT UTILIZATION REPORT');
    DBMS_OUTPUT.PUT_LINE('   Period: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || 
                        ' to ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
    IF p_equipment_type IS NOT NULL THEN
        DBMS_OUTPUT.PUT_LINE('   Type Filter: ' || p_equipment_type);
    END IF;
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('');
    
    -- Process each equipment
    FOR v_rec IN c_utilization LOOP
        v_total_equipment := v_total_equipment + 1;
        v_total_hours := v_total_hours + NVL(v_rec.total_hours, 0);
        v_total_cost := v_total_cost + NVL(v_rec.total_maintenance_cost, 0);
        
        DBMS_OUTPUT.PUT_LINE('Equipment ID: ' || v_rec.equipment_id);
        DBMS_OUTPUT.PUT_LINE('  Type/Model: ' || v_rec.equipment_type || ' - ' || v_rec.model);
        DBMS_OUTPUT.PUT_LINE('  Status: ' || v_rec.status);
        DBMS_OUTPUT.PUT_LINE('  Assignments: ' || NVL(v_rec.assignment_count, 0));
        DBMS_OUTPUT.PUT_LINE('  Hours Used: ' || TO_CHAR(NVL(v_rec.total_hours, 0), '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('  Fuel Consumed: ' || TO_CHAR(NVL(v_rec.total_fuel, 0), '999,999.99') || ' L');
        DBMS_OUTPUT.PUT_LINE('  Maintenance Events: ' || NVL(v_rec.maintenance_count, 0));
        DBMS_OUTPUT.PUT_LINE('  Maintenance Cost: $' || TO_CHAR(NVL(v_rec.total_maintenance_cost, 0), '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('───────────────────────────────────────────────────────────────');
        
        -- Limit output for readability
        IF v_total_equipment >= 5 THEN
            DBMS_OUTPUT.PUT_LINE('... (showing first 5 records only)');
            EXIT;
        END IF;
    END LOOP;
    
    -- Summary
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    DBMS_OUTPUT.PUT_LINE('SUMMARY');
    DBMS_OUTPUT.PUT_LINE('  Total Equipment: ' || v_total_equipment);
    DBMS_OUTPUT.PUT_LINE('  Total Hours: ' || TO_CHAR(v_total_hours, '999,999.99'));
    DBMS_OUTPUT.PUT_LINE('  Total Maintenance Cost: $' || TO_CHAR(v_total_cost, '999,999,999.99'));
    IF v_total_equipment > 0 THEN
        DBMS_OUTPUT.PUT_LINE('  Avg Hours per Equipment: ' || 
                            TO_CHAR(v_total_hours / v_total_equipment, '999,999.99'));
    END IF;
    DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR generating report: ' || SQLERRM);
        log_error(SQLCODE, SQLERRM, 'generate_utilization_report',
                 'Date range: ' || p_start_date || ' to ' || p_end_date);
END generate_utilization_report;
/
