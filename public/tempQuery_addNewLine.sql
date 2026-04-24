select *
from accounting 
where origin_uuid = 'TRL-060426-dHU2c';

select * 
from transaction
where accounting_uuid = 'ACC-070426-ZCtI5';

select * 
from accounting 
where origin_uuid = 'TRL-070426-YfTF8'
order by updated_at desc;

WITH temp AS (
    SELECT *
    FROM transaction
    WHERE transaction_uuid = 'TSC-070426-UrnWP'
)
INSERT INTO transaction (
    transaction_uuid,
    accounting_uuid,
    vehicle_uuid,
    user_uuid,
    financial_account_code,
    entry_type,
    value,
    account_uuid,
    created_at,
    updated_at,
    deleted_at
)
SELECT
    transaction_uuid || 'Up',         -- ubah UUID
    accounting_uuid,
    vehicle_uuid,
    user_uuid,
    '11501',                         -- override value
    entry_type,
    value,
    account_uuid,
    created_at,
    updated_at,
    deleted_at
FROM temp;