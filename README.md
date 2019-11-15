# HVmanager

HVmanager is a PowerShell script to manager virtual machines on Hyper-V hypervisor. 

With the script you can : 
- create virtual machine from a template
- get information about a specific virtual machine
- delete an inused virtual machine

**HVmanager was writted with PowerShell 5.1, check your version with ```Get-Host``` if you have issue with the script**

## Configuration in the script

To use the script, you need to edit 3 variables on ```displayMenu``` function : 
- ```$templateFolder``` is the folder which contains your virtual machine templates
- ```$configPath``` is the path of configuration folder set in Hyper-V
- ```$vhdPath``` is the path of virtual disk folder set in Hyper-V

**Before launch script, make sure you have set the goods settings. HVmanager will automatic check these folder at startup**

>Configuration folder set in Hyper-V
![config](https://user-images.githubusercontent.com/52102633/60756644-2c964300-a000-11e9-9270-d116a4ef5671.png)  

>Virtual disks folder set in Hyper-V
![vhd](https://user-images.githubusercontent.com/52102633/60756645-2dc77000-a000-11e9-9f7c-5883662cd500.png)

```powershell
function displayMenu() {
#  Function to get user choice


# Define folder which contain VHD and VHDX
# EDIT THESE 3 VARIABLES
$templateFolder = 'E:\WM'
$configPath = 'D:\HYPERV\VMs'
$vhdPath = 'D:\HYPERV\HDD'

[...]
```



## Machine creation

HVmanager will ask you informations about the new virtual machine to create : 
- the name of the virtual machine
- the generation (view https://www.nakivo.com/blog/hyper-v-generation-1-vs-2/ for more details)
- the number of VCPU
- the quantity of memory
- the virtual switch used by the virtual machine

### Differencing disk

To get a quick creation, HVmanager create a differencing disk. 

The template disk is use for reading data needs by the guest system. The differencing disk will be used to write modifications.
This method is very fast but performances are a little bit weak, because of constant reading and writting on 2 virtuals disks.


HVmanager will create folders with the virtual machine name in : 
- `$configPath` define in the displayMenu function
- `$vhdPath` define in the displayMenu function



**The differencing disk will have the same extension as the parent disk**

> Resume of settings before create a machine
```
   
   _    ___      __                                          
  | |  | \ \    / /                                          
  | |__| |\ \  / / __ ___   __ _ _ __   __ _  __ _  ___ _ __ 
  |  __  | \ \/ / '_ ' _ \ / _' | '_ \ / _' |/ _' |/ _ \ '__|
  | |  | |  \  /| | | | | | (_| | | | | (_| | (_| |  __/ |   
  |_|  |_|   \/ |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|   
                                              __/ |          
                                             |___/           
 
-------------------- Resume --------------------
Name of virtual machine : VM demo
Generation of the virtual machine : Generation 1
Parent disk of virtual machine : E:\WM\DEB9_template.vhd
Number of virtual CPU : 4
Quantity of memory : 1024
Virtual switch used : Out switch


[?] Do you confirm creation (y/n) : 
```

>Successfull creation 
```
   _    ___      __                                          
  | |  | \ \    / /                                          
  | |__| |\ \  / / __ ___   __ _ _ __   __ _  __ _  ___ _ __ 
  |  __  | \ \/ / '_ ' _ \ / _' | '_ \ / _' |/ _' |/ _ \ '__|
  | |  | |  \  /| | | | | | (_| | | | | (_| | (_| |  __/ |   
  |_|  |_|   \/ |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|   
                                              __/ |          
                                             |___/           
 
Creation of virtual machine : VM demo
--------------------------------------
[+] Create differencing disk
[+] Successfully create virtual disk
[+] Create virtual machine VM demo
[+] Successfully created virtual machine
[+] Set CPU specifications

[+] Virtual machine successfully created
```



## Getting informations about a virtual machine

HVmanager can retrieve informations about a virtual machine 

```
   _    ___      __                                          
  | |  | \ \    / /                                          
  | |__| |\ \  / / __ ___   __ _ _ __   __ _  __ _  ___ _ __ 
  |  __  | \ \/ / '_ ' _ \ / _' | '_ \ / _' |/ _' |/ _ \ '__|
  | |  | |  \  /| | | | | | (_| | | | | (_| | (_| |  __/ |   
  |_|  |_|   \/ |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|   
                                              __/ |          
                                             |___/           
 
Informations about VM demo virtual machine
---------------------------------------------------

- Virtual machine status : Off
- Quantity of memory :  1024 MB
- Number of VCPU : 4
- Virtual machine from generation : 1
- Virtual disk used : D:\HYPERV\HDD\VM_demo\VM_demonstration.vhd
- Parent disk used : E:\WM\DEB9_template.vhd
- Switch used : Out switch


[+] Press enter to return at menu : 
```


## Delete a virtual machine

HVmanager can delete a virtual machine and all related files (config folder, virtual disk folder). HVmanager will check if the virtual machine is running before suppression. In this case, suppression is deny.

>**This action can't be undo, be carefull with this function**

* Try to suppress a running virtual machine

```
   _    ___      __                                          
  | |  | \ \    / /                                          
  | |__| |\ \  / / __ ___   __ _ _ __   __ _  __ _  ___ _ __ 
  |  __  | \ \/ / '_ ' _ \ / _' | '_ \ / _' |/ _' |/ _ \ '__|
  | |  | |  \  /| | | | | | (_| | | | | (_| | (_| |  __/ |   
  |_|  |_|   \/ |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|   
                                              __/ |          
                                             |___/           
 
1. VM demo
2. Windows 7 Home Premium x64

[?] Which virtual machine delete  : 1

[!] The virtual machine is running, stop it before suppression
```

* Try to suppress a non running virtual machine 

```
   _    ___      __                                          
  | |  | \ \    / /                                          
  | |__| |\ \  / / __ ___   __ _ _ __   __ _  __ _  ___ _ __ 
  |  __  | \ \/ / '_ ' _ \ / _' | '_ \ / _' |/ _' |/ _ \ '__|
  | |  | |  \  /| | | | | | (_| | | | | (_| | (_| |  __/ |   
  |_|  |_|   \/ |_| |_| |_|\__,_|_| |_|\__,_|\__, |\___|_|   
                                              __/ |          
                                             |___/           
 
1. VM demo
2. Windows 7 Home Premium x64


[?] Which virtual machine delete  : 1
COMMENTAIRES : Remove-VM supprimera l'ordinateur virtuel « VM demo ».
COMMENTAIRES : Opération « Supprimer le répertoire » en cours sur la cible « D:\HYPERV\VMs\VM demo ».
COMMENTAIRES : Opération « Supprimer le répertoire » en cours sur la cible « D:\HYPERV\VMs\VM demo\Virtual Machines ».
COMMENTAIRES : Opération « Supprimer le répertoire » en cours sur la cible « D:\HYPERV\HDD\VM_demo ».
COMMENTAIRES : Opération « Supprimer le fichier » en cours sur la cible « D:\HYPERV\HDD\VM_demo\VM_demo.vhd ».
[+] Virtual machine VM demo successfully deleted
```