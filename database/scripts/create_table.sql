-- ============================================================================
-- TABLE 1: DEPARTMENTS
-- ============================================================================
CREATE TABLE DEPARTMENTS (
    DEPARTMENT_ID NUMBER(10) CONSTRAINT pk_departments PRIMARY KEY,
    DEPARTMENT_NAME VARCHAR2(100) CONSTRAINT nn_dept_name NOT NULL CONSTRAINT uq_dept_name UNIQUE,
    LOCATION VARCHAR2(200),
    BUDGET NUMBER(15,2) CONSTRAINT chk_dept_budget CHECK (BUDGET >= 0),
    MANAGER_ID NUMBER(10), -- FK to SUPERVISORS (added later)
    CREATED_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT chk_dept_name_length CHECK (LENGTH(DEPARTMENT_NAME) >= 3)
) TABLESPACE mining_data;

COMMENT ON TABLE DEPARTMENTS IS 'Organizational departments';
COMMENT ON COLUMN DEPARTMENTS.DEPARTMENT_ID IS 'Primary key - Department ID';
COMMENT ON COLUMN DEPARTMENTS.DEPARTMENT_NAME IS 'Department name (unique)';

-- ============================================================================
-- TABLE 2: SUPERVISORS
-- ============================================================================
CREATE TABLE SUPERVISORS (
    SUPERVISOR_ID NUMBER(10) CONSTRAINT pk_supervisors PRIMARY KEY,
    FIRST_NAME VARCHAR2(50) CONSTRAINT nn_sup_fname NOT NULL,
    LAST_NAME VARCHAR2(50) CONSTRAINT nn_sup_lname NOT NULL,
    PHONE VARCHAR2(20),
    EMAIL VARCHAR2(100) CONSTRAINT uq_sup_email UNIQUE,
    DEPARTMENT_ID NUMBER(10) CONSTRAINT nn_sup_dept_id NOT NULL,
    HIRE_DATE DATE DEFAULT SYSDATE,
    CONSTRAINT fk_sup_dept FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID),
    CONSTRAINT chk_sup_email CHECK (EMAIL LIKE '%@%')
) TABLESPACE mining_data;

COMMENT ON TABLE SUPERVISORS IS 'Site and department supervisors';

-- Add FK to DEPARTMENTS.MANAGER_ID now that SUPERVISORS exists
ALTER TABLE DEPARTMENTS 
ADD CONSTRAINT fk_dept_manager FOREIGN KEY (MANAGER_ID) REFERENCES SUPERVISORS(SUPERVISOR_ID);

-- ============================================================================
-- TABLE 3: MAINTENANCE_CREW
-- ============================================================================
CREATE TABLE MAINTENANCE_CREW (
    CREW_ID NUMBER(10) CONSTRAINT pk_crew PRIMARY KEY,
    FIRST_NAME VARCHAR2(50) CONSTRAINT nn_crew_fname NOT NULL,
    LAST_NAME VARCHAR2(50) CONSTRAINT nn_crew_lname NOT NULL,
    SPECIALIZATION VARCHAR2(100),
    PHONE VARCHAR2(20),
    EMAIL VARCHAR2(100) CONSTRAINT uq_crew_email UNIQUE,
    HIRE_DATE DATE DEFAULT SYSDATE CONSTRAINT nn_crew_hire NOT NULL,
    DEPARTMENT_ID NUMBER(10) CONSTRAINT nn_crew_dept_id NOT NULL,
    STATUS VARCHAR2(20) DEFAULT 'Active' CONSTRAINT nn_crew_status NOT NULL,
    CONSTRAINT fk_crew_dept FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID),
    CONSTRAINT chk_crew_status CHECK (STATUS IN ('Active', 'On-Leave', 'Terminated')),
    CONSTRAINT chk_crew_email CHECK (EMAIL LIKE '%@%')
) TABLESPACE mining_data;

COMMENT ON TABLE MAINTENANCE_CREW IS 'Maintenance personnel and technicians';

