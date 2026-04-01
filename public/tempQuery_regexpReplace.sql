select * 
from accounting
where origin_uuid LIKE '%de1%';

UPDATE accounting
SET origin_uuid = REGEXP_REPLACE(origin_uuid, 'de1.*$', '')
WHERE origin_uuid LIKE '%de1%';