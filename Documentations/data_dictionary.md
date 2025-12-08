# Data Dictionary – Mining Equipment Scheduler

This document describes the logical data model for the Mining Equipment Scheduler, including:

- Tables and their purpose
- Columns, data types, and constraints
- Keys (PK/FK) and important business rules

Datatypes are expressed in Oracle-style notation (NUMBER, VARCHAR2, DATE), but the model is logical and can be adapted to other RDBMS.

---

## 1. DEPARTMENTS

Holds organizational units that own equipment and staff.

### Table: DEPARTMENTS

| Column           | Data Type       | Constraints                     | Description                          |
|------------------|-----------------|----------------------------------|--------------------------------------|
| DEPARTMENT_ID    | NUMBER(10)      | PK, NOT NULL                    | Unique department identifier         |
| DEPARTMENT_NAME  | VARCHAR2(100)   | NOT NULL                        | Name of the department               |

**Notes / Business Rules**

- One department can own many equipment records and employ many operators, maintenance crew, and supervisors.

---

## 2. EQUIPMENT

Master data for all mining equipment.

### Table: EQUIPMENT

| Column         | Data Type       | Constraints                                                                 | Description                                      |
|----------------|-----------------|-----------------------------------------------------------------------------|--------------------------------------------------|
| EQUIPMENT_ID   | NUMBER(10)      | PK, NOT NULL                                                                | Unique equipment identifier                      |
| EQUIPMENT_CODE | VARCHAR2(30)    | NOT NULL, UNIQUE                                                            | Business code/tag for equipment                  |
| EQUIPMENT_TYPE | VARCHAR2(50)    | NOT NULL                                                                    | Type (e.g., EXCAVATOR, TRUCK, DRILL, LOADER)     |
| MODEL          | VARCHAR2(100)   | NOT NULL                                                                    | Equipment model                                  |
| SERIAL_NUMBER  | VARCHAR2(50)    | NOT NULL, UNIQUE                                                            | Manufacturer serial number                       |
| PURCHASE_DATE  | DATE            | NOT NULL                                                                    | Acquisition date                                 |
| STATUS         | VARCHAR2(20)    | NOT NULL, CHECK (STATUS IN ('AVAILABLE','IN_USE','MAINTENANCE','RETIRED')) | Current status                                   |
| CAPACITY       | NUMBER(10,2)    | NULL                                                                       | Load/volume capacity (e.g., tons, m³)            |
| DEPARTMENT_ID  | NUMBER(10)      | FK → DEPARTMENTS.DEPARTMENT_ID, NULL                                       | Owning department                                |

**Notes / Business Rules**

- `STATUS` may optionally be treated as a FK to `EQUIPMENT_STATUS.STATUS_CODE` (see Section 15).
- Each equipment belongs to at most one department at a time.

---

## 3. MINING_SITES

Defines pits, plants, stockpiles, workshops, etc.

### Table: MINING_SITES

| Column        | Data Type       | Constraints                                                              | Description                            |
|---------------|-----------------|--------------------------------------------------------------------------|----------------------------------------|
| SITE_ID       | NUMBER(10)      | PK, NOT NULL                                                             | Unique site identifier                 |
| SITE_NAME     | VARCHAR2(100)   | NOT NULL                                                                 | Name of site                           |
| SITE_TYPE     | VARCHAR2(30)    | NOT NULL, CHECK (SITE_TYPE IN ('PIT','PLANT','STOCKPILE','WORKSHOP'))   | Site type                              |
| LOCATION_DESC | VARCHAR2(255)   | NULL                                                                     | Address / general location description |
| ACTIVE_FLAG   | CHAR(1)         | NOT NULL, CHECK (ACTIVE_FLAG IN ('Y','N'))                               | Flag indicating if site is active      |

**Notes**

- A site can have many equipment assignments, usage logs, and fuel records.

---

## 4. SHIFTS

Defines work shifts used in assignments and usage logs.

### Table: SHIFTS