-- ============================================================================
-- TABLE 4: EQUIPMENT
-- ============================================================================
CREATE TABLE EQUIPMENT (
    EQUIPMENT_ID NUMBER(10) CONSTRAINT pk_equipment PRIMARY KEY,
    EQUIPMENT_TYPE VARCHAR2(50) CONSTRAINT nn_equip_type NOT NULL,
    MODEL VARCHAR2(100) CONSTRAINT nn_equip_model NOT NULL,
    SERIAL_NUMBER VARCHAR2(50) CONSTRAINT nn_equip_serial NOT NULL CONSTRAINT uq_equip_serial UNIQUE,
    PURCHASE_DATE DATE CONSTRAINT nn_equip_purchase NOT NULL,
    CAPACITY NUMBER(10,2) CONSTRAINT nn_equip_capacity NOT NULL,
    STATUS VARCHAR2(20) DEFAULT 'Available' CONSTRAINT nn_equip_status NOT NULL,
    LAST_MAINTENANCE_DATE DATE,
    DEPARTMENT_ID NUMBER(10) CONSTRAINT nn_equip_dept_id NOT NULL,
    CONSTRAINT fk_equip_dept FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID),
    CONSTRAINT chk_equip_type CHECK (EQUIPMENT_TYPE IN ('Excavator', 'Haul Truck', 'Drill Rig', 'Loader', 'Grader', 'Dozer', 'Crane')),
    CONSTRAINT chk_equip_status CHECK (STATUS IN ('Available', 'In-Use', 'Maintenance', 'Broken', 'Retired')),
    CONSTRAINT chk_equip_capacity CHECK (CAPACITY > 0),
    CONSTRAINT chk_purchase_date CHECK (PURCHASE_DATE <= SYSDATE)
) TABLESPACE mining_data;

COMMENT ON TABLE EQUIPMENT IS 'Mining equipment inventory';
COMMENT ON COLUMN EQUIPMENT.CAPACITY IS 'Load capacity in tons or cubic meters';

-- ============================================================================
-- TABLE 5: OPERATORS
-- ============================================================================
CREATE TABLE OPERATORS (
    OPERATOR_ID NUMBER(10) CONSTRAINT pk_operators PRIMARY KEY,
    FIRST_NAME VARCHAR2(50) CONSTRAINT nn_op_fname NOT NULL,
    LAST_NAME VARCHAR2(50) CONSTRAINT nn_op_lname NOT NULL,
    LICENSE_NUMBER VARCHAR2(50) CONSTRAINT nn_op_license NOT NULL CONSTRAINT uq_op_license UNIQUE,
    LICENSE_EXPIRY DATE CONSTRAINT nn_op_expiry NOT NULL,
    PHONE VARCHAR2(20),
    EMAIL VARCHAR2(100) CONSTRAINT uq_op_email UNIQUE,
    HIRE_DATE DATE DEFAULT SYSDATE CONSTRAINT nn_op_hire NOT NULL,
    STATUS VARCHAR2(20) DEFAULT 'Active' CONSTRAINT nn_op_status NOT NULL,
    DEPARTMENT_ID NUMBER(10) CONSTRAINT nn_op_dept_id NOT NULL,
    CONSTRAINT fk_op_dept FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENTS(DEPARTMENT_ID),
    CONSTRAINT chk_op_status CHECK (STATUS IN ('Active', 'On-Leave', 'Terminated')),
    CONSTRAINT chk_op_email CHECK (EMAIL LIKE '%@%' OR EMAIL IS NULL),
    CONSTRAINT chk_license_expiry CHECK (LICENSE_EXPIRY > HIRE_DATE)
) TABLESPACE mining_data;

COMMENT ON TABLE OPERATORS IS 'Equipment operators and drivers';

-- ============================================================================
-- TABLE 6: MINING_SITES
-- ============================================================================
CREATE TABLE MINING_SITES (
    SITE_ID NUMBER(10) CONSTRAINT pk_sites PRIMARY KEY,
    SITE_NAME VARCHAR2(100) CONSTRAINT nn_site_name NOT NULL CONSTRAINT uq_site_name UNIQUE,
    LOCATION VARCHAR2(200) CONSTRAINT nn_site_location NOT NULL,
    SITE_TYPE VARCHAR2(50) CONSTRAINT nn_site_type NOT NULL,
    CAPACITY NUMBER(10,2),
    STATUS VARCHAR2(20) DEFAULT 'Active' CONSTRAINT nn_site_status NOT NULL,
    SUPERVISOR_ID NUMBER(10),
    CONSTRAINT fk_site_supervisor FOREIGN KEY (SUPERVISOR_ID) REFERENCES SUPERVISORS(SUPERVISOR_ID),
    CONSTRAINT chk_site_type CHECK (SITE_TYPE IN ('Open-Pit', 'Underground', 'Processing Plant', 'Quarry')),
    CONSTRAINT chk_site_status CHECK (STATUS IN ('Active', 'Inactive', 'Under-Development', 'Closed')),
    CONSTRAINT chk_site_capacity CHECK (CAPACITY IS NULL OR CAPACITY > 0)
) TABLESPACE mining_data;

