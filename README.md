# SoundBrowser
  
![sb_thumbnail](https://user-images.githubusercontent.com/97316608/213938141-4501318a-5f82-4491-942b-6bee521aba67.png)  
  
A WotLK sound browsing addon  
  
# Features  
  
Two filter options + an extra that works with the two filter options.  
* Standard filter, search by ID, name, path, filename.  
* Search by ID with same length as the input text, matching numbers and filling in blanks (x or .).
* Extra filter option to include path while searching.

Other features  
* Stop music played by the addon.
* Bookmark your favourite sounds.
* Play up individual sounds tied to the same ID  
  
# Installation
  
If you have custom sounds, please follow the step below: [Preparing sound data](https://github.com/Fiurs-Hearth/SoundBrowser/edit/master/README.md#preparing-sound-data)  
  
## Installing the addon  
* [Download the addon](https://github.com/Fiurs-Hearth/SoundBrowser/archive/refs/heads/master.zip)
* Unpack the file
* Open the unpacked file and rename the folder named `SoundBrowser-master` to `SoundBrowser`
* Put the renamed folder into the AddOns folder: `World of Warcraft\Interface\AddOns`
* Start or restart WoW if already running 
* Recommended: [Set script memory to 0](https://imgur.com/a/V65UiKd), this helps against most game crashes caused by addons, click link for instructions.
  
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
  
Save the file and done!  

