SET SERVEROUTPUT ON SIZE UNLIMITED;
-- Drop table if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE public_holidays CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('✓ Dropped existing public_holidays table');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ℹ No existing table to drop');
END;
/
-- Drop sequence if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE public_holidays_seq';
    DBMS_OUTPUT.PUT_LINE('✓ Dropped existing sequence');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ℹ No existing sequence to drop');
END;
/
-- Public Holidays Table
CREATE TABLE public_holidays (
    holiday_id NUMBER PRIMARY KEY,
    holiday_date DATE NOT NULL UNIQUE,
    holiday_name VARCHAR2(100) NOT NULL,
    holiday_type VARCHAR2(50) DEFAULT 'National',
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    created_date DATE DEFAULT SYSDATE,
    created_by VARCHAR2(50) DEFAULT USER
);

-- sequence for holiday_id
CREATE SEQUENCE public_holidays_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Public Holidays for 2025
INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-01-01', 'New Year Day', 'National');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-02-01', 'National Heroes Day', 'National');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-04-07', 'Genocide Memorial Day', 'National');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-04-18', 'Good Friday', 'Religious');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-04-21', 'Easter Monday', 'Religious');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-05-01', 'Labour Day', 'National');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-07-01', 'Independence Day', 'National');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-07-04', 'Liberation Day', 'National');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-08-15', 'Assumption Day', 'Religious');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-12-25', 'Christmas Day', 'Religious');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2025-12-26', 'Boxing Day', 'National');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2024-12-15', 'Test Holiday 1', 'Testing');

INSERT INTO public_holidays (holiday_id, holiday_date, holiday_name, holiday_type)
VALUES (public_holidays_seq.NEXTVAL, DATE '2024-12-20', 'Test Holiday 2', 'Testing');

COMMIT;
-- Display holidays
SELECT 
    holiday_id,
    TO_CHAR(holiday_date, 'DD-MON-YYYY') as holiday_date,
    TO_CHAR(holiday_date, 'DAY') as day_name,
    holiday_name,
    holiday_type,
    is_active
FROM public_holidays
ORDER BY holiday_date;
SELECT 
    holiday_type,
    COUNT(*) as total_holidays
FROM public_holidays
WHERE is_active = 'Y'
GROUP BY holiday_type
ORDER BY total_holidays DESC;