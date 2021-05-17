# AEM Content Import

Helpers to export and import content into AEM instances.

## Prerequisites

You will need to have the following software installed to ensure you can contribute to development of this codebase:

* [Powershell 7](https://github.com/PowerShell/PowerShell/releases) - this will make your windows terminal work check with `$PSVersionTable`

## Available Scripts

Following scripts are available in the repo

* `webdavenable.ps1` - disabled WebDav on AEM instance
* `webdavdisable.ps1` - enable WebDav on AEM instance
* `filevault-import.ps1` - import content into AEM instance
* `filevault-export.ps1` - export content from AEM instance

Each script has a number of parameters available that you can specify to match your deployment, see top of each script.

## Selective Import of content form repo to local AEM instance

You can specify a specific path in the content that you want to import to an instance.

```.\filevault-import.ps1 -ROOT_PATHS /content/cq:tags```

This will import local tags files into your local AEM instance.

## Selective Export of content form local AEM instance

You can specify a specific path in the AEM instance that you want to export into this repo.

**DO NOT COMMIT META-INF FOLDER**

```.\filevault-export.ps1 -ROOT_PATHS /content/cq:tags```

This will export tags folder from your local AEM instance.
