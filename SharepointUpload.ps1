$webUrl  = "http://contoso.com";  #http://contoso.com Replace with your Site Url

$docLibraryName = "Documents"; ##Documents - Replace with your library name

$docFolderName =  "SharePoint"; ##SharePoint - Replace with Folder name if you have sub folders in Library

$docNumber = "SeachDocument.docx"; ##SeachDocument.docx - Replace with File name which you will have in file share location

try
  {

   $inputRowCollection = Get-ChildItem $DocumentsRepositoryPath -Recurse | Where-Object {$_.Name -like $docNumber+ "*"}

   if($inputRowCollection.Count -eq 0)
   {
    $row.IsMigrated = "File Missing"
   }

   if($inputRowCollection.Count -eq 1)
   {
    $row.IsMigrated = UploadFileInLibrary $webUrl  $docLibraryName $inputRowCollection.PSPath $docFolderName
   }
   elseif($inputRowCollection.Count -ge 1)
   {
    $row.IsMigrated = "Duplicate Documents"
   }
  }          
  catch          
  {
   Write-Host "File Path : ($inputRowCollection.PSPath) - Error ($documentData): "$_.Exception -f Red;
   Write-Output "File Path : ($inputRowCollection.PSPath) - Error ($documentData): "$_.Exception >> $ExceptionLogFile
   $logData = $logData + "`tNA`t" + $_.Exception + "`tFail`tNA"  
  }

#Function to upload Document into SharePoint library
function UploadFileInLibrary          
{
 [CmdletBinding()]          
 Param(          
 [Parameter(Mandatory=$true,ValueFromPipeline=$true)]          
 [string]$webUrl,          
 [Parameter(Mandatory=$true)]          
 [string]$DocLibName,          
 [Parameter(Mandatory=$true)]          
 [string]$FilePath,            
 [Parameter(Mandatory=$false)]          
 [string]$FolderName
 )              

  try
  {

 #region Code for Migration

 $spWeb = Get-SPWeb -Identity $webUrl

 $List = $spWeb.Lists[$DocLibName]          
 $folder = $List.RootFolder          
 if($FolderName -ne "")
 {
  $folder = $list.RootFolder.SubFolders[$FolderName]
 }
 $FileName = $FilePath.Substring($FilePath.LastIndexOf("\")+1)          
 $File= Get-ChildItem $FilePath  
 $fileExtension = ([System.IO.FileInfo] (Get-Item $File.FullName)).Extension
 [Microsoft.SharePoint.SPFile]$spFile = $spWeb.GetFile($folder.Url + "/" + $docNumber+$fileExtension)          
 $flagConfirm = 'y'          
 if($spFile.Exists -eq $true)          
 {          
 #    $flagConfirm = Read-Host "File $FileName already exists in library $DocLibName, do you    want to upload a new version(y/n)?"          
  return "Document Exist."
 }          

 if ($flagConfirm -eq 'y' -or $flagConfirm -eq 'Y')          
 {
  $spWeb.AllowUnsafeUpdates = $true;

  $fileStream = ([System.IO.FileInfo] (Get-Item $File.FullName)).OpenRead()
  $fileExtension = ([System.IO.FileInfo] (Get-Item $File.FullName)).Extension
    #Add file          
    write-host -NoNewLine -f yellow "Copying file " $File.Name " to " $folder.ServerRelativeUrl "..."          
    [Microsoft.SharePoint.SPFile]$spFile = $folder.Files.Add($folder.Url + "/" + $docNumber+$fileExtension, [System.IO.Stream]$fileStream, $true)          
    write-host -f Green "...Success!"          
    #Close file stream          
    $fileStream.Close()          
    write-host -NoNewLine -f yellow "Update file properties " $spFile.Name "..."

  #Check the whether exists or not in site
  $docContentType = $docContentType   

  if($docContentType -eq $IMS)
  {
   $docContentType = $List.ContentTypes[$docContentType]
   $spFile.Item["ContentTypeId"] = $docContentType.Id;
   $spFile.Item["Content Type"] = $docContentType.Name;
   $spFile.Item["Name"] = $docNumber
   $spFile.Item["Title"] = $docTitle     
   $spFile.Item.Update()          
   write-host -f Green "...Success!"
   $spFile.CheckIn("Checked In By Administrator");
            Write-Host "$($spFile.Name) Checked In" -ForeGroundColor Green
  } 

  $spWeb.AllowUnsafeUpdates = $false;
 }


 return "Uploaded";

 #endregion

 }
 catch
 {
  Write-Host "File Path : ($inputRowCollection.PSPath) - Error in DocumentsMigration method : "$_.Exception -f Red;
  Write-Output "File Path : ($inputRowCollection.PSPath) - Error in DocumentsMigration method: "$_.Exception >> $ExceptionLogFile
  return "Error while uploading";
 }
}