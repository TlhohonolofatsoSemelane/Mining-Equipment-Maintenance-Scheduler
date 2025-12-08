SET SERVEROUTPUT ON SIZE UNLIMITED;
SET LINESIZE 200;
-- TEST 1: calculate_utilization_rate
SELECT 
    equipment_id,
    equipment_type,
    model,
    calculate_utilization_rate(equipment_id, ADD_MONTHS(SYSDATE, -1), SYSDATE) as utilization_pct
FROM equipment
WHERE ROWNUM <= 5
ORDER BY equipment_id;

-- TEST 2: get_total_maintenance_cost
SELECT 
    equipment_id,
    equipment_type,
    model,
    get_total_maintenance_cost(equipment_id, ADD_MONTHS(SYSDATE, -12), SYSDATE) as total_cost
FROM equipment
WHERE ROWNUM <= 5
ORDER BY equipment_id;

-- TEST 3: validate_operator_availability
SELECT 
    operator_id,
    first_name || ' ' || last_name as operator_name,
    status,
    validate_operator_availability(operator_id, SYSDATE) as availability
FROM operators
WHERE ROWNUM <= 5
ORDER BY operator_id;

-- TEST 5: get_equipment_status_summary
SELECT 
    equipment_id,
    get_equipment_status_summary(equipment_id) as status_summary
FROM equipment
WHERE ROWNUM <= 5
ORDER BY equipment_id;

-- TEST 6: Combined Function Test (Safe functions only)
SELECT 
    e.equipment_id,
    e.equipment_type,
    e.model,
    calculate_utilization_rate(e.equipment_id) as utilization,
    get_total_maintenance_cost(e.equipment_id) as maint_cost,
    get_equipment_status_summary(e.equipment_id) as status
FROM equipment e
WHERE ROWNUM <= 5
ORDER BY e.equipment_id;

-- TEST 7: Direct PL/SQL Block Test
DECLARE
    v_utilization NUMBER;
    v_cost NUMBER;
    v_availability VARCHAR2(50);
    v_summary VARCHAR2(500);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing functions for Equipment ID 1:');
    DBMS_OUTPUT.PUT_LINE('─────────────────────────────────────');
    
    v_utilization := calculate_utilization_rate(1);
    DBMS_OUTPUT.PUT_LINE('Utilization Rate: ' || NVL(TO_CHAR(v_utilization), 'NULL') || '%');
    
    v_cost := get_total_maintenance_cost(1);
    DBMS_OUTPUT.PUT_LINE('Total Maintenance Cost: $' || NVL(TO_CHAR(v_cost), '0'));
    
    v_summary := get_equipment_status_summary(1);
    DBMS_OUTPUT.PUT_LINE('Status Summary: ' || v_summary);
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Testing operator availability:');
    DBMS_OUTPUT.PUT_LINE('─────────────────────────────────────');
    
    v_availability := validate_operator_availability(1);
    DBMS_OUTPUT.PUT_LINE('Operator 1 Availability: ' || v_availability);
    
    v_availability := validate_operator_availability(2);
    DBMS_OUTPUT.PUT_LINE('Operator 2 Availability: ' || v_availability);
    
    DBMS_OUTPUT.PUT_LINE('');
END;
/