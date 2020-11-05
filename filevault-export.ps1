Param(
    #equivalent of using localhost in docker container
    [string]$SOURCE_HOST = "localhost",
    # TCP port SOURCE_CQ listens on
    [string]$SOURCE_PORT = "4502",
    # AEM Admin user for SOURCE_HOST
    [string]$SOURCE_AEM_USER = "admin",
    # AEM Admin password for SOURCE_HOST
    [string]$SOURCE_AEM_PASSWORD = "admin",
    # Server WebDav Path
    #$SOURCE_WEBDAV_PATH = "/crx/server/crx.default/jcr:root/"
    [string]$SOURCE_WEBDAV_PATH = "/crx",
    [string]$SCHEMA = "http",
    #to set additional flags if required
    [string]$VLT_FLAGS = "--insecure",
    [string]$VLT_CMD = "./bin/vlt",
    # Root folder name for placing content
    [string]$CONTENT_DESTINATION = ".\src\main\content",
    [string]$FILTER_FILE = "${CONTENT_DESTINATION}\META-INF\vault\filter.xml",
    [string]$FILTER_FILE_LOCATION = "${CONTENT_DESTINATION}\META-INF",
    [string[]]$ROOT_PATHS = (
        "/content/dam/",
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
Write-Host "SCHEMA: $SCHEMA"
Write-Host "SOURCE_HOST: $SOURCE_HOST"
Write-Host "SOURCE_PORT: $SOURCE_PORT"
Write-Host "SOURCE_AEM_USER: $SOURCE_AEM_USER"
Write-Host "CONTENT_DESTINATION: $CONTENT_DESTINATION"
Write-Host "ROOT_PATHS: $ROOT_PATHS"
Write-Host "FILTER_FILE: $FILTER_FILE"
Write-Host "Silent: $Silent"
Write-Host "VLT_FLAGS: $VLT_FLAGS"
Write-Host "VLT_CMD:"

$ROOT_PATHS | ForEach-Object {
    Write-Host "${VLT_CMD} ${VLT_FLAGS} --credentials ${SOURCE_AEM_USER}:****** export -v ${SCHEMA}://${SOURCE_HOST}:${SOURCE_PORT}${SOURCE_WEBDAV_PATH} $_ ${CONTENT_DESTINATION}"
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

    Invoke-Expression -Command "${VLT_CMD} ${VLT_FLAGS} -Xmx2g --credentials ${SOURCE_AEM_USER}:${SOURCE_AEM_PASSWORD} export -v ${SCHEMA}://${SOURCE_HOST}:${SOURCE_PORT}${SOURCE_WEBDAV_PATH} $_ ${CONTENT_DESTINATION}" | Tee-Object -FilePath "..\filevailt-export-$LOG_FILENAME.log"
    # Need to delete Filter File so that export process does not get confused
    if (-Not($_ -eq $ROOT_PATHS_LAST)) {
        if (-Not($FILTER_FILE_LOCATION.StartsWith("./"))) {
            Remove-Item $FILTER_FILE
        }
    }
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
