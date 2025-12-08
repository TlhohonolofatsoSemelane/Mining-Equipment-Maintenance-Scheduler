SET SERVEROUTPUT ON SIZE UNLIMITED;
-- Drop table if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE audit_log CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('✓ Dropped existing audit_log table');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ℹ No existing table to drop');
END;
/

-- Drop sequence if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE audit_log_seq';
    DBMS_OUTPUT.PUT_LINE('✓ Dropped existing sequence');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ℹ No existing sequence to drop');
END;
/

-- Create Audit Log Table
CREATE TABLE audit_log (
    audit_id NUMBER PRIMARY KEY,
    table_name VARCHAR2(50) NOT NULL,
    operation_type VARCHAR2(10) NOT NULL CHECK (operation_type IN ('INSERT', 'UPDATE', 'DELETE')),
    operation_status VARCHAR2(20) DEFAULT 'ALLOWED' CHECK (operation_status IN ('ALLOWED', 'DENIED', 'ERROR')),
    record_id NUMBER,
    old_values CLOB,
    new_values CLOB,
    denial_reason VARCHAR2(500),
    username VARCHAR2(50) DEFAULT USER,
    user_ip VARCHAR2(50),
    session_id NUMBER,
    operation_date DATE DEFAULT SYSDATE,
    operation_timestamp TIMESTAMP DEFAULT SYSTIMESTAMP,
    day_of_week VARCHAR2(20),
    is_weekend CHAR(1),
    is_holiday CHAR(1),
    error_code VARCHAR2(20),
    error_message VARCHAR2(500)
);

-- Create sequence for audit_id
CREATE SEQUENCE audit_log_seq
    START WITH 1
    INCREMENT BY 1
    CACHE 100
    NOCYCLE;

-- Create indexes for performance
CREATE INDEX idx_audit_table_name ON audit_log(table_name);
CREATE INDEX idx_audit_operation_date ON audit_log(operation_date);
CREATE INDEX idx_audit_username ON audit_log(username);
CREATE INDEX idx_audit_status ON audit_log(operation_status);
CREATE INDEX idx_audit_operation_type ON audit_log(operation_type);

DESC audit_log;