| Column          | Data Type       | Constraints          | Description                                |
|-----------------|-----------------|----------------------|--------------------------------------------|
| SHIFT_ID        | NUMBER(10)      | PK, NOT NULL         | Unique shift identifier                    |
| SHIFT_NAME      | VARCHAR2(50)    | NOT NULL             | Shift name (e.g., DAY, NIGHT, ROTATION)    |
| START_TIME      | DATE            | NOT NULL             | Shift start time (time component used)     |
| END_TIME        | DATE            | NOT NULL             | Shift end time (time component used)       |
| HOURS_PER_SHIFT | NUMBER(4,2)     | NOT NULL             | Total hours in the shift                   |

**Notes**

- Time-of-day is stored in `START_TIME` and `END_TIME`; the date part is not semantically relevant.

---

## 5. OPERATORS

Equipment operators/drivers.

### Table: OPERATORS

| Column        | Data Type       | Constraints                                 | Description                             |
|---------------|-----------------|----------------------------------------------|-----------------------------------------|
| OPERATOR_ID   | NUMBER(10)      | PK, NOT NULL                                 | Unique operator identifier              |
| EMPLOYEE_NO   | VARCHAR2(20)    | NOT NULL, UNIQUE                             | HR/employee number                      |
| FULL_NAME     | VARCHAR2(100)   | NOT NULL                                     | Operator name                           |
| DEPARTMENT_ID | NUMBER(10)      | FK → DEPARTMENTS.DEPARTMENT_ID, NOT NULL     | Department                              |
| ACTIVE_FLAG   | CHAR(1)         | NOT NULL, CHECK (ACTIVE_FLAG IN ('Y','N'))   | Indicates if operator is active         |

**Notes**

- One department can have many operators.
- Operators are assigned to equipment via `EQUIPMENT_ASSIGNMENT`.

---

## 6. MAINTENANCE_CREW

Maintenance technicians and related personnel.

### Table: MAINTENANCE_CREW

| Column        | Data Type       | Constraints                                 | Description                                   |
|---------------|-----------------|----------------------------------------------|-----------------------------------------------|
| CREW_ID       | NUMBER(10)      | PK, NOT NULL                                 | Unique crew member identifier                 |
| EMPLOYEE_NO   | VARCHAR2(20)    | NOT NULL, UNIQUE                             | HR/employee number                            |
| FULL_NAME     | VARCHAR2(100)   | NOT NULL                                     | Name of maintenance crew member               |
| SKILL_LEVEL   | VARCHAR2(20)    | NULL                                         | Skill/role (e.g., MECHANIC, ELECTRICIAN)      |
| DEPARTMENT_ID | NUMBER(10)      | FK → DEPARTMENTS.DEPARTMENT_ID, NOT NULL     | Department                                    |
| ACTIVE_FLAG   | CHAR(1)         | NOT NULL, CHECK (ACTIVE_FLAG IN ('Y','N'))   | Indicates if crew member is active            |

**Notes**

- A crew member can be assigned as the primary technician on work orders.

---

## 7. SUPERVISORS

Site and maintenance supervisors/managers.

### Table: SUPERVISORS

| Column        | Data Type       | Constraints                                 | Description                                 |
|---------------|-----------------|----------------------------------------------|---------------------------------------------|
| SUPERVISOR_ID | NUMBER(10)      | PK, NOT NULL                                 | Unique supervisor identifier                |
| EMPLOYEE_NO   | VARCHAR2(20)    | NOT NULL, UNIQUE                             | HR/employee number                          |
| FULL_NAME     | VARCHAR2(100)   | NOT NULL                                     | Supervisor name                             |
| DEPARTMENT_ID | NUMBER(10)      | FK → DEPARTMENTS.DEPARTMENT_ID, NOT NULL     | Department                                  |
| ACTIVE_FLAG   | CHAR(1)         | NOT NULL, CHECK (ACTIVE_FLAG IN ('Y','N'))   | Indicates if supervisor is active           |

**Notes**

- Supervisors create work orders and may oversee equipment assignments.

---

## 8. EQUIPMENT_ASSIGNMENT

Daily allocation of equipment to site, operator, and shift.

### Table: EQUIPMENT_ASSIGNMENT

