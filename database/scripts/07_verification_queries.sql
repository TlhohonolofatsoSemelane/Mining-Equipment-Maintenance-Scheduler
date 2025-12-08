SELECT 'PDB STATUS' AS check, name, open_mode FROM v$pdbs 
WHERE name = 'MON_27293_SEMELANE_MININGEQUIPMENTMS_DB';

SELECT 'TABLESPACES' AS check, tablespace_name, status FROM dba_tablespaces 
WHERE tablespace_name LIKE 'MINING%';

SELECT 'USER STATUS' AS check, username, account_status FROM dba_users 
WHERE username = 'MINING_ADMIN';

SELECT 'SEQUENCES' AS check, COUNT(*) AS total FROM user_sequences;