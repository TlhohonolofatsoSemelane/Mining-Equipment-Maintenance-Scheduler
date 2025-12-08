SET SERVEROUTPUT ON SIZE UNLIMITED;
-- ============================================================================
-- FUNCTION 1: Calculate Equipment Utilization Rate
-- Purpose: Calculate percentage of time equipment was in use
-- Type: Calculation Function
-- Returns: NUMBER (percentage)
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_utilization_rate (
    p_equipment_id IN NUMBER,
    p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -1),
    p_end_date IN DATE DEFAULT SYSDATE
) RETURN NUMBER
IS
    v_total_hours NUMBER := 0;
    v_available_hours NUMBER;
    v_utilization_rate NUMBER;
    v_equipment_exists NUMBER;
BEGIN
    -- Validate equipment exists
    SELECT COUNT(*) INTO v_equipment_exists
    FROM equipment
    WHERE equipment_id = p_equipment_id;
    
    IF v_equipment_exists = 0 THEN
        RETURN NULL;
    END IF;
    
    -- Calculate total hours used (CORRECTED: hours_operated, log_date)
    SELECT NVL(SUM(hours_operated), 0)
    INTO v_total_hours
    FROM equipment_usage_log
    WHERE equipment_id = p_equipment_id
    AND log_date BETWEEN p_start_date AND p_end_date;
    
    -- Calculate available hours (24 hours per day)
    v_available_hours := (p_end_date - p_start_date) * 24;
    
    -- Avoid division by zero
    IF v_available_hours = 0 THEN
        RETURN 0;
    END IF;
    
    -- Calculate utilization rate as percentage
    v_utilization_rate := (v_total_hours / v_available_hours) * 100;
    
    -- Cap at 100% (in case of data anomalies)
    IF v_utilization_rate > 100 THEN
        v_utilization_rate := 100;
    END IF;
    
    RETURN ROUND(v_utilization_rate, 2);
    
EXCEPTION
    WHEN OTHERS THEN
        log_error(SQLCODE, SQLERRM, 'calculate_utilization_rate',
                 'Equipment ID: ' || p_equipment_id);
        RETURN NULL;
END calculate_utilization_rate;
/

-- ============================================================================
-- FUNCTION 2: Calculate Total Maintenance Cost
-- Purpose: Get total maintenance cost for equipment in date range
-- Type: Calculation Function
-- Returns: NUMBER (cost)
-- ============================================================================

CREATE OR REPLACE FUNCTION get_total_maintenance_cost (
    p_equipment_id IN NUMBER,
    p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -12),
    p_end_date IN DATE DEFAULT SYSDATE
) RETURN NUMBER
IS
    v_total_cost NUMBER := 0;
BEGIN
    -- CORRECTED: Use start_date from maintenance_history
    SELECT NVL(SUM(cost), 0)
    INTO v_total_cost
    FROM maintenance_history
    WHERE equipment_id = p_equipment_id
    AND TRUNC(CAST(start_date AS DATE)) BETWEEN p_start_date AND p_end_date;
    
    RETURN v_total_cost;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        log_error(SQLCODE, SQLERRM, 'get_total_maintenance_cost',
                 'Equipment ID: ' || p_equipment_id);
        RETURN NULL;
END get_total_maintenance_cost;
/

-- ============================================================================
-- FUNCTION 3: Validate Operator Availability
-- Purpose: Check if operator is available for assignment
-- Type: Validation Function
-- Returns: VARCHAR2 ('AVAILABLE', 'BUSY', 'INACTIVE', 'NOT_FOUND')
-- ============================================================================

CREATE OR REPLACE FUNCTION validate_operator_availability (
    p_operator_id IN NUMBER,
    p_check_date IN DATE DEFAULT SYSDATE
) RETURN VARCHAR2
IS
    v_operator_status VARCHAR2(50);
    v_active_assignments NUMBER;
BEGIN
    -- Check if operator exists and get status
    BEGIN
        SELECT status INTO v_operator_status
        FROM operators
        WHERE operator_id = p_operator_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'NOT_FOUND';
    END;
    
    -- Check if operator is active
    IF v_operator_status != 'Active' THEN
        RETURN 'INACTIVE';
    END IF;
    
    -- Check for active assignments on the check date
    -- CORRECTED: Use assignment_date and end_time
    SELECT COUNT(*)
    INTO v_active_assignments
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
    WHEN OTHERS THEN
        log_error(SQLCODE, SQLERRM, 'validate_operator_availability',
                 'Operator ID: ' || p_operator_id);
        RETURN 'ERROR';
END validate_operator_availability;
/

-- ============================================================================
-- FUNCTION 4: Calculate Fuel Efficiency
-- Purpose: Calculate fuel consumption per hour for equipment
-- Type: Calculation Function
-- Returns: NUMBER (liters per hour)
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_fuel_efficiency (
    p_equipment_id IN NUMBER,
    p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -3),
    p_end_date IN DATE DEFAULT SYSDATE
) RETURN NUMBER
IS
    v_total_fuel NUMBER := 0;
    v_total_hours NUMBER := 0;
    v_efficiency NUMBER;
BEGIN
    -- Get total fuel and hours
    SELECT 
        NVL(SUM(fuel_consumed_liters), 0),
        NVL(SUM(hours_operated), 0)
    INTO v_total_fuel, v_total_hours
    FROM equipment_usage_log
    WHERE equipment_id = p_equipment_id
    AND log_date BETWEEN p_start_date AND p_end_date
    AND fuel_consumed_liters IS NOT NULL
    AND hours_operated > 0;
    
    -- Avoid division by zero
    IF v_total_hours = 0 THEN
        RETURN NULL;
    END IF;
    
    v_efficiency := v_total_fuel / v_total_hours;
    
    RETURN ROUND(v_efficiency, 2);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        log_error(SQLCODE, SQLERRM, 'calculate_fuel_efficiency',
                 'Equipment ID: ' || p_equipment_id);
        RETURN NULL;
END calculate_fuel_efficiency;
/

CREATE OR REPLACE FUNCTION get_equipment_status_summary (
    p_equipment_id IN NUMBER
) RETURN VARCHAR2
IS
    v_equipment_type VARCHAR2(50);
    v_model VARCHAR2(100);
    v_status VARCHAR2(50);
    v_last_maintenance DATE;
    v_total_hours NUMBER;
    v_summary VARCHAR2(500);
BEGIN
    -- Get equipment details
    SELECT 
        equipment_type,
        model,
        status,
        last_maintenance_date
    INTO 
        v_equipment_type,
        v_model,
        v_status,
        v_last_maintenance
    FROM equipment
    WHERE equipment_id = p_equipment_id;
    
    -- Get total hours from usage log
    SELECT NVL(SUM(hours_operated), 0)
    INTO v_total_hours
    FROM equipment_usage_log
    WHERE equipment_id = p_equipment_id;
    
    -- Build formatted summary
    v_summary := v_equipment_type || ' ' || v_model || 
                 ' | Status: ' || v_status || 
                 ' | Hours: ' || TO_CHAR(v_total_hours, '999,999') ||
                 ' | Last Maintenance: ' || 
                 NVL(TO_CHAR(v_last_maintenance, 'DD-MON-YYYY'), 'Never');
    
    RETURN v_summary;
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Equipment ID ' || p_equipment_id || ' not found';
    WHEN OTHERS THEN
        log_error(SQLCODE, SQLERRM, 'get_equipment_status_summary',
                 'Equipment ID: ' || p_equipment_id);
        RETURN 'ERROR: Unable to retrieve status';
END get_equipment_status_summary;
/