-- Equipment indexes
CREATE INDEX idx_equip_type ON EQUIPMENT(EQUIPMENT_TYPE) TABLESPACE mining_indexes;
CREATE INDEX idx_equip_status ON EQUIPMENT(STATUS) TABLESPACE mining_indexes;
CREATE INDEX idx_equip_dept ON EQUIPMENT(DEPARTMENT_ID) TABLESPACE mining_indexes;

-- Operator indexes
CREATE INDEX idx_op_status ON OPERATORS(STATUS) TABLESPACE mining_indexes;
CREATE INDEX idx_op_dept ON OPERATORS(DEPARTMENT_ID) TABLESPACE mining_indexes;

-- Assignment indexes
CREATE INDEX idx_assign_date ON EQUIPMENT_ASSIGNMENT(ASSIGNMENT_DATE) TABLESPACE mining_indexes;
CREATE INDEX idx_assign_equip ON EQUIPMENT_ASSIGNMENT(EQUIPMENT_ID) TABLESPACE mining_indexes;
CREATE INDEX idx_assign_op ON EQUIPMENT_ASSIGNMENT(OPERATOR_ID) TABLESPACE mining_indexes;
CREATE INDEX idx_assign_site ON EQUIPMENT_ASSIGNMENT(SITE_ID) TABLESPACE mining_indexes;

-- Usage log indexes (important for BI queries)
CREATE INDEX idx_usage_date ON EQUIPMENT_USAGE_LOG(LOG_DATE) TABLESPACE mining_indexes;
CREATE INDEX idx_usage_equip ON EQUIPMENT_USAGE_LOG(EQUIPMENT_ID) TABLESPACE mining_indexes;
CREATE INDEX idx_usage_site ON EQUIPMENT_USAGE_LOG(SITE_ID) TABLESPACE mining_indexes;

-- Maintenance indexes
CREATE INDEX idx_maint_date ON MAINTENANCE_SCHEDULE(SCHEDULED_DATE) TABLESPACE mining_indexes;
CREATE INDEX idx_maint_equip ON MAINTENANCE_SCHEDULE(EQUIPMENT_ID) TABLESPACE mining_indexes;
CREATE INDEX idx_hist_equip ON MAINTENANCE_HISTORY(EQUIPMENT_ID) TABLESPACE mining_indexes;

-- Downtime indexes
CREATE INDEX idx_down_equip ON DOWNTIME_RECORDS(EQUIPMENT_ID) TABLESPACE mining_indexes;
CREATE INDEX idx_down_type ON DOWNTIME_RECORDS(DOWNTIME_TYPE) TABLESPACE mining_indexes;

-- Audit log index
CREATE INDEX idx_audit_date ON AUDIT_LOG(OPERATION_DATE) TABLESPACE mining_indexes;
CREATE INDEX idx_audit_table ON AUDIT_LOG(TABLE_NAME) TABLESPACE mining_indexes;