COMMENT ON TABLE MINING_SITES IS 'Mining site locations and details';

-- ============================================================================
-- TABLE 7: SHIFTS
-- ============================================================================
CREATE TABLE SHIFTS (
    SHIFT_ID NUMBER(10) CONSTRAINT pk_shifts PRIMARY KEY,
    SHIFT_NAME VARCHAR2(50) CONSTRAINT nn_shift_name NOT NULL CONSTRAINT uq_shift_name UNIQUE,
    START_TIME TIMESTAMP CONSTRAINT nn_shift_start NOT NULL,
    END_TIME TIMESTAMP CONSTRAINT nn_shift_end NOT NULL,
    DURATION_HOURS NUMBER(4,2) CONSTRAINT nn_shift_duration NOT NULL,
    CONSTRAINT chk_shift_duration CHECK (DURATION_HOURS > 0 AND DURATION_HOURS <= 24),
    CONSTRAINT chk_shift_times CHECK (END_TIME > START_TIME)
) TABLESPACE mining_data;

COMMENT ON TABLE SHIFTS IS 'Work shift schedules';

-- ============================================================================
-- TABLE 8: EQUIPMENT_ASSIGNMENT
-- ============================================================================
CREATE TABLE EQUIPMENT_ASSIGNMENT (
    ASSIGNMENT_ID NUMBER(10) CONSTRAINT pk_assignment PRIMARY KEY,
    EQUIPMENT_ID NUMBER(10) CONSTRAINT nn_assign_equip_id NOT NULL,
    OPERATOR_ID NUMBER(10) CONSTRAINT nn_assign_op_id NOT NULL,
    SITE_ID NUMBER(10) CONSTRAINT nn_assign_site_id NOT NULL,
    SHIFT_ID NUMBER(10) CONSTRAINT nn_assign_shift_id NOT NULL,
    ASSIGNMENT_DATE DATE DEFAULT SYSDATE CONSTRAINT nn_assign_date NOT NULL,
    START_TIME TIMESTAMP CONSTRAINT nn_assign_start NOT NULL,
    END_TIME TIMESTAMP,
    STATUS VARCHAR2(20) DEFAULT 'Scheduled' CONSTRAINT nn_assign_status NOT NULL,
    CONSTRAINT fk_assign_equip FOREIGN KEY (EQUIPMENT_ID) REFERENCES EQUIPMENT(EQUIPMENT_ID),
    CONSTRAINT fk_assign_op FOREIGN KEY (OPERATOR_ID) REFERENCES OPERATORS(OPERATOR_ID),
    CONSTRAINT fk_assign_site FOREIGN KEY (SITE_ID) REFERENCES MINING_SITES(SITE_ID),
    CONSTRAINT fk_assign_shift FOREIGN KEY (SHIFT_ID) REFERENCES SHIFTS(SHIFT_ID),
    CONSTRAINT chk_assign_status CHECK (STATUS IN ('Scheduled', 'In-Progress', 'Completed', 'Cancelled')),
    CONSTRAINT chk_assign_times CHECK (END_TIME IS NULL OR END_TIME > START_TIME)
) TABLESPACE mining_data;

COMMENT ON TABLE EQUIPMENT_ASSIGNMENT IS 'Daily equipment-operator-site assignments';

