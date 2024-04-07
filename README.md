# AccountManager
This takes a list of accounts and transactions and outputs a summary file of them. LLM prompts used are at the bottom of the readme.
This program is pretty straightforward. No data input is required from the user.

It takes files named ACCOUNTS.TXT and TRANSACTIONS.TXT, sorts the latter per account, and then prints a formatted result.

An account has a starting balance; purchases add to this while payments deduct from it.

In the context of this program, negative value transactions are invalid. These will be tagged as invalid in the statement results and will not contribute to the totals.

The output for the above input is as follows (Does not reflect output exactly due to GitHub's automatic formatting):

STATEMENT OF ACCOUNT
234987234981       J. T. Kirk & Co.   Starting Balance: 298.18

23456   Purchase    Culvers              14.72

Total Purchases:      14.72
Total Payments:        0.00
Ending Balance:      312.90
*********************************************************
STATEMENT OF ACCOUNT
456109801804       J. L. Picard   Starting Balance: 0.0

23460   Purchase    Sid's Lids           132.75
23482   Payment     Cash                 105.00

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

#LLM Prompts ChatGPT 3.0
Certainly! Here are all the prompts you provided in this chat:

"I'd like to use this as a filter condition on a list, but I need to turn it into a lambda. Can you help with that?"

"how would I filter a list of lists to find one that contains a particular tag"

"can you use filter instead of findf"

"If I have a list of strings, can you write a function that will turn specific keywords into symbols?"

"Oh sorry, actually I have a list of lists with strings I need to do this with"

"Great, that worked well. Can we add to those conditions the ability to change any string with a decimal point in it to a number?"

"that seems to give an error. It expects a string instead of a character"

"I have several lists of data that I want to turn into structs. Can you generate me some code to match these? I'll enter them one at a time"

"Name is Purchase. account number, transactionId, vendor, amount"

"Name is cash-payment. account-number, amount"

"actually, sorry on that last one I forgot a field. It should be this: Name is cash-payment account-number, transaction-number, amount"

"name is check-payment. account-number, transaction-number, check-number, amount"

"the next two are the same, just with different names. credit-payment debit-payment account-number, transaction-number, card-number, amount"

"All right, now I want to convert a list of values into these structs. Let's just start with a function that converts a list of purchases into a list of purchase structs. The list has a Purchase tag that can be ignored because it is going to be a struct for purchase. Here is my example: (Purchase "234987234981" "23456" "Culvers" 14.72)"

"what does the underscore mean in there"

"I'm getting this error: . . application: not a procedure; expected a procedure that can be applied to arguments given: '('Purchase "234987234981" "23456" "Culvers" 14.72)"

"Could you generate me a bunch of test data? Here's the sample file I have. Keep in mind, the first number in each list is an account number; I need that number to be one of the three that are already in the file."

"that's good, but I want like 100 test entries"

"ok, let's step back. I really don't want to have code to do this. I'd like you to just give me some test data as a bunch of text"

"The format is good, and purchases look fine. However, it looks like all the payments are on the same account. Can you randomize those up a bit between the three accounts?"

"I have four very similar functions. Can you suggest a refactoring of them so I may just be sending in a subfunction to do the work?"

"how do I remove empty strings from a list"

"I'm stuck here. When I use your example data it works, but when I use mine, it removes everything from the list"

"this is my data: '(("456109801804" "" "J. L. Picard" "" "" "0.0" "") ("234987234981" "" "J. T. Kirk & Co." "" "298.18") ("982340982348" "" "Spacely Sprockets" "" "29109.14") )"

"I am getting frustrated by this not working. Let's try a different approach. Let's say I've got this data in a file: 456109801804 "J. L. Picard" 0.0 234987234981 "J. T. Kirk & Co." 298.18 982340982348 "Spacely Sprockets" 29109.14 How would you load that into a list using all spaces and tabs as delimiters and only have three items in the list at the end"

"let's back u[p even further. Can you just give me a function that reads all lines in a file as a list"

"Can you add printing the lines to that"

"If I want to use regex-split, and I have this expression [^\s"']+|"([^"])"|'([^'])' how would I put that in the code with all the escapes I need"

"when using match to build a struct, if I have fields I don't want to initialize, how do I put placeholders in"

"If I want to output text to a file, how would I do that"

"What if I want to recursively output to a file until a list of data is empty"

"how would I use filter to select all structs in a list that have a matching account-number"

"let's get more specific. Here's my struct: (struct purchase (account-number transaction-number vendor amount) #:transparent)"

"if I want to overwrite an existing output file, how do I do that"

"If I make a list with multiple types of structs, and they all have the same field name, can I sort them all by that"

"what if I have five different types"

"If I have a list of structs and want to print each of their values on a separate line per struct, how would I do that"

"how would I set up justified columns for this output"

"how would I append my 5 different lists of structs together"

"earlier you gave me a function for recursively adding together fields of a list of structs. How would you modify that to only add values greater than zero"

"Can you print all the prompts I gave you for this chat"
