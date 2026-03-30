SELECT 
    e.enumlabel AS enum_value
FROM 
    pg_enum e
JOIN 
    pg_type t ON e.enumtypid = t.oid
WHERE 
    t.typname = 'financial_account_category_enum';

alter type financial_account_category_enum add value 'CASH_BANK';

UPDATE financial_account
set financial_account_category = 'CASH_BANK'
where financial_account_code = '1101';


select * from financial_account;