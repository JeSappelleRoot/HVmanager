



# ---------------------------------------------------------------------------------------
function displayBanner() {
# With a banner, it's always better ! \o/

    Clear-Host

   Write-Host "
   
   
   _    ___      __                                          
  | |  | \ \    / /                                          
  | |__| |\ \  / / __ ___   __ _ _ __   __ _  __ _  ___ _ __ 
  |  __  | \ \/ / '_ ' _ \ / _' | '_ \ / _' |/ _' |/ _ \ '__|
  | |  | |  \  /| | | | | | (_| | | | | (_| | (_| |  __/ |   
  |_|  |_|   \/ |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|   
                                              __/ |          
                                             |___/           
 "



    return
}


# ---------------------------------------------------------------------------------------
function setVM ($template) {
#Function to create a virtual machine with different attributes



    # Initialize a powershell hashtable
    $machineProperties = @{}

    # Add $parentDisk to machine properties
    $machineProperties['parentDisk'] = $template

    # Get the max number of VCPU allowed by Hyper-V,  the number of logical CPU on host hardware
    $maxCPU =  (Get-WmiObject -class Win32_processor).NumberOfLogicalProcessors
    
    # Get all available switch
    $allVirtualSwitch = (Get-VMSwitch).Name

    # Get all existing virtual machines
    $allVirtualMachines = (Get-VM | Select-Object -Property Name)

    # Get the name of the virtual machine to create
    $loop = $true
    while ($loop) {
        displayBanner
        $name = Read-Host "[?] Which name for the virtual machine "
        if (-not($name)) {
            Write-Host '[!] Please specify a non empty name'
            Start-Sleep  -Seconds 2
        }
        elseif ($allVirtualMachines | Where-Object {$_.Name -match $name}) {
            Write-Host '[!] Name' $name 'is already use, specify another one'
            Start-Sleep  -Seconds 2
        }

        else{
            $machineProperties['name'] = $name
            Break
        }
    }

    # Set the generation of the virtual machine (generation 1 or 2)
    $loop = $true
    while ($loop) {
        displayBanner
        $generation = Read-Host "[?] Which generation do you want to use (1/2) "
        if ($generation -ne 1 -and $generation -ne 2) {
            Write-Host '[!] Please specify a generation with 1 or 2'
            Start-Sleep  -Seconds 2
        }
        else{
            $machineProperties['generation'] = $generation
            Break
        }
    }



    # Get the number of VCPU 
    $loop = $true
    while ($loop) {
        displayBanner
        $cpu = Read-Host "[?] How many VCPU ? ($($maxCPU) max) "
        if ($cpu -lt 1 -or $cpu -gt $maxCPU) {
            Write-Host "[!] Please specify a number of CPU between 1 and $($maxCPU)"
            Start-Sleep  -Seconds 2
        }
        else{
            $machineProperties['cpu'] = $cpu
            Break
        }
    }

    # Get the quantity of memory 
    $loop = $true
    while ($loop) {
        displayBanner
        [int64]$memory = Read-Host "[?] How many memory ? (256/512/1024/2048/4096)"
        if (($memory -ne 256) -and($memory -ne 512) -and ($memory -ne 1024) -and ($memory -ne 2048) -and ($memory -ne 4096)) {
            Write-Host "[!] Please specify memory quantity in 256/512/1024/2048/4096"
            Start-Sleep  -Seconds 2
        }
        else{
            $machineProperties['memory'] = $memory
            Break
        }
    }

    # Set the switch used by virtual machine
    $loop = $true
    while ($loop) {
        displayBanner
        
        $count = 1
        foreach ($switchName in $allVirtualSwitch) {
            Write-Host "$count. $switchName"
            $count++
        }

        $vSwitch = Read-Host "`n[?] Which virtual switch use "
        if ($vSwitch -lt 1 -or $vSwitch -gt ($count - 1)) {
            Write-Host "[!] Please specify a switch number between 1 and $($count - 1)"
            Start-Sleep  -Seconds 2
        }
        else{
            $machineProperties['switch'] = $allVirtualSwitch[$vSwitch - 1]
            Break
        }
    }

    # Final loop the show a resume and ask for creation confirmation
    $loop = $true
    While ($loop) {
        
        displayBanner
        
        Write-Host "-------------------- Resume --------------------"
        
        Write-Host "Name of virtual machine :" $machineProperties['name']
        Write-Host "Generation of the virtual machine : Generation" $machineProperties['generation']
        Write-Host "Parent disk of virtual machine :" $machineProperties['parentDisk']
        Write-Host "Number of virtual CPU :" $machineProperties['cpu']
        Write-Host "Quantity of memory :" $machineProperties['memory']
        Write-Host "Virtual switch used :" $machineProperties['switch']
        Write-Host `n
    
        $confirm = Read-Host "[?] Do you confirm creation (y/n)"
        
        if ($confirm -ne 'y' -and $confirm -ne 'n') {
            Write-Host "[!] Please confirm with [y] or don't with [n]"
            Start-Sleep 2
        }
        elseif ($confirm -eq 'y') {return $machineProperties}
        elseif ($confirm -eq 'n') {Exit}
    }
}

# ---------------------------------------------------------------------------------------
function createVM([hashtable]$properties,$configPath,$hddPath) {
# Function to create a virtual machine in Hyper-V hypervisor
    displayBanner

    # Get all specs of virtual machine
    $name = $properties['name']
    $generation = $properties['generation']
    $cpu = $properties['cpu']
    $memory = $properties['memory']
    $vSwitch = $properties['switch']

    # Set parent disk and child disk
    #Replace space by underscore in virtual disk name
    $parentDisk = $properties['parentDisk']
    $diskExtension = $parentDisk.ToString().Split('.')[-1]
    $diskName = "$($name.Replace(' ','_')).$($diskExtension)"
    $childDiskPath = "$hddPath\$($name.Replace(' ','_'))\$diskName"

    # Display an auto adaptative header with name of virtual machine 
    # \o/
    $header = "Creation of virtual machine : $name"
    Write-Host $header
    Write-Host $('-' * $header.Length)

# Try differencing disk creation
try {
    Write-Host "[+] Create differencing disk"
    New-VHD -ParentPath $parentDisk -Path $childDiskPath -Differencing | Out-Null
    if ($?) {Write-Host "[+] Successfully create virtual disk"}
}
catch {$_.Exception.Message}

# Try virtual machine creation
try {
    Write-Host "[+] Create virtual machine $name"
    $machine = @{
        Name = $name
        MemoryStartupBytes = $memory * 1MB
        Generation = $generation
        VHDPath = $childDiskPath
        SwitchName = $vSwitch
        Path = $configPath
    }

    New-VM @machine | Out-Null
    if ($?) {Write-Host "[+] Successfully created virtual machine"}

}
catch {$_.Exception.Message}

# Try to change the number of CPU
try {
    Write-Host "[+] Set CPU specifications"
    Set-VMProcessor $name -count $cpu
}
catch {$_.Exception.Message}

# Trye to disable automatic snapshot
try {Set-VM -VMName $name -AutomaticCheckpointsEnabled $False}
catch {$_.Exception.Message}

Write-Host "`n[+] Virtual machine successfully created"

Start-Sleep -Seconds 3

return displayMenu
}


# ---------------------------------------------------------------------------------------
function getInfo($name) {
#Function to display info about a specific virtual machine

	try {

		displayBanner

		$header = "Informations about $name virtual machine"
		# Automatic header separator
		$separator = '-' * $header.Length
		Write-Host $header
		Write-Host $separator`n

		# Display info
		Write-Host "- Virtual machine status :" (Get-VM $name).state
		Write-Host "- Quantity of memory : " $((Get-VM $name).MemoryStartup / 1MB) "MB"
		Write-Host "- Number of VCPU :" (Get-VM $name).ProcessorCount
		Write-Host "- Virtual machine from generation :" (Get-VM $name).Generation
		Write-Host "- Virtual disk used :" (Get-VM $name  | Select-Object VMId | Get-VHD).Path
		Write-Host "- Parent disk used :" (Get-VM $name | Select-Object VMid | Get-VHD).ParentPath
		Write-Host "- Switch used :" (Get-VM $name).NetworkAdapters.SwitchName
		Write-Host `n

		$end = Read-Host "[+] Press enter to return at menu"

		return displayMenu
	}

	catch {$_.Exception.Message}

}
# ---------------------------------------------------------------------------------------
function deleteMachine($name) {
#Function to delete a virtual machine

	try {

		# Get state of virtual machine
		# If virtual machine is running, delete is deny
		$state = (Get-VM $name).State
		if ($state -eq 'Running') {
			Write-Host "`n[!] The virtual machine is running, stop it before suppression"
			Start-Sleep -Seconds 2
			return displayMenu
		}
		else {
		#Else if virtual machine is not running
		#Get config folder of virtual machine
		$config = (Get-VM $name).Path
		# Get virtual disk folder of virtual machine
		$vhdPath = (Get-VM $name |`
					Select-Object -Property VMid |`
					Get-VHD | Split-Path -Parent
                    )

		# Remove VM, config and virtual disk
		Remove-VM $allVirtualMachine[$choice - 1]
		Remove-Item -Path $config -Recurse
		Remove-Item -Path $vhdPath -Recurse
		Write-Host "[+] Virtual machine $name successfully deleted"
		Start-Sleep -Seconds 2
		} 

		return displayMenu
	}

	catch {$_.Exception.Message}
}




# ---------------------------------------------------------------------------------------
function checkConfig ($template,$config,$vhd) {
#Function to check the initial configuration

	try {

    displayBanner

    #Initialize a error counter
    $error = 0

    # If the config folder does not exist
    if (-not(Test-Path $config)) {
        Write-Host "[!] The config folder $config does not exist"
        $error ++
    }
    # If the virtual disk folder does not exist
    if (-not(Test-Path $vhd)) {
        Write-Host "[!] The virtual disk folder $vhd does not exist"
        $error ++
    }

    # Get templates files
    $files = (
              Get-ChildItem $template -ErrorAction SilentlyContinue|`
              Where {$_.Extension -match '.vhdx' -or $_.Extension -match '.vhd'}
              )
    # If no template detected
    if (($files | Measure-Object).Count -lt 1) {
        Write-Host "[!] No virtual machine templates detected"
        $error ++
    }

    # If error greater than 0, errors detected
    # Quit script !
    if ($error -gt 0) {Exit}


    return

	}

	catch {$_.Exception.Message}
}


# ---------------------------------------------------------------------------------------
function displayMenu() {
#  Function to get user choice


    # Define folder which contain VHD and VHDX
    # EDIT THESE 3 VARIABLES
    $templateFolder = 'E:\Partition 2\WM'
    $configPath = 'D:\HYPERV\VMs'
    $vhdPath = 'D:\HYPERV\HDD'

    # Get defined folder by user before running script
    checkConfig $templateFolder $configPath $vhdPath

    $loop = $true
    while ($loop) {

        displayBanner

        "
        1. Create a virtual machine
        2. Information about a virtual machine
        3. Delete a virtual machine
        
        q. Quit
        
        "
        $choice = Read-Host "[?] What do you want to do "

        if ($choice -ne '1' -and $choice -ne 2 -and $choice -ne 3 -and $choice -ne 'q') {
            Write-Host "Please make a choice between 1 and 3, or q to quit HV-Manager"
            Start-Sleep -Seconds 2
        }
        else {break}

    }

    switch ($choice) {

        # Choice for virtual machine creation
        '1' {

            # Get all virtual disk available in template folder
            $allVirtualDisks =  Get-ChildItem $templateFolder | `
                                Where-Object {$_.Extension -match '.vhdx' -or $_.Extension -match '.vhd'} | `
                                Select-Object -Property Name, BaseName, Extension, FullName
            
            
            # Choose a template
            $loop = $true
            While ($loop -eq $true) {
                displayBanner
                
                $count = 1
                foreach ($template in $allVirtualDisks.BaseName) {
                    "$count. " + $template
                    $count++
                }
                Write-Host ""
                [int32]$choice = Read-Host "Which template use ? "
                if (($choice -lt 1 -or $choice -gt $count - 1) -or ($choice.ToString() -notmatch '(^\d+$)')) {
                    Write-Host "[!] Please make a choice between 1 and $($count - 1)"
                    Start-Sleep -Seconds 2
                }    
                else {Break}
            }
            
            $chooseTemplate = ($allVirtualDisks[$choice - 1].FullName)
            
            # Configure virtual machine options (Name, CPU, RAM, switch...) and store values in hashtable
            $characteristics = (setVM $chooseTemplate)
            
            # Create the virtual machine with all parameters
            createVM $characteristics $configPath $vhdPath

        }

        # If user want to get info about a virtual machine
        '2' {

            [array]$allVirtualMachine = (Get-VM).Name


            $loop = $true

            while ($loop) {
                $count = 1
                displayBanner
                foreach ($virtualMachine in $allVirtualMachine) {
                    Write-Host "$count. $VirtualMachine"
                    $count ++
                }
                Write-Host `n
                $choice = Read-Host "[?] Info about which virtual machine "
                if ($choice -lt 1 -or $choice -ge $count) {
                    Write-Host "[!] Please specify a choice between 1 and $($count - 1) or all"
                    Start-Sleep -Seconds 2        
                }

                else {Break}
            }

            getInfo $allVirtualMachine[$choice - 1]

    }

        # If user want to delete a virtual machine
        '3' {

            [array]$allVirtualMachine = (Get-VM).Name
            $loop = $true

            while ($loop) {
                $count = 1
                displayBanner

                foreach ($virtualMachine in $allVirtualMachine) {
                    Write-Host "$count. $VirtualMachine"
                    $count ++
                }
                Write-Host `n
                $choice = Read-Host "[?] Which virtual machine delete "
                if ($choice -lt 1 -or $choice -ge $count) {
                    Write-Host "[!] Please specify a choice between 1 and $($count - 1) or all"
                    Start-Sleep -Seconds 2        
                }
                else {Break}
            }

            deleteMachine $allVirtualMachine[$choice - 1]

        }

        # If user want to quit the script
        'q' {Exit}

    }

    return
}
   

# -------------------------------------------------------------------------
# -------------------------- Begin of the script --------------------------
# -------------------------------------------------------------------------

displayMenu


