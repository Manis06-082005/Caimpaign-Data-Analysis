-- CampaignData
CREATE TABLE campaign_data (
    id VARCHAR PRIMARY KEY,
    name TEXT,
    category TEXT,
    intake TEXT,
    university TEXT,
    status TEXT,
    start_date TIMESTAMP
);2

-- OutreachData
CREATE TABLE outreach_data (
    reference_id VARCHAR,
    recieved_at TIMESTAMP,
    university TEXT,
    caller_name TEXT,
    outcome_1 TEXT,
    remark TEXT,
    campaign_id VARCHAR,
    escalation_required TEXT
);

-- ApplicantData
CREATE TABLE applicant_data (
    app_id VARCHAR,
    country TEXT,
    university TEXT,
    phone_number TEXT
);
delete from outreach_data o
using outreach_data b
where
   o.ctid < b.ctid
   AND o. Reference_ID =b.Reference_ID
   and o.recieved_At =b.recieved_At
    and o.University =b.University
   and o.Caller_Name =b.Caller_Name
  and  o.Outcome_1 =b.Outcome_1
   and o.Remark=b.Remark
   and o.Campaign_ID =b.Campaign_ID
   and o.Escalation_Required=b.Escalation_Required
DELETE FROM applicant_data a
USING applicant_data b
WHERE 
  a.ctid < b.ctid
  AND a.App_ID = b.App_ID
  AND a.Country = b.Country
  AND a.University = b.University
  AND a.Phone_Number = b.Phone_Number;

SELECT Reference_ID,
       Recieved_At,
       University,
       Caller_Name,
       Outcome_1,
       Remark,
       Campaign_ID,
       Escalation_Required,
       COUNT(*) AS duplicate_count
FROM outreach_data
GROUP BY Reference_ID,
         Recieved_At,
         University,
         Caller_Name,
         Outcome_1,
         Remark,
         Campaign_ID,
         Escalation_Required
HAVING COUNT(*) > 1;



select distinct outcome_category from master_table




SELECT App_ID,
       Country,
       University,
       Phone_Number,
       COUNT(*) AS duplicate_count
FROM applicant_data
GROUP BY App_ID,
         Country,
         University,
         Phone_Number
HAVING COUNT(*) > 1;








  
select distinct count(App_id) from applicant_data
select Country from applicant_data
UPDATE applicant_data

SET country = REGEXP_REPLACE(
                  REGEXP_REPLACE(country, '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}', 'Unknown', 'g'),
                  '-', 'Unknown', 'g'
              );
select country,count(App_ID) from applicant_data
group by country
UPDATE applicant_data
SET country = CASE 
    -- Standard spellings
    WHEN LOWER(country) IN ('nigeira','nigera','nigeria','na','naq') THEN 'Nigeria'
    WHEN LOWER(country) IN ('mororcco','morocco','morocco,','morocco ') THEN 'Morocco'
    WHEN LOWER(country) IN ('ubekistan','uzbekistan','tazakkistan','tajikistan') THEN 'Uzbekistan'
    WHEN LOWER(country) IN ('ethiopi','ethiopia','ethiopia , italy','ethiopia, italy') THEN 'Ethiopia'
    WHEN LOWER(country) IN ('jamica','jamaica') THEN 'Jamaica'
    WHEN LOWER(country) IN ('nepaal','nepal') THEN 'Nepal'
    WHEN LOWER(country) IN ('columbia','colombia') THEN 'Colombia'
    WHEN LOWER(country) IN ('hk','hong kong','hong kong, china','taiwan, china','taiwan,') THEN 'Hong Kong'
    WHEN LOWER(country) IN ('russia','russian federation','russIa') THEN 'Russia'
    WHEN LOWER(country) IN ('south sudan','sudan','sudan ') THEN 'Sudan'
    WHEN LOWER(country) IN ('uae','united arab emirates') THEN 'United Arab Emirates'
    WHEN LOWER(country) IN ('uk','england','united kingdom') THEN 'United Kingdom'
    WHEN LOWER(country) IN ('usa','united states of america') THEN 'United States'
    WHEN LOWER(country) IN ('south korea','republic of korea') THEN 'South Korea'
    WHEN LOWER(country) IN ('north korea','dprk') THEN 'North Korea'
    WHEN LOWER(country) IN ('cote d ivoire','côte divoire','côte d’ivoire','cote d''ivoire','c�te divoire') THEN 'Côte d''Ivoire'
    WHEN LOWER(country) IN ('brasil','brazil') THEN 'Brazil'
    WHEN LOWER(country) IN ('myanmmar','myanmar') THEN 'Myanmar'
    WHEN LOWER(country) IN ('goban','gabon') THEN 'Gabon'
    WHEN LOWER(country) IN ('behrain','bahrain') THEN 'Bahrain'
    WHEN LOWER(country) IN ('netherland','netherlands') THEN 'Netherlands'
    WHEN LOWER(country) IN ('sri lanka','sri lanka ') THEN 'Sri Lanka'
    WHEN LOWER(country) IN ('congo republic','congo, the democratic republic of the','congo') THEN 'Congo'
    
    -- Non-country / invalid entries → Unknown
    WHEN LOWER(country) IN (
        'finance','personal reason','student wants to change the degree from doctor of philosophy to masters',
        'he got admitted into another university','not able to provide official transcript',
        'not attending illinois tech, going to a higher ranked university','no planes','not connected'
    ) THEN 'Unknown'
    
    ELSE INITCAP(country)  -- Standardize case
