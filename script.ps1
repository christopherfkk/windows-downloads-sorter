### Overview
### Step 1: Combine all image files into the "images" folder
### Step 2: Sort through the Minerva assignment PDFs
### Step 3: sort remaining files into their extensions


## Step 1: Combine all image files into the "images" folder

# Create images directory if not exists
$folderName = "C:\Users\Christopher Fok\Downloads\images"
if (-Not (Test-Path $folderName)) {
	New-Item $folderName -ItemType Directory
};

# Define some parameters
$sourcePath     = "C:\Users\Christopher Fok\Downloads";
$destPath       = "C:\Users\Christopher Fok\Downloads\images";
$imageExtensions  = '*.jpeg','*.tiff','*.jpg','*.jpeg', '*.HEIC', '*.jfif', '*.png';

# Get files in my Downloads folder with these extension, then move them
Get-ChildItem -Path $sourcePath -Recurse -Include $imageExtensions -File | Move-Item -Destination $destPath;


## Step 2: Sort through the Minerva assignment PDFs

# Create assignments directory if not exists
$folderName = "C:\Users\Christopher Fok\Downloads\minerva_assignments";
if (-Not (Test-Path $folderName)) {
	New-Item $folderName -ItemType Directory
};

# Define some parameters again
$sourcePath     = "C:\Users\Christopher Fok\Downloads";
$assignmentPath = "C:\Users\Christopher Fok\Downloads\minerva_assignments";
$pdfExtensions  = '*.pdf';

# Get .pdf files in my Downloads folder, filter by subject keywords in filename ("cs166-first-assignment"), then move them
Get-ChildItem -Path $sourcePath -Recurse -Include $pdfExtensions | where {$_ -like '*CS*' -or $_ -like '*SS*'-or $_ -like '*CP*'} | move-item -Destination $assignmentPath;

## Step 3: sort remaining files into their extensions

function Sort-Files {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$cwd = (Get-Location).Path
    )

    #$filecount = Get-Childitem $cwd -file | Group-Object Extension -NoElement | Sort-Object count -desc

    # Gather the extensions of the files in the folder path
    $extforfolders = Get-ChildItem $cwd -File -Exclude *.ps1 | Select-Object Extension
    # Gather the list of files only
    $files = Get-ChildItem $cwd -File

    # Create a new list to add the extensions to
    $extensions = New-Object Collections.Generic.List[String]

    Write-Host "Getting files and creating subfolders of extensions if it does not exist..."
    foreach($folder in $extforfolders){
        # Use the .NET class to create a directory. If it exits will proceed. If not exists, will create the directory
        [System.IO.Directory]::CreateDirectory("$cwd\$($folder.Extension)") | Out-Null
        # Add every extension to the list. Will sort later.
        $extensions.Add($folder.Extension)
    }

    if ($extensions.Count -gt 0) {
        foreach ($file in $files) {
            try {
                Write-Host "Moving $($file) to folder: $cwd\$($file.Extension)"
                # If File exists or in use ErrorAction Stop so we can catch the error properly
                # Using $file.FullName to get long path of file since script/function may not always be in the same directory as files. 
                Move-Item $file.FullName -Destination "$cwd\$($file.Extension)" -Force -ErrorAction Stop
            }
            catch { 
                Write-Warning "Failed to move file '$file' to folder '$($file.Extension)'. File either exists in folder or is in use."
            }
        }
        
        Write-Host "Summary of Sorting Files"
        # Group and count the extentions
        $extensions | Group-Object -NoElement | Sort-Object count -Descending
    } else {
        Write-Host "No files to sort here: $cwd"
    }
}

# Call the Sort-Files function with the current user's downloads
Sort-Files -cwd $env:USERPROFILE\downloads
