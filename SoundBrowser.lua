-- The code is a mess, thank you, old me.
local searchResults = {}
local searchResultsLength = 0
local resultFrame = {}
local maxResults = 340
local framesPerPage = 17
local maxPageNumber = 0
--local currentPage = 1
local bookmarkedFrame = {}
local everySecond = 0
local SoundData
local resultFrame_allSounds
local pathFilter = ""
local SB_shadow

function SetStatus(text, status)

    local startTimer = time()

    local statusFrame = _G['SB_mainFrameResultsStatus']
    local statusText = _G['SB_mainFrameResultsStatusTextStatus']
    statusText:SetText(text)

    if(status == 1) then

        statusFrame:SetBackdropColor(0, 1, 0, 1)

    elseif(status == 2) then
        
        statusFrame:SetBackdropColor(1, 0, 0, 1)

    end

    statusFrame:SetScript("OnUpdate", function()
        if( ( time() - startTimer ) >= 3) then
            statusFrame:SetBackdropColor(0, 0, 0, 0.60)
            statusFrame:SetScript("OnUpdate", nil)
        end
    end)
end

function SetupBookmarks()

    if(SB_bookmarkedSounds ~= nil) then

        local i = 0
        -- Reset bookmarked frames
        if(_G["bookmarkedFrame_1"]) then
            for k,v in pairs(bookmarkedFrame) do
                i = i + 1
                local frame = _G["bookmarkedFrame_"..i]
                if(frame) then
                    frame:Hide()
                end
            end
        end

        if(not next(SB_bookmarkedSounds)) then
            return
        else
            local i = 0
            local bookmarkMainFrame = _G["SB_mainFrameBookmarked"]
            i = 0
            for k, v in pairs(SB_bookmarkedSounds) do
                i = i + 1

                if(_G["bookmarkedFrame_"..i])then

                    bookmarkedFrame[i].text:SetText("|c00FF9922" .. v.id .. " - |c00FFFF00" .. v.name .. ", |c0066BBDD" .. v.sounds )
                    bookmarkedFrame[i]:Show()
                else
                    bookmarkedFrame[i] = CreateFrame("Frame", "bookmarkedFrame_"..i, bookmarkMainFrame, nil)
                    bookmarkedFrame[i]:SetWidth(bookmarkMainFrame:GetWidth() - 8)
                    bookmarkedFrame[i]:SetHeight(16)
                    bookmarkedFrame[i]:SetPoint("TOPLEFT", 4, (-16 * (i -1 )) - 4 )
    
                    bookmarkedFrame[i]:SetBackdrop({
                        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                    })
                    bookmarkedFrame[i]:EnableMouse(true)
    
                    bookmarkedFrame[i].text = bookmarkedFrame[i]:CreateFontString("", "OVERLAY");
                    bookmarkedFrame[i].text:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
                    bookmarkedFrame[i].text:SetPoint("CENTER", 0, 0)
                    bookmarkedFrame[i].text:SetText("|c00FF9922" .. v.id .. " - |c00FFFF00" .. v.name .. ", |c0066BBDD" .. v.sounds )
    
                    bookmarkedFrame[i].text:SetTextColor(1, 1, 0, 1)
                    bookmarkedFrame[i].text:SetWidth(bookmarkMainFrame:GetWidth() - 20)
                    bookmarkedFrame[i].text:SetHeight(bookmarkedFrame[i]:GetHeight() - 5)
                    bookmarkedFrame[i].text:SetJustifyH("LEFT")

                    bookmarkedFrame[i]:SetScript("OnMouseDown", OnMouseDown_resultFrame)
                    bookmarkedFrame[i]:SetScript("OnEnter", OnEnter_resultFrame)
                    bookmarkedFrame[i]:SetScript("OnMouseUp", OnMouseUp_resultFrame)
                    if( everySecond == 0) then
                        everySecond = 1
                        bookmarkedFrame[i]:SetScript("OnLeave", OnLeave_resultFrame_1)
                        bookmarkedFrame[i]:SetBackdropColor(1, 1, 1, 0.70)
                    else
                        everySecond = 0
                        bookmarkedFrame[i]:SetScript("OnLeave", OnLeave_resultFrame_2)
                        bookmarkedFrame[i]:SetBackdropColor(0.0, 0.0, 0.0, 0.35)
                    end
                    bookmarkedFrame[i]:Show()
                end

                bookmarkedFrame[i].data = {}
                bookmarkedFrame[i].data.id = v.id
                bookmarkedFrame[i].data.sounds = {}
                bookmarkedFrame[i].data.sounds[1] = v.sounds
                bookmarkedFrame[i].data.path = v.path
                bookmarkedFrame[i].data.name = v.name

            end

        end

    end

