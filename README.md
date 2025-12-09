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
### Full technical details are available in the documentation under database/documentation/ and business_intelligence/.
| Document                    | Description                                                                 |
|:---------------------------|:----------------------------------------------------------------------------|
| Data Dictionary        | Detailed breakdown of all tables, columns, data types, and constraints     |
| System Architecture    | High-level design of layers, schema groups, and relationships             |
| Design Decisions       | Justification for 3NF model, separation of assignments/usage/maintenance  |
| BI Requirements        | KPI definitions and dashboard requirements for maintenance analytics      |
| KPI Definitions        | Exact formulas for utilisation, availability, MTBF, downtime, and costs   |
| Dashboards             | Mockups and descriptions of maintenance and operations dashboards         |

# 📸 Screenshots
## Planned Evidence


### 1.Database Objects (SQL Developer)

#### Object browser showing:

#### All core tables (EQUIPMENT, WORK_ORDERS, EQUIPMENT_ASSIGNMENT, etc.)
Procedures, functions, packages, and triggers






### 2.ER Diagram

#### Complete ERD with:

#### All tables and their primary keys
#### Foreign key relationships (equipment → assignments → usage/maintenance)

<img width="2748" height="1858" alt="ERD_Diagram" src="https://github.com/user-attachments/assets/402c0c28-e960-4d87-9d59-aaf80e5f7d4f" />

### 3.Sample Data (5–10 Rows)

#### Example queries, e.g.:

#### SELECT * FROM EQUIPMENT FETCH FIRST 10 ROWS ONLY;

<img width="959" height="539" alt="sample_data" src="https://github.com/user-attachments/assets/93ecdd34-cf01-4e7f-95d5-977dfaf6b865" />

### 4.Procedures / Triggers in Editor

#### PL/SQL editor displaying:

#### A maintenance procedure (e.g. generating work orders from due schedules)
An audit or schedule-update trigger

<img width="959" height="528" alt="02_procedures" src="https://github.com/user-attachments/assets/f8c75479-847a-47ce-8415-fd07d81d7930" />

<img width="959" height="501" alt="03_functions" src="https://github.com/user-attachments/assets/6d0871ca-00b4-4de0-88ff-1662a124c0e1" />

 <img width="959" height="538" alt="04_simple_triggers" src="https://github.com/user-attachments/assets/deed8975-0cf6-4f44-b92b-8ac284c72f91" />

 <img width="959" height="533" alt="05_compound_trigger" src="https://github.com/user-attachments/assets/9319a46e-802b-44c0-b539-ecea1369269b" />


### 5.Test Results and Execution

#### Anonymous PL/SQL blocks running test scenarios
#### DBMS_OUTPUT showing results (e.g. created work orders, calculated KPIs)
#### Validation queries confirming constraints and relationships

<img width="959" height="536" alt="06_comprehensive_testing" src="https://github.com/user-attachments/assets/9ee593eb-ea04-450f-b537-307a7505a44d" />

<img width="955" height="539" alt="08_testing_procedures" src="https://github.com/user-attachments/assets/3bcb1cfe-ccbf-4342-aece-0891ea0d6b0e" />

<img width="959" height="527" alt="09_testing_functions" src="https://github.com/user-attachments/assets/ff94aa35-0145-4131-bbed-47a55423cf03" />

### 6.Audit Log Entries

### Query against AUDIT_LOG showing:

#### EVENT_DATETIME, USER_NAME, ACTION_TYPE, TABLE_NAME, RECORD_PK

<img width="958" height="535" alt="Basic_retrieval_audit_logs" src="https://github.com/user-attachments/assets/96518ddb-6711-4c01-a7d4-882c4cfb198f" />


### 7.OEM Monitoring (Optional)

#### Oracle Enterprise Manager screenshots for:

#### Session activity
#### Performance metrics
#### Tablespace / storage usage

<img width="921" height="400" alt="database_overview" src="https://github.com/user-attachments/assets/6a7201a9-612f-4305-8697-bbcff87f4266" />

