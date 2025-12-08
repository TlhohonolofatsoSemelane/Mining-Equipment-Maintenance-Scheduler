# Mining Equipment Maintenance Scheduler

![Oracle](https://img.shields.io/badge/Database-Oracle%2021c-red)
![Language](https://img.shields.io/badge/Language-PL%2FSQL-orange)
![Institution](https://img.shields.io/badge/Institution-AUCA-blue)
![Course](https://img.shields.io/badge/Course-INSY%208311-green)

> **Capstone Project | Database Development with PL/SQL**  
> *Adventist University of Central Africa (AUCA)*

---

## 👤 Author Information

| Field           | Detail                                             |
|:----------------|:---------------------------------------------------|
| **Student Name**| **Tlhohonolofatso Temana Semane**                  |
| **Student ID**  | **27293**                                          |
| **Group**       | Monday (A)                                         |
| **Lecturer**    | Eric Maniraguha                                    |
| **Database PDB**| `Mon_27293_Semelane_MiningScheduler_db`             |

---

## 📑 Table of Contents
1. [Project Overview](#-project-overview)  
2. [Key Objectives](#-key-objectives)  
3. [System Architecture](#-system-architecture)  
4. [Technical Stack](#-technical-stack)  
5. [Reliability & Safety Features](#-reliability--safety-features)  
6. [Folder Structure](#-folder-structure)  
7. [Documentation & BI](#-documentation--bi)  
8. [Screenshots](#-screenshots)  
9. [Quick Start Guide](#-quick-start-guide)  

---

## 📖 Project Overview

### 🚩 Problem Statement
Large mining operations rely heavily on mobile equipment (trucks, excavators, loaders, drills) that must be **available, reliable, and safe**. In many sites, equipment assignments and maintenance activities are still managed with spreadsheets and manual logs. This leads to inconsistent data, double-booked machines, missed preventive maintenance, and poor visibility of downtime and maintenance costs.

The absence of an integrated database makes it difficult to answer key questions like:  
**Which equipment is assigned where today?**  
**Which work orders are overdue?**  
**Why is availability dropping for a specific truck or site?**

### 💡 Proposed Solution
This project implements an **Oracle PL/SQL–based Maintenance Scheduler Database** that centralises all operational and maintenance data for mining equipment. It supports:

- Daily **equipment assignments** to sites, shifts, and operators  
- **Preventive and corrective maintenance** planning via schedules and work orders  
- Logging of **usage, downtime, and fuel consumption**  
- **Audit logging** of changes to critical tables for accountability  
- BI-ready structures to measure **utilisation, availability, downtime, and maintenance cost**

---

## 🎯 Key Objectives

- **Centralised Equipment Register:** Maintain a single source of truth for all mining equipment, including type, status, and owning department.
- **Assignment Management:** Plan and record daily equipment assignments by site, shift, and primary operator.
- **Maintenance Lifecycle Control:** Manage preventive schedules, work orders, and completed maintenance history.
- **Operational Metrics Tracking:** Capture equipment usage, downtime, and fuel consumption for performance analysis.
- **Auditability & Governance:** Log key data changes and support compliance with maintenance and safety standards.
- **BI-Ready Data Model:** Enable analytics for utilisation, availability, MTBF, and maintenance cost per unit of production.

---

## 🏗 System Architecture

The database follows a **3NF normalised schema** and models a realistic mining maintenance environment where equipment is assigned to sites and maintained via structured work orders.

### Core Tables (Sample Entities)
1. **EQUIPMENT** — Master data for trucks, excavators, loaders, drills, etc.
2. **MINING_SITES** — Pits, plants, stockpiles, and workshops where equipment operates.
3. **OPERATORS / MAINTENANCE_CREW / SUPERVISORS** — People who operate, service, or manage equipment.
4. **EQUIPMENT_ASSIGNMENT** — Daily allocation of equipment to site, shift, and operator.
5. **MAINTENANCE_SCHEDULE / WORK_ORDERS / MAINTENANCE_HISTORY** — Preventive plans, work orders, and completed maintenance.
6. **EQUIPMENT_USAGE_LOG / DOWNTIME_RECORDS / FUEL_CONSUMPTION** — Usage, breakdowns, and fuel metrics.
7. **AUDIT_LOG** — Generic audit trail for key DML operations.

The design separates **master data**, **operational transactions**, and **event/metric data** to support both OLTP and BI use cases.

---

## ⚙️ Technical Stack

| Component         | Technology                                           |
|:-----------------|:-----------------------------------------------------|
| **Database**     | Oracle Database 21c XE                               |
| **Language**     | PL/SQL (Procedures, Functions, Packages, Triggers)   |
| **Version Control** | GitHub                                            |
| **Development Tools** | Oracle SQL Developer                            |
| **Monitoring**   | Oracle Enterprise Manager (OEM)                      |
| **BI Tools**     | SQL analytics + KPI/Dashboard mockups                |
| **Normalization**| 3NF (Third Normal Form)                              |

---

## 🔐 Reliability & Safety Features

### Operational Control
- **Single Assignment Rule:** An equipment unit can only be assigned once per site/shift/date combination (no double-booking).
- **Status-Based Usage:** Equipment status (AVAILABLE, IN_USE, MAINTENANCE, RETIRED) controls where it can appear (assignments vs work orders).
- **Shift & Site Validation:** All assignments and logs reference valid sites and shifts only.

### Maintenance & Downtime
- **Preventive Maintenance Schedules:** Interval-based (hours/days/km/tons) schedules ensure regular inspections and servicing.
- **Work Order Lifecycle:** Status transitions (OPEN → IN_PROGRESS → COMPLETED → CLOSED) controlled by PL/SQL logic.
- **Downtime Tracking:** Dedicated table for breakdowns and planned maintenance to support availability and MTBF calculations.

### Audit & Governance
- **Audit Logging:** Triggers/procedures record key changes (INSERT/UPDATE/DELETE) into `AUDIT_LOG` with timestamp, user, action, and table name.
- **Traceability:** Work orders and maintenance history link back to specific equipment and schedules for full traceability.
- **Compliance Reporting:** Queries and BI views support reporting on overdue maintenance, open work orders, and downtime trends.

---

## 📂 Folder Structure

```text
Mining_Equipment_Maintenance_Scheduler/
│
├── README.md                                    # 📘 Project Overview & Setup Guide
│
├── database/
│   ├── scripts/                                 # ⚙️ Core SQL Scripts
│   │   ├── 01_create_pdb.sql                    # (Optional) PDB / user creation
│   │   ├── 02_create_tables.sql                 # Table structures (DDL)
│   │   ├── 03_insert_data.sql                   # Sample data population (DML)
│   │   ├── 04_validation.sql                    # Integrity & validation checks
│   │   ├── 05_procedures_functions.sql          # Procedures, functions, packages
│   │   ├── 06_triggers.sql                      # Triggers & business rules
│   │
│   └── documentation/                           # 📘 DB Setup & Design Docs
│       ├── database_overview.md                 # Schema summary
│       ├── schema_setup_guide.md                # How to build the DB
│       ├── testing_and_validation.md            # How it was tested
│       ├── data_dictionary.md                   # Tables, columns, constraints
│       ├── architecture.md                      # Architecture overview
│       └── design_decisions.md                  # Design rationale
│
├── queries/                                     # 🔍 Reporting & Analytics SQL
│   ├── data_retrieval.sql                       # Basic SELECT queries
│   ├── analytics_queries.sql                    # Window functions & aggregations
│   └── audit_queries.sql                        # Audit & compliance reports
│
├── business_intelligence/                       # 📊 BI Strategy & Dashboards
│   ├── bi_requirements.md                       # BI objectives & KPIs
│   ├── dashboards.md                            # Dashboard mockups
│   └── kpi_definitions.md                       # Key performance indicators
│
├── screenshots/                                 # 📸 Implementation Evidence
│   ├── database_objects/                        # ERD, table list, code editor
│   ├── test_results/                            # Execution and test outputs
│   └── oem_monitoring/                          # Oracle Enterprise Manager views
│
└── documentation/                               # 📚 System-Level Documentation
    ├── data_dictionary.md                       # Global reference copy (if required)
    ├── architecture.md                          # System-level architecture
    └── design_decisions.md                      # High-level design choices
```

# 📚 Documentation & BI

## Critical Note
Full technical details are available in the documentation under database/documentation/ and business_intelligence/.
| Document                    | Description                                                                 |
|:---------------------------|:----------------------------------------------------------------------------|
| Data Dictionary        | Detailed breakdown of all tables, columns, data types, and constraints     |
| System Architecture    | High-level design of layers, schema groups, and relationships             |
| Design Decisions       | Justification for 3NF model, separation of assignments/usage/maintenance  |
| BI Requirements        | KPI definitions and dashboard requirements for maintenance analytics      |
| KPI Definitions        | Exact formulas for utilisation, availability, MTBF, downtime, and costs   |
| Dashboards             | Mockups and descriptions of maintenance and operations dashboards         |

📸 Screenshots
Planned Evidence


Database Objects (SQL Developer)

Object browser showing:

All core tables (EQUIPMENT, WORK_ORDERS, EQUIPMENT_ASSIGNMENT, etc.)
Procedures, functions, packages, and triggers






ER Diagram

Complete ERD with:

All tables and their primary keys
Foreign key relationships (equipment → assignments → usage/maintenance)






Sample Data (5–10 Rows)

Example queries, e.g.:

SELECT * FROM EQUIPMENT FETCH FIRST 10 ROWS ONLY;
SELECT * FROM WORK_ORDERS FETCH FIRST 10 ROWS ONLY;







Procedures / Triggers in Editor

PL/SQL editor displaying:

A maintenance procedure (e.g. generating work orders from due schedules)
An audit or schedule-update trigger







Test Results and Execution

Anonymous PL/SQL blocks running test scenarios
DBMS_OUTPUT showing results (e.g. created work orders, calculated KPIs)
Validation queries confirming constraints and relationships





Audit Log Entries

Query against AUDIT_LOG showing:

EVENT_DATETIME, USER_NAME, ACTION_TYPE, TABLE_NAME, RECORD_PK






OEM Monitoring (Optional)

Oracle Enterprise Manager screenshots for:

Session activity
Performance metrics
Tablespace / storage usage







🚀 Quick Start Guide
Follow these steps to deploy the Mining Equipment Maintenance Scheduler locally.
Prerequisites

Oracle Database 21c (XE or Enterprise Edition)
Oracle SQL Developer
Git or GitHub access

Step 1: Database / PDB Creation (If Applicable)


Open SQL Developer and connect as SYSDBA.


Run database/scripts/01_create_pdb.sql (if included) to create the PDB and schema user.


Verify the PDB is open:
SELECT name, open_mode FROM v$pdbs;



Step 2: Schema Implementation


Connect as the project schema user (e.g. mining_scheduler_user).


Run table and constraint scripts:
@database/scripts/02_create_tables.sql
@database/scripts/04_validation.sql      -- Optional structural checks



Confirm tables are created (e.g. SELECT * FROM EQUIPMENT; should return no rows but no errors).


Step 3: Data Population


Run the sample data script:
@database/scripts/03_insert_data.sql



Check that key tables are populated:
SELECT COUNT(*) FROM EQUIPMENT;
SELECT COUNT(*) FROM WORK_ORDERS;
SELECT COUNT(*) FROM EQUIPMENT_ASSIGNMENT;



Step 4: PL/SQL Logic (Procedures, Functions, Packages, Triggers)


Create program units:
@database/scripts/05_procedures_functions.sql
@database/scripts/06_triggers.sql



Ensure all procedures, functions, packages, and triggers compile successfully in SQL Developer.


Step 5: Testing


Enable server output:
SET SERVEROUTPUT ON;



Execute the test blocks included at the bottom of the scripts (or in queries/):
@queries/data_retrieval.sql
@queries/analytics_queries.sql
@queries/audit_queries.sql



Confirm:

Assignments are created correctly and double-booking is prevented.
Work orders and maintenance history behave as expected.
Downtime and usage logs are captured.
Audit log entries are generated for configured tables.



Step 6: Documentation & Screenshots


Review and, if needed, update:

database/documentation/data_dictionary.md
database/documentation/architecture.md
database/documentation/design_decisions.md



Generate / export the ER diagram and save it to:

screenshots/database_objects/erd_full_schema.png



Capture screenshots of:

Database objects, sample data, code, tests, and audit log
Place them under screenshots/database_objects/ and screenshots/test_results/




📊 Business Intelligence
Key Performance Indicators (KPIs)

Equipment Utilisation (%)

Operating hours / available shift hours per equipment, shift, or site.


Availability (%)

(Total time − Downtime) / Total time for each equipment unit.


Mean Time Between Failures (MTBF)

Total operating hours / number of breakdown events.


Mean Time To Repair (MTTR)

Average duration of breakdown-related work orders.


Maintenance Cost per Equipment

Sum of labour and parts cost per equipment, per month.


Fuel Efficiency

Fuel used per ton moved or per operating hour.



Dashboard Mockups


Operational Control Dashboard

Current equipment assignments by site and shift.
Today’s open work orders by priority and status.



Maintenance Performance Dashboard

MTBF and MTTR trends.
Overdue vs completed preventive maintenance.



Cost & Efficiency Dashboard

Maintenance cost per equipment and per site.
Fuel efficiency vs production output.



Downtime & Availability Dashboard

Breakdown events by cause and equipment type.
Availability percentage by equipment and site.





You can tweak the PDB name, user name, and any counts (e.g., number of sample records) to match your actual implementation.
