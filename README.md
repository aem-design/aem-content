# AEM Content Import

Helpers to export and import content into AEM instances.

## Prerequisites

You will need to have the following software installed to ensure you can contribute to development of this codebase:

* [Powershell 7](https://github.com/PowerShell/PowerShell/releases) - this will make your windows terminal work check with `$PSVersionTable`

## Update your paths you want to export

1. update variable `$ROOT_PATHS` in file `filevault-export.ps1` to allow extract of content from AEM instance. 

```powershell
    [string[]]$ROOT_PATHS = (
        "/content/dam/",
    ),
```

## Update your path you want to import

1. add filters to `src/main/content/META-INF/vault/filter.xml` to ensure the package and vlt import process works. 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<workspaceFilter version="1.0">
    <filter root="/content/dam/" />
</workspaceFilter>
```

2. update `Content-Package-Roots` in `src/main/content/META-INF/MANIFEST.MF` with comma separated paths you are going to import.

```yaml
Content-Package-Roots: /content/dam/
```

## Scripts

Purpose of scripts

1. `webdavdisable.ps1` - disabled WebDav on AEM with following params:

```powershell
    [string]$SERVER_PATH_CONFIG_WEBDAV = "/apps/system/config/org.apache.sling.jcr.davex.impl.servlets.SlingDavExServlet",
    [string]$LOGIN = "admin:admin",
    [string]$SERVER_HOST = "localhost",
    [string]$PROTOCOL = "http",
    [string]$PORT = 4502,
    [string]$TIMEOUT = 5,
    [HashTable]$BODY = @{
        "jcr:primaryType"="sling:OsgiConfig"
        "alias"="/crx/server"
        "dav.create-absolute-uri"="true"
        "dav.create-absolute-uri@TypeHint"="Boolean"
        "../../jcr:primaryType"="sling:Folder"
        "../jcr:primaryType"="sling:Folder"
    },
    [string]$ADDRESS = "${PROTOCOL}://${SERVER_HOST}:${PORT}"
```

2. `webdavenable.ps1` - enable WebDav on AEM with following params:

```powershell
    [string]$SERVER_PATH_CONFIG_WEBDAV = "/apps/system/config/org.apache.sling.jcr.davex.impl.servlets.SlingDavExServlet",
    [string]$LOGIN = "admin:admin",
    [string]$SERVER_HOST = "localhost",
    [string]$PROTOCOL = "http",
    [string]$PORT = 4502,
    [string]$TIMEOUT = 5,
    [HashTable]$BODY = @{
        "jcr:primaryType"="sling:OsgiConfig"
        "alias"="/crx/server"
        "dav.create-absolute-uri"="true"
        "dav.create-absolute-uri@TypeHint"="Boolean"
        "../../jcr:primaryType"="sling:Folder"
        "../jcr:primaryType"="sling:Folder"
    },
    [string]$ADDRESS = "${PROTOCOL}://${SERVER_HOST}:${PORT}"
```

3. `filevault-export.ps1` - export content using VLT from AEM instance that has WebDav enabled with following params:

```powershell
    #equivalent of using localhost in docker container
    [string]$AEM_HOST = "localhost",
    # TCP port SOURCE_CQ listens on
    [string]$AEM_PORT = "4502",
    # AEM Admin user for AEM_HOST
    [string]$AEM_USER = "admin",
    # AEM Admin password for AEM_HOST
    [string]$AEM_PASSWORD = "admin",
    # Server WebDav Path
    #$SOURCE_WEBDAV_PATH = "/crx/server/crx.default/jcr:root/"
    [string]$SOURCE_WEBDAV_PATH = "/crx",
    [string]$AEM_SCHEMA = "http",
    #to set additional flags if required
    [string]$VLT_FLAGS = "--insecure",
    [string]$VLT_CMD = "./bin/vlt",
    [string]$ROOT_PATH = "/content/dam/",
    # Root folder name for placing content
    [string]$CONTENT_DESTINATION = ".\src\main\content",
    [string]$FILTER_FILE = "${CONTENT_DESTINATION}\META-INF\vault\filter.xml",
    [string]$FILTER_FILE_LOCATION = "${CONTENT_DESTINATION}\META-INF",
    [string[]]$ROOT_PATHS = ("/content/dam/", "/content/dam/files/", "/content/dam/images/")
```
    
4. `filevault-import.ps1` - import content using VLT from AEM instance that has WebDav. This script will disable and enable Asset workflows and Mailer service. This script can be called with following params:

```powershell
    #equivalent of using localhost in docker container
    $AEM_HOST = "localhost",
    # TCP port SOURCE_CQ listens on
    $AEM_PORT = "4502",
    # AEM Admin user for AEM_HOST
    $AEM_USER = "admin",
    # AEM Admin password for AEM_HOST
    $AEM_PASSWORD = "admin",
    # Root folder name for placing content
    $SOURCE_CONTENT_FOLDER = "localhost-author-export",
    $AEM_SCHEMA = "http",
    #to set additional flags if required
    $VLT_FLAGS = "--insecure", 
    $VLT_CMD = "./bin/vlt",
    $ROOT_PATH = "/",
    $CONTENT_SOURCE = "src\main\content\jcr_root",
    # connection timeout
    $TIMEOUT = "5",
    # host address
    $ADDRESS = "${AEM_SCHEMA}://${AEM_HOST}:${AEM_PORT}"
```

## Export Content from an Environment

1. To export content from an environment run scripts in following order:

* `webdavenable.ps1`
* `filevault-export.ps1` 
* `webdavdisable.ps1`

2. Add, Commit and Push updates

## Import Content to an Environment 

1. To import content from an environment run scripts in following order:

* `filevault-import.ps1` 
