select 
    fa.financial_account_code,
    fa.financial_account_name,
    fa.financial_account_type,
    sum(
        case 
            when t.entry_type='DEBIT' then t.value
            else -t.value
        end
    ) as total_debit
from transaction t
inner join financial_account fa 
    on t.financial_account_code = fa.financial_account_code 
    and t.account_uuid = fa.account_uuid
where 
    t.account_uuid = 'TRP-110126-ABC123' 
    and t.deleted_at IS NULL
group by 
    fa.financial_account_code,
    fa.financial_account_name,
    fa.financial_account_type
order by 
    financial_account_code;

select sum(case when t.entry_type='DEBIT' then t.value else -t.value end) as value
from transaction t
inner join financial_account fa on t.financial_account_code = fa.financial_account_code and t.account_uuid = fa.account_uuid
where t.account_uuid = 'TRP-110126-ABC123' and fa.financial_account_type = 'ASSET' AND t.deleted_at IS NULL;


select fa.financial_account_code, fa.financial_account_name, 
sum(case when t.entry_type='CREDIT' then t.value else -t.value end) as value
from transaction t
inner join financial_account fa on t.financial_account_code = fa.financial_account_code and t.account_uuid = fa.account_uuid
where t.account_uuid = 'TRP-110126-ABC123' and fa.financial_account_type = 'LIABILITY' AND t.deleted_at IS NULL
group by fa.financial_account_code, fa.financial_account_name
order by financial_account_code
;

select fa.financial_account_code, fa.financial_account_name, 
sum(case when t.entry_type='CREDIT' then t.value else -t.value end) as value
from transaction t
inner join financial_account fa on t.financial_account_code = fa.financial_account_code and t.account_uuid = fa.account_uuid
where t.account_uuid = 'TRP-110126-ABC123' and fa.financial_account_type in ('EQUITY', 'REVENUE', 'EXPENSE') AND t.deleted_at IS NULL
group by fa.financial_account_code, fa.financial_account_name
order by financial_account_code
;

select sum(case when t.entry_type='CREDIT' then t.value else -t.value end) as value
from transaction t
inner join financial_account fa on t.financial_account_code = fa.financial_account_code and t.account_uuid = fa.account_uuid
where t.account_uuid = 'TRP-110126-ABC123' and fa.financial_account_type in ('LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE') AND t.deleted_at IS NULL;
				