END;

UPDATE outreach_data
SET remark = 'No Remark'
WHERE remark = 'NULL'; 




UPDATE applicant_data
SET App_ID = CASE 
    WHEN REGEXP_REPLACE(App_ID, '[^0-9]', '', 'g') = '' 
         THEN 'Unknown'
    ELSE REGEXP_REPLACE(App_ID, '[^0-9]', '', 'g')
END;
-- normalize numeric string: remove non-digits; return 'Unknown' if empty
CREATE OR REPLACE FUNCTION keep_digits_or_unknown(text)
RETURNS text LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE WHEN REGEXP_REPLACE($1::text, '[^0-9]', '', 'g') = 
	'' THEN 'Unknown'
                ELSE REGEXP_REPLACE($1::text, '[^0-9]', '', 'g') END;
$$;






-- normalize country (small mapping + fallback to INITCAP)
CREATE OR REPLACE FUNCTION normalize_country(txt text) RETURNS text LANGUAGE sql IMMUTABLE AS $$
    SELECT CASE
      WHEN txt IS NULL OR btrim(txt) = '' THEN 'Unknown'
      WHEN lower(txt) IN ('nigeira','nigera','na','naq','nigera','nigera') THEN 'Nigeria'
      WHEN lower(txt) IN ('mororcco','morocco','morocco,','morocco ') THEN 'Morocco'
      WHEN lower(txt) IN ('ubekistan','tazakkistan') THEN 'Uzbekistan'
      WHEN lower(txt) LIKE 'ethiopi%' THEN 'Ethiopia'
      WHEN lower(txt) IN ('jamica','jamaica') THEN 'Jamaica'
      WHEN lower(txt) IN ('nepaal') THEN 'Nepal'
      WHEN lower(txt) IN ('columbia') THEN 'Colombia'
      WHEN lower(txt) IN ('hk','hong kong','hong kong, china','taiwan, china','taiwan,') THEN 'Hong Kong'
      WHEN lower(txt) IN ('russia','russian federation','russIa') THEN 'Russia'
      WHEN lower(txt) IN ('south sudan','sudan','sudan ') THEN 'Sudan'
      WHEN lower(txt) IN ('uae','united arab emirates') THEN 'United Arab Emirates'
      WHEN lower(txt) IN ('uk','england','united kingdom') THEN 'United Kingdom'
      WHEN lower(txt) IN ('usa','united states of america') THEN 'United States'
      WHEN lower(txt) IN ('south korea','republic of korea') THEN 'South Korea'
      WHEN lower(txt) IN ('north korea','dprk') THEN 'North Korea'
      WHEN lower(txt) LIKE '%cote%' OR lower(txt) LIKE '%côte%' OR lower(txt) LIKE '%cote d%ivoire%' THEN 'Côte d''Ivoire'
      WHEN lower(txt) IN ('brasil','brazil') THEN 'Brazil'
      WHEN lower(txt) IN ('myanmmar') THEN 'Myanmar'
      WHEN lower(txt) IN ('goban','gabon') THEN 'Gabon'
      WHEN lower(txt) IN ('behrain','bahrain') THEN 'Bahrain'
      WHEN lower(txt) IN ('netherland') THEN 'Netherlands'
      WHEN lower(txt) LIKE 'sri lanka%' THEN 'Sri Lanka'
      WHEN lower(txt) IN ('congo republic','congo, the democratic republic of the','congo','congo republic','congo, the democratic republic of the') THEN 'Congo'
      WHEN lower(txt) IN (
        'finance','personal reason','student wants to change the degree from doctor of philosophy to masters',
        'he got admitted into another university','not able to provide official transcript',
        'not attending illinois tech, going to a higher ranked university','no planes','not connected'
      ) THEN 'Unknown'
      ELSE INITCAP(btrim(txt))
    END;
