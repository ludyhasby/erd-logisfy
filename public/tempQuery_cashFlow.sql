select a.description, a.accounting_uuid, fa.financial_account_code, fa.financial_account_name, t.entry_type, t.value
from transaction t
join financial_account fa on t.financial_account_code = fa.financial_account_code and t.account_uuid = fa.account_uuid
join accounting a on t.accounting_uuid = a.accounting_uuid and t.account_uuid = a.account_uuid
where fa.financial_account_category = 'CASH_BANK'
order by a.accounting_uuid, a.created_at desc;

select distinct from_table 
from accounting;

select t.financial_account_code, a.description
from accounting a
join transaction t on a.accounting_uuid = t.accounting_uuid
join financial_account fa on t.financial_account_code = fa.financial_account_code and t.account_uuid = fa.account_uuid
where from_table = 'close_book' and fa.financial_account_category = 'CASH_BANK';

-- accrued_salaries (kas berkurang, bayar piutang sopir) -> Operating (Pengeluaran atas Gaji Sopir Tertahan)
-- vehicle_expense (pengeluaran terkait beban kendaraan) -> Operating (Pengeluaran atas Beban Kendaraan)
-- reimbursement (pengeluaran terkait beban kendaraan yang di tangguhkan (dibayarkan dulu) oleh sopir ) -> Operating (Pembayaran Reimbursement Sopir)
-- trip_log_payment (penerimaan uang dari vendor atas muatan / biaya trip) -> Operating (Pendapatan dari Vendor)
-- trip_payment_driver (pembayaran atas uang jalan / gaji sopir) -> Operating (Pengeluaran atas Uang Jalan / Gaji Sopir)
-- vehicle (pengeluaran uang muka atas tambah asset, yaitu kendaraan) -> Investing -> (Pengeluaran Uang Muka Asset Kendaran)
-- vehicle_isntallment (pengeluaran terkait pembayaran angsuran) -> Fianancing (Pembayaran atas Angsuran Kendaran)


select date(a.created_at) as created_at, 
a.accounting_uuid, a.description, 
fa.financial_account_name, t.entry_type, t.value, 
case 
	when a.from_table in (
		'accrued_salaries', 
		'vehicle_expense', 
		'reimbursement', 
		'trip_log_payment', 
		'trip_payment_driver'
	) then 'OPERATING'
	when a.from_table = 'vehicle' then 'INVESTING'
	when a.from_table = 'vehicle_installment' then 'FINANCING'
end as cash_flow_type, 
case 
	when a.from_table = 'accrued_salaries' then 'Pengeluaran atas Gaji Sopir Tertahan'
	when a.from_table = 'vehicle_expense' then 'Pengeluaran atas Beban Kendaraan'
	when a.from_table = 'reimbursement' then 'Pengeluaran atas Reimbursement Sopir'
	when a.from_table = 'trip_log_payment' then 'Pendapatan dari Vendor'
	when a.from_table = 'trip_payment_driver' then 'Pengeluaran atas Uang Jalan / Gaji Sopir'
	when a.from_table = 'vehicle' then 'Pengeluaran Uang Muka Asset Kendaran'
	when a.from_table = 'vehicle_installment' then 'Pembayaran atas Angsuran Kendaran'
