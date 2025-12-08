-- ============================================
-- ANALYTICS QUERIES
-- Mining Equipment Management System
-- ============================================

-- Analytics Query 1: Equipment Utilization Rate by Department
SELECT 
    d.department_name,
    COUNT(DISTINCT e.equipment_id) as total_equipment,
    COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) as equipment_in_use,
    COUNT(DISTINCT CASE WHEN e.status = 'Available' THEN e.equipment_id END) as equipment_available,
    ROUND(
        COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT e.equipment_id), 0), 
        2
    ) as utilization_rate_percentage,
    CASE 
        WHEN ROUND(COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
                   NULLIF(COUNT(DISTINCT e.equipment_id), 0), 2) >= 70 THEN 'HIGH UTILIZATION'
        WHEN ROUND(COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
                   NULLIF(COUNT(DISTINCT e.equipment_id), 0), 2) >= 50 THEN 'MODERATE UTILIZATION'
        ELSE 'LOW UTILIZATION'
    END as utilization_category
FROM departments d
LEFT JOIN equipment e ON d.department_id = e.department_id
GROUP BY d.department_name
ORDER BY utilization_rate_percentage DESC NULLS LAST;

-- Analytics Query 2: Monthly Equipment Assignment Trends
SELECT 
    TO_CHAR(assignment_date, 'YYYY-MM') as month,
    TO_CHAR(assignment_date, 'Mon YYYY') as month_name,
    COUNT(assignment_id) as total_assignments,
    COUNT(DISTINCT equipment_id) as unique_equipment,
    COUNT(DISTINCT operator_id) as unique_operators,
    COUNT(DISTINCT site_id) as unique_sites,
    COUNT(CASE WHEN status = 'Active' THEN 1 END) as active_assignments,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) as completed_assignments
FROM equipment_assignment
GROUP BY TO_CHAR(assignment_date, 'YYYY-MM'), TO_CHAR(assignment_date, 'Mon YYYY')
ORDER BY TO_CHAR(assignment_date, 'YYYY-MM') DESC;

-- Analytics Query 3: Top 10 Most Used Equipment
SELECT 
    e.equipment_id,
    e.model,
    et.type_name as equipment_type,
    e.status,
    COUNT(ea.assignment_id) as total_assignments,
    COUNT(DISTINCT ea.operator_id) as operators_used,
    COUNT(DISTINCT ea.site_id) as sites_deployed,
    COALESCE(SUM(fc.total_cost), 0) as total_fuel_cost,
    COALESCE(SUM(dr.duration_hours), 0) as total_downtime_hours
FROM equipment e
JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id
LEFT JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
LEFT JOIN fuel_consumption fc ON e.equipment_id = fc.equipment_id
LEFT JOIN downtime_records dr ON e.equipment_id = dr.equipment_id
GROUP BY e.equipment_id, e.model, et.type_name, e.status
ORDER BY total_assignments DESC
FETCH FIRST 10 ROWS ONLY;

-- Analytics Query 4: Operator Productivity Analysis
SELECT 
    o.operator_id,
    o.first_name || ' ' || o.last_name as operator_name,
    d.department_name,
    COUNT(ea.assignment_id) as total_assignments,
    COUNT(DISTINCT ea.equipment_id) as equipment_types_operated,
    COUNT(DISTINCT ea.site_id) as sites_worked,
    COUNT(CASE WHEN ea.status = 'Completed' THEN 1 END) as completed_assignments,
    ROUND(
        COUNT(CASE WHEN ea.status = 'Completed' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(ea.assignment_id), 0), 
        2
    ) as completion_rate,
    CASE 
        WHEN COUNT(ea.assignment_id) >= 10 THEN 'HIGH PRODUCTIVITY'
        WHEN COUNT(ea.assignment_id) >= 5 THEN 'MODERATE PRODUCTIVITY'
        WHEN COUNT(ea.assignment_id) > 0 THEN 'LOW PRODUCTIVITY'
        ELSE 'NO ACTIVITY'
    END as productivity_rating
FROM operators o
JOIN departments d ON o.department_id = d.department_id
LEFT JOIN equipment_assignment ea ON o.operator_id = ea.operator_id
GROUP BY o.operator_id, o.first_name, o.last_name, d.department_name
ORDER BY total_assignments DESC;

