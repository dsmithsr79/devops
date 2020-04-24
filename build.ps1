#
# Usage 
# . .\build.ps1 [ create | restore | restore2bookmark | reset | refresh | bookmark | delete ] [bookmark_name]
param (
    [String]$ACTION='',
    [String]$BM_NAME=''  
)#

# 
# Variables ...
#
$DLPX_GRP = "SQL_TDM"
$DLPX_DB = "delphix_demo"
$DLPX_VDB = "vdelphix_demo"

$date = Get-Date  
$DT = $date.ToString("yyyyMMddHHmmss") 

# 
# Process Action ...
#
if ("${ACTION}" -eq "create") {

   echo "Building ..."
   #. .\create_window_target_env.ps1

   . .\group_operations.ps1 create "${DLPX_GRP}"

   $DLPX_GRP = "SQL_TDM"
   $DLPX_DB = "delphix_demo"
   $DLPX_VDB = "vdelphix_demo"
   . .\provision_sqlserver_i.ps1 "${DLPX_DB}" "${DLPX_VDB}" "${DLPX_GRP}" "win1" MSSQLSERVER

   . .\jetstream_template_create.ps1 tpl delphix_demo ds
   . .\jetstream_container_create.ps1 tpl ds vdelphix_demo dc
   . .\jetstream_bookmark_create_from_latest.ps1 tpl dc baseline false 'tag123'

} elseif ("${ACTION}" -eq "break_fix") {

   echo "Create Break_Fix ..."
   $DLPX_GRP = "SQL_Break_Fix"
   . .\group_operations.ps1 create "${DLPX_GRP}"
   $DLPX_GRP = "SQL_Break_Fix"
   $DLPX_DB = "delphix_demo"
   $DLPX_VDB = "vbreak_fix"
   . .\provision_sqlserver_break_fix.ps1 "${DLPX_DB}" "${DLPX_VDB}" "${DLPX_GRP}" "win1" MSSQLSERVER
   
} elseif ("${ACTION}" -eq "restore") {

   echo "Restore ..."
   #. .\vdb_operations.ps1 rollback "${DLPX_VDB}"
   . .\jetstream_container_restore_to_bookmark.ps1 tpl dc baseline

} elseif ("${ACTION}" -eq "restore2bookmark") {

   echo "Restore to Bookmark ${BM_NAME} ..."
   if ( "${BM_NAME}" -ne "" ) {
      . .\jetstream_container_restore_to_bookmark.ps1 tpl dc "${BM_NAME}"
   } else { 
      echo "Warning: Missing Bookmark Name ${BM_NAME} ..."
   } 
} elseif ("${ACTION}" -eq "reset") {

   echo "Reset ..."
   . .\jetstream_container_reset.ps1 tpl dc 

} elseif ("${ACTION}" -eq "refresh") {

   echo "Refresh ..."
   #. .\vdb_operations.ps1 refresh "${DLPX_VDB}"
   . .\jetstream_container_refresh.ps1 tpl dc

} elseif ("${ACTION}" -eq "bookmark") {

   if ( "${BM_NAME}" -eq "" ) {
      $BM_NAME = "BM_${DT}"
   } 
   echo "Creating Bookmark ${BM_NAME} ..."
   . .\jetstream_bookmark_create_from_latest.ps1 tpl dc "${BM_NAME}" false 'api'

} elseif ("${ACTION}" -eq "delete") {

   echo "Clean Up ..."
   . .\jetstream_container_delete.ps1 tpl dc delete false
   . .\jetstream_template_delete.ps1 tpl delete

   $DLPX_VDB = "vdelphix_demo"
   . .\vdb_init.ps1 delete "${DLPX_VDB}"

   $DLPX_GRP = "SQL_TDM" 
   $DLPX_DB = "delphix_demo"
   $DLPX_VDB = "vdelphix_demo"
   . .\group_operations.ps1 delete "${DLPX_GRP}"

} else {

   echo "Usage: . .\build.ps1 [ create | restore | restore2bookmark | reset | refresh | bookmark | delete ] [bookmark_name]"

}
exit