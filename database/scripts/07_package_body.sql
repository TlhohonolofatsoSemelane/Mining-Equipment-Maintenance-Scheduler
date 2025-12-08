SET SERVEROUTPUT ON SIZE UNLIMITED;
CREATE OR REPLACE PACKAGE BODY equipment_management_pkg AS

    -- ========================================================================
    -- PRIVATE HELPER FUNCTION (not in spec - package internal only)
    -- ========================================================================
    FUNCTION is_valid_equipment(p_equipment_id IN NUMBER) RETURN BOOLEAN IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_count
        FROM equipment
        WHERE equipment_id = p_equipment_id;
        RETURN v_count > 0;
    END is_valid_equipment;

    -- ========================================================================
    -- PROCEDURE: assign_equipment_to_operator
    -- ========================================================================
    PROCEDURE assign_equipment_to_operator (
        p_equipment_id IN NUMBER,
        p_operator_id IN NUMBER,
        p_site_id IN NUMBER,
        p_start_time IN TIMESTAMP DEFAULT SYSTIMESTAMP,
        p_assignment_id OUT NUMBER,
        p_status OUT VARCHAR2
    ) AS
        v_equipment_status VARCHAR2(50);
        v_operator_status VARCHAR2(50);
        v_site_exists NUMBER;
        equipment_not_available EXCEPTION;
        invalid_operator EXCEPTION;
        invalid_site EXCEPTION;
    BEGIN
        -- Validate equipment
        SELECT status INTO v_equipment_status
        FROM equipment WHERE equipment_id = p_equipment_id;
        
        IF v_equipment_status != 'Available' THEN
            RAISE equipment_not_available;
        END IF;
        
        -- Validate operator
        SELECT status INTO v_operator_status
        FROM operators WHERE operator_id = p_operator_id;
        
        IF v_operator_status != 'Active' THEN
            RAISE invalid_operator;
        END IF;
        
        -- Validate site
        SELECT COUNT(*) INTO v_site_exists
        FROM mining_sites WHERE site_id = p_site_id;
        
        IF v_site_exists = 0 THEN
            RAISE invalid_site;
        END IF;
        
        -- Create assignment
        INSERT INTO equipment_assignment (
            equipment_id, operator_id, site_id, 
            assignment_date, start_time, end_time, status
        ) VALUES (
            p_equipment_id, p_operator_id, p_site_id,
            TRUNC(SYSDATE), p_start_time, NULL, 'Active'
        ) RETURNING assignment_id INTO p_assignment_id;
        
        -- Update equipment status
        UPDATE equipment SET status = 'In-Use'
        WHERE equipment_id = p_equipment_id;
        
        COMMIT;
        p_status := 'SUCCESS: Assignment created with ID ' || p_assignment_id;
        
    EXCEPTION
        WHEN equipment_not_available THEN
            ROLLBACK;
            p_status := 'ERROR: Equipment not available';
            log_error(-20001, 'Equipment not available', 'assign_equipment_to_operator',
                     'Equipment ID: ' || p_equipment_id);
        WHEN invalid_operator THEN
            ROLLBACK;
            p_status := 'ERROR: Invalid operator';
            log_error(-20002, 'Invalid operator', 'assign_equipment_to_operator',
                     'Operator ID: ' || p_operator_id);
        WHEN invalid_site THEN
            ROLLBACK;
            p_status := 'ERROR: Invalid site';
            log_error(-20003, 'Invalid site', 'assign_equipment_to_operator',
                     'Site ID: ' || p_site_id);
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR: ' || SQLERRM;
            log_error(SQLCODE, SQLERRM, 'assign_equipment_to_operator',
                     'Equipment: ' || p_equipment_id);
    END assign_equipment_to_operator;

    -- ========================================================================
    -- PROCEDURE: record_maintenance
    -- ========================================================================
    PROCEDURE record_maintenance (
        p_equipment_id IN NUMBER,
        p_notes IN VARCHAR2,
        p_cost IN OUT NUMBER,
        p_duration_hours IN NUMBER,
        p_performed_by IN NUMBER,
        p_history_id OUT NUMBER,
        p_status OUT VARCHAR2
    ) AS
        v_start_date TIMESTAMP := SYSTIMESTAMP;
        v_end_date TIMESTAMP := SYSTIMESTAMP + NUMTODSINTERVAL(p_duration_hours, 'HOUR');
    BEGIN
        -- Apply markup if needed (using package constant)
        IF p_cost < c_min_cost THEN
            p_cost := p_cost * c_markup_rate;
        END IF;
        
        -- Insert maintenance record
        INSERT INTO maintenance_history (
            equipment_id, start_date, end_date,
            actual_duration_hours, cost, notes, performed_by
        ) VALUES (
            p_equipment_id, v_start_date, v_end_date,
            p_duration_hours, p_cost, p_notes, p_performed_by
        ) RETURNING history_id INTO p_history_id;
        
        -- Update equipment status
        UPDATE equipment
        SET status = 'Maintenance',
            last_maintenance_date = SYSDATE
        WHERE equipment_id = p_equipment_id;
        
        COMMIT;
        p_status := 'SUCCESS: Maintenance recorded with ID ' || p_history_id;
        
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR: ' || SQLERRM;
            log_error(SQLCODE, SQLERRM, 'record_maintenance',
                     'Equipment: ' || p_equipment_id);
    END record_maintenance;

    -- ========================================================================
    -- PROCEDURE: update_equipment_status
    -- ========================================================================
    PROCEDURE update_equipment_status (
        p_equipment_id IN NUMBER,
        p_new_status IN VARCHAR2,
        p_reason IN VARCHAR2 DEFAULT NULL,
        p_old_status OUT VARCHAR2,
        p_status OUT VARCHAR2
    ) AS
        v_current_status VARCHAR2(50);
    BEGIN
        SELECT status INTO v_current_status
        FROM equipment WHERE equipment_id = p_equipment_id;
        
        p_old_status := v_current_status;
        
        UPDATE equipment SET status = p_new_status
        WHERE equipment_id = p_equipment_id;
        
        COMMIT;
        p_status := 'SUCCESS: Status updated from ' || v_current_status || ' to ' || p_new_status;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_status := 'ERROR: Equipment not found';
        WHEN OTHERS THEN
            ROLLBACK;
            p_status := 'ERROR: ' || SQLERRM;
            log_error(SQLCODE, SQLERRM, 'update_equipment_status',
                     'Equipment ID: ' || p_equipment_id);
    END update_equipment_status;

    -- ========================================================================
    -- PROCEDURE: generate_utilization_report
    -- ========================================================================
    PROCEDURE generate_utilization_report (
        p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -1),
        p_end_date IN DATE DEFAULT SYSDATE,
        p_equipment_type IN VARCHAR2 DEFAULT NULL
    ) AS
        CURSOR c_utilization IS
            SELECT 
                e.equipment_id,
                e.equipment_type,
                e.model,
                e.status,
                COUNT(DISTINCT ea.assignment_id) as assignment_count,
                SUM(NVL(eu.hours_operated, 0)) as total_hours
            FROM equipment e
            LEFT JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
                AND TRUNC(ea.assignment_date) BETWEEN p_start_date AND p_end_date
            LEFT JOIN equipment_usage_log eu ON e.equipment_id = eu.equipment_id
                AND eu.log_date BETWEEN p_start_date AND p_end_date
            WHERE (p_equipment_type IS NULL OR e.equipment_type = p_equipment_type)
            GROUP BY e.equipment_id, e.equipment_type, e.model, e.status
            ORDER BY total_hours DESC NULLS LAST;
        
        v_count NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
        DBMS_OUTPUT.PUT_LINE('EQUIPMENT UTILIZATION REPORT');
        DBMS_OUTPUT.PUT_LINE('Period: ' || TO_CHAR(p_start_date, 'DD-MON-YYYY') || 
                            ' to ' || TO_CHAR(p_end_date, 'DD-MON-YYYY'));
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
        
        FOR rec IN c_utilization LOOP
            v_count := v_count + 1;
            DBMS_OUTPUT.PUT_LINE('Equipment ' || rec.equipment_id || ': ' || 
                                rec.equipment_type || ' - ' || rec.model);
            DBMS_OUTPUT.PUT_LINE('  Hours: ' || rec.total_hours || 
                                ', Assignments: ' || rec.assignment_count);
            EXIT WHEN v_count >= 5;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('═══════════════════════════════════════════════════════════════');
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM);
    END generate_utilization_report;

    -- ========================================================================
    -- PROCEDURE: process_overdue_maintenance
    -- ========================================================================
    PROCEDURE process_overdue_maintenance (
        p_days_overdue IN NUMBER DEFAULT 90
    ) AS
        CURSOR c_overdue IS
            SELECT equipment_id, equipment_type, model,
                   TRUNC(SYSDATE - NVL(last_maintenance_date, purchase_date)) as days_overdue
            FROM equipment
            WHERE TRUNC(SYSDATE - NVL(last_maintenance_date, purchase_date)) > p_days_overdue
            AND status != 'Retired';
        
        v_count NUMBER := 0;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('OVERDUE MAINTENANCE REPORT');
        DBMS_OUTPUT.PUT_LINE('Threshold: ' || p_days_overdue || ' days');
        
        FOR rec IN c_overdue LOOP
            v_count := v_count + 1;
            DBMS_OUTPUT.PUT_LINE('Equipment ' || rec.equipment_id || 
                                ': ' || rec.days_overdue || ' days overdue');
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Total: ' || v_count || ' equipment items');
    END process_overdue_maintenance;

    -- ========================================================================
    -- FUNCTION: calculate_utilization_rate
    -- ========================================================================
    FUNCTION calculate_utilization_rate (
        p_equipment_id IN NUMBER,
        p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -1),
        p_end_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER IS
        v_total_hours NUMBER := 0;
        v_available_hours NUMBER;
    BEGIN
        SELECT NVL(SUM(hours_operated), 0) INTO v_total_hours
        FROM equipment_usage_log
        WHERE equipment_id = p_equipment_id
        AND log_date BETWEEN p_start_date AND p_end_date;
        
        v_available_hours := (p_end_date - p_start_date) * 24;
        
        IF v_available_hours = 0 THEN
            RETURN 0;
        END IF;
        
        RETURN LEAST(ROUND((v_total_hours / v_available_hours) * 100, 2), c_max_utilization);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END calculate_utilization_rate;

    -- ========================================================================
    -- FUNCTION: get_total_maintenance_cost
    -- ========================================================================
    FUNCTION get_total_maintenance_cost (
        p_equipment_id IN NUMBER,
        p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -12),
        p_end_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER IS
        v_total_cost NUMBER := 0;
    BEGIN
        SELECT NVL(SUM(cost), 0) INTO v_total_cost
        FROM maintenance_history
        WHERE equipment_id = p_equipment_id
        AND TRUNC(CAST(start_date AS DATE)) BETWEEN p_start_date AND p_end_date;
        
        RETURN v_total_cost;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END get_total_maintenance_cost;

    -- ========================================================================
    -- FUNCTION: validate_operator_availability
    -- ========================================================================
    FUNCTION validate_operator_availability (
        p_operator_id IN NUMBER,
        p_check_date IN DATE DEFAULT SYSDATE
    ) RETURN VARCHAR2 IS
        v_operator_status VARCHAR2(50);
        v_active_assignments NUMBER;
    BEGIN
        SELECT status INTO v_operator_status
        FROM operators WHERE operator_id = p_operator_id;
        
        IF v_operator_status != 'Active' THEN
            RETURN 'INACTIVE';
        END IF;
        
        SELECT COUNT(*) INTO v_active_assignments
        FROM equipment_assignment
        WHERE operator_id = p_operator_id
        AND TRUNC(assignment_date) <= p_check_date
        AND (end_time IS NULL OR TRUNC(CAST(end_time AS DATE)) >= p_check_date);
        
        IF v_active_assignments > 0 THEN
            RETURN 'BUSY';
        ELSE
            RETURN 'AVAILABLE';
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'NOT_FOUND';
        WHEN OTHERS THEN
            RETURN 'ERROR';
    END validate_operator_availability;

    -- ========================================================================
    -- FUNCTION: calculate_fuel_efficiency
    -- ========================================================================
    FUNCTION calculate_fuel_efficiency (
        p_equipment_id IN NUMBER,
        p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -3),
        p_end_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER IS
        v_total_fuel NUMBER := 0;
        v_total_hours NUMBER := 0;
    BEGIN
        SELECT 
            NVL(SUM(fuel_consumed_liters), 0),
            NVL(SUM(hours_operated), 0)
        INTO v_total_fuel, v_total_hours
        FROM equipment_usage_log
        WHERE equipment_id = p_equipment_id
        AND log_date BETWEEN p_start_date AND p_end_date
        AND hours_operated > 0;
        
        IF v_total_hours = 0 THEN
            RETURN NULL;
        END IF;
        
        RETURN ROUND(v_total_fuel / v_total_hours, 2);
    EXCEPTION
        WHEN OTHERS THEN
            RETURN NULL;
    END calculate_fuel_efficiency;

    -- ========================================================================
    -- FUNCTION: get_equipment_status_summary
    -- ========================================================================
    FUNCTION get_equipment_status_summary (
        p_equipment_id IN NUMBER
    ) RETURN VARCHAR2 IS
        v_equipment_type VARCHAR2(50);
        v_model VARCHAR2(100);
        v_status VARCHAR2(50);
        v_summary VARCHAR2(500);
    BEGIN
        SELECT 
            equipment_type,
            model,
            status
        INTO 
            v_equipment_type,
            v_model,
            v_status
        FROM equipment
        WHERE equipment_id = p_equipment_id;
        
        v_summary := v_equipment_type || ' ' || v_model || ' | Status: ' || v_status;
        
        RETURN v_summary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Equipment ID ' || p_equipment_id || ' not found';
        WHEN OTHERS THEN
            RETURN 'ERROR: Unable to retrieve status';
    END get_equipment_status_summary;

END equipment_management_pkg;