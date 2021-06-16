#!/bin/bash
# https://docs.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest#az_storage_blob_undelete

# auth option 1: use env vars
#export AZURE_STORAGE_ACCOUNT=
#export AZURE_STORAGE_KEY=
#az storage blob undelete -c mfc -n msb.txt

# auth option 2: --sas-token= --account-name=

# auth option 3: --account-name= & az login
az storage blob undelete -c mfc -n msb.txt --account-name= 

# auth option 4: ...