-- ============================================================================
-- TABLE 9: MAINTENANCE_SCHEDULE
-- ============================================================================
CREATE TABLE MAINTENANCE_SCHEDULE (
    SCHEDULE_ID NUMBER(10) CONSTRAINT pk_maint_schedule PRIMARY KEY,
    EQUIPMENT_ID NUMBER(10) CONSTRAINT nn_sched_equip_id NOT NULL,
    MAINTENANCE_TYPE VARCHAR2(50) CONSTRAINT nn_sched_type NOT NULL,
    SCHEDULED_DATE DATE CONSTRAINT nn_sched_date NOT NULL,
    ESTIMATED_DURATION_HOURS NUMBER(6,2) CONSTRAINT nn_sched_duration NOT NULL,
    PRIORITY VARCHAR2(20) DEFAULT 'Medium' CONSTRAINT nn_sched_priority NOT NULL,
    DESCRIPTION VARCHAR2(500),
    STATUS VARCHAR2(20) DEFAULT 'Scheduled' CONSTRAINT nn_sched_status NOT NULL,
    CREW_ID NUMBER(10),
    CONSTRAINT fk_sched_equip FOREIGN KEY (EQUIPMENT_ID) REFERENCES EQUIPMENT(EQUIPMENT_ID),
    CONSTRAINT fk_sched_crew FOREIGN KEY (CREW_ID) REFERENCES MAINTENANCE_CREW(CREW_ID),
    CONSTRAINT chk_maint_type CHECK (MAINTENANCE_TYPE IN ('Preventive', 'Corrective', 'Predictive', 'Emergency')),
    CONSTRAINT chk_maint_priority CHECK (PRIORITY IN ('Critical', 'High', 'Medium', 'Low')),
    CONSTRAINT chk_maint_status CHECK (STATUS IN ('Scheduled', 'In-Progress', 'Completed', 'Cancelled')),
    CONSTRAINT chk_maint_duration CHECK (ESTIMATED_DURATION_HOURS > 0)
) TABLESPACE mining_data;

COMMENT ON TABLE MAINTENANCE_SCHEDULE IS 'Planned maintenance activities';

-- ============================================================================
-- TABLE 10: MAINTENANCE_HISTORY
-- ============================================================================
CREATE TABLE MAINTENANCE_HISTORY (
    HISTORY_ID NUMBER(10) CONSTRAINT pk_maint_history PRIMARY KEY,
    SCHEDULE_ID NUMBER(10) CONSTRAINT uq_history_sched UNIQUE,
    EQUIPMENT_ID NUMBER(10) CONSTRAINT nn_hist_equip_id NOT NULL,
    START_DATE TIMESTAMP CONSTRAINT nn_hist_start NOT NULL,
    END_DATE TIMESTAMP,
    ACTUAL_DURATION_HOURS NUMBER(6,2),
    COST NUMBER(12,2) CONSTRAINT nn_hist_cost NOT NULL,
    PARTS_USED CLOB,
    NOTES VARCHAR2(1000),
    PERFORMED_BY NUMBER(10) CONSTRAINT nn_hist_crew NOT NULL,
    CONSTRAINT fk_hist_sched FOREIGN KEY (SCHEDULE_ID) REFERENCES MAINTENANCE_SCHEDULE(SCHEDULE_ID),
    CONSTRAINT fk_hist_equip FOREIGN KEY (EQUIPMENT_ID) REFERENCES EQUIPMENT(EQUIPMENT_ID),
    CONSTRAINT fk_hist_crew FOREIGN KEY (PERFORMED_BY) REFERENCES MAINTENANCE_CREW(CREW_ID),
    CONSTRAINT chk_hist_times CHECK (END_DATE IS NULL OR END_DATE > START_DATE),
    CONSTRAINT chk_hist_cost CHECK (COST >= 0)
) TABLESPACE mining_data
LOB (PARTS_USED) STORE AS (TABLESPACE mining_lobs);

COMMENT ON TABLE MAINTENANCE_HISTORY IS 'Completed maintenance records';

