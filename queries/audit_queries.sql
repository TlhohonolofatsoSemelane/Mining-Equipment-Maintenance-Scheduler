-- ============================================
-- AUDIT QUERIES
-- Mining Equipment Management System
-- ============================================

-- Audit Query 1: All Audit Log Entries (Recent First)
SELECT 
    audit_id,
    username,
    table_name,
    action,
    timestamp,
    status,
    error_message,
    CASE 
        WHEN status = 'SUCCESS' THEN '✓'
        ELSE '✗'
    END as status_icon
FROM audit_log
ORDER BY timestamp DESC;

-- Audit Query 2: Failed Operations Summary
SELECT 
    table_name,
    action,
    COUNT(*) as failure_count,
    COUNT(DISTINCT username) as affected_users,
    MIN(timestamp) as first_failure,
    MAX(timestamp) as last_failure,
    LISTAGG(DISTINCT error_message, '; ') WITHIN GROUP (ORDER BY error_message) as error_messages
FROM audit_log
WHERE status = 'DENIED'
GROUP BY table_name, action
ORDER BY failure_count DESC;

-- Audit Query 3: User Activity Summary
SELECT 
    username,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful_ops,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied_ops,
    COUNT(CASE WHEN action = 'INSERT' THEN 1 END) as inserts,
    COUNT(CASE WHEN action = 'UPDATE' THEN 1 END) as updates,
    COUNT(CASE WHEN action = 'DELETE' THEN 1 END) as deletes,
    COUNT(CASE WHEN action = 'SELECT' THEN 1 END) as selects,
    MIN(timestamp) as first_activity,
    MAX(timestamp) as last_activity,
    ROUND(
        COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) * 100.0 / 
        COUNT(*), 
        2
    ) as success_rate
FROM audit_log
GROUP BY username
ORDER BY total_operations DESC;

-- Audit Query 4: Operations by Table
SELECT 
    table_name,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN action = 'INSERT' THEN 1 END) as inserts,
    COUNT(CASE WHEN action = 'UPDATE' THEN 1 END) as updates,
    COUNT(CASE WHEN action = 'DELETE' THEN 1 END) as deletes,
    COUNT(CASE WHEN action = 'SELECT' THEN 1 END) as selects,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied,
    ROUND(
        COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) * 100.0 / 
        COUNT(*), 
        2
    ) as success_rate
FROM audit_log
GROUP BY table_name
ORDER BY total_operations DESC;

-- Audit Query 5: Weekend Violations
SELECT 
    audit_id,
    username,
    table_name,
    action,
    timestamp,
    TO_CHAR(timestamp, 'DY') as day_of_week,
    error_message
FROM audit_log
WHERE TO_CHAR(timestamp, 'DY') IN ('SAT', 'SUN')
  AND status = 'DENIED'
ORDER BY timestamp DESC;

-- Audit Query 6: After-Hours Operations
SELECT 
    audit_id,
    username,
    table_name,
    action,
    timestamp,
    TO_CHAR(timestamp, 'HH24:MI:SS') as time_of_day,
    status,
    error_message,
    CASE 
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) BETWEEN 0 AND 5 THEN 'LATE NIGHT (00:00-05:59)'
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) BETWEEN 6 AND 8 THEN 'EARLY MORNING (06:00-08:59)'
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) BETWEEN 18 AND 21 THEN 'EVENING (18:00-21:59)'
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) BETWEEN 22 AND 23 THEN 'LATE EVENING (22:00-23:59)'
        ELSE 'BUSINESS HOURS'
    END as time_category
FROM audit_log
WHERE TO_NUMBER(TO_CHAR(timestamp, 'HH24')) NOT BETWEEN 9 AND 17
ORDER BY timestamp DESC;

-- Audit Query 7: Daily Audit Summary
SELECT 
    TO_CHAR(timestamp, 'YYYY-MM-DD') as audit_date,
    TO_CHAR(timestamp, 'Day') as day_name,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied,
    COUNT(DISTINCT username) as unique_users,
    COUNT(DISTINCT table_name) as tables_accessed,
    ROUND(
        COUNT(CASE WHEN status = 'DENIED' THEN 1 END) * 100.0 / 
        COUNT(*), 
        2
    ) as violation_rate
FROM audit_log
GROUP BY TO_CHAR(timestamp, 'YYYY-MM-DD'), TO_CHAR(timestamp, 'Day')
ORDER BY TO_CHAR(timestamp, 'YYYY-MM-DD') DESC;

-- Audit Query 8: Compliance Status by Table
SELECT 
    table_name,
    COUNT(*) as total_operations,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as compliant_operations,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as violations,
    ROUND(
        COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) * 100.0 / 
        COUNT(*), 
        2
    ) as compliance_rate,
    CASE 
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) = 0 THEN 'FULLY COMPLIANT'
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) <= 2 THEN 'MOSTLY COMPLIANT'
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) <= 5 THEN 'NEEDS ATTENTION'
        ELSE 'CRITICAL VIOLATIONS'
    END as compliance_status
FROM audit_log
GROUP BY table_name
ORDER BY compliance_rate ASC;

-- Audit Query 9: Recent Violations (Last 7 Days)
SELECT 
    audit_id,
    username,
    table_name,
    action,
    timestamp,
    error_message,
    TRUNC(SYSDATE - timestamp) as days_ago,
    CASE 
        WHEN TO_CHAR(timestamp, 'DY') IN ('SAT', 'SUN') THEN 'WEEKEND VIOLATION'
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) NOT BETWEEN 6 AND 22 THEN 'OFF-HOURS VIOLATION'
        ELSE 'BUSINESS HOURS VIOLATION'
    END as violation_type
