# Design Decisions – Mining Equipment Scheduler

This document highlights the main design choices in the data and system model, plus why they were made.

---

## 1. Data Model Shape

### 1.1 Normalised Relational Schema

**Decision:** Use a normalised relational schema (≈3NF) instead of wide denormalised tables.

**Why:**

- Avoids data duplication (e.g. equipment details stored once).
- Easier to enforce consistency with PK/FK and CHECK constraints.
- Fits typical enterprise RDBMS environments and reporting tools.

**Impact:**

- Queries often involve joins.
- Reporting that needs denormalised views can use database views or a BI layer.

---

## 2. People & Organisation

### 2.1 Separate Role Tables (Operators, Crew, Supervisors)

**Decision:** Use separate tables `OPERATORS`, `MAINTENANCE_CREW`, `SUPERVISORS` instead of a single `EMPLOYEES` table.

**Why:**

- Each role participates in different processes:
  - Operators → `EQUIPMENT_ASSIGNMENT`
  - Maintenance crew → `WORK_ORDERS`
  - Supervisors → `WORK_ORDERS`, `EQUIPMENT_ASSIGNMENT`, `AUDIT_LOG` (via `USER_NAME`)
- Keeps documentation and relationships simple and explicit.

**Impact:**

- Some repeated columns (e.g. FULL_NAME, EMPLOYEE_NO).
- If integrated with an HR system later, a mapping step will be needed.

---

## 3. Assignments, Usage, and Downtime

### 3.1 Split Between Assignment and Usage

**Decision:** Use `EQUIPMENT_ASSIGNMENT` for planned allocation and `EQUIPMENT_USAGE_LOG` for actual usage metrics.

**Why:**

- Planning and reality are related but not the same:
  - Assignments: who, where, when.
  - Usage: hours, fuel, production.
- Allows usage to be recorded even if assignments are missing, or coming from automated systems.

**Impact:**

- Reports that compare planned vs actual require joins between the two tables.

### 3.2 One Primary Operator per Equipment per Shift

**Decision:** In `EQUIPMENT_ASSIGNMENT`, enforce one operator per `(ASSIGN_DATE, EQUIPMENT_ID, SHIFT_ID)`.

**Why:**

- Matches the idea of a primary accountable operator per piece of equipment per shift.
- Simplifies the model and UI.

**Impact:**

- Additional helpers/trainees are not explicitly modelled in this phase.
- A future enhancement could add an `ASSIGNMENT_OPERATORS` junction table.

### 3.3 Explicit Downtime Table

**Decision:** Use `DOWNTIME_RECORDS` to track downtime instead of inferring it from usage gaps.

**Why:**

- Downtime is a key KPI and needs:
  - Start/end timestamps
  - Type (BREAKDOWN vs PLANNED_MAINT)
  - Optional link to a `WORK_ORDER`
- Easier and more accurate than guessing from missing data.

---

## 4. Maintenance Modelling

### 4.1 Separate Schedule, Work Orders, and History

**Decision:** Use three tables:
- `MAINTENANCE_SCHEDULE` – recurring plans
- `WORK_ORDERS` – individual jobs
- `MAINTENANCE_HISTORY` – completed work

**Why:**

- One schedule can generate many work orders over time.
- Work orders can exist without being completed (cancelled, on hold).
- History needs its own fields (cost, downtime, duration) and should be stable once completed.

**Impact:**

- Relationships are slightly more complex, but match how real-world maintenance systems behave.

### 4.2 One History Record per Work Order

**Decision:** Make `MAINTENANCE_HISTORY.WORK_ORDER_ID` unique → 1:1 with `WORK_ORDERS`.

**Why:**

- Simplifies reporting: each WO has a single “final” completion record.
- Fits the level of detail required in this phase.

**Impact:**

- Complex multi-stage jobs are still modelled as one work order; finer breakdown would need future tables (e.g. `MAINTENANCE_ACTIVITY`).

---

## 5. Status, Holidays, and Audit

### 5.1 Equipment Status Lookup

**Decision:** Provide `EQUIPMENT_STATUS` as a lookup table for status codes, even though `EQUIPMENT.STATUS` could also be enforced with a CHECK constraint.

**Why:**

- Allows descriptions and activation flags per status.
- Easier to extend or deactivate statuses without changing table DDL.

**Impact:**

- Slightly more setup, but more flexible for real operations.

### 5.2 Public Holidays as Reference, Not FK

**Decision:** Use `PUBLIC_HOLIDAYS` as a reference table checked by application logic, not via FKs from assignments.

**Why:**

- Rules around working on public holidays are business-specific and may allow overrides.
- These are easier to enforce in code than through strict DB constraints.

**Impact:**

- Application layer must validate assignments against `PUBLIC_HOLIDAYS` where required.

### 5.3 Generic Audit Log

**Decision:** Use a generic `AUDIT_LOG` without FKs to each business table.

**Why:**

- Avoids a large number of audit tables and FK chains.
- Simple structure: who, when, what table, and old/new values.

**Impact:**

- Integrity between business data and audit entries is logical rather than enforced by FKs.
- Reporting must interpret `TABLE_NAME` and `RECORD_PK` as text.

---

## 6. Reporting & BI

### 6.1 OLTP First, BI via Views/ETL

**Decision:** Keep the OLTP schema normalised and handle reporting/analytics via:

- SQL views, and/or
- A later BI/ETL layer (e.g. star schemas).

**Why:**

- Keeps the core system clean and consistent for day-to-day operations.
- Avoids mixing transactional and analytical concerns in the same schema.

**Impact:**

- Some BI use cases will need ETL or specialised views.
- A few “slightly redundant” fields (e.g. `EQUIPMENT_ID` in `MAINTENANCE_HISTORY`) are included to make reporting simpler without major denormalisation.