| Column        | Data Type       | Constraints                                                      | Description                                   |
|---------------|-----------------|------------------------------------------------------------------|-----------------------------------------------|
| ASSIGNMENT_ID | NUMBER(10)      | PK, NOT NULL                                                     | Unique equipment assignment identifier        |
| ASSIGN_DATE   | DATE            | NOT NULL                                                         | Date of assignment                            |
| EQUIPMENT_ID  | NUMBER(10)      | FK → EQUIPMENT.EQUIPMENT_ID, NOT NULL                            | Assigned equipment                            |
| SITE_ID       | NUMBER(10)      | FK → MINING_SITES.SITE_ID, NOT NULL                              | Site where equipment is assigned              |
| OPERATOR_ID   | NUMBER(10)      | FK → OPERATORS.OPERATOR_ID, NOT NULL                             | Operator assigned                             |
| SHIFT_ID      | NUMBER(10)      | FK → SHIFTS.SHIFT_ID, NOT NULL                                   | Shift for the assignment                      |
| SUPERVISOR_ID | NUMBER(10)      | FK → SUPERVISORS.SUPERVISOR_ID, NULL                             | Optional supervisor in charge                 |
| REMARKS       | VARCHAR2(500)   | NULL                                                             | Free-text comments                            |

**Indexes / Business Rules**

- Unique constraint: `(ASSIGN_DATE, EQUIPMENT_ID, SHIFT_ID)`  
  Ensures the same equipment cannot be assigned to more than one operator per shift on the same day.

---

## 9. MAINTENANCE_SCHEDULE

Planned preventive maintenance and inspection schedules per equipment.

### Table: MAINTENANCE_SCHEDULE

| Column        | Data Type       | Constraints                                                                    | Description                                  |
|---------------|-----------------|--------------------------------------------------------------------------------|----------------------------------------------|
| SCHEDULE_ID   | NUMBER(10)      | PK, NOT NULL                                                                   | Unique schedule identifier                   |
| EQUIPMENT_ID  | NUMBER(10)      | FK → EQUIPMENT.EQUIPMENT_ID, NOT NULL                                          | Equipment to which the schedule applies      |
| MAINT_TYPE    | VARCHAR2(20)    | NOT NULL, CHECK (MAINT_TYPE IN ('PM','INSPECTION'))                            | Type of maintenance                          |
| INTERVAL_TYPE | VARCHAR2(20)    | NOT NULL, CHECK (INTERVAL_TYPE IN ('HOURS','DAYS','KM','TONS'))                | Basis for interval                           |
| INTERVAL_VALUE| NUMBER(10,2)    | NOT NULL                                                                       | Interval value (e.g., 500 hours)             |
| LAST_DONE_DATE| DATE            | NULL                                                                           | Date of last maintenance under this schedule |
| LAST_DONE_METER | NUMBER(12,2)  | NULL                                                                           | Meter reading at last maintenance            |
| NEXT_DUE_DATE | DATE            | NULL                                                                           | Calculated next due date                     |
| NEXT_DUE_METER| NUMBER(12,2)    | NULL                                                                           | Calculated next due meter                    |
| ACTIVE_FLAG   | CHAR(1)         | NOT NULL, CHECK (ACTIVE_FLAG IN ('Y','N'))                                     | Indicates if schedule is active              |

**Notes**

- A single equipment can have multiple schedules (e.g., 250-hr, 500-hr, annual).

---

## 10. WORK_ORDERS

Represents maintenance work to be performed (preventive or corrective).

### Table: WORK_ORDERS

