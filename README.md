# Mining-Equipment-Maintenance-Scheduler

## Student Information
- **Name:** [Tlhohonolofatso Temana Semelane]
- **Student ID:** [Your ID Number]
- **Course:** [Course Code and Name]
- **Submission Date:** 2025-11-16

---

## Problem Statement
Mining operations face significant challenges in managing equipment maintenance schedules, tracking equipment downtime, and ensuring timely servicing to prevent costly breakdowns. Manual maintenance tracking leads to missed service intervals, unplanned equipment failures, and inefficient resource allocation. This project develops a comprehensive database system to automate maintenance scheduling, track equipment health, and optimize maintenance operations for improved equipment reliability and operational efficiency.

---

## Key Objectives
- ✅ Design and implement a normalized relational database for mining equipment maintenance management
- ✅ Create stored procedures and functions for maintenance scheduling, work order management, and parts inventory
- ✅ Implement triggers for automated audit logging, maintenance alerts, and data validation
- ✅ Develop analytics queries using window functions and aggregations for maintenance trends
- ✅ Ensure data integrity through proper constraints and relationships
- ✅ Generate comprehensive reports for maintenance planning and equipment utilization
- ✅ Implement Business Intelligence dashboards for real-time monitoring

---

## Quick Start Instructions

### Prerequisites
- Oracle Database 19c or higher (with Pluggable Database support)
- SQL Developer or SQL*Plus
- Oracle Enterprise Manager (OEM) for monitoring
- Minimum 100MB database storage

### Installation Steps

#### Phase 1: Database Setup
1. **Create Pluggable Database**
   ```sql
   @database/scripts/scripts/01_create_pdb.sql
Setup Admin and Configuration
Copy
@database/scripts/scripts/03_setup_admin_user.sql
@database/scripts/scripts/04_configure_memory.sql
@database/scripts/scripts/05_enable_archivelog.sql
Phase 2: Create Database Objects
Create Tables and Sequences

Copy
@database/scripts/scripts/create_table.sql
@database/scripts/scripts/06_create_sequences.sql
@database/scripts/scripts/indexes.sql
Load Sample Data

Copy
@database/scripts/scripts/insert_data
Phase 3: Create PL/SQL Objects
Create Functions and Procedures

Copy
@database/scripts/scripts/03_functions.sql
@database/scripts/scripts/02_procedures.sql
Create Triggers

Copy
@database/scripts/scripts/02_audit_log.sql
@database/scripts/scripts/04_simple_triggers.sql
@database/scripts/scripts/05_compound_triggers.sql
Create Packages

Copy
@database/scripts/scripts/06_package_spec.sql
@database/scripts/scripts/07_package_body.sql
@database/scripts/scripts/01_holiday_manager.sql
Create Custom Exceptions

Copy
@database/scripts/scripts/01_custom_exceptions.sql
Phase 4: Testing
Run Test Scripts
Copy
@database/scripts/scripts/08_testing_procedures.sql
@database/scripts/scripts/09_testing_functions.sql
@database/scripts/scripts/10_testing_packages.sql
@database/scripts/scripts/06_comprehensive_test.sql
@database/scripts/scripts/07_verification_queries.sql
Phase 5: Analytics & BI
Execute Analytics Queries

Copy
@queries/analytics_queries.sql
@queries/audit_queries.sql
@queries/data_retrieval.sql
Setup BI Dashboards

Copy
@Business_intelligence/scripts/bi_views.sql
@Business_intelligence/scripts/bi_test_data.sql
@Business_intelligence/scripts/bi_dashboard_queries.sql
Project Documentation Links
Core Documentation
📄 Architecture Overview
📄 Data Dictionary
📄 Design Decisions
📄 Phase 2 Process
📄 Database Overview
Business Intelligence
📊 BI Requirements
📊 KPI Definitions
📊 Dashboard Documentation