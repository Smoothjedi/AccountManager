# AccountManager
This takes a list of accounts and transactions and outputs a summary file of them
This program is pretty straightforward. No data input is required from the user.
It takes files named ACCOUNTS.TXT and TRANSACTIONS.TXT, sorts the latter per account, and then prints a formatted result.
Sample Accounts text:
456109801804  "J. L. Picard"   0.0 
234987234981  "J. T. Kirk & Co."  298.18
982340982348  "Spacely Sprockets"  29109.14

Sample Transactions text:
Purchase	234987234981	23456	"Culvers"	14.72
Purchase	456109801804	23460	"Sid's Lids"	132.75
Payment	982340982348	23460	Credit	23098479087234	10000.00
Purchase	982340982348	23472	"Mort's Metals"	17293.14
Payment	456109801804	23482	Cash	105.00
Purchase 982340982348	23458	"Peter's Plastics"	416.92
Payment 982340982348	23670	Check	11101	20000.00
Payment 982340982348	22670	Check	11101	-20000.00

An account has a starting balance; purchases add to this while payments deduct from it.
In the context of this program, negative value transactions are invalid. These will be tagged as invalid in the statement results and will not contribute to the totals.

The output for the above input is as follows:
STATEMENT OF ACCOUNT
234987234981       J. T. Kirk & Co.   Starting Balance: 298.18

23456   Purchase    Culvers              14.72

Total Purchases:              14.72
Total Payments:      0.00 (Invalid)
Ending Balance:              312.90
*********************************************************
STATEMENT OF ACCOUNT
456109801804       J. L. Picard   Starting Balance: 0.0

23460   Purchase    Sid's Lids           132.75
23482   Payment     Cash                  105.0

Total Purchases:     132.75
Total Payments:      105.00
Ending Balance:       27.75
*********************************************************
STATEMENT OF ACCOUNT
982340982348       Spacely Sprockets   Starting Balance: 29109.14

22670   Payment     Check #11101         -20000.00 (Invalid)
23458   Purchase    Peter's Plastics                  416.92
23460   Payment     Credit *7234                    10000.00
23472   Purchase    Mort's Metals                   17293.14
23670   Payment     Check #11101                    20000.00

Total Purchases:     17710.06
Total Payments:      30000.00
Ending Balance:      16819.20
*********************************************************
