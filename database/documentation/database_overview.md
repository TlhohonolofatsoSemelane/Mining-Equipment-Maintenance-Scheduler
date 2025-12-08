# Database Overview – Mining Equipment Scheduler

This document provides a concise overview of the database component for the **Mining Equipment Scheduler** project.

It should be read together with:

- `data_dictionary.md` – table/column definitions  
- `architecture.md` – overall system architecture  
- `design_decisions.md` – rationale behind the model  

---

## 1. Purpose of the Database

The database supports the end‑to‑end lifecycle of mining equipment operations:

- Registering equipment, sites, shifts, and staff
- Planning daily assignments (equipment → site → shift → operator)
- Managing maintenance schedules and work orders
- Tracking completed maintenance work (history and cost)
- Logging usage, downtime, and fuel consumption
- Providing a reliable data source for BI/KPIs

The schema is designed in **3NF** and targets a relational RDBMS (e.g. Oracle / PostgreSQL / SQL Server).

---

## 2. Schema Structure (Logical Groups)

The main tables are grouped logically as follows:

### 2.1 Master Data

- `EQUIPMENT`  
- `DEPARTMENTS`  
- `MINING_SITES`  
- `SHIFTS`  
- `OPERATORS`  
- `MAINTENANCE_CREW`  
- `SUPERVISORS`  
- `EQUIPMENT_STATUS`  
- `SPARE_PARTS_INVENTORY`  

These tables change relatively slowly and define core reference data.

---

### 2.2 Operational / Transactional Data

- `EQUIPMENT_ASSIGNMENT` – planned allocation (who/where/when)  
- `MAINTENANCE_SCHEDULE` – recurring PM/inspection plans  
- `WORK_ORDERS` – individual maintenance jobs  
- `MAINTENANCE_HISTORY` – completed maintenance (1:1 with work orders)  

These tables represent day‑to‑day operational activity.

---

### 2.3 Event / Metric Data

- `EQUIPMENT_USAGE_LOG` – hours, fuel, production per day/shift  
- `DOWNTIME_RECORDS` – breakdowns and planned downtime events  
- `FUEL_CONSUMPTION` – detailed fuel issues per equipment/site  

These tables are the main **fact-like** sources for analytics and KPIs.

---

### 2.4 Support / Governance

- `PUBLIC_HOLIDAYS` – used by business rules to restrict scheduling  
- `AUDIT_LOG` – generic audit trail (who changed what and when)  

These tables help enforce governance, compliance, and business logic.

---

## 3. Relationship Highlights

Some key relationships (full details in the ERD + data dictionary):

- One `DEPARTMENT` → many `EQUIPMENT`, `OPERATORS`, `MAINTENANCE_CREW`, `SUPERVISORS`  
- One `EQUIPMENT` → many `EQUIPMENT_ASSIGNMENT`, `WORK_ORDERS`, `MAINTENANCE_SCHEDULE`, `MAINTENANCE_HISTORY`, `USAGE_LOG`, `DOWNTIME_RECORDS`, `FUEL_CONSUMPTION`  
- One `MAINTENANCE_SCHEDULE` → many `WORK_ORDERS` → one `MAINTENANCE_HISTORY`  
- One `SITE` and one `SHIFT` → many `EQUIPMENT_ASSIGNMENT` and `EQUIPMENT_USAGE_LOG`  

---


