# AD FS Metadata Manager

These PowerShell scripts implement an identity federation trust
manager for Microsoft Active Directory Federation Services (AD FS)
versions 2.0, 2.1, and 3.0.  They download identity provider (a/k/a
"claims provider") or service provider (a/k/a relying party) metadata
from the InCommon Federation's
[Per-Entity Metadata Pilot](https://spaces.internet2.edu/display/InCCollaborate/Per-Entity+Metadata+Pilot)
project and install (or update) it on the local AD FS farm via the
[AD FS PowerShell API](https://msdn.microsoft.com/en-us/library/ee895353.aspx).