end as cash_flow_category
from transaction t
join financial_account fa on t.financial_account_code = fa.financial_account_code and t.account_uuid = fa.account_uuid
join accounting a on t.accounting_uuid = a.accounting_uuid and t.account_uuid = a.account_uuid
where fa.financial_account_category = 'CASH_BANK' and a.from_table != ''
order by cash_flow_type, a.from_table, a.created_at asc
union
with other2 as (
WITH other AS (
    SELECT 
        a.accounting_uuid, 
        a.account_uuid, 
        a.description, 
        t.transaction_uuid , 
        a.created_at 
    FROM transaction t 
    JOIN financial_account fa 
        ON t.financial_account_code = fa.financial_account_code 
        AND t.account_uuid = fa.account_uuid 
    JOIN accounting a 
        ON t.accounting_uuid = a.accounting_uuid 
        AND t.account_uuid = a.account_uuid 
    WHERE fa.financial_account_category = 'CASH_BANK' 
      AND a.from_table NOT IN (
          'accrued_salaries', 
          'vehicle_expense', 
          'reimbursement', 
          'trip_log_payment', 
          'trip_payment_driver', 
          'vehicle', 
          'vehicle_installment'
      ) 
      AND t.deleted_at IS NULL
)
SELECT 
	date(o.created_at) as created_at, 
	o.accounting_uuid, 
	o.description, 
    fa.financial_account_name,
    t.entry_type, 
    t.value,
    case
    	when fa.financial_account_category = 'CURRENT_ASSET' then 'FINANCING'
    	when fa.financial_account_category = 'FIXED_ASSET' then 'INVESTING'
    	when fa.financial_account_type = 'LIABILITY' then 'FINANCING'
    	when fa.financial_account_category = 'EQUITY' then 'FINANCING'
    	when fa.financial_account_type = 'REVENUE' then 'OPERATING'
    	when fa.financial_account_type = 'EXPENSE' then 'OPERATING'
    end as cash_flow_type, 
    'Lainnya' as cash_flow_category, 
    o.account_uuid
FROM other o 
JOIN transaction t 
    ON o.accounting_uuid = t.accounting_uuid 
    AND o.account_uuid = t.account_uuid
JOIN financial_account fa 
    ON t.financial_account_code = fa.financial_account_code 
    AND t.account_uuid = fa.account_uuid
WHERE fa.financial_account_category != 'CASH_BANK' AND t.deleted_at IS NULL
ORDER BY t.accounting_uuid, t.value desc
)
select distinct o2.created_at, 
	o2.accounting_uuid, 
	o2.description, 
    fa.financial_account_name,
    t.entry_type, 
    t.value,
    o2.cash_flow_type, 
    o2.cash_flow_category
from other2 o2
JOIN transaction t 
    ON o2.accounting_uuid = t.accounting_uuid 
    AND o2.account_uuid = t.account_uuid
JOIN financial_account fa 
    ON t.financial_account_code = fa.financial_account_code 
    AND t.account_uuid = fa.account_uuid
where fa.financial_account_category = 'CASH_BANK';



select distinct financial_account_type, financial_account_category


from financial_account
order by financial_account_type, financial_account_category;


WITH base AS (
    SELECT 
        date(a.created_at) AS created_at,
        a.accounting_uuid,
        a.account_uuid,
        a.description,
        a.from_table,
        t.entry_type,
        t.value,
        fa.financial_account_name,
        fa.financial_account_category,
        fa.financial_account_type
    FROM transaction t
    JOIN accounting a 
        ON t.accounting_uuid = a.accounting_uuid 
        AND t.account_uuid = a.account_uuid
    JOIN financial_account fa 
        ON t.financial_account_code = fa.financial_account_code 
        AND t.account_uuid = fa.account_uuid
    WHERE 
        t.deleted_at IS NULL
),

classified AS (
    SELECT *,
        -- CASH FLOW TYPE
        CASE 
            -- PRIORITY: mapping explicit from_table
            WHEN from_table IN (
                'accrued_salaries', 
                'vehicle_expense', 
                'reimbursement', 
                'trip_log_payment', 
                'trip_payment_driver'
            ) THEN 'OPERATING'

            WHEN from_table = 'vehicle' THEN 'INVESTING'
            WHEN from_table = 'vehicle_installment' THEN 'FINANCING'

            -- FALLBACK mapping
            WHEN financial_account_category = 'FIXED_ASSET' THEN 'INVESTING'
            WHEN financial_account_category IN ('CURRENT_ASSET', 'EQUITY') THEN 'FINANCING'
            WHEN financial_account_type = 'LIABILITY' THEN 'FINANCING'
            WHEN financial_account_type IN ('REVENUE', 'EXPENSE') THEN 'OPERATING'

            ELSE 'OPERATING'
        END AS cash_flow_type,

        -- CASH FLOW CATEGORY
        CASE 
            WHEN from_table = 'accrued_salaries' THEN 'Pengeluaran atas Gaji Sopir Tertahan'
            WHEN from_table = 'vehicle_expense' THEN 'Pengeluaran atas Beban Kendaraan'
            WHEN from_table = 'reimbursement' THEN 'Pengeluaran atas Reimbursement Sopir'
            WHEN from_table = 'trip_log_payment' THEN 'Pendapatan dari Vendor'
            WHEN from_table = 'trip_payment_driver' THEN 'Pengeluaran atas Uang Jalan / Gaji Sopir'
            WHEN from_table = 'vehicle' THEN 'Pengeluaran Uang Muka Asset Kendaraan'
            WHEN from_table = 'vehicle_installment' THEN 'Pembayaran atas Angsuran Kendaraan'
            ELSE 'Lainnya'
        END AS cash_flow_category
    FROM base
)