| Column        | Data Type       | Constraints                                                                                                            | Description                                   |
|---------------|-----------------|------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| WORK_ORDER_ID | NUMBER(10)      | PK, NOT NULL                                                                                                           | Unique work order identifier                  |
| WO_NUMBER     | VARCHAR2(30)    | NOT NULL, UNIQUE                                                                                                       | Human-readable work order number              |
| EQUIPMENT_ID  | NUMBER(10)      | FK → EQUIPMENT.EQUIPMENT_ID, NOT NULL                                                                                  | Equipment requiring work                      |
| SCHEDULE_ID   | NUMBER(10)      | FK → MAINTENANCE_SCHEDULE.SCHEDULE_ID, NULL                                                                            | Related schedule (for PM WOs)                 |
| CREW_ID       | NUMBER(10)      | FK → MAINTENANCE_CREW.CREW_ID, NULL                                                                                    | Primary responsible crew member               |
| WORK_TYPE     | VARCHAR2(20)    | NOT NULL, CHECK (WORK_TYPE IN ('PM','CM','OTHER'))                                                                     | Work type (Preventive, Corrective, Other)     |
| PRIORITY      | VARCHAR2(10)    | NOT NULL, CHECK (PRIORITY IN ('LOW','MED','HIGH','URGENT'))                                                            | Priority level                                |
| STATUS        | VARCHAR2(20)    | NOT NULL, CHECK (STATUS IN ('OPEN','IN_PROGRESS','ON_HOLD','COMPLETED','CANCELLED'))                                   | Current status                                |
| PLANNED_START | DATE            | NULL                                                                                                                   | Planned start date/time                       |
| PLANNED_END   | DATE            | NULL                                                                                                                   | Planned end date/time                         |
| ACTUAL_START  | DATE            | NULL                                                                                                                   | Actual start date/time                        |
| ACTUAL_END    | DATE            | NULL                                                                                                                   | Actual end date/time                          |
| CREATED_BY    | NUMBER(10)      | FK → SUPERVISORS.SUPERVISOR_ID, NOT NULL                                                                               | Supervisor/planner who created the WO         |
| CREATED_DATE  | DATE            | NOT NULL                                                                                                               | Date/time the WO was created                  |
| COMMENTS      | VARCHAR2(2000)  | NULL                                                                                                                   | Additional details                            |

**Notes**

- Preventive maintenance WOs usually link to a `SCHEDULE_ID`.
- Corrective WOs typically have `SCHEDULE_ID` = NULL.

---

## 11. MAINTENANCE_HISTORY

Completed maintenance events derived from work orders.

### Table: MAINTENANCE_HISTORY

| Column         | Data Type       | Constraints                                                     | Description                                       |
|----------------|-----------------|-----------------------------------------------------------------|---------------------------------------------------|
| HISTORY_ID     | NUMBER(10)      | PK, NOT NULL                                                    | Unique maintenance history record                 |
| WORK_ORDER_ID  | NUMBER(10)      | FK → WORK_ORDERS.WORK_ORDER_ID, NOT NULL, UNIQUE               | Related work order (1:1 relationship)             |
| SCHEDULE_ID    | NUMBER(10)      | FK → MAINTENANCE_SCHEDULE.SCHEDULE_ID, NULL                    | Related schedule (if PM)                          |
| EQUIPMENT_ID   | NUMBER(10)      | FK → EQUIPMENT.EQUIPMENT_ID, NOT NULL                          | Redundant FK for easier reporting                 |
| COMPLETED_DATE | DATE            | NOT NULL                                                        | Date maintenance was completed                    |
| DURATION_HOURS | NUMBER(9,2)     | NULL                                                            | Total duration of work                            |
| DOWNTIME_HOURS | NUMBER(9,2)     | NULL                                                            | Downtime caused by this maintenance               |
| LABOUR_COST    | NUMBER(12,2)    | NULL                                                            | Labour cost                                       |
| PARTS_COST     | NUMBER(12,2)    | NULL                                                            | Cost of parts consumed                            |
| TOTAL_COST     | NUMBER(12,2)    | NULL                                                            | Total cost (labour + parts)                       |

**Notes**

- Each completed work order should have at most one `MAINTENANCE_HISTORY` record.
- `EQUIPMENT_ID` is technically derivable from `WORK_ORDER_ID`, but kept here for BI convenience.

---

## 12. SPARE_PARTS_INVENTORY

Tracks spare parts stock at a logical/global level.

### Table: SPARE_PARTS_INVENTORY

