# Architecture – Mining Equipment Scheduler

This document gives a high-level view of how the Mining Equipment Scheduler is structured and how the main parts fit together.

---

## 1. High-Level System Overview

The system is a **web-based line-of-business application** that manages:

- Equipment master data and status
- Daily assignments of equipment to sites, shifts, and operators
- Maintenance scheduling, work orders, and history
- Usage, downtime, and fuel records

At a high level the solution follows a **3-tier architecture**:

1. **Presentation Layer** – Web UI for planners, supervisors, operators, and maintenance staff.
2. **Application / API Layer** – Business logic exposed via REST-style endpoints.
3. **Data Layer** – Relational database implementing the ERD and data dictionary.

---

## 2. Logical Layers

### 2.1 Presentation Layer

Responsibilities:

- Display lists and details of:
  - Equipment, sites, shifts, staff
  - Assignments and work orders
- Capture user input for:
  - New assignments
  - New/updated work orders
  - Usage, downtime, and fuel records
- Provide basic validation and a role-aware UI (e.g. operators vs supervisors).

Typical screens:

- Equipment register and status
- Daily assignment board
- Work order list and detail
- Usage & downtime entry
- Basic KPI/summary reports

---

## 3. Application / API Layer

Responsibilities:

- Implement core business rules, for example:
  - Prevent double-booking of equipment per date/shift
  - Restrict assignments on public holidays (using `PUBLIC_HOLIDAYS`)
  - Enforce work order status transitions (OPEN → IN_PROGRESS → COMPLETED)
- Coordinate database operations in transactions:
  - E.g. completing a work order and creating `MAINTENANCE_HISTORY`
- Provide a consistent API surface, e.g.:

  - `GET /equipment`, `GET /equipment/{id}`
  - `POST /assignments`
  - `POST /workorders`, `PATCH /workorders/{id}`
  - `POST /usage-logs`, `POST /downtimes`, `POST /fuel`

- Write entries into `AUDIT_LOG` for key actions.

The API layer is the main place where **business rules** live; the database enforces structural integrity.

---

## 4. Data Layer

The data layer is a **normalised relational schema** (≈3NF) built around these groups:

- **Master data**
  - `EQUIPMENT`, `DEPARTMENTS`, `MINING_SITES`, `SHIFTS`
  - `OPERATORS`, `MAINTENANCE_CREW`, `SUPERVISORS`
  - `EQUIPMENT_STATUS`, `SPARE_PARTS_INVENTORY`
- **Operational / transactional**
  - `EQUIPMENT_ASSIGNMENT`
  - `MAINTENANCE_SCHEDULE`, `WORK_ORDERS`, `MAINTENANCE_HISTORY`
- **Event / metric**
  - `EQUIPMENT_USAGE_LOG`
  - `DOWNTIME_RECORDS`
  - `FUEL_CONSUMPTION`
- **Support / governance**
  - `PUBLIC_HOLIDAYS`
  - `AUDIT_LOG`

Key points:

- Primary keys are simple numeric IDs.
- Foreign keys enforce relationships as per the ERD.
- CHECK constraints (or lookups) enforce valid codes (e.g. statuses, types).
- Indexes are defined on PKs, FKs, and important search fields:
  - `EQUIPMENT_CODE`, `WO_NUMBER`, `ASSIGN_DATE`, `LOG_DATE`, etc.

---

## 5. Reporting and Integration (Conceptual)

- **Reporting**:
  - Operational reporting can be done directly on the OLTP schema or via database views.
  - Main fact-like tables for analytics are:
    - `EQUIPMENT_USAGE_LOG`, `MAINTENANCE_HISTORY`, `DOWNTIME_RECORDS`, `FUEL_CONSUMPTION`.

- **Integration (future)**:
  - HR system (for staff master data via `EMPLOYEE_NO`)
  - ERP / inventory (for detailed parts and stock)
  - Fuel management systems (to feed `FUEL_CONSUMPTION`)

The current design keeps the database clean and normalised, and leaves denormalised views or data warehouse models for a later phase.
