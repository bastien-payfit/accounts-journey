-- @block Get Lars
SELECT *
FROM staging_salesforce.batchaccountrelation__c
LIMIT 50;

-- @block Get LARs assignment dates and account names
SELECT 
    a.name as account_name,
    lar.assignement_date__c
FROM staging_salesforce.batchaccountrelation__c lar 
JOIN staging_salesforce.account a 
    on lar.account__c = a.id
WHERE not lar.isdeleted and lar.assignement_date__c is not NULL;

-- @block Account names, LARs' assignment dates and List Nature
SELECT 
    a.name as account_name,
    lar.assignement_date__c,
    b.nature__c
FROM staging_salesforce.batchaccountrelation__c lar 
JOIN staging_salesforce.account a 
    on lar.account__c = a.id
JOIN staging_salesforce.batch__c b 
    on lar.batch__c = b.id
WHERE not lar.isdeleted and lar.assignement_date__c is not NULL;

-- @block Accounts, first assignment date and last assignment date
SELECT 
    a.name as account_name,
    MIN(lar.assignement_date__c) first_assignment_date,
    MAX(lar.assignement_date__c) last_assignment_date
FROM staging_salesforce.batchaccountrelation__c lar 
JOIN staging_salesforce.account a 
    on lar.account__c = a.id
WHERE not lar.isdeleted and lar.assignement_date__c is not NULL
GROUP BY 
    a.id,
    a.name;

-- @block Accounts and first list nature
WITH no_nature as (
    SELECT 
        a.id account_id,
        a.name as account_name,
        MIN(lar.assignement_date__c) first_assignment_date
    FROM staging_salesforce.batchaccountrelation__c lar 
    JOIN staging_salesforce.account a 
        on lar.account__c = a.id
    WHERE not lar.isdeleted and lar.assignement_date__c is not NULL
    GROUP BY 
        a.id,
        a.name
)
SELECT
    no_nature.*,
    b.nature__c first_nature
FROM no_nature
JOIN staging_salesforce.batchaccountrelation__c lar
    on no_nature.account_id = lar.account__c
JOIN staging_salesforce.batch__c b 
    on lar.batch__c = b.id
WHERE lar.assignement_date__c = no_nature.first_assignment_date;


-- @block Count distinct first natures
WITH no_nature as (
    SELECT 
        a.id account_id,
        a.name as account_name,
        MIN(lar.assignement_date__c) first_assignment_date
    FROM staging_salesforce.batchaccountrelation__c lar 
    JOIN staging_salesforce.account a 
        on lar.account__c = a.id
    WHERE 
        not lar.isdeleted 
        and lar.assignement_date__c is not null
        and a.first_demo_date__c is not null
        and a.first_demo_date__c >= '2021-01-01'
    GROUP BY 
        a.id,
        a.name
),
first_nature as(
    SELECT
        no_nature.*,
        b.nature__c first_nature
    FROM no_nature
    JOIN staging_salesforce.batchaccountrelation__c lar
        on no_nature.account_id = lar.account__c
    JOIN staging_salesforce.batch__c b 
        on lar.batch__c = b.id
    WHERE lar.assignement_date__c = no_nature.first_assignment_date
),
nature_count as(
    SELECT
        distinct first_nature.first_nature,
        count(*) nature_count
    FROM first_nature
    GROUP BY 1
)
SELECT 
    first_nature,
    nature_count,
    CONVERT(VARCHAR(20), CONVERT(DECIMAL(18,2), (nature_count * 100.00)/(SELECT SUM(nature_count) FROM nature_count))) + '%' as proportion
FROM nature_count;