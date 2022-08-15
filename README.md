# ArxmlAutomation
Based on C# and Powershell, Provide a solution to automate Arxml files from AUTOSAR classic.

## Package Naming Rules

The naming rule for the packages are:

ArxmlAutomation_\<Scope\>_\<Extend\>

### Scope \<Mandotory\>

The scope means the major use case of this package.

e.g. The Basic means the basic use case. And the Swc are the package major for Swc automation.

### Extend \<Optional\>

Optional fields, those function inside may return un-standard object. e.g. PSCustomeObj hash table. 
