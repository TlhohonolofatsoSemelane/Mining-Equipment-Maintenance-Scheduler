# 📊 Dashboard Specifications Document

## Mining Equipment Management System (MEMS)
**Version:** 1.0  
**Date:** December 8, 2024  
**Author:** [Your Name]  
**Course:** Advanced Database Management & PL/SQL  
**Institution:** AUCA

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Dashboard 1: Executive Summary](#2-dashboard-1-executive-summary)
3. [Dashboard 2: Audit & Compliance](#3-dashboard-2-audit--compliance)
4. [Dashboard 3: Performance & Resources](#4-dashboard-3-performance--resources)
5. [Dashboard Access Control](#5-dashboard-access-control)
6. [Technical Implementation](#6-technical-implementation)
7. [User Guide](#7-user-guide)

---

## 1. Introduction

This document provides comprehensive specifications for the three Business Intelligence dashboards implemented in the Mining Equipment Management System. Each dashboard serves specific stakeholder needs with real-time data visualization and actionable insights.

### 1.1 Dashboard Overview

| Dashboard | Primary Users | Update Frequency | Key Focus |
|-----------|--------------|------------------|-----------|
| **Dashboard 1: Executive** | CEO, COO, Directors | Real-time (5-min refresh) | Strategic KPIs & trends |
| **Dashboard 2: Compliance** | Compliance Officer, Auditors | Real-time (30-sec refresh) | Violations & audit trail |
| **Dashboard 3: Performance** | Operations, Site Managers | Daily | Resource optimization |

### 1.2 Total BI Views Created

**13 BI Views** supporting 3 dashboards:

**Dashboard 1 Views (5):**
- `v_executive_kpi_cards`
- `v_executive_trends`
- `v_department_performance`
- `v_equipment_summary`
- `v_operator_summary`

**Dashboard 2 Views (3):**
- `v_compliance_overview`
- `v_audit_violations`
- `v_compliance_by_table`

**Dashboard 3 Views (5):**
- `v_equipment_performance`
- `v_operator_performance`
- `v_site_resource_usage`
- `v_maintenance_analysis`
- `v_downtime_analysis`

---

## 2. Dashboard 1: Executive Summary

### 2.1 Dashboard Purpose

Provide executive leadership with high-level operational metrics, trends, and departmental performance for strategic decision-making.

### 2.2 Target Audience

- **Primary:** CEO, COO, CFO, Department Heads
- **Secondary:** Senior Management, Board Members
- **Access Level:** Executive Management

### 2.3 Dashboard Layout

┌─────────────────────────────────────────────────────────────────┐
│                    EXECUTIVE DASHBOARD                          │
│                 Mining Equipment Management System              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────── KPI CARDS SECTION ──────────────────┐   │
│  │                                                         │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │   │
│  │  │  Total   │  │Available │  │Equipment │  │ Active │ │   │
│  │  │Equipment │  │Equipment │  │ In Use   │  │Operator│ │   │
│  │  │    36    │  │    17    │  │    0     │  │   8    │ │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └────────┘ │   │
│  │                                                         │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │   │
│  │  │Equipment │  │  Total   │  │  Total   │  │ System │ │   │
│  │  │Utilization│  │Fuel Cost │  │Downtime  │  │ Health │ │   │
│  │  │  0.00%   │  │ $16,207  │  │ 157 hrs  │  │  POOR  │ │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └────────┘ │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌────────────────── TRENDS SECTION ──────────────────────┐   │
│  │                                                         │   │
│  │  📈 MONTHLY ASSIGNMENT TRENDS                          │   │
│  │  ┌─────────────────────────────────────────────────┐  │   │
│  │  │ Month    │Assignments│Equipment│Operators│Hours │  │   │
│  │  ├─────────────────────────────────────────────────┤  │   │
│  │  │ Dec 2025 │    20     │   20    │    9    │ 8.00 │  │   │
│  │  └─────────────────────────────────────────────────┘  │   │
│  │                                                         │   │
│  │  [Line Chart: Assignments over time]                   │   │
│  │  [Bar Chart: Equipment & Operator trends]              │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌────────────── DEPARTMENT PERFORMANCE ──────────────────┐   │
│  │                                                         │   │
│  │  Department      │Equipment│Operators│Util%│Performance│   │
│  │  ────────────────┼─────────┼─────────┼─────┼──────────│   │
│  │  Operations      │    5    │    2    │ 0%  │   LOW    │   │
│  │  Maintenance     │    4    │    1    │ 0%  │   LOW    │   │
│  │  Logistics       │    3    │    1    │ 0%  │   LOW    │   │
│  │  ...             │   ...   │   ...   │ ... │   ...    │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Copy

### 2.4 Dashboard Components

#### Section 1: KPI Cards (Top Section)

**View:** `v_executive_kpi_cards`

**SQL Implementation:**
```sql
CREATE OR REPLACE VIEW v_executive_kpi_cards AS
SELECT 
    -- Equipment Metrics
    (SELECT COUNT(*) FROM equipment) as total_equipment,
    (SELECT COUNT(*) FROM equipment WHERE status = 'Available') as available_equipment,
    (SELECT COUNT(*) FROM equipment WHERE status = 'In Use') as equipment_in_use,
    
    -- Utilization Rate
    ROUND(
        (SELECT COUNT(*) FROM equipment WHERE status = 'In Use') * 100.0 / 
        NULLIF((SELECT COUNT(*) FROM equipment), 0),
        2
    ) as equipment_utilization_rate,
    
    -- Operator Metrics
    (SELECT COUNT(*) FROM operators WHERE status = 'Active') as active_operators,
    
    -- Financial Metrics
    (SELECT ROUND(SUM(total_cost), 2) FROM fuel_consumption) as total_fuel_cost,
    
    -- Downtime Metrics
    (SELECT ROUND(SUM(duration_hours), 2) FROM downtime_records) as total_downtime_hours,
    
    -- System Health Status
    CASE 
        WHEN ROUND((SELECT COUNT(*) FROM equipment WHERE status = 'In Use') * 100.0 / 
                   NULLIF((SELECT COUNT(*) FROM equipment), 0), 2) >= 70 
             AND (SELECT SUM(duration_hours) FROM downtime_records) < 100 
            THEN 'EXCELLENT'
        WHEN ROUND((SELECT COUNT(*) FROM equipment WHERE status = 'In Use') * 100.0 / 
                   NULLIF((SELECT COUNT(*) FROM equipment), 0), 2) >= 50 
             AND (SELECT SUM(duration_hours) FROM downtime_records) < 150 
            THEN 'GOOD'
        WHEN ROUND((SELECT COUNT(*) FROM equipment WHERE status = 'In Use') * 100.0 / 
                   NULLIF((SELECT COUNT(*) FROM equipment), 0), 2) >= 30 
             AND (SELECT SUM(duration_hours) FROM downtime_records) < 200 
            THEN 'FAIR'
        ELSE 'POOR'
    END as system_health_status
FROM dual;
Display Format:

Large numeric values
Color-coded status indicators
Trend arrows (↑↓→)
Percentage badges
Section 2: Monthly Trends (Middle Section)
View: v_executive_trends

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_executive_trends AS
SELECT 
    TO_CHAR(start_datetime, 'Mon YYYY') as month_name,
    TO_CHAR(start_datetime, 'YYYYMM') as month_sort,
    COUNT(*) as total_assignments,
    COUNT(DISTINCT equipment_id) as equipment_used,
    COUNT(DISTINCT operator_id) as operators_active,
    COUNT(DISTINCT site_id) as sites_active,
    ROUND(AVG(
        CASE 
            WHEN end_datetime IS NOT NULL 
            THEN (end_datetime - start_datetime) * 24
            ELSE (SYSDATE - start_datetime) * 24
        END
    ), 2) as avg_assignment_hours
FROM equipment_assignment
GROUP BY TO_CHAR(start_datetime, 'Mon YYYY'),
         TO_CHAR(start_datetime, 'YYYYMM')
ORDER BY month_sort DESC;
Visualizations:

Line chart: Assignments over time
Bar chart: Equipment & operators by month
Trend indicators: Growth percentages
Section 3: Department Performance (Bottom Section)
View: v_department_performance

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_department_performance AS
SELECT 
    d.department_id,
    d.department_name,
    COUNT(DISTINCT e.equipment_id) as equipment_count,
    COUNT(DISTINCT o.operator_id) as operator_count,
    COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) as equipment_in_use,
    ROUND(
        (COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
         NULLIF(COUNT(DISTINCT e.equipment_id), 0)), 
        2
    ) as utilization_rate,
    CASE 
        WHEN ROUND((COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
                    NULLIF(COUNT(DISTINCT e.equipment_id), 0)), 2) >= 70 
            THEN 'HIGH PERFORMANCE'
        WHEN ROUND((COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
                    NULLIF(COUNT(DISTINCT e.equipment_id), 0)), 2) >= 50 
            THEN 'GOOD PERFORMANCE'
        WHEN ROUND((COUNT(DISTINCT CASE WHEN e.status = 'In Use' THEN e.equipment_id END) * 100.0 / 
                    NULLIF(COUNT(DISTINCT e.equipment_id), 0)), 2) >= 30 
            THEN 'AVERAGE PERFORMANCE'
        ELSE 'LOW PERFORMANCE'
    END as performance_rating
FROM departments d
LEFT JOIN equipment e ON d.department_id = e.department_id
LEFT JOIN operators o ON d.department_id = o.department_id
GROUP BY d.department_id, d.department_name
ORDER BY utilization_rate DESC NULLS LAST;
Display Format:

Sortable table
Color-coded performance ratings
Drill-down capability
2.5 Key Features
✅ Real-time Updates: 5-minute auto-refresh

✅ Color Coding: Green/Yellow/Red status indicators

✅ Drill-down: Click KPIs for detailed reports

✅ Export: PDF/Excel export functionality

✅ Alerts: Email notifications for critical metrics

✅ Mobile Responsive: Accessible on tablets/phones

2.6 Business Value
Quick Decision Making: At-a-glance system status
Trend Identification: Spot patterns early
Performance Comparison: Benchmark departments
Resource Optimization: Identify underutilization
Strategic Planning: Data-driven insights
3. Dashboard 2: Audit & Compliance
3.1 Dashboard Purpose
Monitor regulatory compliance, track violations, and provide comprehensive audit trail for security and governance.

3.2 Target Audience
Primary: Compliance Officer, Security Team, Auditors
Secondary: Legal Team, Risk Management
Access Level: Compliance & Security
3.3 Dashboard Layout
Copy
┌─────────────────────────────────────────────────────────────────┐
│                  COMPLIANCE DASHBOARD                           │
│              Audit & Violation Monitoring System                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌────────────── COMPLIANCE OVERVIEW ──────────────────────┐   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐ │   │
│  │  │Compliance│  │Violation │  │ Weekend  │  │ Holiday │ │   │
│  │  │   Rate   │  │   Rate   │  │Violations│  │Violation│ │   │
│  │  │  0.00%   │  │ 100.00%  │  │    0     │  │    0    │ │   │
│  │  │   🔴     │  │   🔴     │  │   🟢     │  │   🟢    │ │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └─────────┘ │   │
│  │                                                          │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐              │   │
│  │  │  Today's │  │  Unique  │  │  Total   │              │   │
│  │  │Violations│  │Violators │  │Operations│              │   │
│  │  │    5     │  │    1     │  │    5     │              │   │
│  │  │   🟠     │  │   🟡     │  │    ℹ️    │              │   │
│  │  └──────────┘  └──────────┘  └──────────┘              │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌────────────── VIOLATION ANALYSIS ──────────────────────┐   │
│  │                                                          │   │
│  │  📊 VIOLATIONS BY DAY OF WEEK                           │   │
│  │  ┌────────────────────────────────────────────────┐    │   │
│  │  │ Day      │ Allowed │ Denied │ Total │ Comp% │    │   │
│  │  ├────────────────────────────────────────────────┤    │   │
│  │  │ MONDAY   │    0    │   5    │   5   │  0%   │    │   │
│  │  │ TUESDAY  │    0    │   0    │   0   │  N/A  │    │   │
│  │  │ ...      │   ...   │  ...   │  ...  │  ...  │    │   │
│  │  └────────────────────────────────────────────────┘    │   │
│  │                                                          │   │
│  │  [Bar Chart: Violations by day]                         │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌───────────── COMPLIANCE BY TABLE ────────────────────┐     │
│  │                                                        │     │
│  │  Table Name         │Operations│Denied│Comp%│Status  │     │
│  │  ───────────────────┼──────────┼──────┼─────┼────────│     │
│  │  EQUIPMENT          │    3     │  3   │ 0%  │🔴 HIGH │     │
│  │  EQUIPMENT_ASSIGN   │    2     │  2   │ 0%  │🔴 HIGH │     │
│  │  ...                │   ...    │ ...  │ ... │  ...   │     │
│  │                                                        │     │
│  └────────────────────────────────────────────────────────┘     │
│                                                                 │
│  ┌──────────────── RECENT VIOLATIONS ──────────────────────┐   │
│  │                                                          │   │
│  │  Time    │Table│Operation│User │Reason                 │   │
│  │  ────────┼─────┼─────────┼─────┼───────────────────────│   │
│  │  14:30:45│EQUIP│ INSERT  │ADMIN│Weekend operation      │   │
│  │  14:30:44│EQUIP│ UPDATE  │ADMIN│Weekend operation      │   │
│  │  ...     │ ... │  ...    │ ... │ ...                   │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
3.4 Dashboard Components
Section 1: Compliance Overview (Top Section)
View: v_compliance_overview

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_compliance_overview AS
SELECT 
    -- Total Operations
    COUNT(*) as total_operations,
    
    -- Compliance Metrics
    COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) as allowed_operations,
    COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) as denied_operations,
    
    -- Compliance Rate
    ROUND(
        (COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
         NULLIF(COUNT(*), 0)), 
        2
    ) as compliance_rate_percentage,
    
    -- Violation Rate
    ROUND(
        (COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) * 100.0 / 
         NULLIF(COUNT(*), 0)), 
        2
    ) as violation_rate_percentage,
    
    -- Weekend Violations
    COUNT(CASE WHEN is_weekend = 'Y' AND operation_status = 'DENIED' THEN 1 END) as weekend_violations,
    
    -- Holiday Violations
    COUNT(CASE WHEN is_holiday = 'Y' AND operation_status = 'DENIED' THEN 1 END) as holiday_violations,
    
    -- Today's Violations
    COUNT(CASE WHEN TRUNC(operation_timestamp) = TRUNC(SYSDATE) 
               AND operation_status = 'DENIED' THEN 1 END) as todays_violations,
    
    -- Unique Violators
    COUNT(DISTINCT CASE WHEN operation_status = 'DENIED' THEN username END) as unique_violators,
    
    -- Compliance Status
    CASE 
        WHEN ROUND((COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(*), 0)), 2) = 100 
            THEN 'PERFECT COMPLIANCE'
        WHEN ROUND((COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(*), 0)), 2) >= 95 
            THEN 'GOOD COMPLIANCE'
        WHEN ROUND((COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(*), 0)), 2) >= 85 
            THEN 'MODERATE COMPLIANCE'
        ELSE 'HIGH VIOLATIONS'
    END as compliance_status
FROM audit_log;
Section 2: Violation Analysis (Middle Section)
View: v_audit_violations

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_audit_violations AS
SELECT 
    day_of_week,
    operation_status,
    COUNT(*) as operation_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage_of_total,
    ROUND(
        COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
        NULLIF(COUNT(*), 0),
        2
    ) as compliance_rate
FROM audit_log
GROUP BY day_of_week, operation_status
ORDER BY 
    DECODE(day_of_week, 
           'MONDAY', 1, 'TUESDAY', 2, 'WEDNESDAY', 3, 
           'THURSDAY', 4, 'FRIDAY', 5, 'SATURDAY', 6, 'SUNDAY', 7),
    operation_status;
Section 3: Compliance by Table (Bottom Left)
View: v_compliance_by_table

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_compliance_by_table AS
SELECT 
    table_name,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) as allowed_operations,
    COUNT(CASE WHEN operation_status = 'DENIED' THEN 1 END) as denied_operations,
    ROUND(
        (COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
         NULLIF(COUNT(*), 0)), 
        2
    ) as compliance_rate_percentage,
    CASE 
        WHEN ROUND((COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(*), 0)), 2) = 100 
            THEN 'PERFECT COMPLIANCE'
        WHEN ROUND((COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(*), 0)), 2) >= 95 
            THEN 'GOOD COMPLIANCE'
        WHEN ROUND((COUNT(CASE WHEN operation_status = 'ALLOWED' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(*), 0)), 2) >= 85 
            THEN 'MODERATE COMPLIANCE'
        ELSE 'HIGH VIOLATIONS'
    END as compliance_status
FROM audit_log
GROUP BY table_name
ORDER BY compliance_rate_percentage ASC, total_operations DESC;
Section 4: Recent Violations (Bottom Right)
SQL Query:

Copy
-- Real-time Violation Feed
SELECT 
    TO_CHAR(operation_timestamp, 'HH24:MI:SS') as time,
    table_name,
    operation_type,
    username,
    denial_reason,
    ROUND((SYSDATE - operation_timestamp) * 24 * 60, 0) as minutes_ago
FROM audit_log
WHERE operation_status = 'DENIED'
ORDER BY operation_timestamp DESC
FETCH FIRST 10 ROWS ONLY;
3.5 Key Features
✅ Real-time Monitoring: 30-second auto-refresh

✅ Instant Alerts: Desktop/email notifications for violations

✅ Audit Trail: Complete operation history

✅ Drill-down: Click violations for full details

✅ Export: Compliance reports for auditors

✅ Historical Analysis: Trend identification

3.6 Alert Configuration
Immediate Alerts:

Any weekend violation
Any holiday violation
Compliance rate drops below 95%
More than 5 violations in one day
Daily Reports:

Compliance summary
Violation details
User activity report
Weekly Reports:

Compliance trends
Top violators
Table-level analysis
3.7 Business Value
Regulatory Compliance: Demonstrate adherence to policies
Risk Management: Early detection of security issues
Audit Readiness: Complete audit trail
Training Identification: Spot users needing training
Policy Enforcement: Automated rule enforcement
4. Dashboard 3: Performance & Resources
4.1 Dashboard Purpose
Monitor operational efficiency, resource utilization, maintenance effectiveness, and optimize equipment and operator deployment across sites.

4.2 Target Audience
Primary: Operations Manager, Site Managers, Maintenance Manager
Secondary: Department Supervisors, Resource Planners
Access Level: Operations & Site Management
4.3 Dashboard Layout
Copy
┌─────────────────────────────────────────────────────────────────┐
│              PERFORMANCE & RESOURCES DASHBOARD                  │
│                  Operational Efficiency Monitor                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────── EQUIPMENT PERFORMANCE ─────────────────────┐    │
│  │                                                         │    │
│  │  Equipment│Type  │Assignments│Last Used│Performance   │    │
│  │  ─────────┼──────┼───────────┼─────────┼──────────────│    │
│  │  EQ-001   │Truck │    15     │ 2 days  │ HIGH USAGE   │    │
│  │  EQ-002   │Drill │     8     │ 5 days  │ MODERATE     │    │
│  │  EQ-003   │Loader│     2     │ 45 days │ LOW USAGE    │    │
│  │  ...      │ ...  │    ...    │  ...    │  ...         │    │
│  │                                                         │    │
│  │  [Bar Chart: Equipment usage distribution]             │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌──────────── OPERATOR PERFORMANCE ──────────────────────┐    │
│  │                                                         │    │
│  │  Operator │Assignments│Equipment│Sites│Productivity    │    │
│  │  ─────────┼───────────┼─────────┼─────┼───────────────│    │
│  │  John Doe │    12     │    8    │  5  │ EXCELLENT     │    │
│  │  Jane Smith│    9     │    6    │  4  │ GOOD          │    │
│  │  ...      │    ...    │   ...   │ ... │  ...          │    │
│  │                                                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌──────────── SITE RESOURCE USAGE ────────────────────────┐   │
│  │                                                          │   │
│  │  Site Name    │Equipment│Operators│Assignments│Activity │   │
│  │  ─────────────┼─────────┼─────────┼───────────┼─────────│   │
│  │  North Mine   │    8    │    4    │    15     │VERY ACT │   │
│  │  South Quarry │    5    │    3    │     8     │ACTIVE   │   │
│  │  East Pit     │    2    │    1    │     2     │LOW ACT  │   │
│  │  ...          │   ...   │   ...   │    ...    │  ...    │   │
│  │                                                          │   │
│  │  [Map View: Site locations with activity indicators]    │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
│  ┌─────── MAINTENANCE ANALYSIS ──────┐ ┌─── DOWNTIME ────┐    │
│  │                                    │ │                 │    │
│  │  Scheduled:     18                 │ │ Total: 157hrs   │    │
│  │  Completed:     15                 │ │ Events: 15      │    │
│  │  Pending:        3                 │ │ Avg: 10.5hrs    │    │
│  │  Completion: 83.33%                │ │ Status: WARNING │    │
│  │                                    │ │                 │    │
│  │  [Pie Chart: Maintenance status]   │ │ [Chart: By type]│    │
│  │                                    │ │                 │    │
│  └────────────────────────────────────┘ └─────────────────┘    │
│                                                                 │
│  ┌──────────────── FUEL ANALYSIS ──────────────────────────┐   │
│  │                                                          │   │
│  │  Equipment  │ Liters │  Cost  │ Efficiency │ Category  │   │
│  │  ───────────┼────────┼────────┼────────────┼───────────│   │
│  │  EQ-001     │ 1,250  │ $1,875 │   8.5 L/hr │ MODERATE  │   │
│  │  EQ-002     │ 2,100  │ $3,150 │  12.3 L/hr │ HIGH COST │   │
│  │  ...        │  ...   │  ...   │    ...     │  ...      │   │
│  │                                                          │   │
│  │  [Chart: Fuel cost trends over time]                    │   │
│  │                                                          │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
4.4 Dashboard Components
Section 1: Equipment Performance
View: v_equipment_performance

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_equipment_performance AS
SELECT 
    e.equipment_id,
    e.model,
    et.type_name as equipment_type,
    COUNT(ea.assignment_id) as total_assignments,
    MAX(ea.start_datetime) as last_used_date,
    ROUND(SYSDATE - MAX(ea.start_datetime), 0) as days_since_last_use,
    CASE 
        WHEN COUNT(ea.assignment_id) >= 10 THEN 'HIGH USAGE'
        WHEN COUNT(ea.assignment_id) >= 5 THEN 'MODERATE USAGE'
        WHEN COUNT(ea.assignment_id) >= 1 THEN 'LOW USAGE'
        ELSE 'NO USAGE'
    END as performance_category,
    CASE 
        WHEN MAX(ea.start_datetime) IS NULL THEN 'NEVER USED'
        WHEN ROUND(SYSDATE - MAX(ea.start_datetime), 0) > 60 THEN 'IDLE > 60 DAYS'
        WHEN ROUND(SYSDATE - MAX(ea.start_datetime), 0) > 30 THEN 'IDLE > 30 DAYS'
        WHEN ROUND(SYSDATE - MAX(ea.start_datetime), 0) > 7 THEN 'IDLE > 7 DAYS'
        ELSE 'RECENTLY USED'
    END as usage_status
FROM equipment e
JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id
LEFT JOIN equipment_assignment ea ON e.equipment_id = ea.equipment_id
GROUP BY e.equipment_id, e.model, et.type_name
ORDER BY total_assignments DESC NULLS LAST;
Section 2: Operator Performance
View: v_operator_performance

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_operator_performance AS
SELECT 
    o.operator_id,
    o.first_name || ' ' || o.last_name as operator_name,
    COUNT(ea.assignment_id) as total_assignments,
    COUNT(DISTINCT ea.equipment_id) as equipment_operated,
    COUNT(DISTINCT ea.site_id) as sites_worked,
    ROUND(AVG(
        CASE 
            WHEN ea.end_datetime IS NOT NULL 
            THEN (ea.end_datetime - ea.start_datetime) * 24
            ELSE (SYSDATE - ea.start_datetime) * 24
        END
    ), 2) as avg_assignment_hours,
    CASE 
        WHEN COUNT(ea.assignment_id) >= 10 THEN 'EXCELLENT'
        WHEN COUNT(ea.assignment_id) >= 7 THEN 'GOOD'
        WHEN COUNT(ea.assignment_id) >= 4 THEN 'AVERAGE'
        WHEN COUNT(ea.assignment_id) >= 1 THEN 'BELOW AVERAGE'
        ELSE 'NO ACTIVITY'
    END as productivity_rating
FROM operators o
LEFT JOIN equipment_assignment ea ON o.operator_id = ea.operator_id
GROUP BY o.operator_id, o.first_name, o.last_name
ORDER BY total_assignments DESC NULLS LAST;
Section 3: Site Resource Usage
View: v_site_resource_usage

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_site_resource_usage AS
SELECT 
    ms.site_id,
    ms.site_name,
    ms.location,
    COUNT(DISTINCT ea.equipment_id) as equipment_deployed,
    COUNT(DISTINCT ea.operator_id) as operators_assigned,
    COUNT(ea.assignment_id) as active_assignments,
    CASE 
        WHEN COUNT(ea.assignment_id) >= 5 THEN 'VERY ACTIVE'
        WHEN COUNT(ea.assignment_id) >= 3 THEN 'ACTIVE'
        WHEN COUNT(ea.assignment_id) >= 1 THEN 'LOW ACTIVITY'
        ELSE 'INACTIVE'
    END as activity_level,
    ROUND(
        COUNT(DISTINCT ea.equipment_id) * 1.0 / 
        NULLIF(COUNT(DISTINCT ea.operator_id), 0),
        2
    ) as equipment_per_operator_ratio
FROM mining_sites ms
LEFT JOIN equipment_assignment ea ON ms.site_id = ea.site_id
WHERE ea.end_datetime IS NULL OR ea.end_datetime IS NOT NULL
GROUP BY ms.site_id, ms.site_name, ms.location
ORDER BY active_assignments DESC NULLS LAST;
Section 4: Maintenance Analysis
View: v_maintenance_analysis

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_maintenance_analysis AS
SELECT 
    e.equipment_id,
    e.model,
    et.type_name as equipment_type,
    COUNT(ms.schedule_id) as total_scheduled,
    COUNT(CASE WHEN ms.status = 'Completed' THEN 1 END) as completed_maintenance,
    COUNT(CASE WHEN ms.status = 'Scheduled' THEN 1 END) as pending_maintenance,
    ROUND(
        (COUNT(CASE WHEN ms.status = 'Completed' THEN 1 END) * 100.0 / 
         NULLIF(COUNT(ms.schedule_id), 0)), 
        2
    ) as completion_rate_percentage,
    CASE 
        WHEN ROUND((COUNT(CASE WHEN ms.status = 'Completed' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(ms.schedule_id), 0)), 2) >= 90 
            THEN 'EXCELLENT MAINTENANCE'
        WHEN ROUND((COUNT(CASE WHEN ms.status = 'Completed' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(ms.schedule_id), 0)), 2) >= 75 
            THEN 'GOOD MAINTENANCE'
        WHEN ROUND((COUNT(CASE WHEN ms.status = 'Completed' THEN 1 END) * 100.0 / 
                    NULLIF(COUNT(ms.schedule_id), 0)), 2) >= 50 
            THEN 'NEEDS IMPROVEMENT'
        ELSE 'POOR MAINTENANCE'
    END as maintenance_category
FROM equipment e
JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id
LEFT JOIN maintenance_schedule ms ON e.equipment_id = ms.equipment_id
GROUP BY e.equipment_id, e.model, et.type_name
ORDER BY completion_rate_percentage ASC NULLS LAST;
Section 5: Downtime Analysis
View: v_downtime_analysis

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_downtime_analysis AS
SELECT 
    e.equipment_id,
    e.model,
    et.type_name as equipment_type,
    COUNT(dr.downtime_id) as downtime_events,
    ROUND(SUM(dr.duration_hours), 2) as total_downtime_hours,
    ROUND(AVG(dr.duration_hours), 2) as avg_downtime_per_event,
    ROUND(SUM(dr.duration_hours) * 100, 2) as total_impact_cost,
    CASE 
        WHEN SUM(dr.duration_hours) >= 20 THEN 'CRITICAL - High Downtime'
        WHEN SUM(dr.duration_hours) >= 10 THEN 'WARNING - Moderate Downtime'
        WHEN SUM(dr.duration_hours) >= 1 THEN 'OK - Low Downtime'
        ELSE 'EXCELLENT - No Downtime'
    END as downtime_status
FROM equipment e
JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id
LEFT JOIN downtime_records dr ON e.equipment_id = dr.equipment_id
GROUP BY e.equipment_id, e.model, et.type_name
ORDER BY total_downtime_hours DESC NULLS LAST;
Section 6: Fuel Consumption Analysis
View: v_fuel_consumption_analysis

SQL Implementation:

Copy
CREATE OR REPLACE VIEW v_fuel_consumption_analysis AS
SELECT 
    e.equipment_id,
    e.model,
    et.type_name as equipment_type,
    COUNT(fc.consumption_id) as refueling_count,
    ROUND(SUM(fc.quantity_liters), 2) as total_fuel_liters,
    ROUND(SUM(fc.total_cost), 2) as total_fuel_cost,
    ROUND(AVG(fc.quantity_liters), 2) as avg_liters_per_refuel,
    ROUND(AVG(fc.total_cost), 2) as avg_cost_per_refuel,
    ROUND(SUM(fc.total_cost) / NULLIF(SUM(fc.quantity_liters), 0), 2) as cost_per_liter,
    CASE 
        WHEN SUM(fc.total_cost) >= 1000 THEN 'HIGH FUEL COST'
        WHEN SUM(fc.total_cost) >= 500 THEN 'MODERATE FUEL COST'
        ELSE 'LOW FUEL COST'
    END as fuel_cost_category
FROM equipment e
JOIN equipment_types et ON e.equipment_type_id = et.equipment_type_id
LEFT JOIN fuel_consumption fc ON e.equipment_id = fc.equipment_id
GROUP BY e.equipment_id, e.model, et.type_name
ORDER BY total_fuel_cost DESC NULLS LAST;
4.5 Key Features
✅ Comprehensive Metrics: Equipment, operators, sites, maintenance, downtime, fuel

✅ Resource Optimization: Identify underutilized assets

✅ Performance Tracking: Monitor efficiency trends

✅ Predictive Insights: Identify potential issues early

✅ Cost Analysis: Track fuel and downtime costs

✅ Drill-down Reports: Detailed analysis on demand

4.6 Business Value
Resource Optimization: Maximize equipment and operator utilization
Cost Reduction: Identify high-cost equipment and inefficiencies
Maintenance Planning: Proactive maintenance scheduling
Capacity Planning: Understand resource distribution
Performance Management: Track and improve operator productivity
5. Dashboard Access Control
5.1 Role-Based Access
Role	Dashboard 1	Dashboard 2	Dashboard 3	Permissions
CEO	✅ Full	✅ Full	✅ Full	View, Export
COO	✅ Full	✅ Full	✅ Full	View, Export
CFO	✅ Full	❌ No	✅ Limited	View, Export
Compliance Officer	✅ Limited	✅ Full	❌ No	View, Export, Audit
Operations Manager	✅ Limited	❌ No	✅ Full	View, Export
Site Manager	✅ Limited	❌ No	✅ Site-only	View
Department Head	✅ Dept-only	❌ No	✅ Dept-only	View
Auditor	❌ No	✅ Read-only	❌ No	View, Export
5.2 Access Implementation
Copy
-- Create roles
CREATE ROLE executive_role;
CREATE ROLE compliance_role;
CREATE ROLE operations_role;
CREATE ROLE site_manager_role;

-- Grant view access
GRANT SELECT ON v_executive_kpi_cards TO executive_role;
GRANT SELECT ON v_compliance_overview TO compliance_role;
GRANT SELECT ON v_equipment_performance TO operations_role;

-- Assign roles to users
GRANT executive_role TO ceo_user, coo_user;
GRANT compliance_role TO compliance_officer;
GRANT operations_role TO ops_manager;
6. Technical Implementation
6.1 View Creation Summary
Copy
-- Dashboard 1 Views
CREATE OR REPLACE VIEW v_executive_kpi_cards AS ...
CREATE OR REPLACE VIEW v_executive_trends AS ...
CREATE OR REPLACE VIEW v_department_performance AS ...

-- Dashboard 2 Views
CREATE OR REPLACE VIEW v_compliance_overview AS ...
CREATE OR REPLACE VIEW v_audit_violations AS ...
CREATE OR REPLACE VIEW v_compliance_by_table AS ...

-- Dashboard 3 Views
CREATE OR REPLACE VIEW v_equipment_performance AS ...
CREATE OR REPLACE VIEW v_operator_performance AS ...
CREATE OR REPLACE VIEW v_site_resource_usage AS ...
CREATE OR REPLACE VIEW v_maintenance_analysis AS ...
CREATE OR REPLACE VIEW v_downtime_analysis AS ...
CREATE OR REPLACE VIEW v_fuel_consumption_analysis AS ...
6.2 Performance Optimization
Indexing Strategy:

Copy
-- Indexes for performance
CREATE INDEX idx_equipment_status ON equipment(status);
CREATE INDEX idx_operator_status ON operators(status);
CREATE INDEX idx_assignment_dates ON equipment_assignment(start_datetime, end_datetime);
CREATE INDEX idx_audit_timestamp ON audit_log(operation_timestamp);
CREATE INDEX idx_audit_status ON audit_log(operation_status);
Materialized Views (for large datasets):

Copy
-- For historical trend analysis
CREATE MATERIALIZED VIEW mv_monthly_trends
REFRESH COMPLETE ON DEMAND
AS SELECT * FROM v_executive_trends;

-- Refresh schedule
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'refresh_monthly_trends',
        job_type        => 'PLSQL_BLOCK',
        job_action      => 'BEGIN DBMS_MVIEW.REFRESH(''MV_MONTHLY_TRENDS''); END;',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=DAILY; BYHOUR=1',
        enabled         => TRUE
    );
END;
/
6.3 Refresh Frequencies
Dashboard	Refresh Method	Frequency	Implementation
Dashboard 1	Auto-refresh	5 minutes	JavaScript timer
Dashboard 2	Auto-refresh	30 seconds	WebSocket/AJAX
Dashboard 3	Manual/Auto	Daily	Scheduled job
7. User Guide
7.1 Accessing Dashboards
Step 1: Login to system

Copy
URL: https://your-server/mems/dashboards
Username: [Your credentials]
Password: [Your password]
Step 2: Select dashboard from menu

Executive Summary
Audit & Compliance
Performance & Resources
Step 3: Navigate and interact

Click KPIs for details
Use filters for specific data
Export reports as needed
7.2 Common Tasks
Task 1: Check System Health
Open Dashboard 1
View "System Health Status" card
If POOR/FAIR, click for details
Review recommendations
Task 2: Monitor Compliance
Open Dashboard 2
Check "Today's Violations"
If > 0, review violation details
Take corrective action
Task 3: Optimize Resources
Open Dashboard 3
Review "Equipment Performance"
Identify idle equipment
Redeploy or schedule maintenance
7.3 Exporting Reports
PDF Export:

Copy
1. Click "Export" button
2. Select "PDF"
3. Choose sections to include
4. Click "Generate"
5. Download file
Excel Export:

Copy
1. Click "Export" button
2. Select "Excel"
3. Data exports to spreadsheet
4. Save locally
7.4 Troubleshooting
Issue: Dashboard not loading

Solution: Check internet connection, refresh browser, clear cache
Issue: Data not updating

Solution: Check refresh settings, verify database connection
Issue: Access denied

Solution: Contact administrator to verify permissions
8. Conclusion
The three-dashboard BI system provides comprehensive monitoring and analysis capabilities:

Dashboard Summary
Dashboard	Views	KPIs	Primary Value
Executive	5	12	Strategic decision-making
Compliance	3	8	Regulatory adherence
Performance	5	15	Operational optimization
Key Achievements
✅ 13 BI Views - Comprehensive data coverage

✅ 35+ KPIs - Multi-dimensional analysis

✅ Real-time Monitoring - Immediate insights

✅ Role-based Access - Security & governance

✅ Export Capabilities - Reporting flexibility

✅ Mobile Responsive - Access anywhere

Business Impact
Improved Decision Making: Data-driven insights
Enhanced Compliance: 100% audit trail
Optimized Resources: Better utilization
Cost Reduction: Identify inefficiencies
Increased Productivity: Performance tracking
Document Control:

Version	Date	Author	Changes
1.0	Dec 8, 2024	[Your Name]	Initial dashboard specifications
End of Dashboard Specifications Document