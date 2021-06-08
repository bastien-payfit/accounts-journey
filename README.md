# Introduction
## Purpose
Once they're created, *Accounts* in Salesforce navigate through different *Lists* before their very first demo date (if any).

For that matter, [Clément](https://github.com/clementspiers) wanted to see if *Accounts* that had a scheduled demo date followed a typical path through specific *Lists* before their demos.

For instance, it would be really informative if we discovered that 90% of *Accounts* on which a demo occurred started their journey in a *List* of nature "Batch" and ended in a *List* of nature "Reassignment".

>Clément already knew where their journey ended. **We will discover where it starts.**

## The Looker Dead-End
I did not find a way to process that info in Looker with simple dimensions, measures or table calculations. The only thread I had left to explore was that of Looker's **derived tables**. 

Unfortunately, data ops are not really fond of this alternative which proves to be very intensive on Redshift resources.

Since Clément does not need the info more than 4 times a year, we settled for a simple SQL request. 

>This doc will walk you through a few intermediary requests to help you understand the final one.

# Walk-through
## Basic joins
### LARs
Basic request to get *LARs'* fields:
```sql
-- @block Get Lars
SELECT *
FROM staging_salesforce.batchaccountrelation__c
LIMIT 50;
```
### Accounts & LARs
A first join between *Accounts* and their associated *LARs*. The request displays account names next to all the assignment dates of their associated *LARs*:
```sql
-- @block Get LARs assignment dates and account names
SELECT 
    a.name as account_name,
    lar.assignement_date__c
FROM staging_salesforce.batchaccountrelation__c lar 
JOIN staging_salesforce.account a 
    on lar.account__c = a.id
WHERE not lar.isdeleted and lar.assignement_date__c is not NULL;
```
### Accounts, LARs and List
Now, we join *Accounts* to their *Lists* thanks to the *LARs* (it's their sole purpose after all). This request displays account names next to all their *LARs'* assignment dates and the *List* natures associated to those *LARs*:
```sql
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
```
## Dates are taken into account
### Accounts and first *List* Nature
Thanks to an intermediary table, we can now find the first *List* nature the *Account* went through.

**More specifically:**
- The first table contains *Accounts* next to their first assignment date (i.e the assignment date of the first LAR they were associated to).
- The final `SELECT` joins the first *List* nature to the *Account* based on the first assignment date. We know the assignment date of the first *LAR*. So we just have to find the right *List* nature thanks to this very first *LAR*. Hence the final jointures.



```sql
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
```
## Final counts