# Solarwinds-Orion-to-Spider-API-sync
Powershell script for updating Spider(6.4.6.2876) database using Solarwinds Orion NCM database(2020.2.5)<br>
Required Powershell module sqlserver.


![SolarSpider_Data_Schema_Model](https://user-images.githubusercontent.com/106514761/176888458-2c6668fa-f056-454b-9e38-c5c96e5edf75.jpg)


Required Report Fields:<br>
  Identifier<br>	
	Object name<br>
	Name<br>	
	Hostname<br>	
	IP Address<br>	
	Business Unit<br>	
	Division<br>	
	Region<br>	
	Country<br>	
	Asset number<br>	
	Asset Type<br>	
	Asset status<br>	
	Asset Model<br>	
	Serial Number<br>		
	City<br>	
	Street or Building<br>	
	Legal Entity<br>	
	Location<br>
Also Spider's report should be sorted by Switch System Asset\Function Units.<br>

![SolarSpider_Flow_Chart](https://user-images.githubusercontent.com/106514761/176888324-587784a9-c3ef-4809-9bf1-0cc8ea286bc2.jpg)