<img width="913" height="236" alt="performance_metrics" src="https://github.com/user-attachments/assets/496d082b-2e2e-484d-a30d-fdc57289724d" />

<img width="919" height="331" alt="sql_monitoring" src="https://github.com/user-attachments/assets/a8d30c95-fa84-408b-9393-d4fbcc1bb8fa" />


### 🚀 Quick Start Guide

#### Follow these steps to deploy the project locally.

#### Prerequisites:

#### Oracle Database 21c (XE or Enterprise Edition)

#### Oracle SQL Developer

#### GitHub account

#### Step 1: Database Creation

#### Open SQL Developer and connect as SYSDBA

#### Run database/scripts/01_create_pdb.sql to create the PDB and Admin User

#### Verify PDB is open:

##### SELECT name, open_mode FROM v$pdbs;

#### Step 2: Schema Implementation

#### Connect as mining_scheduler_admin

#### Run database/scripts/02_create_tables.sql to build the structure

#### Run database/scripts/03_insert_data.sql to load 100+ sample records

#### Run database/scripts/04_validation.sql to confirm data integrity

#### Step 3: PL/SQL Logic

#### Run database/scripts/05_procedures_functions.sql to create procedures, functions, packages

#### Run database/scripts/06_triggers.sql to implement business rules

####Step 4: Testing

#### Execute test blocks at the end of each script

#### Verify outputs using SET SERVEROUTPUT ON

#### Run audit queries to confirm logging works

#### Step 5: Documentation

#### Update documentation/data_dictionary.md with actual table structures

##### Generate ER diagram and save to documentation/

#### Take screenshots and organize in screenshots/ folder


## 📊 Business Intelligence

The Mining Equipment Management System includes a SQL‑driven BI layer with **3 dashboards**, **13 BI views**, and **35+ KPIs**, documented in:

- `Business intelligence/dashboards.md`
- `Business intelligence/kpi_definitions.md`
- `Business intelligence/bi_requirements.md`
- `Business intelligence/scripts/bi_views.sql`
- `Business intelligence/scripts/bi_dashboard_queries.sql`

### 🔑 Key KPIs (Examples)

- **Equipment Utilisation (%)** – Operating hours vs available hours per equipment, shift, or site.  
- **Availability (%)** – (Total time − downtime) / total time per unit.  
- **MTBF / MTTR** – Mean time between failures and mean time to repair, from downtime and maintenance data.  
- **Maintenance Completion & Cost** – Scheduled vs completed work, and cost per equipment / site.  
- **Fuel Efficiency & Cost** – Litres and cost per operating hour or ton moved.  
- **Compliance Rate & Violations** – Allowed vs denied operations, weekend/holiday violations, and table‑level compliance.

### 📈 Dashboards (Console / SQL-Based)

Implemented as formatted SQL reports (see `bi_dashboard_queries.sql`) and illustrated in:

- `Business intelligence/screenshots/02_dashboard1_executive.png`
- `Business intelligence/screenshots/03_dashboard2_compliance..png`
- `Business intelligence/screenshots/04_dashboard3_performance.png`

**Dashboard 1 – Executive Summary**

- High‑level KPIs from `v_executive_kpi_cards`.  
- Monthly trends and department performance.  
- Daily snapshot of assignments, equipment, operators, and sites.

**Dashboard 2 – Audit & Compliance**

- Overall compliance and violation rates from `v_compliance_overview`.  
- Compliance by table (`v_compliance_by_table`) and violation patterns.  
- Recent denied operations from the audit log.

**Dashboard 3 – Performance & Resources**

- Equipment, operator, and site performance views.  
- Maintenance schedule status, downtime summaries, and fuel consumption.  
- Resource usage by site and equipment status distribution.

A full description of layout, KPIs, and view definitions is provided in the BI documents under the `Business intelligence/` folder, with `01_BI_views_list.png` showing all BI views created.
