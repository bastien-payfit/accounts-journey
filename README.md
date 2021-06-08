# Introduction
## Purpose
Once they're created, *Accounts* in Salesforce navigate through different *Lists* before their very first demo date (if any).

For that matter, [Clément](https://github.com/clementspiers) wanted to see if *Accounts* that had a scheduled demo date followed a typical path through specific *Lists* before their demos.

For instance, it would be really informative if we discovered that 90% of *Accounts* on which a demo occurred started their journey in a *List* of nature "Batch" and ended in a *List* of nature "Reassignment".

## The Looker Dead-End
I did not find a way to process that info in Looker with simple dimensions, measures or table calculations. The only thread I had left to explore was that of Looker's **derived tables**. 

Unfortunately, data ops are not really fond of this alternative which proves to be very intensive on Redshift resources.

Since Clément does not need the info more than 4 times a year, we settled for a simple SQL request. 

>This doc will walk you through a few intermediary requests to help you understand the final one.

# Walk-through
