# HVmanager

HVmanager is a PowerShell script to manager virtual machines on Hyper-V hypervisor. 

With the script you can : 
- create virtual machine from a template
- get information about a specific virtual machine
- delete an inused virtual machine


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

## Machine creation

HVmanager will ask you informations about the new virtual machine to create : 
- the name of the virtual machine
- the generation (view https://www.nakivo.com/blog/hyper-v-generation-1-vs-2/ for more details)
- the number of VCPU
- the quantity of memory
- the virtual switch used by the virtual machine

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
Name of virtual machine : VM demonstration
Generation of the virtual machine : Generation 1
Parent disk of virtual machine : E:\Partition 2\WM\DEB9_template.vhd
Number of virtual CPU : 4
Quantity of memory : 1024
Virtual switch used : Switch sortant


[?] Do you confirm creation (y/n) : 
```