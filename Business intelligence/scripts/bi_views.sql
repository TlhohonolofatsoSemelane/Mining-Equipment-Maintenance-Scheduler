-- Dashboard 1: Executive Summary Views
-- ====================================

-- View 1: Executive KPI Cards
CREATE OR REPLACE VIEW v_executive_kpi_cards AS
SELECT 
    COUNT(DISTINCT e.equipment_id) as total_equipment,
    COUNT(DISTINCT CASE WHEN e.status = 'Available' THEN e.equipment_id END) as available_equipment,
    COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) as equipment_in_use,
    ROUND(
        COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT e.equipment_id), 0), 
        2
    ) as equipment_utilization_rate,
    COUNT(DISTINCT o.operator_id) as active_operators,
    COALESCE(SUM(fc.total_cost), 0) as total_fuel_cost,
    COALESCE(SUM(dr.duration_hours), 0) as total_downtime_hours,
    CASE 
        WHEN COALESCE(SUM(dr.duration_hours), 0) < 50 THEN 'EXCELLENT'
        WHEN COALESCE(SUM(dr.duration_hours), 0) < 100 THEN 'GOOD'
        WHEN COALESCE(SUM(dr.duration_hours), 0) < 200 THEN 'FAIR'
        ELSE 'POOR'
    END as system_health_status
FROM equipment e
LEFT JOIN operators o ON 1=1
LEFT JOIN fuel_consumption fc ON e.equipment_id = fc.equipment_id
LEFT JOIN downtime_records dr ON e.equipment_id = dr.equipment_id;

-- View 2: Department Performance
CREATE OR REPLACE VIEW v_department_performance AS
SELECT 
    d.department_id,
    d.department_name,
    COUNT(DISTINCT e.equipment_id) as equipment_count,
    COUNT(DISTINCT o.operator_id) as operator_count,
    COUNT(DISTINCT ea.assignment_id) as total_assignments,
    CASE 
        WHEN COUNT(DISTINCT e.equipment_id) = 0 THEN 0
        ELSE ROUND(
            COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
            COUNT(DISTINCT e.equipment_id), 
            2
        )
    END as utilization_rate,
    CASE 
        WHEN COUNT(DISTINCT e.equipment_id) = 0 THEN 'NO EQUIPMENT'
        WHEN ROUND(
            COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
            COUNT(DISTINCT e.equipment_id), 2
        ) >= 70 THEN 'HIGH PERFORMANCE'
        WHEN ROUND(
            COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
            COUNT(DISTINCT e.equipment_id), 2
        ) >= 50 THEN 'GOOD PERFORMANCE'
        ELSE 'LOW PERFORMANCE'
    END as performance_rating
FROM departments d
LEFT JOIN equipment e ON d.department_id = e.department_id
LEFT JOIN operators o ON d.department_id = o.department_id
LEFT JOIN equipment_assignment ea ON o.operator_id = ea.operator_id
GROUP BY d.department_id, d.department_name;


-- Dashboard 2: Audit & Compliance Views
-- ======================================

-- View 3: Compliance Overview
CREATE OR REPLACE VIEW v_compliance_overview AS
SELECT 
    COUNT(*) as total_operations,
    COUNT(CASE WHEN action IN ('INSERT', 'UPDATE', 'DELETE') AND status = 'SUCCESS' THEN 1 END) as compliant_operations,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied_operations,
    ROUND(
        COUNT(CASE WHEN action IN ('INSERT', 'UPDATE', 'DELETE') AND status = 'SUCCESS' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0), 
        2
    ) as compliance_rate_percentage,
    ROUND(
        COUNT(CASE WHEN status = 'DENIED' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0), 
        2
    ) as violation_rate_percentage,
    COUNT(CASE WHEN TO_CHAR(timestamp, 'DY') IN ('SAT', 'SUN') AND status = 'DENIED' THEN 1 END) as weekend_violations,
    COUNT(CASE WHEN TRUNC(timestamp) = TRUNC(SYSDATE) AND status = 'DENIED' THEN 1 END) as todays_violations,
    CASE 
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) = 0 THEN 'PERFECT COMPLIANCE'
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) <= 5 THEN 'GOOD COMPLIANCE'
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) <= 20 THEN 'NEEDS ATTENTION'
        ELSE 'CRITICAL VIOLATIONS'
    END as compliance_status
