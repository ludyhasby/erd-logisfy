SELECT trip_payment_driver_uuid, trip_load_uuid, sequence, amount, trigger, status, notes, proof, account_uuid, created_at, updated_at, deleted_at
	FROM public.trip_payment_driver;

select * from trip_payment_driver
where trip_payment_driver_uuid = 'TPD-110326-dtrEr';

select * from accounting
where value = 4000000 and origin_uuid = 'TRL-110326-7uqmo';

select * from transaction 
where accounting_uuid = 'ACC-110326-ey47o';