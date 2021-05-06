Param(
    #equivalent of using localhost in docker container
    [string]$AEM_HOST = "localhost",
    # TCP port SOURCE_CQ listens on
    [string]$AEM_PORT = "4502",
    # AEM Admin user for AEM_HOST
    [string]$AEM_USER = "admin",
    # AEM Admin password for AEM_HOST
    [string]$AEM_PASSWORD = "admin",
    # Root folder name for placing content
    [string]$SOURCE_CONTENT_FOLDER = "localhost-author-export",
    # Server WebDav Path
    #$AEM_WEBDAV_PATH = "/crx/server/crx.default/jcr:root/"
    [string]$AEM_WEBDAV_PATH = "/crx",
    [string]$AEM_SCHEMA = "http",
    #to set additional flags if required
    [string]$VLT_FLAGS = "--insecure -Xmx2g",
    [string]$VLT_CMD = "./bin/vlt",
    # Root folder name for placing content
    [string]$CONTENT_DESTINATION = ".\src\main\content",
    [string]$FILTER_FILE = "${CONTENT_DESTINATION}\META-INF\vault\filter.xml",
    [string]$FILTER_FILE_LOCATION = "${CONTENT_DESTINATION}\META-INF",
    #which filter paths to import
    [string[]]$ROOT_PATHS,
    [string]$ROOT_PATH = "/",
    [string]$CONTENT_SOURCE = "src\main\content\jcr_root",
    # connection timeout
    [string]$TIMEOUT = "5",
    # host address
    [string]$ADDRESS = "${AEM_SCHEMA}://${AEM_HOST}:${AEM_PORT}",
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


Function Format-XMLIndent
{
    [Cmdletbinding()]
    [Alias("IndentXML")]
    param
    (
      [Parameter(ValueFromPipeline)]
      [xml]$Content,
      [int]$Indent
    )

    # String Writer and XML Writer objects to write XML to string
    $StringWriter = New-Object System.IO.StringWriter
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter

    # Default = None, change Formatting to Indented
    $xmlWriter.Formatting = "indented"

    # Gets or sets how many IndentChars to write for each level in
    # the hierarchy when Formatting is set to Formatting.Indented
    $xmlWriter.Indentation = $Indent

    $Content.WriteContentTo($XmlWriter)
    $XmlWriter.Flush();$StringWriter.Flush()
    $StringWriter.ToString()
}


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


    Write-Output "Performing action $Method on $Url."

    $Response = Invoke-WebRequest -Method Post -Headers $HEADERS -TimeoutSec $Timeout -Uri "$Url" -Form $Body -ContentType "application/x-www-form-urlencoded"

}

Write-Output "------- CONFIG ----------"
Write-Output "AEM_SCHEMA: $AEM_SCHEMA"
Write-Output "AEM_HOST: $AEM_HOST"
Write-Output "AEM_PORT: $AEM_PORT"
Write-Output "AEM_USER: $AEM_USER"
Write-Output "CONTENT_SOURCE: $CONTENT_SOURCE"
Write-Output "ROOT_PATH: $ROOT_PATH"
Write-Output "FILTER_FILE: $FILTER_FILE"
Write-Output "Silent: $Silent"
Write-Output "VLT_FLAGS: $VLT_FLAGS"
Write-Output "VLT_CMD: $VLT_CMD"
Write-Output "ROOT_PATHS:"
$ROOT_PATHS | ForEach-Object {
  Write-Output " - $_"
}

if (-not($Silent))
{
    $START = Read-Host -Prompt 'Do you want to start import with these settings? (y/n)'

    if ($START -ne "y")
    {
        Write-Output "Quiting..."
        Exit
    }
}


