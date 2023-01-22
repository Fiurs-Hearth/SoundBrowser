# SoundBrowser
A WotLK sound browsing addon  
  
# Installation  
  
## Preparing sound data  
  
Export the dbc.  
Click File -> Export Strings as Patch...  
(See image below)  
  
![image](https://user-images.githubusercontent.com/97316608/213922538-12f98450-7d3a-443b-8aa7-29bbca56c30e.png)  
  
Save it as a `.txt`.  
Open it up, select all of the content with Ctrl-A.  
Go into the addon's folder and open SoundEntries.lua  
Paste the content from the `.txt` file into the `soundEntryDBC = [[PASTE HERE]]` table. (See image below)  
  
Start of the table should look like this after it has been pasted.  
  
![image](https://user-images.githubusercontent.com/97316608/213922714-b3e8224e-c8ef-4689-affd-9d7ced83a7f8.png)  
  
End of the table should look like this after it has been pasted.  
  
![image](https://user-images.githubusercontent.com/97316608/213922982-31ceb211-8dd4-404d-9be4-d91f277a3793.png)  
  
Save the file.  