FROM audit_log;

-- View 4: Compliance by Table
CREATE OR REPLACE VIEW v_compliance_by_table AS
SELECT 
    table_name,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful_operations,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied_operations,
    ROUND(
        COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0), 
        2
    ) as compliance_rate_percentage,
    CASE 
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) = 0 THEN 'FULLY COMPLIANT'
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) <= 2 THEN 'MOSTLY COMPLIANT'
        ELSE 'VIOLATIONS DETECTED'
    END as compliance_status
FROM audit_log
GROUP BY table_name;

-- View 5: Audit Trail Summary
CREATE OR REPLACE VIEW v_audit_trail_summary AS
SELECT 
    TO_CHAR(timestamp, 'YYYY-MM-DD') as audit_date,
    table_name,
    action,
    COUNT(*) as operation_count,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied,
    COUNT(DISTINCT username) as unique_users
FROM audit_log
GROUP BY TO_CHAR(timestamp, 'YYYY-MM-DD'), table_name, action;

-- View 6: Recent Violations
CREATE OR REPLACE VIEW v_recent_violations AS
SELECT 
    audit_id,
    username,
    table_name,
    action,
    timestamp,
    error_message,
    CASE 
        WHEN TO_CHAR(timestamp, 'DY') IN ('SAT', 'SUN') THEN 'WEEKEND VIOLATION'
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) < 6 OR TO_NUMBER(TO_CHAR(timestamp, 'HH24')) > 22 
            THEN 'OFF-HOURS VIOLATION'
        ELSE 'BUSINESS HOURS VIOLATION'
    END as violation_type
FROM audit_log
WHERE status = 'DENIED'
ORDER BY timestamp DESC;


-- Dashboard 3: Performance & Resources Views
-- ===========================================

-- View 7: Equipment Performance
CREATE OR REPLACE VIEW v_equipment_performance AS
SELECT 
    e.equipment_id,
    e.model,
    e.status,
    et.type_name as equipment_type,
    COUNT(DISTINCT ea.assignment_id) as total_assignments,
    COALESCE(SUM(fc.total_cost), 0) as total_fuel_cost,
    COALESCE(SUM(dr.duration_hours), 0) as total_downtime_hours,
    CASE 
        WHEN COUNT(DISTINCT ea.assignment_id) >= 10 THEN 'HIGH USAGE'
        WHEN COUNT(DISTINCT ea.assignment_id) >= 5 THEN 'MODERATE USAGE'
        WHEN COUNT(DISTINCT ea.assignment_id) > 0 THEN 'LOW USAGE'
        ELSE 'NO USAGE'
    END as performance_category
FROM equipment e
JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id
LEFT JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
LEFT JOIN fuel_consumption fc ON e.equipment_id = fc.equipment_id
LEFT JOIN downtime_records dr ON e.equipment_id = dr.equipment_id
GROUP BY e.equipment_id, e.model, e.status, et.type_name;

-- View 8: Operator Performance
CREATE OR REPLACE VIEW v_operator_performance AS
SELECT 
    o.operator_id,
    o.first_name || ' ' || o.last_name as operator_name,
    o.license_number,
    d.department_name,
    COUNT(DISTINCT ea.assignment_id) as total_assignments,
    COUNT(DISTINCT ea.equipment_id) as equipment_operated,
    COUNT(DISTINCT ea.site_id) as sites_worked,
    CASE 
        WHEN COUNT(DISTINCT ea.assignment_id) >= 10 THEN 'HIGH PRODUCTIVITY'
        WHEN COUNT(DISTINCT ea.assignment_id) >= 5 THEN 'GOOD PRODUCTIVITY'
        WHEN COUNT(DISTINCT ea.assignment_id) > 0 THEN 'MODERATE PRODUCTIVITY'
        ELSE 'LOW PRODUCTIVITY'
    END as productivity_rating
FROM operators o
JOIN departments d ON o.department_id = d.department_id
LEFT JOIN equipment_assignment ea ON o.operator_id = ea.operator_id
GROUP BY o.operator_id, o.first_name, o.last_name, o.license_number, d.department_name;