$$;
CREATE OR REPLACE FUNCTION outcome_category(txt text) 
RETURNS text 
LANGUAGE sql 
IMMUTABLE AS $$
  SELECT CASE
    WHEN txt IS NULL THEN 'Other'

    -- First check for "Not Connected" or similar outcomes
    WHEN lower(txt) ~ 'not connected|no answer|voicemail|no answer/|disconnected|
	failed call' 
      THEN 'No Answer/Disconnected'

    -- Then check for Connected-related outcomes
    WHEN lower(txt) ~ '(^| )connected($| )|completed application|ready to pay|
	already paid|will submit|student has the needed information|will confirm|want to defer|
	student will join|still making a decision|i901|already enrolled|will start application' 
      THEN 'Connected'

    -- Fallback
    ELSE 'Other'
  END;
$$;
select  distinct outcome_category from master_table

DROP TABLE IF EXISTS master_table;
CREATE TABLE master_table AS
WITH dedup_outreach AS (
  -- get latest outreach row per reference_id + recieved_at + other fields if needed
  SELECT DISTINCT ON (reference_id, recieved_at)
     reference_id,
     recieved_at,
     university        AS outreach_university,
     caller_name,
     outcome_1,
     remark,
     campaign_id,
     escalation_required,
     ctid
  FROM outreach_data
  ORDER BY reference_id, recieved_at, recieved_at DESC, ctid
)
, dedup_applicant AS (
  -- if there are multiple applicant rows for same app_id, keep latest by nothing specific; use ctid tie-breaker
  SELECT DISTINCT ON (app_id)
    app_id,
    normalize_country(country) AS country,
    university AS applicant_university,
    keep_digits_or_unknown(phone_number) AS phone_number
  FROM applicant_data
  ORDER BY app_id, ctid
)
, dedup_campaign AS (
  SELECT id AS campaign_id, name AS campaign_name, category, intake, university AS campaign_university, status, start_date
  FROM campaign_data
)
SELECT
  COALESCE(a.app_id, d.reference_id) AS app_id,
  d.reference_id,
  d.recieved_at,
  COALESCE(d.campaign_id, c.campaign_id) AS campaign_id,
  c.campaign_name,
  c.category AS campaign_category,
  c.intake AS campaign_intake,
  COALESCE(a.applicant_university, d.outreach_university, c.campaign_university) AS university,
  d.caller_name,
  d.outcome_1,
  outcome_category(d.outcome_1) AS outcome_category,
  COALESCE(NULLIF(btrim(d.remark),''), 'No Remark') AS remark,
  d.escalation_required,
  a.country AS normalized_country,
  a.phone_number AS normalized_phone,
  keep_digits_or_unknown(a.app_id) AS normalized_app_id,
  now() AS created_at
FROM dedup_outreach d
LEFT JOIN dedup_applicant a ON a.app_id = d.reference_id
LEFT JOIN dedup_campaign c ON c.campaign_id = d.campaign_id;


select * from master_table
UPDATE master_table
SET app_id = 'Unknown'
WHERE app_id = '0';

UPDATE master_table
SET reference_id = 'Unknown'
WHERE reference_id = '0';