end

-- Bookmarked sounds.
local bookmarkedDummyFrame = CreateFrame("FRAME"); -- Need a frame to respond to events
bookmarkedDummyFrame:RegisterEvent("ADDON_LOADED"); -- Fired when saved variables are loaded
bookmarkedDummyFrame:RegisterEvent("PLAYER_LOGOUT"); -- Fired when about to log out

bookmarkedDummyFrame:SetScript("OnEvent", function()

    if event == "ADDON_LOADED" and arg1 == "AIO_Client" then

        --SB_bookmarkedSounds = nil
        if(SB_bookmarkedSounds == nil) then
            SB_bookmarkedSounds = {};
        end
        
        SetupBookmarks()
    --elseif event == "PLAYER_LOGOUT" then

    end
end)

function SB_PlaySound(data, index, frame)

    if( frame and string.find(frame:GetName(), "bookmarkedFrame_" ) )then
        index = 1
    end

    if(data ~= nil and data.sounds ~= nil and data.path ~= nil) then
        local sound
        if(index == false)then
            sound = data.sounds
        else
            sound = data.sounds[index]
        end

        -- Check if the sound is a music file
        if(string.find(string.lower(data.path), "\\music")) then
            isPlayed = PlayMusic(data.path .. "\\" .. sound, "master")
            isPlayed = true
            isMusic = true
        else
            isPlayed = PlaySoundFile(data.path .. "\\" .. sound, "master")
            isMusic = false
        end 

        if(isPlayed == nil) then
            SetStatus("Could not find selected file or to many sounds playing at the same time.", 2)
        else
            if(isMusic)then
                SetStatus("Music played.", 1)
            else
                SetStatus("Sound played.", 1)
            end
        end
    else
        SetStatus("Could not play sound for unknown reason.", 2)
    end
end

-- Checkboxes script
function OnClickCheckbox(self)
    
    local name = this:GetName()
    local otherCheckbox = ""
    
    local isChecked = this:GetChecked() 
    if(name ~= "SB_mainFrameFilterNoFilter") then
        otherCheckbox = _G["SB_mainFrameFilterNoFilter"]
    else
        otherCheckbox = _G["SB_mainFrameFilterLikeMaxCharFilter"]
    end
    local otherIsChecked = otherCheckbox:GetChecked()

    if(isChecked and otherIsChecked) then
        otherCheckbox:SetChecked(false) 

    elseif(isChecked == nil and otherIsChecked == nil ) then
        this:SetChecked(true)
    end

    SB_textChangedPath((SB_mainFrameFilterPathEditBox:GetText() or ""))
    SB_textChanged((SB_mainFrameSearchEditBox:GetText() or "S"))
end

function SetPageVariables()
    
    -- Checkboxes
    noFilterCheckbox = SB_mainFrameFilterNoFilter
    likeMaxCharFilterCheckbox = SB_mainFrameFilterLikeMaxCharFilter
    noFilterCheckbox:SetScript("OnClick", OnClickCheckbox)
    likeMaxCharFilterCheckbox:SetScript("OnClick", OnClickCheckbox)

    currentPage = SB_mainFrameResultsFontPageTextCurrentPage
    currentPageNumber = tonumber( currentPage:GetText() )

    maxPage = SB_mainFrameResultsFontPageTextMaxPage

    SB_mainFrameResults:EnableMouseWheel(true)
    SB_mainFrameResults:SetScript("OnMouseWheel", function()
        if(not next(searchResults)) then
            return
        else
            currentPageNumber = currentPageNumber + arg1
            if( currentPageNumber == 0 ) then
                currentPageNumber = 1
            end
            currentPage:SetText(currentPageNumber)
            if(currentPageNumber > maxPageNumber ) then
                currentPageNumber = maxPageNumber
                currentPage:SetText(currentPageNumber)
            else
                HandleOutput(searchResults)
            end
        end
    end)
