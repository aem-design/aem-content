
$SCRIPT_PATH = Split-Path $MyInvocation.MyCommand.Path -Parent
$VLT_HOME=(Convert-Path "${SCRIPT_PATH}\..")
$JAVACMD="java"
$REPO="${VLT_HOME}\lib"
$CMD_LINE_ARGS = $PsBoundParameters.Values + $args
$VLT_OPTS="-Xms500m -Xmx2g"
#$VLT_OPTS=-Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000

#$CLASSPATH="${REPO}\org.apache.jackrabbit.vault-3.4.1-SNAPSHOT.jar;${REPO}\vault-vlt-3.4.1-SNAPSHOT.jar;${REPO}\jackrabbit-jcr-commons-2.19.6-SNAPSHOT.jar;${REPO}\vault-diff-3.4.1-SNAPSHOT.jar;${REPO}\diffutils-1.2.1.jar;${REPO}\commons-io-2.5.jar;${REPO}\vault-sync-3.4.1-SNAPSHOT.jar;${REPO}\commons-jci-fam-1.0.jar;${REPO}\commons-logging-api-1.1.jar;${REPO}\org.apache.sling.jcr.api-2.0.6.jar;${REPO}\org.apache.sling.commons.osgi-2.0.6.jar;${REPO}\vault-davex-3.4.1-SNAPSHOT.jar;${REPO}\jackrabbit-jcr-client-2.19.6-SNAPSHOT.jar;${REPO}\jackrabbit-spi-2.19.6-SNAPSHOT.jar;${REPO}\jackrabbit-spi-commons-2.19.6-SNAPSHOT.jar;${REPO}\commons-collections-3.2.2.jar;${REPO}\jackrabbit-jcr2spi-2.19.6-SNAPSHOT.jar;${REPO}\oak-jackrabbit-api-1.18.0.jar;${REPO}\jackrabbit-spi2dav-2.19.6-SNAPSHOT.jar;${REPO}\httpmime-4.5.3.jar;${REPO}\jackrabbit-webdav-2.19.6-SNAPSHOT.jar;${REPO}\httpcore-4.4.12.jar;${REPO}\httpclient-4.5.3.jar;${REPO}\commons-logging-1.0.3.jar;${REPO}\commons-codec-1.10.jar;${REPO}\jcl-over-slf4j-1.7.26.jar;${REPO}\commons-cli-2.0-mahout.jar;${REPO}\jline-0.9.94.jar;${REPO}\jcr-2.0.jar;${REPO}\slf4j-api-1.7.6.jar;${REPO}\slf4j-log4j12-1.7.6.jar;${REPO}\log4j-1.2.12.jar;${REPO}\vault-cli-3.4.1-SNAPSHOT.jar"
$CLASSPATH="${REPO}\" + ((get-content ${SCRIPT_PATH}\class.list) -join ";${REPO}\")

$JAVA_COMMAND="${JAVACMD} ${VLT_OPTS} -classpath ""${env:CLASSPATH_PREFIX};${VLT_HOME}\etc;${CLASSPATH}"" -D""app.name=vlt"" -D""app.repo=${REPO}"" -D""app.home=${VLT_HOME}"" -D""vlt.home=${VLT_HOME}"" org.apache.jackrabbit.vault.cli.VaultFsApp ${CMD_LINE_ARGS}"

Write-Output "------- CONFIG ----------"
Write-Output "SCRIPT_PATH: $SCRIPT_PATH"
Write-Output "VLT_HOME: $VLT_HOME"
Write-Output "JAVACMD: $JAVACMD"
Write-Output "REPO: $REPO"
Write-Output "CMD_LINE_ARGS: $CMD_LINE_ARGS"
Write-Output "VLT_OPTS: $VLT_OPTS"
Write-Output "CLASSPATH: $CLASSPATH"
Write-Output "JAVA_COMMAND: $JAVA_COMMAND"

Invoke-Expression -Command $JAVA_COMMAND