FROM audit_log
WHERE status = 'DENIED'
  AND timestamp >= SYSDATE - 7
ORDER BY timestamp DESC;

-- Audit Query 10: Suspicious Activity Detection
SELECT 
    username,
    table_name,
    COUNT(*) as failed_attempts,
    MIN(timestamp) as first_attempt,
    MAX(timestamp) as last_attempt,
    ROUND((MAX(timestamp) - MIN(timestamp)) * 24 * 60, 2) as time_span_minutes,
    LISTAGG(DISTINCT action, ', ') WITHIN GROUP (ORDER BY action) as attempted_actions,
    CASE 
        WHEN COUNT(*) >= 5 THEN 'HIGH RISK'
        WHEN COUNT(*) >= 3 THEN 'MODERATE RISK'
        ELSE 'LOW RISK'
    END as risk_level
FROM audit_log
WHERE status = 'DENIED'
GROUP BY username, table_name
HAVING COUNT(*) >= 2
ORDER BY failed_attempts DESC, last_attempt DESC;

-- Audit Query 11: Action Type Distribution
SELECT 
    action,
    COUNT(*) as total_count,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied,
    ROUND(
        COUNT(*) * 100.0 / 
        (SELECT COUNT(*) FROM audit_log), 
        2
    ) as percentage_of_total,
    ROUND(
        COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) * 100.0 / 
        COUNT(*), 
        2
    ) as success_rate
FROM audit_log
GROUP BY action
ORDER BY total_count DESC;

-- Audit Query 12: Hourly Activity Pattern
SELECT 
    TO_CHAR(timestamp, 'HH24') as hour,
    COUNT(*) as operation_count,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied,
    COUNT(DISTINCT username) as unique_users,
    CASE 
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) BETWEEN 9 AND 17 THEN 'BUSINESS HOURS'
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) BETWEEN 6 AND 8 THEN 'EARLY HOURS'
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) BETWEEN 18 AND 22 THEN 'EVENING HOURS'
        ELSE 'OFF HOURS'
    END as time_category
FROM audit_log
GROUP BY TO_CHAR(timestamp, 'HH24')
ORDER BY TO_CHAR(timestamp, 'HH24');

-- Audit Query 13: Compliance Overview Dashboard
SELECT 
    COUNT(*) as total_operations,
    COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) as successful_operations,
    COUNT(CASE WHEN status = 'DENIED' THEN 1 END) as denied_operations,
    COUNT(DISTINCT username) as total_users,
    COUNT(DISTINCT table_name) as tables_accessed,
    ROUND(
        COUNT(CASE WHEN status = 'SUCCESS' THEN 1 END) * 100.0 / 
        COUNT(*), 
        2
    ) as overall_compliance_rate,
    COUNT(CASE WHEN TO_CHAR(timestamp, 'DY') IN ('SAT', 'SUN') AND status = 'DENIED' THEN 1 END) as weekend_violations,
    COUNT(CASE WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) NOT BETWEEN 6 AND 22 AND status = 'DENIED' THEN 1 END) as after_hours_violations,
    CASE 
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) = 0 THEN 'PERFECT COMPLIANCE'
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) <= 5 THEN 'GOOD COMPLIANCE'
        WHEN COUNT(CASE WHEN status = 'DENIED' THEN 1 END) <= 20 THEN 'NEEDS IMPROVEMENT'
        ELSE 'CRITICAL ISSUES'
    END as compliance_status
FROM audit_log;

-- Audit Query 14: Top Violators
SELECT 
    username,
    COUNT(*) as total_violations,
    COUNT(DISTINCT table_name) as tables_violated,
    COUNT(DISTINCT action) as actions_violated,
    MIN(timestamp) as first_violation,
    MAX(timestamp) as last_violation,
    LISTAGG(DISTINCT table_name, ', ') WITHIN GROUP (ORDER BY table_name) as affected_tables,
    CASE 
        WHEN COUNT(*) >= 10 THEN 'CRITICAL OFFENDER'
        WHEN COUNT(*) >= 5 THEN 'FREQUENT OFFENDER'
        ELSE 'MINOR OFFENDER'
    END as offender_category
FROM audit_log
WHERE status = 'DENIED'
GROUP BY username
ORDER BY total_violations DESC;

-- Audit Query 15: Audit Trail Export (Full Details)
SELECT 
    audit_id,
    username,
    table_name,
    action,
    TO_CHAR(timestamp, 'YYYY-MM-DD HH24:MI:SS') as operation_timestamp,
    status,
    error_message,
    TO_CHAR(timestamp, 'DY') as day_of_week,
    TO_CHAR(timestamp, 'HH24') as hour_of_day,
    CASE 
        WHEN status = 'SUCCESS' THEN 'COMPLIANT'
        WHEN TO_CHAR(timestamp, 'DY') IN ('SAT', 'SUN') THEN 'WEEKEND VIOLATION'
        WHEN TO_NUMBER(TO_CHAR(timestamp, 'HH24')) NOT BETWEEN 6 AND 22 THEN 'OFF-HOURS VIOLATION'
        ELSE 'POLICY VIOLATION'
    END as violation_category
FROM audit_log
ORDER BY timestamp DESC;
