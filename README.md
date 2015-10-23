Alfresco offers a rich remote API using its WebScripts technology which is
based on the REST paradigm. This projects provides a set of scripts that makes
it more easy to interact with the repository and its exposed resources.

Create or change users, create sites, manage group membership form the command
line instead of the user interface.

Also great for automation: Create some hundreds of users from a table and
automatically add to a set of groups? This becomes a one liner with the
Alfresco shell tools.

# Use cases

Reported use cases have been:

    * Backup User-Group relationships
    * Provision demo systems
    * Keep avatar pictures in sync with a 3rth party source
    * pregenerate >100k thumbnail images
    * Initial import of users and groups, along with user-group and group-subgroup assignements
    * Create a bunch of tenants for a multi-tenancy enabled Alfresco
    * Do repetitive maintenance tasks for multiple tenants in one go 

# How to start?

    1. check out the scripts or download a release tarball
    2. install required 3-rd party tools for json handling
    3. set environment variables
    4. have fun

# Environment Variables

Required environment variables:

    * `ALFTOOLS_USER=<username>`
    * `ALFTOOLS_PASSWORD=<password>`
    * `ALFTOOLS_ENDPOINT='http://<host>.<domain>:<port>/alfresco'`

Optional environment variables:

    * `ALF_VERVBOSE=<true|false>`

# Commands

## `alfAddAspect.sh`

## `alfAddAuthorityToGroup.sh`

## `alfCreateGroup.sh`

## `alfCreateSite.sh`

## `alfCreateSpace.sh`

## `alfCreateTenant.sh`

## `alfCreateUser.sh`

## `alfDeleteAspect.sh`

## `alfDeleteAuthorityFromGroup.sh`

## `alfDeleteGroup.sh`

## `alfDelete.sh`

## `alfDeleteSite.sh`

## `alfDeleteUser.sh`

## `alfGetCompanyHomeNodeRef.sh`

## `alfGet.sh`

## `alfGetThumbnail.sh`

## `alfGetUserHomeFolder.sh`

## `alfGetUser.sh`

## `alfListGroupMembers.sh`

## `alfListGroups.sh`

## `alfList.sh`

## `alfListTenants.sh`

## `alfListUsers.sh`

## `alfMetadata.sh`

## `alfMkdir.sh`

## `alfNodeRef2Path.sh`

## `alfPath2NodeRef.sh`

## `alfRename.sh`

## `alfResetAvatar.sh`

## `alfSearch.sh`

Pass a Lucene search query and get a list of NodeRefs that match the query.

```shell
$ alfSearch.sh '@acme\:propertyName:"propertyValue"'
workspace://SpacesStore/ee5e0d80-dce8-438d-827e-f87ac1d9d0ec
```

## `alfSetAvatar.sh`

## `alfToolsLib.sh`

## `alfUpdateUser.sh`

## `alfUpload.sh`







*The rest of the documentation still needs to be added. Coming up soon*