Write-Output "------- START Update filter ----------"
$ROOT_PATHS_LAST = $ROOT_PATHS | Select-Object -Last 1
$ROOT_PATHS | ForEach-Object {
  $LOG_FILENAME = "$_".Replace("/","-")

  Write-Output "Remove exiting Filer..."
  Copy-Item ".\src\main\content\META-INF\vault\filter-blank.xml" -Destination "$FILTER_FILE"

  Write-Output "Create filter for: $_"
  $FILTER_XML = [xml](Get-Content $FILTER_FILE)
  $FILTER_XML_CONTENT = $FILTER_XML.SelectNodes("//workspaceFilter")
  $FILTER_XML_DELETE = $FILTER_XML_CONTENT.SelectNodes('//filter')
  $FILTER_XML_DELETE | ForEach-Object{
    $DELETE_STATUS = $FILTER_XML_CONTENT.RemoveChild($_)
  }
  $FILTER_XML_CONTENT_NEW = $FILTER_XML.CreateNode("element","filter","")
  $FILTER_XML_CONTENT_NEW.SetAttribute("root",$_)
  $FILTER_XML_CONTENT_NEW_ADD = $FILTER_XML_CONTENT.AppendChild($FILTER_XML_CONTENT_NEW)
  Write-Output "Saving..."
  $FILTER_XML.OuterXml | IndentXML -Indent 4 | Out-File $FILTER_FILE -encoding "UTF8"
  Write-Output "Done..."
}

Write-Output "------- END Update filter ----------"


Write-Output "------- Disable Workflows ----------"
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $WORKFLOW_ASSET_DISABLE_UPDATE -Url "${ADDRESS}${WORKFLOW_ASSET_MODIFY}" -BasicAuthCreds ${AEM_USER}:${AEM_PASSWORD} -Timeout $TIMEOUT
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $WORKFLOW_ASSET_DISABLE_CREATE -Url "${ADDRESS}${WORKFLOW_ASSET_CREATE}" -BasicAuthCreds ${AEM_USER}:${AEM_PASSWORD} -Timeout $TIMEOUT

Write-Output "------- Disable aem mailer bundle ----------"
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $BODY_SERVICE_TO_DISABLE -Url "${ADDRESS}${SERVICE_TO_DISABLE}" -BasicAuthCreds ${AEM_USER}:${AEM_PASSWORD} -Timeout $TIMEOUT


Write-Output "------- START Importing content ----------"
Write-Output "${VLT_CMD} ${VLT_FLAGS} --credentials ${AEM_USER}:****** import -v ${ADDRESS}${AEM_WEBDAV_PATH} ${CONTENT_SOURCE} ${ROOT_PATH}"

Invoke-Expression -Command "${VLT_CMD} ${VLT_FLAGS} --credentials ${AEM_USER}:${AEM_PASSWORD} import -v ${ADDRESS}${AEM_WEBDAV_PATH} ${CONTENT_SOURCE} ${ROOT_PATH} " | Tee-Object -FilePath "..\filevailt-import.log"

Write-Output "------- END Importing content ----------"


Write-Output "------- Enable Workflows ----------"

doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $WORKFLOW_ASSET_ENABLE_UPDATE -Url "${ADDRESS}${WORKFLOW_ASSET_MODIFY}" -BasicAuthCreds ${AEM_USER}:${AEM_PASSWORD} -Timeout $TIMEOUT
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $WORKFLOW_ASSET_ENABLE_CREATE -Url "${ADDRESS}${WORKFLOW_ASSET_CREATE}" -BasicAuthCreds ${AEM_USER}:${AEM_PASSWORD} -Timeout $TIMEOUT

Write-Output "------- Enable aem mailer bundle ----------"
doSlingPost -Method Post -Referer $ADDRESS -UserAgent "curl" -Body $BODY_SERVICE_TO_DISABLE_ENABLE -Url "${ADDRESS}${SERVICE_TO_DISABLE}" -BasicAuthCreds ${AEM_USER}:${AEM_PASSWORD} -Timeout $TIMEOUT

Write-Output "------- Revert Filter.xml ----------"
git checkout HEAD src/main/content/META-INF/vault/filter.xml
Write-Output "------- Revert Filter.xml ----------"
