
BEGIN
    -- More assignments for better trends
    FOR i IN 1..20 LOOP
        INSERT INTO equipment_assignment (
            assignment_id, equipment_id, operator_id, site_id, shift_id,
            assignment_date, start_time, end_time, status
        ) VALUES (
            seq_assignment.NEXTVAL,
            TRUNC(DBMS_RANDOM.VALUE(1, 21)),
            TRUNC(DBMS_RANDOM.VALUE(1, 16)),
            TRUNC(DBMS_RANDOM.VALUE(1, 6)),
            TRUNC(DBMS_RANDOM.VALUE(1, 4)),
            SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 90)),
            SYSTIMESTAMP - TRUNC(DBMS_RANDOM.VALUE(1, 90)),
            CASE WHEN DBMS_RANDOM.VALUE < 0.7 
                THEN SYSTIMESTAMP - TRUNC(DBMS_RANDOM.VALUE(1, 60))
                ELSE NULL END,
            CASE WHEN DBMS_RANDOM.VALUE < 0.7 THEN 'Completed' ELSE 'Active' END
        );
    END LOOP;
    COMMIT;
END;
/

-- Additional Fuel Consumption records
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO fuel_consumption (
            consumption_id, equipment_id, refuel_date,
            quantity_liters, cost_per_liter, total_cost
        ) VALUES (
            seq_fuel_consumption.NEXTVAL,
            TRUNC(DBMS_RANDOM.VALUE(1, 21)),
            SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 60)),
            ROUND(DBMS_RANDOM.VALUE(100, 500), 2),
            ROUND(DBMS_RANDOM.VALUE(1.2, 1.8), 2),
            0
        );
    END LOOP;
    
    -- Update total_cost
    UPDATE fuel_consumption 
    SET total_cost = quantity_liters * cost_per_liter
    WHERE total_cost = 0;
    
    COMMIT;
END;
/

-- Additional Downtime Records
BEGIN
    FOR i IN 1..25 LOOP
        INSERT INTO downtime_records (
            downtime_id, equipment_id, downtime_type_id,
            start_time, end_time, duration_hours,
            cost_impact, description, resolution_status
        ) VALUES (
            seq_downtime.NEXTVAL,
            TRUNC(DBMS_RANDOM.VALUE(1, 21)),
            TRUNC(DBMS_RANDOM.VALUE(1, 6)),
            SYSTIMESTAMP - TRUNC(DBMS_RANDOM.VALUE(1, 60)),
            SYSTIMESTAMP - TRUNC(DBMS_RANDOM.VALUE(1, 30)),
            ROUND(DBMS_RANDOM.VALUE(1, 48), 2),
            ROUND(DBMS_RANDOM.VALUE(100, 5000), 2),
            'Test downtime incident for BI analysis',
            CASE WHEN DBMS_RANDOM.VALUE < 0.8 THEN 'Resolved' ELSE 'Pending' END
        );
    END LOOP;
    COMMIT;
END;
/

-- Additional Maintenance Schedule records
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO maintenance_schedule (
            schedule_id, equipment_id, maintenance_type_id,
            scheduled_date, completion_date, status, notes
        ) VALUES (
            seq_maintenance_schedule.NEXTVAL,
            TRUNC(DBMS_RANDOM.VALUE(1, 21)),
            TRUNC(DBMS_RANDOM.VALUE(1, 6)),
            SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 90)),
            CASE WHEN DBMS_RANDOM.VALUE < 0.6 
                THEN SYSDATE - TRUNC(DBMS_RANDOM.VALUE(1, 60))
                ELSE NULL END,
            CASE 
                WHEN DBMS_RANDOM.VALUE < 0.6 THEN 'Completed'
                WHEN DBMS_RANDOM.VALUE < 0.8 THEN 'Scheduled'
                ELSE 'Overdue'
            END,
            'Test maintenance for BI dashboard'
        );
    END LOOP;
    COMMIT;
END;
/

-- Generate some audit violations for compliance dashboard
BEGIN
    -- Simulate weekend violations
    FOR i IN 1..5 LOOP
        INSERT INTO audit_log (
            audit_id, username, table_name, action,
            timestamp, status, error_message
        ) VALUES (
            seq_audit.NEXTVAL,
            'TEST_USER',
            'EQUIPMENT',
            'UPDATE',
            TRUNC(SYSDATE, 'IW') + 6 + (i/24), -- Saturday
            'DENIED',
            'Weekend operations not allowed'
        );
    END LOOP;
    
    -- Simulate after-hours violations
    FOR i IN 1..3 LOOP
        INSERT INTO audit_log (
            audit_id, username, table_name, action,
            timestamp, status, error_message
        ) VALUES (
            seq_audit.NEXTVAL,
            'TEST_USER',
            'OPERATORS',
            'DELETE',
            TRUNC(SYSDATE) + (23/24), -- 11 PM
            'DENIED',
            'After-hours operations restricted'
        );
    END LOOP;
    
    COMMIT;
END;
/