SELECT 
    created_at,
    accounting_uuid,
    description,
    financial_account_name,
    entry_type,
    value,
    cash_flow_type,
    cash_flow_category
FROM classified
WHERE financial_account_category = 'CASH_BANK'
ORDER BY cash_flow_type, cash_flow_category, created_at;


WITH base AS (
    SELECT 
        a.from_table,
        t.entry_type,
        t.value,
        fa.financial_account_category,
        fa.financial_account_type
    FROM transaction t
    JOIN accounting a 
        ON t.accounting_uuid = a.accounting_uuid 
        AND t.account_uuid = a.account_uuid
    JOIN financial_account fa 
        ON t.financial_account_code = fa.financial_account_code 
        AND t.account_uuid = fa.account_uuid
    WHERE t.deleted_at IS NULL
),
classified AS (
    SELECT
        CASE 
            WHEN from_table IN (
                'accrued_salaries', 
                'vehicle_expense', 
                'reimbursement', 
                'trip_log_payment', 
                'trip_payment_driver'
            ) THEN 'OPERATING'
            WHEN from_table = 'vehicle' THEN 'INVESTING'
            WHEN from_table = 'vehicle_installment' THEN 'FINANCING'
            WHEN financial_account_category = 'FIXED_ASSET' THEN 'INVESTING'
            WHEN financial_account_category IN ('CURRENT_ASSET', 'EQUITY') THEN 'FINANCING'
            WHEN financial_account_type = 'LIABILITY' THEN 'FINANCING'
            WHEN financial_account_type IN ('REVENUE', 'EXPENSE') THEN 'OPERATING'
            ELSE 'OPERATING'
        END AS cash_flow_type,
        CASE 
            WHEN from_table = 'accrued_salaries' THEN 'Pengeluaran atas Gaji Sopir Tertahan'
            WHEN from_table = 'vehicle_expense' THEN 'Pengeluaran atas Beban Kendaraan'
            WHEN from_table = 'reimbursement' THEN 'Pengeluaran atas Reimbursement Sopir'
            WHEN from_table = 'trip_log_payment' THEN 'Pendapatan dari Vendor'
            WHEN from_table = 'trip_payment_driver' THEN 'Pengeluaran atas Uang Jalan / Gaji Sopir'
            WHEN from_table = 'vehicle' THEN 'Pengeluaran Uang Muka Asset Kendaraan'
            WHEN from_table = 'vehicle_installment' THEN 'Pembayaran atas Angsuran Kendaraan'
            ELSE 'Lainnya'
        END AS cash_flow_category,
        entry_type,
        value,
        financial_account_category
    FROM base
)
SELECT
    cash_flow_type,
    cash_flow_category,
    SUM(CASE WHEN entry_type = 'DEBIT' THEN value ELSE 0 END) AS total_in,
    SUM(CASE WHEN entry_type = 'CREDIT' THEN value ELSE 0 END) AS total_out,
    SUM(CASE WHEN entry_type = 'DEBIT' THEN value ELSE -value END) AS net
FROM classified
WHERE financial_account_category = 'CASH_BANK'
GROUP BY cash_flow_type, cash_flow_category
ORDER BY 
    CASE cash_flow_type
        WHEN 'OPERATING' THEN 1
        WHEN 'INVESTING' THEN 2
        WHEN 'FINANCING' THEN 3
        ELSE 4
    END,
    cash_flow_category;



