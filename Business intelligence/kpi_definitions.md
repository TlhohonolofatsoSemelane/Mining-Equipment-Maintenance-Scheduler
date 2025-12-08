# 📊 Key Performance Indicators (KPI) Definitions

## Mining Equipment Management System (MEMS)
**Version:** 1.0  
**Date:** December 8, 2024  
**Author:** [Your Name]  
**Course:** Advanced Database Management & PL/SQL  
**Institution:** AUCA

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Executive Dashboard KPIs](#2-executive-dashboard-kpis)
3. [Compliance Dashboard KPIs](#3-compliance-dashboard-kpis)
4. [Performance Dashboard KPIs](#4-performance-dashboard-kpis)
5. [KPI Summary Matrix](#5-kpi-summary-matrix)
6. [Thresholds & Targets](#6-thresholds--targets)
7. [Update Frequencies](#7-update-frequencies)

---

## 1. Introduction

This document defines all Key Performance Indicators (KPIs) used in the Mining Equipment Management System's Business Intelligence dashboards. Each KPI includes its purpose, calculation method, targets, and interpretation guidelines.

### 1.1 KPI Overview

The system tracks **35+ KPIs** organized across 3 dashboards:

| Dashboard | KPI Count | Primary Focus |
|-----------|-----------|---------------|
| **Dashboard 1: Executive** | 12 KPIs | Strategic oversight & trends |
| **Dashboard 2: Compliance** | 8 KPIs | Regulatory adherence & violations |
| **Dashboard 3: Performance** | 15 KPIs | Operational efficiency & resources |

---

## 2. Executive Dashboard KPIs

### 2.1 Total Equipment Count (EXE-001)

**Definition:** Total number of equipment units in the system

**Calculation:**
```sql
SELECT COUNT(*) as total_equipment FROM equipment;
Current Value: 36 units

Target: N/A (Baseline metric)

Update: Real-time

Purpose: Foundation metric for all equipment calculations and utilization rates.

2.2 Available Equipment (EXE-002)
Definition: Equipment units ready for deployment (status = 'Available')

Calculation:

Copy
SELECT COUNT(*) FROM equipment WHERE status = 'Available';
Current Value: 17 units (47.2%)

Target: ≥ 30% of total equipment

Update: Real-time

Thresholds:

🟢 Optimal: 30-50%
🟡 Acceptable: 20-30% or 50-60%
🔴 Critical: <20% or >60%
Interpretation: Low availability limits new projects; high availability indicates potential underutilization.

2.3 Equipment In Use (EXE-003)
Definition: Equipment currently assigned to operators

Calculation:

Copy
SELECT COUNT(*) FROM equipment WHERE status = 'In Use';
Current Value: 0 units (setup phase)

Target: 60-80% of total (22-29 units)

Update: Real-time

Thresholds:

🟢 Excellent: 70-85%
🟡 Good: 50-70%
🟠 Fair: 30-50%
🔴 Poor: <30%
2.4 Active Operators (EXE-004)
Definition: Operators available for work (status = 'Active')

Calculation:

Copy
SELECT COUNT(*) FROM operators WHERE status = 'Active';
Current Value: 8 operators (88.9%)

Target: ≥ 80% of total operators

Update: Real-time

Thresholds:

🟢 Optimal: ≥85%
🟡 Acceptable: 70-85%
🔴 Critical: <70%
2.5 Equipment Utilization Rate (EXE-005) ⭐ PRIMARY METRIC
Definition: Percentage of equipment in active use

Calculation:

Copy
Equipment Utilization Rate = (Equipment In Use / Total Equipment) × 100

SELECT ROUND(
    (COUNT(CASE WHEN status = 'In Use' THEN 1 END) * 100.0 / 
     NULLIF(COUNT(*), 0)), 2
) as utilization_rate FROM equipment;
Current Value: 0.00% (setup phase)

Target: ≥ 70%

Industry Benchmark: 65-75%

Update: Real-time

Thresholds:

🟢 Excellent: ≥80%
🟡 Good: 60-79%
🟠 Fair: 40-59%
🔴 Poor: <40%
Business Impact: 1% improvement ≈ $50,000 annual savings

Key Insight: Primary indicator of operational efficiency and ROI on equipment investment.

2.6 Total Fuel Cost (EXE-006)
Definition: Cumulative fuel expenditure across all equipment

Calculation:

Copy
SELECT ROUND(SUM(total_cost), 2) FROM fuel_consumption;
Current Value: $16,207.42

Target: Within budget (15-20% of operating costs)

Update: Daily

Thresholds:

🟢 On Budget: Within ±5%
🟡 Warning: 5-15% over
🔴 Critical: >15% over
2.7 Total Downtime Hours (EXE-007)
Definition: Cumulative equipment downtime across all events

Calculation:

Copy
SELECT ROUND(SUM(duration_hours), 2) FROM downtime_records;
Current Value: 157.00 hours

Target: <5% of available hours

Update: Daily

Thresholds:

🟢 Excellent: <100 hours
🟡 Acceptable: 100-150 hours
🟠 Warning: 150-200 hours
🔴 Critical: >200 hours
Cost Impact: Current downtime ≈ $15,700 revenue loss (@ $100/hour)

2.8 System Health Status (EXE-008)
Definition: Overall system health based on utilization and downtime

Calculation:

Copy
System Health = 
    CASE 
        WHEN utilization ≥70% AND downtime <100hrs THEN 'EXCELLENT'
        WHEN utilization ≥50% AND downtime <150hrs THEN 'GOOD'
        WHEN utilization ≥30% AND downtime <200hrs THEN 'FAIR'
        ELSE 'POOR'
    END
Current Value: POOR

Target: EXCELLENT or GOOD

Update: Real-time

Status Meanings:

🟢 EXCELLENT: Optimal performance
🟡 GOOD: Normal operations
🟠 FAIR: Needs attention
🔴 POOR: Immediate action required
2.9 Monthly Assignment Trends (EXE-009)
Definition: Month-by-month operational activity metrics

Calculation:

Copy
SELECT 
    TO_CHAR(start_datetime, 'Mon YYYY') as month,
    COUNT(*) as total_assignments,
    COUNT(DISTINCT equipment_id) as equipment_used,
    COUNT(DISTINCT operator_id) as operators_active,
    ROUND(AVG((end_datetime - start_datetime) * 24), 2) as avg_hours
FROM equipment_assignment
GROUP BY TO_CHAR(start_datetime, 'Mon YYYY')
ORDER BY TO_CHAR(start_datetime, 'YYYYMM') DESC;
Current Data (Dec 2025):

Assignments: 20
Equipment Used: 20
Operators Active: 9
Avg Hours: 8.00
Target: 5-10% month-over-month growth

Update: Daily (aggregated monthly)

2.10 Total Assignments (EXE-010)
Definition: Number of equipment-operator assignments

Calculation:

Copy
SELECT COUNT(*) FROM equipment_assignment 
WHERE TRUNC(start_datetime, 'MM') = TRUNC(SYSDATE, 'MM');
Current Value: 20 (December)

Update: Real-time

2.11 Department Performance Rating (EXE-011)
Definition: Departmental classification based on utilization

Calculation:

Copy
SELECT 
    department_name,
    ROUND((COUNT(CASE WHEN status='In Use' THEN 1 END)*100.0/
           NULLIF(COUNT(*),0)), 2) as utilization,
    CASE 
        WHEN utilization ≥70 THEN 'HIGH PERFORMANCE'
        WHEN utilization ≥50 THEN 'GOOD PERFORMANCE'
        WHEN utilization ≥30 THEN 'AVERAGE PERFORMANCE'
        ELSE 'LOW PERFORMANCE'
    END as rating
FROM departments d
JOIN equipment e ON d.department_id = e.department_id
GROUP BY department_name;
Target: Majority HIGH or GOOD

Update: Daily

Performance Levels:

🟢 HIGH: ≥70% utilization
🟡 GOOD: 50-69%
🟠 AVERAGE: 30-49%
🔴 LOW: <30%
2.12 Average Assignment Hours (EXE-012)
Definition: Mean duration of equipment assignments

Calculation:

Copy
SELECT ROUND(AVG((end_datetime - start_datetime) * 24), 2) 
FROM equipment_assignment;
Current Value: 8.00 hours

Target: 8-12 hours (optimal shift)

Update: Daily

Interpretation:

<4 hours: Inefficient
4-8 hours: Acceptable
8-12 hours: 🟢 Optimal
16 hours: Safety concern

3. Compliance Dashboard KPIs
3.1 Overall Compliance Rate (COM-001) ⭐ CRITICAL
Definition: Percentage of allowed operations

Calculation:

Copy
Compliance Rate = (Allowed Operations / Total Operations) × 100

SELECT ROUND(
    (COUNT(CASE WHEN operation_status='ALLOWED' THEN 1 END)*100.0/
     NULLIF(COUNT(*),0)), 2
) FROM audit_log;
Current Value: 0.00% (test environment)

Target: 100%

Update: Real-time

Thresholds:

🟢 PERFECT: 100%
🟡 GOOD: 95-99%
🟠 MODERATE: 85-94%
🔴 HIGH VIOLATIONS: <85%
3.2 Violation Rate (COM-002)
Definition: Percentage of denied operations

Calculation:

Copy
Violation Rate = (Denied Operations / Total Operations) × 100

SELECT ROUND(
    (COUNT(CASE WHEN operation_status='DENIED' THEN 1 END)*100.0/
     NULLIF(COUNT(*),0)), 2
) FROM audit_log;
Current Value: 100% (test data)

Target: 0%

Update: Real-time

Severity Levels:

🟢 PERFECT: 0%
🟡 GOOD: 1-5%
🟠 MODERATE: 6-15%
🔴 CRITICAL: >15%
3.3 Weekend Violations (COM-003)
Definition: Operations attempted on weekends

Calculation:

Copy
SELECT COUNT(*) FROM audit_log 
WHERE is_weekend='Y' AND operation_status='DENIED';
Target: 0 violations

Update: Real-time

Business Rule: No INSERT/UPDATE/DELETE on weekends for safety compliance.

Alert: Immediate notification for any weekend violation.

3.4 Holiday Violations (COM-004)
Definition: Operations attempted on holidays

Calculation:

Copy
SELECT COUNT(*) FROM audit_log 
WHERE is_holiday='Y' AND operation_status='DENIED';
Target: 0 violations

Update: Real-time

Holidays: New Year's Day, Independence Day, Christmas Day

Alert: Executive notification for any holiday violation.

3.5 Today's Violations (COM-005)
Definition: Denied operations today

Calculation:

Copy
SELECT COUNT(*) FROM audit_log 
WHERE TRUNC(operation_timestamp)=TRUNC(SYSDATE) 
AND operation_status='DENIED';
Current Value: 5 violations

Target: 0

Update: Real-time (30-second refresh)

Alert Conditions:

Desktop notification per violation
Escalation if >5 violations
3.6 Unique Violators (COM-006)
Definition: Distinct users with violations

Calculation:

Copy
SELECT COUNT(DISTINCT username) FROM audit_log 
WHERE operation_status='DENIED';
Target: 0 users

Update: Daily

Action: Training for first-time violators; disciplinary action for repeat offenders.

3.7 Compliance Status by Table (COM-007)
Definition: Compliance classification per table

Calculation:

Copy
SELECT 
    table_name,
    ROUND((COUNT(CASE WHEN operation_status='ALLOWED' THEN 1 END)*100.0/
           NULLIF(COUNT(*),0)), 2) as compliance_rate,
    CASE 
        WHEN compliance_rate=100 THEN 'PERFECT COMPLIANCE'
        WHEN compliance_rate≥95 THEN 'GOOD COMPLIANCE'
        WHEN compliance_rate≥85 THEN 'MODERATE COMPLIANCE'
        ELSE 'HIGH VIOLATIONS'
    END as status
FROM audit_log
GROUP BY table_name;
Target: PERFECT or GOOD for all tables

Update: Real-time

3.8 Operations by Day of Week (COM-008)
Definition: Distribution of operations across weekdays

Calculation:

Copy
SELECT 
    day_of_week,
    operation_status,
    COUNT(*) as count,
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) as pct
FROM audit_log
GROUP BY day_of_week, operation_status;
Purpose: Identify operational patterns and validate business rule enforcement.

Update: Daily

4. Performance Dashboard KPIs
4.1 Equipment Performance Category (PER-001)
Definition: Classification based on assignment count

Calculation:

Copy
Performance Category = 
    CASE 
        WHEN assignments ≥10 THEN 'HIGH USAGE'
        WHEN assignments ≥5 THEN 'MODERATE USAGE'
        WHEN assignments ≥1 THEN 'LOW USAGE'
        ELSE 'NO USAGE'
    END
Target Distribution:

HIGH USAGE: ≥40%
MODERATE: ≥30%
LOW: ≤20%
NO USAGE: ≤10%
Update: Daily

4.2 Operator Productivity Rating (PER-002)
Definition: Classification based on operator assignments

Calculation:

Copy
Productivity Rating = 
    CASE 
        WHEN assignments ≥10 THEN 'EXCELLENT'
        WHEN assignments ≥7 THEN 'GOOD'
        WHEN assignments ≥4 THEN 'AVERAGE'
        WHEN assignments ≥1 THEN 'BELOW AVERAGE'
        ELSE 'NO ACTIVITY'
    END
Target Distribution:

EXCELLENT: ≥30%
GOOD: ≥40%
AVERAGE: ≤20%
BELOW AVERAGE: ≤10%
Update: Daily

4.3 Days Since Last Use (PER-003)
Definition: Days since equipment was last assigned

Calculation:

Copy
SELECT 
    equipment_id,
    ROUND(SYSDATE - MAX(start_datetime), 0) as days_idle
FROM equipment_assignment
GROUP BY equipment_id;
Target: <30 days for all equipment

Alert Thresholds:

🟢 OK: <7 days
🟡 ATTENTION: 7-30 days
🟠 WARNING: 31-60 days
🔴 CRITICAL: >60 days or never used
Update: Daily

4.4 Site Activity Level (PER-004)
Definition: Site classification by active assignments

Calculation:

Copy
Activity Level = 
    CASE 
        WHEN assignments ≥5 THEN 'VERY ACTIVE'
        WHEN assignments ≥3 THEN 'ACTIVE'
        WHEN assignments ≥1 THEN 'LOW ACTIVITY'
        ELSE 'INACTIVE'
    END
Target: Majority ACTIVE or VERY ACTIVE

Update: Real-time

4.5 Maintenance Completion Rate (PER-005)
Definition: Percentage of completed scheduled maintenance

Calculation:

Copy
Completion Rate = (Completed / Total Scheduled) × 100

SELECT ROUND(
    (COUNT(CASE WHEN status='Completed' THEN 1 END)*100.0/
     NULLIF(COUNT(*),0)), 2
) FROM maintenance_schedule;
Target: ≥95%

Update: Daily

Thresholds:

🟢 EXCELLENT: ≥95%
🟡 GOOD: 85-94%
🟠 FAIR: 70-84%
🔴 POOR: <70%
4.6 Maintenance Category (PER-006)
Definition: Classification based on completion rate

Calculation:

Copy
Maintenance Category = 
    CASE 
        WHEN completion_rate ≥90 THEN 'EXCELLENT MAINTENANCE'
        WHEN completion_rate ≥75 THEN 'GOOD MAINTENANCE'
        WHEN completion_rate ≥50 THEN 'NEEDS IMPROVEMENT'
        ELSE 'POOR MAINTENANCE'
    END
Target: EXCELLENT or GOOD

Update: Daily

4.7 Downtime Status (PER-007)
Definition: Classification based on downtime hours

Calculation:

Copy
Downtime Status = 
    CASE 
        WHEN hours ≥20 THEN 'CRITICAL - High Downtime'
        WHEN hours ≥10 THEN 'WARNING - Moderate Downtime'
        WHEN hours ≥1 THEN 'OK - Low Downtime'
        ELSE 'EXCELLENT - No Downtime'
    END
Target: EXCELLENT or OK

Update: Daily

4.8 Downtime by Equipment (PER-008)
Definition: Total downtime hours per equipment

Calculation:

Copy
SELECT 
    equipment_id,
    COUNT(*) as events,
    SUM(duration_hours) as total_hours,
    SUM(duration_hours)*100 as cost_impact
FROM downtime_records
GROUP BY equipment_id;
Target: <10 hours per equipment/month

Update: Daily

4.9 Average Downtime per Event (PER-009)
Definition: Mean duration of downtime events

Calculation:

Copy
SELECT ROUND(AVG(duration_hours), 2) FROM downtime_records;
Target: <2 hours per event

Update: Weekly

4.10 Equipment Deployed per Site (PER-010)
Definition: Equipment count at each site

Calculation:

Copy
SELECT 
    site_name,
    COUNT(DISTINCT equipment_id) as equipment_deployed
FROM equipment_assignment
WHERE end_datetime IS NULL
GROUP BY site_name;
Target: Balanced distribution

Update: Real-time

4.11 Operators Assigned per Site (PER-011)
Definition: Operator count at each site

Calculation:

Copy
SELECT 
    site_name,
    COUNT(DISTINCT operator_id) as operators_assigned
FROM equipment_assignment
WHERE end_datetime IS NULL
GROUP BY site_name;
Target: 1 operator per 1-2 equipment

Update: Real-time

4.12 Total Fuel Liters Consumed (PER-012)
Definition: Total fuel volume consumed

Calculation:

Copy
SELECT SUM(quantity_liters) FROM fuel_consumption;
Purpose: Track usage patterns and environmental impact

Update: Daily

4.13 Fuel Cost Category (PER-013)
Definition: Classification based on fuel expenditure

Calculation:

Copy
Fuel Cost Category = 
    CASE 
        WHEN total_cost ≥1000 THEN 'HIGH FUEL COST'
        WHEN total_cost ≥500 THEN 'MODERATE FUEL COST'
        ELSE 'LOW FUEL COST'
    END
Target: Minimize HIGH COST category

Update: Daily

4.14 Fuel Efficiency (PER-014)
Definition: Liters consumed per operating hour

Calculation:

Copy
Fuel Efficiency = Total Liters / Total Operating Hours
Target: Minimize consumption

Update: Weekly

4.15 Resource Utilization by Site (PER-015)
Definition: Comprehensive site resource metrics

Calculation:

Copy
SELECT 
    site_name,
    equipment_deployed,
    operators_assigned,
    active_assignments,
    activity_level
FROM v_site_resource_usage;
Purpose: Optimize resource allocation across sites

Update: Real-time

5. KPI Summary Matrix
KPI ID	KPI Name	Category	Target	Current	Status
EXE-001	Total Equipment	Baseline	N/A	36	ℹ️
EXE-002	Available Equipment	Operational	≥30%	47.2%	🟢
EXE-003	Equipment In Use	Operational	60-80%	0%	🔴
EXE-004	Active Operators	HR	≥80%	88.9%	🟢
EXE-005	Utilization Rate	Efficiency	≥70%	0%	🔴
EXE-006	Total Fuel Cost	Financial	Budget	$16,207	🟡
EXE-007	Total Downtime	Efficiency	<100hrs	157hrs	🟠
EXE-008	System Health	Composite	GOOD+	POOR	🔴
COM-001	Compliance Rate	Compliance	100%	0%	🔴*
COM-002	Violation Rate	Compliance	0%	100%	🔴*
COM-005	Today's Violations	Compliance	0	5	🟠
PER-005	Maintenance Rate	Maintenance	≥95%	TBD	⏳
*Test environment - expected behavior

6. Thresholds & Targets
6.1 Critical KPIs (Immediate Action Required)
KPI	Critical Threshold	Action
Equipment Utilization	<30%	Immediate review
Compliance Rate	<95%	Investigation
Downtime Hours	>200hrs	Emergency maintenance
Today's Violations	>5	Security alert
6.2 Warning KPIs (Attention Needed)
KPI	Warning Threshold	Action
Equipment Utilization	30-50%	Performance review
Compliance Rate	95-98%	Training needed
Downtime Hours	150-200hrs	Preventive action
Fuel Cost	>Budget +10%	Cost analysis
6.3 Target KPIs (Optimal Performance)
KPI	Target Threshold	Status
Equipment Utilization	≥70%	Optimal
Compliance Rate	100%	Perfect
Downtime Hours	<100hrs	Excellent
Maintenance Completion	≥95%	Excellent
7. Update Frequencies
Frequency	KPIs	Purpose
Real-time	EXE-001 to EXE-005, COM-001 to COM-005	Immediate monitoring
Daily	EXE-006, EXE-007, PER-001 to PER-015	Operational tracking
Weekly	PER-009, PER-014	Trend analysis
Monthly	EXE-009	Strategic planning
8. KPI Usage Guidelines
8.1 Daily Monitoring
Focus: Equipment Utilization, Today's Violations, System Health

Action: Review and address red/yellow alerts

8.2 Weekly Review
Focus: Department Performance, Maintenance Rate, Fuel Trends

Action: Identify trends, plan corrective actions

8.3 Monthly Analysis
Focus: Monthly Trends, Cost per Hour, Site Activity

Action: Strategic planning and resource allocation

9. Conclusion
This KPI framework provides comprehensive monitoring across all operational dimensions:

✅ 35+ KPIs across 5 categories

✅ Real-time monitoring for critical metrics

✅ Clear thresholds and targets

✅ Actionable insights for management

✅ Comprehensive coverage of operations

Key Success Metrics:
Equipment Utilization Rate (Primary)
Overall Compliance Rate (Critical)
System Health Status (Composite)
Maintenance Completion Rate (Operational)
Document Control:

Version	Date	Author	Changes
1.0	Dec 8, 2024	[Your Name]	Initial KPI definitions
End of KPI Definitions Document