-- ============================================================================
-- TABLE 11: EQUIPMENT_USAGE_LOG (FACT TABLE)
-- ============================================================================
CREATE TABLE EQUIPMENT_USAGE_LOG (
    USAGE_ID NUMBER(10) CONSTRAINT pk_usage PRIMARY KEY,
    EQUIPMENT_ID NUMBER(10) CONSTRAINT nn_usage_equip_id NOT NULL,
    ASSIGNMENT_ID NUMBER(10),
    LOG_DATE DATE DEFAULT SYSDATE CONSTRAINT nn_usage_date NOT NULL,
    HOURS_OPERATED NUMBER(6,2) CONSTRAINT nn_usage_hours NOT NULL,
    FUEL_CONSUMED_LITERS NUMBER(10,2),
    PRODUCTION_OUTPUT NUMBER(12,2),
    ODOMETER_READING NUMBER(12,2),
    OPERATOR_ID NUMBER(10) CONSTRAINT nn_usage_op_id NOT NULL,
    SITE_ID NUMBER(10) CONSTRAINT nn_usage_site_id NOT NULL,
    CONSTRAINT fk_usage_equip FOREIGN KEY (EQUIPMENT_ID) REFERENCES EQUIPMENT(EQUIPMENT_ID),
    CONSTRAINT fk_usage_assign FOREIGN KEY (ASSIGNMENT_ID) REFERENCES EQUIPMENT_ASSIGNMENT(ASSIGNMENT_ID),
    CONSTRAINT fk_usage_op FOREIGN KEY (OPERATOR_ID) REFERENCES OPERATORS(OPERATOR_ID),
    CONSTRAINT fk_usage_site FOREIGN KEY (SITE_ID) REFERENCES MINING_SITES(SITE_ID),
    CONSTRAINT chk_usage_hours CHECK (HOURS_OPERATED >= 0 AND HOURS_OPERATED <= 24),
    CONSTRAINT chk_usage_fuel CHECK (FUEL_CONSUMED_LITERS IS NULL OR FUEL_CONSUMED_LITERS >= 0),
    CONSTRAINT chk_usage_output CHECK (PRODUCTION_OUTPUT IS NULL OR PRODUCTION_OUTPUT >= 0)
) TABLESPACE mining_data;

COMMENT ON TABLE EQUIPMENT_USAGE_LOG IS 'Daily equipment usage tracking (fact table for BI)';

-- ============================================================================
-- TABLE 12: DOWNTIME_RECORDS
-- ============================================================================
CREATE TABLE DOWNTIME_RECORDS (
    DOWNTIME_ID NUMBER(10) CONSTRAINT pk_downtime PRIMARY KEY,
    EQUIPMENT_ID NUMBER(10) CONSTRAINT nn_down_equip_id NOT NULL,
    START_TIME TIMESTAMP CONSTRAINT nn_down_start NOT NULL,
    END_TIME TIMESTAMP,
    DURATION_HOURS NUMBER(8,2),
    DOWNTIME_TYPE VARCHAR2(50) CONSTRAINT nn_down_type NOT NULL,
    REASON VARCHAR2(500),
    IMPACT_COST NUMBER(12,2),
    REPORTED_BY NUMBER(10),
    CONSTRAINT fk_down_equip FOREIGN KEY (EQUIPMENT_ID) REFERENCES EQUIPMENT(EQUIPMENT_ID),
    CONSTRAINT fk_down_reporter FOREIGN KEY (REPORTED_BY) REFERENCES OPERATORS(OPERATOR_ID),
    CONSTRAINT chk_down_type CHECK (DOWNTIME_TYPE IN ('Breakdown', 'Maintenance', 'Weather', 'No-Operator', 'Other')),
    CONSTRAINT chk_down_times CHECK (END_TIME IS NULL OR END_TIME > START_TIME),
    CONSTRAINT chk_down_cost CHECK (IMPACT_COST IS NULL OR IMPACT_COST >= 0)
) TABLESPACE mining_data;

COMMENT ON TABLE DOWNTIME_RECORDS IS 'Equipment downtime tracking and analysis';

-- ============================================================================
-- TABLE 13: SPARE_PARTS_INVENTORY
-- ============================================================================
CREATE TABLE SPARE_PARTS_INVENTORY (
    PART_ID NUMBER(10) CONSTRAINT pk_parts PRIMARY KEY,
    PART_NUMBER VARCHAR2(50) CONSTRAINT nn_part_number NOT NULL CONSTRAINT uq_part_number UNIQUE,
    PART_NAME VARCHAR2(100) CONSTRAINT nn_part_name NOT NULL,
    CATEGORY VARCHAR2(50) CONSTRAINT nn_part_category NOT NULL,
    QUANTITY_IN_STOCK NUMBER(10) DEFAULT 0 CONSTRAINT nn_part_qty NOT NULL,
    MINIMUM_STOCK_LEVEL NUMBER(10) CONSTRAINT nn_part_min NOT NULL,
    UNIT_COST NUMBER(10,2) CONSTRAINT nn_part_cost NOT NULL,
    SUPPLIER VARCHAR2(100),
    LAST_RESTOCK_DATE DATE,
    CONSTRAINT chk_part_qty CHECK (QUANTITY_IN_STOCK >= 0),
    CONSTRAINT chk_part_min CHECK (MINIMUM_STOCK_LEVEL >= 0),
    CONSTRAINT chk_part_cost CHECK (UNIT_COST >= 0)
) TABLESPACE mining_data;