end
local currentPage = SB_mainFrameResultsFontPageTextCurrentPage

-- Initialize the sound dbc string into a table
function InitiateSoundEntries()

    if(not(SoundData) and soundEntryDBC ~= nil) then
        -- Remove useless string from the data
        soundEntryDBC = string.gsub(soundEntryDBC, ";IdColumnIndex=0\n", "")
        -- Fix if no last linebreak is spotted
        if( string.sub(soundEntryDBC, string.len(soundEntryDBC), string.len(soundEntryDBC)) ~= "\n" ) then
            soundEntryDBC = soundEntryDBC .. "\n"
        end

        SoundData = {}

        local id, id_end, name, path, row, soundCount, soundsTable

        -- we want the index of the id and the index of the end of the row (next row's id index - 2?)
        local rowData = {
            ['row_start'] = 0,
            ['row_end'] = 0,
            ['name_start'] = 0,
            ['name_end'] = 0,
            ['sound_start'] = 0,
            ['sound_end'] = 0,
            ['path_start'] = 0,
            ['path_end'] = 0,
        }

        local noPathC = 0
        -- start while loop here
        while(true)
        do
            -- Find end of row.
            rowData.row_end = string.find(soundEntryDBC, '\n', rowData.row_start)

            -- ID
            id_end = string.find(soundEntryDBC, ':', rowData.row_start) - 1
            id = string.sub(soundEntryDBC, rowData.row_start, id_end)

            -- NAME
            __, rowData.name_start = string.find(soundEntryDBC, ':2="', rowData.row_start)
            rowData.name_end, __ = string.find(soundEntryDBC, '",', rowData.name_start)
            if(rowData.name_start >= rowData.row_end)then
                --print("ERROR - no name found for ID:", id)
                name = "[NO NAME]"
            else
                name = string.sub(soundEntryDBC, rowData.name_start + 1, rowData.name_end - 1)
            end

            -- PATH
            __, rowData.path_start = string.find(soundEntryDBC, ',23="', rowData.row_start)
            rowData.path_end, __ = string.find(soundEntryDBC, '"', rowData.path_start + 1)

            if(rowData.path_start >= rowData.row_end)then
                --print("ERROR - no path found for ID:", id, "Please check if this is correct.")
                path = "[NO PATH]"
                noPathC = noPathC + 1
            else
                path = string.sub(soundEntryDBC, rowData.path_start + 1, rowData.path_end - 1)
            end

            -- SOUNDS
            soundCount = 1
            soundsTable = {}
            while(true) 
            do
                __, rowData.sound_start = string.find(soundEntryDBC, ','..tostring(soundCount+2)..'="', rowData.row_start)
                rowData.sound_end, __ = string.find(soundEntryDBC, '",', rowData.sound_start)
                -- Check so we are not looking at the wrong row and that it found any sounds
                if(rowData.sound_end >= rowData.row_end or rowData.sound_start == nil)then
                    break
                end
                soundsTable[soundCount] =  string.sub(soundEntryDBC, rowData.sound_start + 1, rowData.sound_end - 1)

                soundCount = soundCount + 1
                if(soundCount > 10) then
                    break
                end
            end

            if(id ~= nil and next(soundsTable) and soundsTable ~= nil)then
                SoundData[tonumber(id)] = {
                    ['id'] = id,
                    ['name'] = name,
                    ['path'] = path,
                    ['sounds'] = soundsTable
                }
            end

            -- Used for new row
            rowData.row_start = rowData.row_end + 1

            -- Check if last row
            if(string.find(soundEntryDBC, '\n', rowData.row_end + 1) == nil)then
                break
            end
        end
    end


end

function FilterSound(k, sound, query, filter)
    local store = false
    local qChar, kChar, includeCount
    local queryLength = string.len(query)

    if(filter == 0) then
        -- Check by ID
        if(string.find(k, query)) then
            store = true
        end
        -- Check by name
        if(string.find(string.lower(sound.name), string.lower(query))) then
            store = true
        end
        -- Check by path
        if(string.find(string.lower(sound.path), string.lower(query))) then
            store = true
        end
        -- Check by sound file name
        for i, s in pairs(sound['sounds']) do
            if(string.find(string.lower(s), string.lower(query))) then
                store = true
                break
            end
        end
    elseif(filter == 1) then
        -- Check if same length 
        if(string.len(k) == queryLength) then
            includeCount = 0
            -- Start looping through each character and check if they match
            for i = 1, queryLength, 1 do
                qChar = query:sub(i,i)
                kChar = tostring(k):sub(i,i)

                if(qChar == "x" or qChar == ".") then
                    includeCount = includeCount + 1
                elseif(qChar == kChar) then
                    store = true
                else
                    store = false
                    break
                end
            end
            -- if there are equal amount of x/. as query length then we add sound to results
            if(includeCount == queryLength) then
                store = true
            end
        end
    end

    return store
end

------------------------------------
-- Function, search sound entries
function SearchSoundEntries(query, maxResults, filter)

    local i = 0
    local skipFirst, skipSecond = false, false
    local soundEntries = {}
    local resultTable = {}
    local startOfQuery = ""
    local tempQuery
    local store

    --[[if(filter == 1) then
        tempQuery = query
        -- We need to get the first characters of the query that are not either a "." or a "x"
        -- We later use that to search for matching results
		for c in string.gmatch(query,".",1) do  
        --for j = 1, #query do
            --local c = query:sub(j,j)
            if(c ~= ".") then
                if(c ~= "x") then
                    startOfQuery = startOfQuery .. c
                end
            end
        end
    end]]

    InitiateSoundEntries()
    for k, sound in pairs(SoundData) do
        store = false

        if(pathFilter ~= nil or pathFilter ~= "")then
            if(string.find(string.lower(sound.path), string.lower(pathFilter))) then
                store = FilterSound(k, sound, query, filter) -- filter WITH path
            end
        else
            store = FilterSound(k, sound, query, filter) -- filter WITHOUT path
        end


        if(store) then
            resultTable[k] = sound
        end
        --break
    end

    return resultTable
end
-- END
------------------------------------
function BookmarkSound(data)

    if(not(SB_bookmarkedSounds)) then
        SB_bookmarkedSounds = {}
    end

    -- Add if not already added
    if(SB_bookmarkedSounds[data.id.."-"..data.sounds[1]] == nil) then

        local count = 0
        for k in pairs(SB_bookmarkedSounds) do
            count = count + 1
        end

        if( count < 14) then
            SB_bookmarkedSounds[data.id.."-"..data.sounds[1]] = {
                ['id'] = data.id,
                ['name'] = data.name,
                ['path'] = data.path,
                ['sounds'] = data.sounds[1]
            }
        else
            SetStatus("Maximum bookmarks reached", 2)
        end
        SetupBookmarks()
    else -- Remove if already added
        SB_bookmarkedSounds[data.id.."-"..data.sounds[1]] = nil
        SetupBookmarks()
    end
end

function OnEnter_resultFrame(self)
    this:SetBackdropColor(0, 1, 0, 1)
end

function OnLeave_resultFrame_1()
    this:SetBackdropColor(1, 1, 1, 0.70)
end

function OnLeave_resultFrame_2()
    this:SetBackdropColor(0, 0, 0, 0.35)
end

function OnMouseUp_resultFrame()
    this:SetBackdropColor(0, 1, 0, 1)
end

function OnMouseDown_resultFrame(self, button)
    this:SetBackdropColor(0, 0.5, 0, 1)
    
    local text = self.textString
    --message("ERROR: No filepath was found for selected sound.")

    if(button == "LeftButton") then
        SB_PlaySound(self.data, 1, self)

    elseif (button == "MiddleButton") then
        BookmarkSound(self.data)
    elseif (button == "RightButton") then
        if(string.find(self:GetName(), "bookmarkedFrame_")) then
            return
        end

        if(_G['resultFrame_allSounds'])then
            if(resultFrame_allSounds:IsVisible())then
                resultFrame_allSounds:Hide()
                return
            end
        end
    
        if(not(_G['resultFrame_allSounds'])) then
            resultFrame_allSounds = CreateFrame("Frame", "resultFrame_allSounds", self, nil)
            resultFrame_allSounds:SetWidth(340)
            resultFrame_allSounds:SetHeight(50)
            resultFrame_allSounds:EnableMouse(true)
            resultFrame_allSounds:SetBackdrop({
                bgFile = "Interface/CHARACTERFRAME/UI-Party-Background",
                edgeFile ="Interface/Tooltips/UI-Tooltip-Border",
                edgeSize="16",
                insets={left=3,right=3,top=3,down=3}
            })
        end
        if(#self.data.sounds > 1)then
            resultFrame_allSounds:Show()
            if( not(_G["SB_mainFrame_shadow"])) then
                SB_shadow = CreateFrame("Frame", "SB_shadow", SB_mainFrameResults, nil)
                SB_shadow:SetPoint("TOP", 0, 0)
                SB_shadow:SetSize(SB_mainFrameResults:GetWidth(), SB_mainFrameResults:GetHeight())
                SB_shadow:SetBackdrop({
                    bgFile="Interface/DialogFrame/UI-DialogBox-Background"
                })
                SB_shadow:SetScript("OnMouseDown", function(s)
                    s:Hide()
                    resultFrame_allSounds:Hide()
                end)
                SB_shadow:SetFrameLevel(150)
                SB_shadow:EnableMouse(true)
                resultFrame_allSounds:SetParent(SB_shadow)
            end
        else
            resultFrame_allSounds:Hide()
            return
        end
        resultFrame_allSounds:SetHeight(#self.data.sounds*30 + 8)
        resultFrame_allSounds:SetPoint("TOPLEFT", self, "TOPRIGHT", -resultFrame_allSounds:GetWidth() + 2, 0 )
        --resultFrame_allSounds:SetToplevel()
    
        for k=1, 10, 1 do
            if(not(resultFrame_allSounds.result)) then
                resultFrame_allSounds.result={}
                break
            end
            if(resultFrame_allSounds.result[k]) then
                resultFrame_allSounds.result[k]:Hide()
            end
        end
    
        for k, v in pairs(self.data.sounds) do
    
            if(not(resultFrame_allSounds.result[k])) then
                resultFrame_allSounds.result[k] = CreateFrame("Frame", "allSounds_"..k, resultFrame_allSounds)
                resultFrame_allSounds.result[k]:SetFrameLevel(155)
                resultFrame_allSounds.result[k].text = resultFrame_allSounds.result[k]:CreateFontString("", "OVERLAY");
                resultFrame_allSounds.result[k].text:SetFont("Fonts\\FRIZQT__.TTF", 13, "")
                resultFrame_allSounds.result[k].text:SetPoint("CENTER", 5, 0)
    
                resultFrame_allSounds.result[k].text:SetTextColor(1, 1, 1, 1)
                resultFrame_allSounds.result[k].text:SetWidth(resultFrame_allSounds:GetWidth() - 8)
                resultFrame_allSounds.result[k].text:SetHeight(30)
                resultFrame_allSounds.result[k].text:SetJustifyH("LEFT")
            end
            resultFrame_allSounds.result[k]:Show()
    
            resultFrame_allSounds.result[k]:SetWidth(resultFrame_allSounds:GetWidth() - 8)
            resultFrame_allSounds.result[k]:SetHeight(30)
            resultFrame_allSounds.result[k]:SetPoint("TOPLEFT", 4, (-30 * (k -1 )) - 4 )
    
            resultFrame_allSounds.result[k]:SetBackdrop({
                bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            })
            if(k%2 == 0)then
                resultFrame_allSounds.result[k]:SetBackdropColor(1,1,1, 0.7)
                resultFrame_allSounds.result[k]:SetScript("OnLeave", OnLeave_resultFrame_1)
                resultFrame_allSounds.result[k]:SetScript("OnEnter", function(s) s:SetBackdropColor(0, 1, 0, 1) end)
                resultFrame_allSounds.result[k]:SetScript("OnMouseDown", function(s, b) s:SetBackdropColor(0, 0.5, 0, 1) end)
                resultFrame_allSounds.result[k]:SetScript("OnMouseUp", function(s, b) 
                    s:SetBackdropColor(0, 1, 0, 1) 
                    if(b == "MiddleButton") then
                        BookmarkSound({['id'] = s.data.id, ['sounds'] = s.data.sounds, ['path'] = s.data.path, ['name'] = s.data.name})
                    else
                        SB_PlaySound({['sounds'] = s.data.sounds[1], ['path'] = s.data.path}, false)
                    end
                end)
            else
                resultFrame_allSounds.result[k]:SetBackdropColor(0,0,0, 0.35)
                resultFrame_allSounds.result[k]:SetScript("OnLeave", OnLeave_resultFrame_2)
                resultFrame_allSounds.result[k]:SetScript("OnEnter", function(s) s:SetBackdropColor(0, 1, 0, 1) end)
                resultFrame_allSounds.result[k]:SetScript("OnMouseDown", function(s) s:SetBackdropColor(0, 0.5, 0, 1) end)
                resultFrame_allSounds.result[k]:SetScript("OnMouseUp", function(s, b) 
                    s:SetBackdropColor(0, 1, 0, 1) 
                    if(b == "MiddleButton") then
                        BookmarkSound({['id'] = s.data.id, ['sounds'] = s.data.sounds, ['path'] = s.data.path, ['name'] = s.data.name})
                    else
                        SB_PlaySound({['sounds'] = s.data.sounds[1], ['path'] = s.data.path}, false)
                    end
                end)
            end
    
            resultFrame_allSounds.result[k]:EnableMouse(true)
    
            resultFrame_allSounds.result[k].text:SetText("|c0066BBDD"..v)
            resultFrame_allSounds.result[k].data = {}
            resultFrame_allSounds.result[k].data.id = self.data.id
            resultFrame_allSounds.result[k].data.sounds = {}
            resultFrame_allSounds.result[k].data.sounds[1] = v
            resultFrame_allSounds.result[k].data.path = self.data.path
            resultFrame_allSounds.result[k].data.name = self.data.name
        end
    end
end
--[[
]]

function HandleOutput(table)
    
    local i = 0
    local j = 0
    parentFrame = _G['SB_mainFrameResults']
    local skipUpTo = (currentPageNumber - 1) * framesPerPage

    if(_G["resultFrame_1"]) then
        for k,v in pairs(resultFrame) do
            i = i + 1
            local frame = _G["resultFrame_"..i]
            frame:Hide()
        end
    end
	everySecond = 0

    i = 0 -- We have to reset this because we incrementing "i" in the for loop before this.
    for k,v in pairs(table) do

        -- Skip X number of results based on current page number
        if(j < skipUpTo ) then
            j = j + 1
            
        elseif(i < framesPerPage and j ~= (skipUpTo - 1) or
                i < framesPerPage and skipUpTo == 0) then

            i = i + 1            

            if(not(_G["resultFrame_"..i]))then
                resultFrame[i] = CreateFrame("Frame", "resultFrame_"..i, parentFrame, nil)
                resultFrame[i]:SetWidth(parentFrame:GetWidth() - 8)
                resultFrame[i]:SetHeight(30)
                resultFrame[i]:SetPoint("TOPLEFT", 4, (-30 * (i -1 )) - 4 )

                resultFrame[i]:SetBackdrop({
                    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                })
                resultFrame[i]:EnableMouse(true)

                -- Scripts
                resultFrame[i]:SetScript("OnEnter", OnEnter_resultFrame)
                resultFrame[i]:SetScript("OnMouseUp", OnMouseUp_resultFrame)
                resultFrame[i]:SetScript("OnMouseDown", OnMouseDown_resultFrame)
                if( everySecond == 0) then
                    everySecond = 1
                    resultFrame[i]:SetScript("OnLeave", OnLeave_resultFrame_1)
                    resultFrame[i]:SetBackdropColor(1, 1, 1, 0.70)
                else
                    everySecond = 0
                    resultFrame[i]:SetScript("OnLeave", OnLeave_resultFrame_2)
                    resultFrame[i]:SetBackdropColor(0.0, 0.0, 0.0, 0.35)
                end

                resultFrame[i].text = resultFrame[i]:CreateFontString("", "ARTWORK");
                resultFrame[i].text:SetFont("Fonts\\FRIZQT__.TTF", 13, "")
                resultFrame[i].text:SetPoint("CENTER", 0, 0)

                resultFrame[i].text:SetTextColor(1, 1, 0, 1)
                resultFrame[i].text:SetWidth(parentFrame:GetWidth() - 20)
                resultFrame[i].text:SetHeight(resultFrame[i]:GetHeight() - 5)
                resultFrame[i].text:SetJustifyH("LEFT")

                resultFrame[i].extraSoundsTex = resultFrame[i]:CreateTexture(nil, "OVERLAY")
                resultFrame[i].extraSoundsTex:SetSize(20,20)
                resultFrame[i].extraSoundsTex:SetPoint("TOPRIGHT", -3, -5)
                resultFrame[i].extraSoundsTex:SetTexture("Interface/Minimap/UI-Minimap-ZoomInButton-Up")
            end
            
            resultFrame[i].text:SetText("|c00FF9922" .. k .. " - |c00FFFF00" .. (v['name'] or "NO NAME FOUND") .. ", |c0033EE88" .. (v['path'] or "NO PATH FOUND") .. ", |c0066BBDD" .. v['sounds'][1] )
            resultFrame[i].data = v
            resultFrame[i].data.id = k
            resultFrame[i].textString = (k .. " - " .. v['name'])
            resultFrame[i]:Show()
            
            if(#v.sounds <= 1)then
                resultFrame[i].extraSoundsTex:Hide()
            else
                resultFrame[i].extraSoundsTex:Show()
            end

        else
            j = j + 1
            break
        end
    end
end

function ClearResultsFrame()
    
    -- Checks if table is empty
    if not next(resultFrame) then
        return
    else

        i = 0
        for k,v in pairs(resultFrame) do
            i = i + 1
            if(_G["resultFrame_"..i])then
                resultFrame[i]:Hide()
            end
        end
        return
    end
end

function SB_textChanged(query)
    
    local filter
    if( string.len(query) > 0 or string.len(pathFilter) > 0) then
        
        if(noFilterCheckbox:GetChecked()) then
            filter = 0
        elseif(likeMaxCharFilterCheckbox:GetChecked()) then
            filter = 1
        else
            filter = 0
        end
        
        searchResults = SearchSoundEntries(query, maxResults, filter)

        if(next(searchResults)) then
            currentPageNumber = 1
            SB_mainFrameResultsFontPageTextCurrentPage:SetText(currentPageNumber)

            searchResultsLength = 0
            for _ in pairs(searchResults) do
                searchResultsLength = searchResultsLength + 1
            end

            maxPageNumber = math.ceil(searchResultsLength / framesPerPage)
            maxPage:SetText( maxPageNumber )

            HandleOutput(searchResults)
        else
            SB_mainFrameResultsFontPageTextCurrentPage:SetText(0)
            maxPage:SetText(0)
            ClearResultsFrame()
        end
    else
        SetStatus("Ready", 1)
        SetupBookmarks()
        ClearResultsFrame()
        SB_mainFrameResultsFontPageTextCurrentPage:SetText(0)
        maxPage:SetText(0)
    end
end

function SB_textChangedPath(path)
    pathFilter = path
end