-- Analytics Query 5: Fuel Consumption Analysis by Equipment Type
SELECT 
    et.type_name as equipment_type,
    COUNT(DISTINCT e.equipment_id) as equipment_count,
    COUNT(fc.consumption_id) as total_refuelings,
    SUM(fc.quantity_liters) as total_liters,
    SUM(fc.total_cost) as total_cost,
    ROUND(AVG(fc.quantity_liters), 2) as avg_liters_per_refuel,
    ROUND(AVG(fc.cost_per_liter), 2) as avg_cost_per_liter,
    ROUND(SUM(fc.total_cost) / NULLIF(COUNT(DISTINCT e.equipment_id), 0), 2) as cost_per_equipment
FROM equipment_types et
LEFT JOIN equipment e ON et.equipment_type_id = e.equipment_type_id
LEFT JOIN fuel_consumption fc ON e.equipment_id = fc.equipment_id
GROUP BY et.type_name
ORDER BY total_cost DESC NULLS LAST;

-- Analytics Query 6: Downtime Impact Analysis
SELECT 
    dt.type_name as downtime_type,
    COUNT(dr.downtime_id) as incident_count,
    SUM(dr.duration_hours) as total_hours,
    ROUND(AVG(dr.duration_hours), 2) as avg_hours_per_incident,
    SUM(dr.cost_impact) as total_cost_impact,
    ROUND(AVG(dr.cost_impact), 2) as avg_cost_per_incident,
    COUNT(CASE WHEN dr.resolution_status = 'Resolved' THEN 1 END) as resolved_count,
    COUNT(CASE WHEN dr.resolution_status = 'Pending' THEN 1 END) as pending_count,
    CASE 
        WHEN SUM(dr.duration_hours) >= 100 THEN 'CRITICAL IMPACT'
        WHEN SUM(dr.duration_hours) >= 50 THEN 'HIGH IMPACT'
        WHEN SUM(dr.duration_hours) >= 20 THEN 'MODERATE IMPACT'
        ELSE 'LOW IMPACT'
    END as impact_level
FROM downtime_types dt
LEFT JOIN downtime_records dr ON dt.downtime_type_id = dr.downtime_type_id
GROUP BY dt.type_name
ORDER BY total_hours DESC NULLS LAST;

-- Analytics Query 7: Maintenance Completion Rate Analysis
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
    ROUND(
        COUNT(CASE WHEN ms.status = 'Overdue' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(ms.schedule_id), 0), 
        2
    ) as overdue_rate,
    CASE 
        WHEN COUNT(CASE WHEN ms.status = 'Overdue' THEN 1 END) = 0 THEN 'EXCELLENT'
        WHEN COUNT(CASE WHEN ms.status = 'Overdue' THEN 1 END) <= 2 THEN 'GOOD'
        WHEN COUNT(CASE WHEN ms.status = 'Overdue' THEN 1 END) <= 5 THEN 'NEEDS ATTENTION'
        ELSE 'CRITICAL'
    END as maintenance_health
FROM maintenance_types mt
LEFT JOIN maintenance_schedule ms ON mt.maintenance_type_id = ms.maintenance_type_id
GROUP BY mt.type_name
ORDER BY completion_rate DESC NULLS LAST;

-- Analytics Query 8: Site Activity and Resource Allocation
SELECT 
    ms.site_name,
    ms.location,
    COUNT(DISTINCT ea.assignment_id) as total_assignments,
    COUNT(DISTINCT ea.equipment_id) as equipment_deployed,
    COUNT(DISTINCT ea.operator_id) as operators_assigned,
    COUNT(DISTINCT CASE WHEN ea.status = 'Active' THEN ea.assignment_id END) as active_assignments,
    ROUND(
        COUNT(DISTINCT CASE WHEN ea.status = 'Active' THEN ea.assignment_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT ea.assignment_id), 0), 
        2
    ) as active_rate,
    CASE 
        WHEN COUNT(DISTINCT ea.assignment_id) >= 15 THEN 'HIGH ACTIVITY'
        WHEN COUNT(DISTINCT ea.assignment_id) >= 8 THEN 'MODERATE ACTIVITY'
        WHEN COUNT(DISTINCT ea.assignment_id) > 0 THEN 'LOW ACTIVITY'
        ELSE 'INACTIVE'
    END as activity_level