COMMENT ON TABLE SPARE_PARTS_INVENTORY IS 'Spare parts inventory management';

-- ============================================================================
-- TABLE 14: FUEL_CONSUMPTION
-- ============================================================================
CREATE TABLE FUEL_CONSUMPTION (
    CONSUMPTION_ID NUMBER(10) CONSTRAINT pk_fuel PRIMARY KEY,
    EQUIPMENT_ID NUMBER(10) CONSTRAINT nn_fuel_equip_id NOT NULL,
    REFUEL_DATE TIMESTAMP DEFAULT SYSTIMESTAMP CONSTRAINT nn_fuel_date NOT NULL,
    LITERS_ADDED NUMBER(10,2) CONSTRAINT nn_fuel_liters NOT NULL,
    COST_PER_LITER NUMBER(8,2) CONSTRAINT nn_fuel_cost_liter NOT NULL,
    TOTAL_COST NUMBER(12,2) CONSTRAINT nn_fuel_total NOT NULL,
    ODOMETER_READING NUMBER(12,2),
    OPERATOR_ID NUMBER(10),
    CONSTRAINT fk_fuel_equip FOREIGN KEY (EQUIPMENT_ID) REFERENCES EQUIPMENT(EQUIPMENT_ID),
    CONSTRAINT fk_fuel_op FOREIGN KEY (OPERATOR_ID) REFERENCES OPERATORS(OPERATOR_ID),
    CONSTRAINT chk_fuel_liters CHECK (LITERS_ADDED > 0),
    CONSTRAINT chk_fuel_cost CHECK (COST_PER_LITER > 0 AND TOTAL_COST > 0)
) TABLESPACE mining_data;

COMMENT ON TABLE FUEL_CONSUMPTION IS 'Fuel consumption tracking and costs';

-- ============================================================================
-- TABLE 15: PUBLIC_HOLIDAYS
-- ============================================================================
CREATE TABLE PUBLIC_HOLIDAYS (
    HOLIDAY_ID NUMBER(10) CONSTRAINT pk_holidays PRIMARY KEY,
    HOLIDAY_NAME VARCHAR2(100) CONSTRAINT nn_holiday_name NOT NULL,
    HOLIDAY_DATE DATE CONSTRAINT nn_holiday_date NOT NULL CONSTRAINT uq_holiday_date UNIQUE,
    COUNTRY VARCHAR2(50) DEFAULT 'Rwanda' CONSTRAINT nn_holiday_country NOT NULL,
    DESCRIPTION VARCHAR2(200),
    CONSTRAINT chk_holiday_future CHECK (HOLIDAY_DATE >= ADD_MONTHS(TRUNC(SYSDATE), -1))
) TABLESPACE mining_data;

COMMENT ON TABLE PUBLIC_HOLIDAYS IS 'Public holidays calendar for Phase VII restrictions';

-- ============================================================================
-- TABLE 16: AUDIT_LOG
-- ============================================================================
CREATE TABLE AUDIT_LOG (
    AUDIT_ID NUMBER(10) CONSTRAINT pk_audit PRIMARY KEY,
    TABLE_NAME VARCHAR2(50) CONSTRAINT nn_audit_table NOT NULL,
    OPERATION VARCHAR2(20) CONSTRAINT nn_audit_op NOT NULL,
    OPERATION_DATE TIMESTAMP DEFAULT SYSTIMESTAMP CONSTRAINT nn_audit_date NOT NULL,
    USERNAME VARCHAR2(50) CONSTRAINT nn_audit_user NOT NULL,
    STATUS VARCHAR2(20) CONSTRAINT nn_audit_status NOT NULL,
    REASON VARCHAR2(200),
    IP_ADDRESS VARCHAR2(50),
    CONSTRAINT chk_audit_op CHECK (OPERATION IN ('INSERT', 'UPDATE', 'DELETE')),
    CONSTRAINT chk_audit_status CHECK (STATUS IN ('ALLOWED', 'DENIED'))
) TABLESPACE mining_data;

COMMENT ON TABLE AUDIT_LOG IS 'System audit trail for Phase VII';
