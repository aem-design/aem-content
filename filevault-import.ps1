Param(
    #equivalent of using localhost in docker container
    [string]$SOURCE_HOST = "localhost",
    # TCP port SOURCE_CQ listens on
    [string]$SOURCE_PORT = "4502",
    # AEM Admin user for SOURCE_HOST
    [string]$SOURCE_AEM_USER = "admin",
    # AEM Admin password for SOURCE_HOST
    [string]$SOURCE_AEM_PASSWORD = "admin",
    # Root folder name for placing content
    [string]$SOURCE_CONTENT_FOLDER = "localhost-author-export",
    # Server WebDav Path
    #$SOURCE_WEBDAV_PATH = "/crx/server/crx.default/jcr:root/"
    [string]$SOURCE_WEBDAV_PATH = "/crx",
    [string]$SCHEMA = "http",
    #to set additional flags if required
    [string]$VLT_FLAGS = "--insecure",
    [string]$VLT_CMD = "./bin/vlt",
    [string]$ROOT_PATH = "/",
    [string]$CONTENT_SOURCE = "src\main\content\jcr_root",
    # connection timeout
    [string]$TIMEOUT = "5",
    # host address
    [string]$ADDRESS = "${SCHEMA}://${SOURCE_HOST}:${SOURCE_PORT}",
    # Workflow Assets Modify path
    [string]$WORKFLOW_ASSET_MODIFY = "/conf/global/settings/workflow/launcher/config/update_asset_mod",
    # Workflow Assets Create path
    [string]$WORKFLOW_ASSET_CREATE = "/conf/global/settings/workflow/launcher/config/update_asset_create",
    # Workflow Assets Create path
    [string]$SERVICE_TO_DISABLE = "/system/console/bundles/com.day.cq.cq-mailer",

    [HashTable]$BODY_SERVICE_TO_DISABLE = @{
        "action"="stop"
    },
    [HashTable]$BODY_SERVICE_TO_DISABLE_ENABLE = @{
        "action"="start"
    },
    [HashTable]$WORKFLOW_ASSET_ENABLE_UPDATE = @{
        "jcr:primaryType"= "cq:WorkflowLauncher"
        "description"= "Update Asset - Modification"
        "enabled"= "true"
        "conditions"= "jcr:content/jcr:mimeType!=video/.*"
        "glob"= "/content/dam(/((?!/subassets).)*/)renditions/original"
        "eventType"= "16"
        "workflow"= "/var/workflow/models/dam/update_asset"
        "runModes"= "author"
        "nodetype"= "nt:file"
        "excludeList"= "event-user-data:changedByWorkflowProcess"
        "enabled@TypeHint"="Boolean"
        "eventType@TypeHint"="Long"
        "conditions@TypeHint"="String[]"
    },

    [HashTable]$WORKFLOW_ASSET_DISABLE_UPDATE = @{
        "jcr:primaryType"= "cq:WorkflowLauncher"
        "description"= "Update Asset - Modification"
        "enabled"= "false"
        "conditions"= "jcr:content/jcr:mimeType!=video/.*"
        "glob"= "/content/dam(/((?!/subassets).)*/)renditions/original"
        "eventType"= "16"
        "workflow"= "/var/workflow/models/dam/update_asset"
        "runModes"= "author"
        "nodetype"= "nt:file"
        "excludeList"= "event-user-data:changedByWorkflowProcess"
        "enabled@TypeHint"="Boolean"
        "eventType@TypeHint"="Long"
        "conditions@TypeHint"="String[]"
    },

    [HashTable]$WORKFLOW_ASSET_ENABLE_CREATE = @{
        "jcr:primaryType"= "cq:WorkflowLauncher"
        "description"= "Update Asset - Create"
        "enabled"= "true"
        "conditions"= "jcr:content/jcr:mimeType!=video/.*"
        "glob"= "/content/dam(/((?!/subassets).)*/)renditions/original"
        "eventType"= "1"
        "workflow"= "/var/workflow/models/dam/update_asset"
        "runModes"= "author"
        "nodetype"= "nt:file"
        "excludeList"= "event-user-data:changedByWorkflowProcess"
        "enabled@TypeHint"="Boolean"
        "eventType@TypeHint"="Long"
        "conditions@TypeHint"="String[]"
    },

    [HashTable]$WORKFLOW_ASSET_DISABLE_CREATE = @{
        "jcr:primaryType"= "cq:WorkflowLauncher"
        "description"= "Update Asset - Create"
        "enabled"= "false"
        "conditions"= "jcr:content/jcr:mimeType!=video/.*"
        "glob"= "/content/dam(/((?!/subassets).)*/)renditions/original"
        "eventType"= "16"
        "workflow"= "/var/workflow/models/dam/update_asset"
        "runModes"= "author"
        "nodetype"= "nt:file"
        "excludeList"= "event-user-data:changedByWorkflowProcess"
        "enabled@TypeHint"="Boolean"
        "eventType@TypeHint"="Long"
        "conditions@TypeHint"="String[]"
    },
    [switch]$Silent = $false

)