FROM mining_sites ms
LEFT JOIN equipment_assignment ea ON ms.site_id = ea.site_id
GROUP BY ms.site_name, ms.location
ORDER BY total_assignments DESC NULLS LAST;

-- Analytics Query 9: Cost Analysis Summary
SELECT 
    'Fuel Costs' as cost_category,
    SUM(total_cost) as total_amount,
    COUNT(*) as transaction_count,
    ROUND(AVG(total_cost), 2) as avg_per_transaction
FROM fuel_consumption
UNION ALL
SELECT 
    'Downtime Costs',
    SUM(cost_impact),
    COUNT(*),
    ROUND(AVG(cost_impact), 2)
FROM downtime_records
ORDER BY total_amount DESC;

-- Analytics Query 10: Equipment Age and Maintenance Correlation
SELECT 
    et.type_name as equipment_type,
    e.equipment_id,
    e.model,
    e.purchase_date,
    TRUNC(MONTHS_BETWEEN(SYSDATE, e.purchase_date) / 12) as age_years,
    COUNT(ms.schedule_id) as maintenance_count,
    COUNT(CASE WHEN ms.status = 'Completed' THEN 1 END) as completed_maintenance,
    SUM(COALESCE(dr.duration_hours, 0)) as total_downtime_hours,
    CASE 
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.purchase_date) / 12) >= 5 THEN 'OLD'
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.purchase_date) / 12) >= 3 THEN 'MATURE'
        ELSE 'NEW'
    END as age_category
FROM equipment e
JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id
LEFT JOIN maintenance_schedule ms ON e.equipment_id = ms.equipment_id
LEFT JOIN downtime_records dr ON e.equipment_id = dr.equipment_id
GROUP BY et.type_name, e.equipment_id, e.model, e.purchase_date
ORDER BY age_years DESC, maintenance_count DESC;

-- Analytics Query 11: Shift Performance Analysis
SELECT 
    s.shift_name,
    s.start_time,
    s.end_time,
    COUNT(ea.assignment_id) as total_assignments,
    COUNT(DISTINCT ea.equipment_id) as equipment_used,
    COUNT(DISTINCT ea.operator_id) as operators_active,
    COUNT(DISTINCT ea.site_id) as sites_active,
    ROUND(
        COUNT(ea.assignment_id) * 100.0 / 
        (SELECT COUNT(*) FROM equipment_assignment), 
        2
    ) as percentage_of_total
FROM shifts s
LEFT JOIN equipment_assignment ea ON s.shift_id = ea.shift_id
GROUP BY s.shift_name, s.start_time, s.end_time
ORDER BY total_assignments DESC;

-- Analytics Query 12: Department Resource Efficiency
SELECT 
    d.department_name,
    COUNT(DISTINCT e.equipment_id) as equipment_count,
    COUNT(DISTINCT o.operator_id) as operator_count,
    COUNT(DISTINCT ea.assignment_id) as total_assignments,
    ROUND(
        COUNT(DISTINCT ea.assignment_id) * 1.0 / 
        NULLIF(COUNT(DISTINCT e.equipment_id), 0), 
        2
    ) as assignments_per_equipment,
    ROUND(
        COUNT(DISTINCT ea.assignment_id) * 1.0 / 
        NULLIF(COUNT(DISTINCT o.operator_id), 0), 
        2
    ) as assignments_per_operator,
    COALESCE(SUM(fc.total_cost), 0) as total_fuel_cost,
    COALESCE(SUM(dr.duration_hours), 0) as total_downtime_hours
FROM departments d
LEFT JOIN equipment e ON d.department_id = e.department_id
LEFT JOIN operators o ON d.department_id = o.department_id
LEFT JOIN equipment_assignment ea ON o.operator_id = ea.operator_id
LEFT JOIN fuel_consumption fc ON e.equipment_id = fc.equipment_id
LEFT JOIN downtime_records dr ON e.equipment_id = dr.equipment_id
GROUP BY d.department_name
ORDER BY total_assignments DESC;