| Column         | Data Type       | Constraints                     | Description                            |
|----------------|-----------------|----------------------------------|----------------------------------------|
| PART_ID        | NUMBER(10)      | PK, NOT NULL                    | Unique part identifier                 |
| PART_CODE      | VARCHAR2(30)    | NOT NULL, UNIQUE                | Part code                              |
| PART_NAME      | VARCHAR2(100)   | NOT NULL                        | Part name                              |
| UNIT_OF_MEASURE| VARCHAR2(20)    | NOT NULL                        | Unit (e.g., PCS, L, KG)                |
| ON_HAND_QTY    | NUMBER(12,2)    | NOT NULL                        | Current quantity in stock              |
| RESERVED_QTY   | NUMBER(12,2)    | NOT NULL                        | Quantity reserved for WOs              |
| REORDER_LEVEL  | NUMBER(12,2)    | NULL                            | Stock level at which to reorder        |

**Notes**

- Multi-warehouse or site-specific inventory can be added later via a separate stock table.

---

## 13. EQUIPMENT_USAGE_LOG

Daily usage metrics (hours, fuel, production) per equipment.

### Table: EQUIPMENT_USAGE_LOG

| Column            | Data Type       | Constraints                             | Description                                      |
|-------------------|-----------------|------------------------------------------|--------------------------------------------------|
| USAGE_ID          | NUMBER(10)      | PK, NOT NULL                             | Unique usage log identifier                      |
| LOG_DATE          | DATE            | NOT NULL                                 | Date of usage                                   |
| EQUIPMENT_ID      | NUMBER(10)      | FK → EQUIPMENT.EQUIPMENT_ID, NOT NULL    | Equipment being logged                           |
| SITE_ID           | NUMBER(10)      | FK → MINING_SITES.SITE_ID, NULL          | Site for that usage day                          |
| SHIFT_ID          | NUMBER(10)      | FK → SHIFTS.SHIFT_ID, NULL               | Shift associated with this usage                 |
| HOURS_WORKED      | NUMBER(6,2)     | NULL                                     | Operating hours                                  |
| FUEL_USED_LITERS  | NUMBER(10,2)    | NULL                                     | Fuel consumed (litres)                           |
| PRODUCTION_UNITS  | NUMBER(12,2)    | NULL                                     | Production output (e.g., tons moved)             |
| CREATED_DATE      | DATE            | NOT NULL                                 | Timestamp when record was created                |

**Notes**

- This table is a key **fact table** for utilization and productivity KPIs.

---

## 14. DOWNTIME_RECORDS

Captures equipment breakdowns and other downtime events.

### Table: DOWNTIME_RECORDS

| Column         | Data Type       | Constraints                                                             | Description                            |
|----------------|-----------------|-------------------------------------------------------------------------|----------------------------------------|
| DOWNTIME_ID    | NUMBER(10)      | PK, NOT NULL                                                            | Unique downtime record identifier      |
| EQUIPMENT_ID   | NUMBER(10)      | FK → EQUIPMENT.EQUIPMENT_ID, NOT NULL                                   | Affected equipment                     |
| START_DATETIME | DATE            | NOT NULL                                                                | Start of downtime                      |
| END_DATETIME   | DATE            | NULL                                                                    | End of downtime                        |
| DOWNTIME_TYPE  | VARCHAR2(20)    | NOT NULL, CHECK (DOWNTIME_TYPE IN ('BREAKDOWN','PLANNED_MAINT','OTHER'))| Type of downtime                       |
| CAUSE          | VARCHAR2(200)   | NULL                                                                    | Short description of cause             |
| WORK_ORDER_ID  | NUMBER(10)      | FK → WORK_ORDERS.WORK_ORDER_ID, NULL                                    | Related work order (if any)            |

**Notes**

- Used to calculate availability, MTBF, and downtime-based KPIs.

---

## 15. FUEL_CONSUMPTION

Captures fuel usage per equipment and site.

### Table: FUEL_CONSUMPTION

| Column       | Data Type       | Constraints                             | Description                          |
|--------------|-----------------|------------------------------------------|--------------------------------------|
| FUEL_ID      | NUMBER(10)      | PK, NOT NULL                             | Unique fuel record identifier        |
| RECORD_DATE  | DATE            | NOT NULL                                 | Date of fuel issue/consumption       |
| EQUIPMENT_ID | NUMBER(10)      | FK → EQUIPMENT.EQUIPMENT_ID, NOT NULL    | Equipment refuelled                  |
| SITE_ID      | NUMBER(10)      | FK → MINING_SITES.SITE_ID, NULL          | Site where fuel was issued           |
| LITERS       | NUMBER(10,2)    | NOT NULL                                 | Litres of fuel used/issued           |
| SOURCE       | VARCHAR2(20)    | NULL                                     | Source (e.g., TANK, BOWSER, OTHER)   |

