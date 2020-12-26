Param(
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
    [string]$VLT_FLAGS = "--insecure -Xmx2g",
    [string]$VLT_CMD = "./bin/vlt",
    # Root folder name for placing content
    [string]$CONTENT_DESTINATION = ".\src\main\content",
    [string]$FILTER_FILE = "${CONTENT_DESTINATION}\META-INF\vault\filter.xml",
    [string]$FILTER_FILE_LOCATION = "${CONTENT_DESTINATION}\META-INF",
    [string[]]$ROOT_PATHS = (
        "/content/dam/"
    ),
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


Write-Host "------- CONFIG ----------"
Write-Host "AEM_SCHEMA: $AEM_SCHEMA"
Write-Host "AEM_HOST: $AEM_HOST"
Write-Host "AEM_PORT: $AEM_PORT"
Write-Host "AEM_USER: $AEM_USER"
Write-Host "CONTENT_DESTINATION: $CONTENT_DESTINATION"
Write-Host "ROOT_PATHS: $ROOT_PATHS"
Write-Host "FILTER_FILE: $FILTER_FILE"
Write-Host "Silent: $Silent"
Write-Host "VLT_FLAGS: $VLT_FLAGS"
Write-Host "VLT_CMD:"

$ROOT_PATHS | ForEach-Object {
    Write-Host "${VLT_CMD} ${VLT_FLAGS} --credentials ${AEM_USER}:****** export -v ${AEM_SCHEMA}://${AEM_HOST}:${AEM_PORT}${SOURCE_WEBDAV_PATH} $_ ${CONTENT_DESTINATION}"
}

if (-not($Silent))
{
    $START = Read-Host -Prompt 'Do you want to start export with these settings? (y/n)'

    if ($START -ne "y")
    {
        Write-Host "Quiting..."
        Exit
    }
}

Write-Host "------- START Exporting content ----------"
$ROOT_PATHS_LAST = $ROOT_PATHS | Select-Object -Last 1
$ROOT_PATHS | ForEach-Object {
    Write-Host "START Export $_"
    $LOG_FILENAME = "$_".Replace("/","-")

    Write-Host "Remove Filer..."
    Copy-Item ".\src\main\content\META-INF\vault\filter-blank.xml" -Destination "$FILTER_FILE"

    Write-Host "Create filter for: $_"
    $FILTER_XML = [xml](Get-Content $FILTER_FILE)
    $FILTER_XML_CONTENT = $FILTER_XML.SelectNodes("//workspaceFilter")
    $FILTER_XML_DELETE = $FILTER_XML_CONTENT.SelectNodes('//filter')
    $FILTER_XML_DELETE | ForEach-Object{
        $DELETE_STATUS = $FILTER_XML_CONTENT.RemoveChild($_)
    }
    $FILTER_XML_CONTENT_NEW = $FILTER_XML.CreateNode("element","filter","")
    $FILTER_XML_CONTENT_NEW.SetAttribute("root",$_)
    $FILTER_XML_CONTENT_NEW_ADD = $FILTER_XML_CONTENT.AppendChild($FILTER_XML_CONTENT_NEW)
    Write-Host "Saving..."
    $FILTER_XML.OuterXml | IndentXML -Indent 4 | Out-File $FILTER_FILE -encoding "UTF8"
    Write-Host "Done..."

    Write-Host "Running VLT..."
    Invoke-Expression -Command "${VLT_CMD} ${VLT_FLAGS} --credentials ${AEM_USER}:${AEM_PASSWORD} export -v ${AEM_SCHEMA}://${AEM_HOST}:${AEM_PORT}${SOURCE_WEBDAV_PATH} $_ ${CONTENT_DESTINATION}" | Tee-Object -FilePath "..\filevailt-export-$LOG_FILENAME.log"

    Write-Host "END Export $_"
}

Write-Host "------- END Exporting content ----------"

Write-Host "------- START Updating ${FILTER_FILE} ----------"

$FILTER_XML = [xml](Get-Content $FILTER_FILE)
Write-Host "Removing Existing Filters..."
$FILTER_XML_CONTENT = $FILTER_XML.SelectNodes("//workspaceFilter")
$FILTER_XML_DELETE = $FILTER_XML_CONTENT.SelectNodes('//filter')
$FILTER_XML_DELETE | ForEach-Object{
    $DELETE_STATUS = $FILTER_XML_CONTENT.RemoveChild($_)
}
Write-Host "Adding Exported Filters..."
$ROOT_PATHS | ForEach-Object {
    $FILTER_XML_CONTENT_NEW = $FILTER_XML.CreateNode("element","filter","")
    $FILTER_XML_CONTENT_NEW.SetAttribute("root",$_)
    $FILTER_XML_CONTENT_NEW_ADD = $FILTER_XML_CONTENT.AppendChild($FILTER_XML_CONTENT_NEW)
}
Write-Host "Saving..."
$FILTER_XML.OuterXml | IndentXML -Indent 4 | Out-File $FILTER_FILE -encoding "UTF8"
Write-Host "Done."
Write-Host "------- DONE Updating ${FILTER_FILE} ----------"
