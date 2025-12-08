SET SERVEROUTPUT ON SIZE UNLIMITED;

CREATE OR REPLACE PACKAGE equipment_management_pkg AS
    
    -- ========================================================================
    -- PACKAGE CONSTANTS
    -- ========================================================================
    c_min_cost CONSTANT NUMBER := 100;
    c_markup_rate CONSTANT NUMBER := 1.10;
    c_max_utilization CONSTANT NUMBER := 100;
    
    -- ========================================================================
    -- PROCEDURE DECLARATIONS
    -- ========================================================================
    
    -- Assign equipment to operator with validation
    PROCEDURE assign_equipment_to_operator (
        p_equipment_id IN NUMBER,
        p_operator_id IN NUMBER,
        p_site_id IN NUMBER,
        p_start_time IN TIMESTAMP DEFAULT SYSTIMESTAMP,
        p_assignment_id OUT NUMBER,
        p_status OUT VARCHAR2
    );
    
    -- Record maintenance activity with cost adjustment
    PROCEDURE record_maintenance (
        p_equipment_id IN NUMBER,
        p_notes IN VARCHAR2,
        p_cost IN OUT NUMBER,
        p_duration_hours IN NUMBER,
        p_performed_by IN NUMBER,
        p_history_id OUT NUMBER,
        p_status OUT VARCHAR2
    );
    
    -- Update equipment status with validation
    PROCEDURE update_equipment_status (
        p_equipment_id IN NUMBER,
        p_new_status IN VARCHAR2,
        p_reason IN VARCHAR2 DEFAULT NULL,
        p_old_status OUT VARCHAR2,
        p_status OUT VARCHAR2
    );
    
    -- Generate utilization report
    PROCEDURE generate_utilization_report (
        p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -1),
        p_end_date IN DATE DEFAULT SYSDATE,
        p_equipment_type IN VARCHAR2 DEFAULT NULL
    );
    
    -- Process overdue maintenance
    PROCEDURE process_overdue_maintenance (
        p_days_overdue IN NUMBER DEFAULT 90
    );
    
    -- ========================================================================
    -- FUNCTION DECLARATIONS
    -- ========================================================================
    
    -- Calculate equipment utilization rate
    FUNCTION calculate_utilization_rate (
        p_equipment_id IN NUMBER,
        p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -1),
        p_end_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER;
    
    -- Get total maintenance cost
    FUNCTION get_total_maintenance_cost (
        p_equipment_id IN NUMBER,
        p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -12),
        p_end_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER;
    
    -- Validate operator availability
    FUNCTION validate_operator_availability (
        p_operator_id IN NUMBER,
        p_check_date IN DATE DEFAULT SYSDATE
    ) RETURN VARCHAR2;
    
    -- Calculate fuel efficiency
    FUNCTION calculate_fuel_efficiency (
        p_equipment_id IN NUMBER,
        p_start_date IN DATE DEFAULT ADD_MONTHS(SYSDATE, -3),
        p_end_date IN DATE DEFAULT SYSDATE
    ) RETURN NUMBER;
    
    -- Get equipment status summary
    FUNCTION get_equipment_status_summary (
        p_equipment_id IN NUMBER
    ) RETURN VARCHAR2;
    
END equipment_management_pkg;
/