select * from 
financial_account
where account_uuid = 'TRP-110126-ABC123'
order by financial_account_code;

select * 
from transaction;

UPDATE financial_account
SET financial_account_code = CASE financial_account_code
    WHEN '1101' THEN '11001'
    WHEN '1102' THEN '11501'
    WHEN '1103' THEN '11502'
	WHEN '1104' THEN '11503'
    WHEN '1201' THEN '13001'
    WHEN '1202' THEN '13002'
    WHEN '2101' THEN '21001'
    WHEN '2102' THEN '21002'
	WHEN '2201' THEN '23001'
    WHEN '3001' THEN '31001'
    WHEN '4101' THEN '41001'
    WHEN '5201' THEN '52001'
    WHEN '5202' THEN '52002'
    WHEN '5203' THEN '52003'
    ELSE financial_account_code
END
WHERE financial_account_code IN (
    '1101','1102','1103', '1104',
    '1201','1202',
    '2101','2102', '2201',
    '3001',
    '4101',
    '5201','5202','5203'
);

UPDATE transaction
SET financial_account_code = CASE financial_account_code
    WHEN '1101' THEN '11001'
    WHEN '1102' THEN '11501'
    WHEN '1103' THEN '11502'
	WHEN '1104' THEN '11503'
    WHEN '1201' THEN '13001'
    WHEN '1202' THEN '13002'
    WHEN '2101' THEN '21001'
    WHEN '2102' THEN '21002'
	WHEN '2201' THEN '23001'
    WHEN '3001' THEN '31001'
    WHEN '4101' THEN '41001'
    WHEN '5201' THEN '52001'
    WHEN '5202' THEN '52002'
    WHEN '5203' THEN '52003'
    ELSE financial_account_code
END
WHERE financial_account_code IN (
    '1101','1102','1103', '1104',
    '1201','1202',
    '2101','2102', '2201',
    '3001',
    '4101',
    '5201','5202','5203'
);