WITH base AS (
    SELECT 
        a.from_table,
        t.entry_type,
        t.value,
        fa.financial_account_category,
        fa.financial_account_type
    FROM transaction t
    JOIN accounting a 
        ON t.accounting_uuid = a.accounting_uuid 
       AND t.account_uuid = a.account_uuid
    JOIN financial_account fa 
        ON t.financial_account_code = fa.financial_account_code 
       AND t.account_uuid = fa.account_uuid
    WHERE t.deleted_at IS NULL
),
classified AS (
    SELECT
        CASE 
            WHEN from_table IN (
                'accrued_salaries', 
                'vehicle_expense', 
                'reimbursement', 
                'trip_log_payment', 
                'trip_payment_driver'
            ) THEN 'OPERATING'
            WHEN from_table = 'vehicle' THEN 'INVESTING'
            WHEN from_table = 'vehicle_installment' THEN 'FINANCING'
            WHEN financial_account_category = 'FIXED_ASSET' THEN 'INVESTING'
            WHEN financial_account_category IN ('CURRENT_ASSET', 'EQUITY') THEN 'FINANCING'
            WHEN financial_account_type = 'LIABILITY' THEN 'FINANCING'
            WHEN financial_account_type IN ('REVENUE', 'EXPENSE') THEN 'OPERATING'
            ELSE 'OPERATING'
        END AS cash_flow_type,
        CASE 
            WHEN from_table = 'accrued_salaries' THEN 'atas Gaji Sopir Tertahan'
            WHEN from_table = 'vehicle_expense' THEN 'atas Beban Kendaraan'
            WHEN from_table = 'reimbursement' THEN 'atas Reimbursement Sopir'
            WHEN from_table = 'trip_log_payment' THEN 'dari Vendor'
            WHEN from_table = 'trip_payment_driver' THEN 'atas Uang Jalan / Gaji Sopir'
            WHEN from_table = 'vehicle' THEN 'Uang Muka Asset Kendaraan'
            WHEN from_table = 'vehicle_installment' THEN 'atas Angsuran Kendaraan'
            ELSE 'Lainnya'
        END AS cash_flow_category,
        entry_type,
        value,
        financial_account_category
    FROM base
),
aggregated AS (
    SELECT
        cash_flow_type,
        cash_flow_category,
        SUM(CASE WHEN entry_type = 'DEBIT'  THEN value ELSE 0 END) AS total_in,
        SUM(CASE WHEN entry_type = 'CREDIT' THEN value ELSE 0 END) AS total_out
    FROM classified
    WHERE financial_account_category = 'CASH_BANK'
    GROUP BY cash_flow_type, cash_flow_category
),
final_rows AS (
    SELECT
        cash_flow_type,
        'Pendapatan ' || cash_flow_category AS cash_flow_category,
        total_in AS amount,
        1 AS row_type,
        CASE cash_flow_type
            WHEN 'OPERATING' THEN 1
            WHEN 'INVESTING' THEN 2
            WHEN 'FINANCING' THEN 3
            ELSE 4
        END AS type_order
    FROM aggregated
    WHERE total_in > 0

    UNION ALL

    SELECT
        cash_flow_type,
        'Pengeluaran ' || cash_flow_category AS cash_flow_category,
        -total_out AS amount,
        2 AS row_type,
        CASE cash_flow_type
            WHEN 'OPERATING' THEN 1
            WHEN 'INVESTING' THEN 2
            WHEN 'FINANCING' THEN 3
            ELSE 4
        END AS type_order
    FROM aggregated
    WHERE total_out > 0
)
SELECT
    cash_flow_type,
    cash_flow_category,
    amount
FROM final_rows
ORDER BY
    type_order,
    cash_flow_type,
    cash_flow_category,
    row_type;
    
    
SELECT 
    COALESCE(SUM(
        CASE 
            WHEN t.entry_type = 'DEBIT' THEN t.value
            WHEN t.entry_type = 'CREDIT' THEN -t.value
            ELSE 0
        END
    ), 0) AS opening_balance
FROM transaction t
JOIN financial_account fa 
    ON t.financial_account_code = fa.financial_account_code 
   AND t.account_uuid = fa.account_uuid
WHERE 
    fa.financial_account_category = 'CASH_BANK'
    AND t.deleted_at IS NULL
    AND t.account_uuid = 'TRP-110126-ABC123'