-- View 9: Site Resource Usage
CREATE OR REPLACE VIEW v_site_resource_usage AS
SELECT 
    ms.site_id,
    ms.site_name,
    ms.location,
    COUNT(DISTINCT ea.assignment_id) as total_assignments,
    COUNT(DISTINCT ea.equipment_id) as equipment_deployed,
    COUNT(DISTINCT ea.operator_id) as operators_assigned,
    COUNT(DISTINCT CASE WHEN ea.status = 'Active' THEN ea.assignment_id END) as active_assignments,
    CASE 
        WHEN COUNT(DISTINCT ea.assignment_id) >= 15 THEN 'HIGH ACTIVITY'
        WHEN COUNT(DISTINCT ea.assignment_id) >= 8 THEN 'MODERATE ACTIVITY'
        WHEN COUNT(DISTINCT ea.assignment_id) > 0 THEN 'LOW ACTIVITY'
        ELSE 'INACTIVE'
    END as activity_level
FROM mining_sites ms
LEFT JOIN equipment_assignment ea ON ms.site_id = ea.site_id
GROUP BY ms.site_id, ms.site_name, ms.location;

-- View 10: Maintenance Performance
CREATE OR REPLACE VIEW v_maintenance_performance AS
SELECT 
    mt.type_name as maintenance_type,
    COUNT(ms.schedule_id) as total_scheduled,
    COUNT(CASE WHEN ms.status = 'Completed' THEN 1 END) as completed,
    COUNT(CASE WHEN ms.status = 'Scheduled' THEN 1 END) as pending,
    COUNT(CASE WHEN ms.status = 'Overdue' THEN 1 END) as overdue,
    ROUND(
        COUNT(CASE WHEN ms.status = 'Completed' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(ms.schedule_id), 0), 
        2
    ) as completion_rate,
    CASE 
        WHEN COUNT(CASE WHEN ms.status = 'Overdue' THEN 1 END) = 0 THEN 'ON TRACK'
        WHEN COUNT(CASE WHEN ms.status = 'Overdue' THEN 1 END) <= 2 THEN 'MINOR DELAYS'
        ELSE 'CRITICAL DELAYS'
    END as maintenance_status
FROM maintenance_types mt
LEFT JOIN maintenance_schedule ms ON mt.maintenance_type_id = ms.maintenance_type_id
GROUP BY mt.maintenance_type_id, mt.type_name;

-- View 11: Downtime Analysis
CREATE OR REPLACE VIEW v_downtime_analysis AS
SELECT 
    dt.type_name as downtime_type,
    COUNT(dr.downtime_id) as incident_count,
    SUM(dr.duration_hours) as total_hours,
    AVG(dr.duration_hours) as avg_hours_per_incident,
    MIN(dr.duration_hours) as min_hours,
    MAX(dr.duration_hours) as max_hours,
    CASE 
        WHEN SUM(dr.duration_hours) < 20 THEN 'MINIMAL IMPACT'
        WHEN SUM(dr.duration_hours) < 50 THEN 'MODERATE IMPACT'
        WHEN SUM(dr.duration_hours) < 100 THEN 'SIGNIFICANT IMPACT'
        ELSE 'CRITICAL IMPACT'
    END as impact_level
FROM downtime_types dt
LEFT JOIN downtime_records dr ON dt.downtime_type_id = dr.downtime_type_id
GROUP BY dt.downtime_type_id, dt.type_name;

-- View 12: Fuel Consumption Analysis
CREATE OR REPLACE VIEW v_fuel_consumption_analysis AS
SELECT 
    e.equipment_id,
    e.model,
    et.type_name as equipment_type,
    COUNT(fc.consumption_id) as refueling_count,
    SUM(fc.quantity_liters) as total_liters,
    SUM(fc.total_cost) as total_cost,
    AVG(fc.cost_per_liter) as avg_cost_per_liter,
    ROUND(SUM(fc.total_cost) / NULLIF(SUM(fc.quantity_liters), 0), 2) as overall_cost_per_liter,
    CASE 
        WHEN SUM(fc.total_cost) > 5000 THEN 'HIGH CONSUMPTION'
        WHEN SUM(fc.total_cost) > 2000 THEN 'MODERATE CONSUMPTION'
        WHEN SUM(fc.total_cost) > 0 THEN 'LOW CONSUMPTION'
        ELSE 'NO CONSUMPTION'
    END as consumption_category
FROM equipment e
JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id
LEFT JOIN fuel_consumption fc ON e.equipment_id = fc.equipment_id
GROUP BY e.equipment_id, e.model, et.type_name;