function doSlingPost {
    [CmdletBinding()]
    Param (

        [Parameter(Mandatory=$true)]
        [string]$Url="http://localhost:4502",

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Post','Delete')]
        [string]$Method,

        [Parameter(Mandatory=$false)]
        [HashTable]$Body,

        [Parameter(Mandatory=$false,
                HelpMessage="Provide Basic Auth Credentials in following format: <user>:<pass>")]
        [string]$BasicAuthCreds="",

        [Parameter(Mandatory=$false)]
        [string]$UserAgent="",

        [Parameter(Mandatory=$false)]
        [string]$Referer="",

        [Parameter(Mandatory=$false)]
        [string]$Timeout="5"

    )



    $HEADERS = @{
    }

    if (-not([string]::IsNullOrEmpty($UserAgent))) {
        $HEADERS.add("User-Agent",$UserAgent)
    }

    if (-not([string]::IsNullOrEmpty($Referer))) {
        $HEADERS.add("Referer",$Referer)
    }


    if (-not([string]::IsNullOrEmpty($BasicAuthCreds))) {
        $BASICAUTH = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($BasicAuthCreds))
        $HEADERS.add("Authorization","Basic $BASICAUTH")
    }


    Write-Host "Performing action $Method on $Url."

    $Response = Invoke-WebRequest -Method Post -Headers $HEADERS -TimeoutSec $Timeout -Uri "$Url" -Form $Body -ContentType "application/x-www-form-urlencoded"

#    $Response.Content


}

Write-Host "------- CONFIG ----------"
Write-Host "SCHEMA: $SCHEMA"
Write-Host "SOURCE_HOST: $SOURCE_HOST"
Write-Host "SOURCE_PORT: $SOURCE_PORT"
Write-Host "SOURCE_AEM_USER: $SOURCE_AEM_USER"
Write-Host "CONTENT_SOURCE: $CONTENT_SOURCE"
Write-Host "ROOT_PATH: $ROOT_PATH"
Write-Host "Silent: $Silent"
Write-Host "VLT_FLAGS: $VLT_FLAGS"
Write-Host "VLT_CMD: $VLT_CMD"

if (-not($Silent))
{
    $START = Read-Host -Prompt 'Do you want to start import with these settings? (y/n)'

    if ($START -ne "y")
    {
        Write-Host "Quiting..."
        Exit
    }
}

Write-Host "------- Disable Workflows ----------"
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $WORKFLOW_ASSET_DISABLE_UPDATE -Url "${ADDRESS}${WORKFLOW_ASSET_MODIFY}" -BasicAuthCreds ${SOURCE_AEM_USER}:${SOURCE_AEM_PASSWORD} -Timeout $TIMEOUT
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $WORKFLOW_ASSET_DISABLE_CREATE -Url "${ADDRESS}${WORKFLOW_ASSET_CREATE}" -BasicAuthCreds ${SOURCE_AEM_USER}:${SOURCE_AEM_PASSWORD} -Timeout $TIMEOUT

Write-Host "------- Disable aem mailer bundle ----------"
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $BODY_SERVICE_TO_DISABLE -Url "${ADDRESS}${SERVICE_TO_DISABLE}" -BasicAuthCreds ${SOURCE_AEM_USER}:${SOURCE_AEM_PASSWORD} -Timeout $TIMEOUT


Write-Host "------- START Importing content ----------"
Write-Host "${VLT_CMD} ${VLT_FLAGS} --credentials ${SOURCE_AEM_USER}:****** import -v ${ADDRESS}${SOURCE_WEBDAV_PATH} ${CONTENT_SOURCE} ${ROOT_PATH}"

Invoke-Expression -Command "${VLT_CMD} ${VLT_FLAGS} -Xmx2g --credentials ${SOURCE_AEM_USER}:${SOURCE_AEM_PASSWORD} import -v ${ADDRESS}${SOURCE_WEBDAV_PATH} ${CONTENT_SOURCE} ${ROOT_PATH} " | Tee-Object -FilePath "..\filevailt-import.log"

Write-Host "------- END Importing content ----------"


Write-Host "------- Enable Workflows ----------"

doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $WORKFLOW_ASSET_ENABLE_UPDATE -Url "${ADDRESS}${WORKFLOW_ASSET_MODIFY}" -BasicAuthCreds ${SOURCE_AEM_USER}:${SOURCE_AEM_PASSWORD} -Timeout $TIMEOUT
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $WORKFLOW_ASSET_ENABLE_CREATE -Url "${ADDRESS}${WORKFLOW_ASSET_CREATE}" -BasicAuthCreds ${SOURCE_AEM_USER}:${SOURCE_AEM_PASSWORD} -Timeout $TIMEOUT

Write-Host "------- Enable aem mailer bundle ----------"
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $BODY_SERVICE_TO_DISABLE_ENABLE -Url "${ADDRESS}${SERVICE_TO_DISABLE}" -BasicAuthCreds ${SOURCE_AEM_USER}:${SOURCE_AEM_PASSWORD} -Timeout $TIMEOUT