SELECT app_id, campaign_id, COUNT(*) 
FROM master_table
GROUP BY app_id, campaign_id
HAVING COUNT(*) > 1;

ALTER TABLE campaign_data
ALTER COLUMN id TYPE TEXT;

ALTER TABLE applicant_data
ALTER COLUMN app_id TYPE TEXT;

ALTER TABLE outreach_data
ALTER COLUMN reference_id TYPE TEXT;

select * from campaign_data



ALTER TABLE master_table
ALTER COLUMN app_id TYPE TEXT,
ALTER COLUMN reference_id TYPE TEXT,
ALTER COLUMN campaign_id TYPE TEXT;


-- See column names and types
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'master_table';

-- Are dates valid?
SELECT MIN(recieved_at) AS earliest_date,
       MAX(recieved_at) AS latest_date
FROM master_table;

-- Are campaign IDs always numeric?
SELECT DISTINCT campaign_id
FROM master_table
WHERE campaign_id ~ '[^0-9]';



SELECT 
    COUNT(*) FILTER (WHERE app_id IS NULL OR app_id = '') AS missing_app_id,
    COUNT(*) FILTER (WHERE campaign_id IS NULL OR campaign_id = '') AS missing_campaign_id,
    COUNT(*) FILTER (WHERE caller_name IS NULL OR caller_name = '') AS missing_caller_name,
    COUNT(*) FILTER (WHERE outcome_category IS NULL OR outcome_category = '') AS missing_outcome_category
FROM master_table;



SELECT app_id, campaign_id, recieved_at, COUNT(*) AS duplicate_count
FROM master_table
GROUP BY app_id, campaign_id, recieved_at
HAVING COUNT(*) > 1;




SELECT 
    COUNT(*) AS total_calls,
    SUM(CASE WHEN outcome_category = 'Connected' THEN 1 ELSE 0 END)
	AS connected_calls,
    SUM(CASE WHEN outcome_category = 'No Answer/Disconnected' THEN 1 ELSE 0 END) 
	AS disconnected_calls,
    SUM(CASE WHEN outcome_category NOT IN ('Connected','No Answer/Disconnected')
	THEN 1 ELSE 0 END) AS other_calls
FROM master_table;

select distinct app_id from applicant_data



SELECT *
FROM master_table
WHERE escalation_required = 'Yes' AND (caller_name IS NULL OR caller_name = '');

SELECT *
FROM ma
WHERE Agent_Name IS NULL OR Call_Status IS NULL;

SELECT 
    'master_table' AS table_name, COUNT(*) AS record_count
FROM master_table
UNION ALL
SELECT 
    'campaign_data' AS table_name, COUNT(*) AS record_count
FROM campaign_data
UNION ALL
SELECT 
    'outreach_data' AS table_name, COUNT(*) AS record_count
FROM outreach_data
UNION ALL
SELECT 
    'applicant_data' AS table_name, COUNT(*) AS record_count
FROM applicant_data;





SELECT m.app_id, m.university AS master_university, 
c.university AS campaign_university, m.campaign_id
FROM master_table m
JOIN campaign_data c ON m.campaign_id = c.id
WHERE m.university <> c.university;






SELECT 
    m.campaign_id,
    COUNT(*) AS total_records
FROM master_table m
LEFT JOIN campaign_data c 
       ON m.campaign_id = c.id
WHERE c.id IS NULL
GROUP BY m.campaign_id;
select * from master_table limit 5
select distinct country from applicant_data





SELECT 
    (SUM(CASE WHEN outcome_category = 'Connected Calls' THEN 1 ELSE 0 END) * 100.0 
     / COUNT(*)) AS connectivity_rate
FROM master_table;



SELECT 
    (SUM(CASE WHEN outcome_category = 'Connected' THEN 1 ELSE 0 END) * 100.0 
     / COUNT(*)) AS connectivity_rate
FROM master_table;
SELECT 
    outcome_category,
    COUNT(*) AS total_calls,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM master_table), 2) AS percentage_rate
FROM master_table
GROUP BY outcome_category;






select outcome_category, count(outcome_category)
from master_table
group by outcome_category 