**Notes**

- This can be reconciled with `EQUIPMENT_USAGE_LOG.FUEL_USED_LITERS` for analysis.

---

## 16. EQUIPMENT_STATUS

Lookup table for valid equipment status codes.

### Table: EQUIPMENT_STATUS

| Column      | Data Type       | Constraints                     | Description                        |
|-------------|-----------------|----------------------------------|------------------------------------|
| STATUS_CODE | VARCHAR2(20)    | PK, NOT NULL                    | Code (AVAILABLE, IN_USE, etc.)     |
| DESCRIPTION | VARCHAR2(100)   | NULL                            | Description of status              |
| ACTIVE_FLAG | CHAR(1)         | NOT NULL, CHECK (ACTIVE_FLAG IN ('Y','N')) | Indicates if status is in use |

**Notes**

- `EQUIPMENT.STATUS` can optionally reference `EQUIPMENT_STATUS.STATUS_CODE` instead of using a CHECK.

---

## 17. PUBLIC_HOLIDAYS

Stores dates when operations may be restricted.

### Table: PUBLIC_HOLIDAYS

| Column       | Data Type       | Constraints          | Description                         |
|--------------|-----------------|----------------------|-------------------------------------|
| HOLIDAY_DATE | DATE            | PK, NOT NULL         | Date of public holiday              |
| DESCRIPTION  | VARCHAR2(100)   | NOT NULL             | Holiday name/description            |
| COUNTRY_CODE | VARCHAR2(5)     | NULL                 | ISO country code (if applicable)    |

**Notes**

- Used by business logic to restrict scheduling/assignments on holidays.

---

## 18. AUDIT_LOG

Generic system audit trail for key actions.

### Table: AUDIT_LOG

| Column         | Data Type       | Constraints                                       | Description                                   |
|----------------|-----------------|---------------------------------------------------|-----------------------------------------------|
| AUDIT_ID       | NUMBER(10)      | PK, NOT NULL                                      | Unique audit log identifier                    |
| EVENT_DATETIME | DATE            | NOT NULL                                          | Date/time of the audited event                 |
| USER_NAME      | VARCHAR2(50)    | NOT NULL                                          | User who performed the action                  |
| ACTION_TYPE    | VARCHAR2(20)    | NOT NULL, CHECK (ACTION_TYPE IN ('INSERT','UPDATE','DELETE','LOGIN','LOGOUT')) | Type of action   |
| TABLE_NAME     | VARCHAR2(50)    | NOT NULL                                          | Name of affected table                         |
| RECORD_PK      | VARCHAR2(100)   | NULL                                              | Primary key value(s) of affected record        |
| OLD_VALUE      | CLOB            | NULL                                              | Previous values (if captured)                  |
| NEW_VALUE      | CLOB            | NULL                                              | New values (if captured)                       |

**Notes**

- No FKs to business tables to keep the audit model generic and performant.
- Can be filtered by `TABLE_NAME` and `RECORD_PK` for traceability.

---

## 19. Normalization & Design Notes (Short Summary)

- **1NF**: No repeating groups (e.g., assignments, usage, downtime all in separate tables).
- **2NF**: Surrogate keys avoid partial dependencies; attributes depend on whole PK.
- **3NF**: Reference data (sites, departments, status codes) separated from transactional data.
- **Fact Tables (for BI)**: `EQUIPMENT_USAGE_LOG`, `MAINTENANCE_HISTORY`, `DOWNTIME_RECORDS`, optionally `WORK_ORDERS`.
- **Dimension Tables (for BI)**: `EQUIPMENT`, `MINING_SITES`, `SHIFTS`, `DEPARTMENTS`, and a future `DATE_DIMENSION`.

---
