local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.sadCore.savedVarsGlobalName = "SAdArenaMarkers_Settings_Global"
addon.sadCore.savedVarsPerCharName = "SAdArenaMarkers_Settings_Char"
addon.sadCore.compartmentFuncName = "SAdArenaMarkers_Compartment_Func"

addon.settings = {}
addon.unitSpecs = {}
addon.settings.iconSize = 40
addon.settings.highlightSize = 55
addon.settings.borderSize = 64
addon.settings.iconWidth = 64
addon.settings.iconHeight = 64
addon.settings.classIconPath = "Interface/GLUES/CHARACTERCREATE/UI-CHARACTERCREATE-CLASSES"
addon.settings.unsupportedZones = { "dungeon", "raid" }
addon.settings.updateDelay = 0.1
addon.settings.defaultVerticalOffset = 40
addon.settings.nameplateSizeOffset = 0
addon.settings.nameplateSizeOffsetMultiplier = 10
addon.settings.defaultArenaMarkerSize = 90
addon.settings.defaultArenaMarkerVerticalOffset = -20
addon.settings.defaultFriendlyMarkerSize = 150
addon.settings.defaultFriendlyMarkerVerticalOffset = -20
addon.settings.defaultFriendlyCustomNameSize = 22
addon.settings.batchSize = 3
addon.settings.batchInterval = .03
addon.settings.nameplateQueue = {}
addon.settings.queueTimer = nil
addon.settings.markers = {
    marker1 = { atlas = "CovenantSanctum-Renown-DoubleArrow", rotation = math.pi / 2 },
    marker2 = { atlas = "Azerite-PointingArrow", rotation = 0 },
    marker3 = { atlas = "NPE_ArrowDown", rotation = 0 },
    marker4 = { atlas = "common-icon-forwardarrow", rotation = -math.pi / 2 },
    marker5 = { atlas = "plunderstorm-nameplates-icon-2", rotation = 0 },
    marker6 = { atlas = "charactercreate-icon-customize-body-selected", rotation = 0 },
    marker7 = { atlas = "housing-layout-room-orb-ring-highlight", rotation = 0 },
    marker8 = { atlas = "plunderstorm-map-zoneYellow-hover", rotation = 0 },
    marker9 = { atlas = "Customization_Fixture_Node_Selected", rotation = 0 },
    marker10 = { atlas = "honorsystem-icon-prestige-1", rotation = 0 },
    marker11 = { atlas = "honorsystem-icon-prestige-2", rotation = 0 },
    marker12 = { atlas = "honorsystem-icon-prestige-3", rotation = 0 },
    marker13 = { atlas = "honorsystem-icon-prestige-4", rotation = 0 },
}
addon.settings.arenaMarkers = {
    arena1 = { atlas = "services-number-1" },
    arena2 = { atlas = "services-number-2" },
    arena3 = { atlas = "services-number-3" },
}
addon.settings.healerMarkers = {
    healer1 = { atlas = "UI-LFG-RoleIcon-Healer-Disabled" },
    healer2 = { atlas = "UI-LFG-RoleIcon-Healer" },
    healer3 = { atlas = "roleicon-tiny-healer" },    
    healer4 = { atlas = "UI-Frame-HealerIcon" },
    healer5 = { atlas = "Icon-Healer" },
    healer6 = { atlas = "Crosshair_important_128" },
    healer7 = { atlas = "Crosshair_legendaryquest_128" },
    healer8 = { atlas = "Crosshair_Quest_128" },
    healer9 = { atlas = "crosshair_track_128" },
    healer10 = { atlas = "nameplates-icon-elite-gold" },
    healer11 = { atlas = "nameplates-icon-elite-silver" },
    healer12 = { atlas = "UI-LFG-RoleIcon-Leader" },
    healer13 = { atlas = "UI-LFG-ReadyMark" },
    healer14 = { atlas = "Gamepad_Rev_Plus_64" },
    healer15 = { atlas = "communities-icon-addgroupplus" },
    healer16 = { atlas = "UI-LFG-RoleIcon-Decline" },
    healer17 = { atlas = "UI-LFG-DeclineMark" },
}

function addon:Initialize()
    self.author = "Rôkk-Wyrmrest Accord"

    local markerOptions = {}
    table.insert(markerOptions, { value = "none", label = "none" })
    table.insert(markerOptions, { value = "classIcon", label = "markerStyleClassIcon", icon="UI-HUD-UnitFrame-Player-Portrait-ClassIcon-Monk" })
    table.insert(markerOptions, { value = "specIcon", label = "markerStyleSpecIcon", icon="GarrMission_ClassIcon-Monk-Mistweaver" })
    
    local markerCount = 0
    for _ in pairs(self.settings.markers) do markerCount = markerCount + 1 end
    for i = 1, markerCount do
        local markerKey = "marker" .. i
        local markerInfo = self.settings.markers[markerKey]
        if markerInfo then
            local labelKey = "markerStyle" .. markerKey:sub(1,1):upper() .. markerKey:sub(2)
            table.insert(markerOptions, {
                value = markerKey,
                label = labelKey,
                icon = markerInfo.atlas,
                onValueChange = function() addon:RefreshAllNameplates() end
            })
        end
    end
    
    local healerMarkerOptions = {}
    table.insert(healerMarkerOptions, {
        value = "none",
        label = "none",
        onValueChange = function() addon:RefreshAllNameplates() end
    })
    local healerCount = 0
    for _ in pairs(self.settings.healerMarkers) do healerCount = healerCount + 1 end
    for i = 1, healerCount do
        local healerKey = "healer" .. i
        local healerInfo = self.settings.healerMarkers[healerKey]
        if healerInfo then
            local labelKey = "healerMarker" .. healerKey:sub(1,1):upper() .. healerKey:sub(2)
            table.insert(healerMarkerOptions, {
                value = healerKey,
                label = labelKey,
                icon = healerInfo.atlas,
                onValueChange = function() addon:RefreshAllNameplates() end
            })
        end
    end

    local arenaMarkerOptions = {}
    table.insert(arenaMarkerOptions, {
        value = "none",
        label = "none",
        onValueChange = function() addon:RefreshAllNameplates() end
    })
    table.insert(arenaMarkerOptions, {
        value = "numbers",
        label = "arenaMarker123",
        icon = "services-number-1",
        onValueChange = function() addon:RefreshAllNameplates() end
    })

    self:AddSettingsPanel("friendlyMarkers", {
        title = "friendlyMarkers",
        controls = {
            {
                type = "header",
                name = "friendlyMarkersHeader"
            },
            {
                type = "dropdown",
                name = "markerTexture",
                default = "marker1",
                options = markerOptions,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "slider",
                name = "markerSize",
                default = addon.settings.defaultFriendlyMarkerSize,
                min = 1,
                max = 500,
                step = 1,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "slider",
                name = "markerVerticalOffset",
                default = addon.settings.defaultFriendlyMarkerVerticalOffset,
                min = -100,
                max = 100,
                step = 1,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "slider",
                name = "markerWidth",
                default = 0,
                min = -5,
                max = 5,
                step = 0.5,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "checkbox",
                name = "showFriendlyHealthBars",
                default = true,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "slider",
                name = "friendlyCustomNameSize",
                default = addon.settings.defaultFriendlyCustomNameSize,
                min = 8,
                max = 40,
                step = 1,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "dropdown",
                name = "friendlyHealerIcon",
                default = "none",
                options = healerMarkerOptions,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "checkbox",
                name = "partyHighlightTarget",
                default = true,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
        }
    })

    self:AddSettingsPanel("arenaMarkers", {
        title = "arenaMarkers",
        controls = {
            {
                type = "header",
                name = "arenaMarkersHeader"
            },
            {
                type = "dropdown",
                name = "arenaMarkerTexture",
                default = "none",
                options = arenaMarkerOptions,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "slider",
                name = "arenaMarkerSize",
                default = addon.settings.defaultArenaMarkerSize,
                min = 1,
                max = 500,
                step = 1,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "slider",
                name = "arenaMarkerVerticalOffset",
                default = addon.settings.defaultArenaMarkerVerticalOffset,
                min = -100,
                max = 100,
                step = 1,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "dropdown",
                name = "enemyHealerIcon",
                default = "none",
                options = healerMarkerOptions,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "checkbox",
                name = "arenaHighlightTarget",
                default = true,
                onValueChange = function() addon:RefreshAllNameplates() end
            },
            {
                type = "description",
                name = "arena123required"
            },
        }
    })

    local enableZoneControls = {}
    for _, zoneName in ipairs(self.zones) do
        local supported = not tContains(self.settings.unsupportedZones, zoneName)
        
        if supported then
            table.insert(enableZoneControls, {
                type = "checkbox",
                name = "enabledIn" .. zoneName,
                default = true,
                persistent = true,
                onValueChange = function() addon:RefreshAllNameplates() end
            })
        else
            table.insert(enableZoneControls, {
                type = "description",
                name = zoneName .. "NotSupported"
            })
        end
    end

    self:AddSettingsPanel("zones", {
        title = "enableInZoneTitle",
        controls = enableZoneControls
    })
   
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function(event, isInitialLogin, isReloadingUI)
        C_Timer.After(0.5, function()
            self:CvarUpdate("nameplateSize")
        end)
    end)

    self:RegisterEvent("CVAR_UPDATE", function(event, cvarName)
        self:CvarUpdate(cvarName)
    end)

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED", function(eventTable, eventName, unit)
        if unit then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate then
                self:HandleNameplateEvent(nameplate)
            end
        end
    end)

    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", function(eventTable, eventName, unit)
        if unit then
            local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
            if nameplate then
                self:HideMarker(nameplate)
            end
        end
    end)

    self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", function(event)
        self:RefreshAllNameplates()
    end)

    self:RegisterEvent("ARENA_OPPONENT_UPDATE", function(event)
        self:RefreshAllNameplates()
    end)

    self:RegisterEvent("UNIT_FACTION", function(event, unit)
        if unit and string.match(unit, "nameplate") then
            self:RefreshAllNameplates()
        end
    end)

    self:RegisterEvent("PLAYER_TARGET_CHANGED", function(event)
        self:RefreshAllNameplates()
    end)
end

addon.sadCore.releaseNotes = {
    version = "1.4",
    notes = {
        "v1_4_1_specIcon",
        "v1_4_2_highlightTarget",
    }
}

function addon:AfterCreateSettingsPanel(panel)
    if panel.panelKey == "friendlyMarkers" then
        panel:Hide()
        panel:HookScript("OnShow", function()
            self:CheckFriendlyNameplatesSetting()
        end)
    end
end

function addon:CheckFriendlyNameplatesSetting()
    local showFriendlyPlayers = GetCVar("nameplateShowFriendlyPlayers")
    if showFriendlyPlayers ~= "1" then
        addon:Info("Friendly Nameplates are disabled. Friendly Nameplates must be enabled to see custom markers.")
    end
end

function addon:OnZoneChange(currentZone)
    self:RefreshAllNameplates()
end

function addon:RefreshAllNameplates()
    local units = { "party1", "party2", "arena1", "arena2", "arena3" }
    for _, unit in ipairs(units) do
        if self:SecureCall(UnitExists, unit) then
            local specID = self:GetSpecIDForUnit(unit)
            if specID then
                local _, specName, _, icon = self:SecureCall(GetSpecializationInfoByID, specID)
                self.unitSpecs[unit] = {
                    specID = specID,
                    specName = specName,
                    icon = icon
                }
            else
                self.unitSpecs[unit] = nil
            end
        else
            self.unitSpecs[unit] = nil
        end
    end
    
    local nameplates = self:SecureCall(C_NamePlate.GetNamePlates)
    for _, nameplate in ipairs(nameplates) do
        self:HandleNameplateEvent(nameplate)
    end
end

function addon:GetSpecIDForUnit(unit)
    if string.match(unit, "^arena%d+$") then
        local arenaIndex = tonumber(string.match(unit, "%d+"))
        local specID = self:SecureCall(GetArenaOpponentSpec, arenaIndex)
        return specID
    end
    
    local raidIndex = self:SecureCall(UnitInRaid, unit)
    if raidIndex then
        local _, _, classID = self:SecureCall(UnitClass, unit)
        if classID then
            local specIndex = self:SecureCall(GetSpecialization, false, false, raidIndex)
            if specIndex and specIndex > 0 then
                local specID = self:SecureCall(GetSpecializationInfoForClassID, classID, specIndex)
                return specID
            end
        end
    end
    
    return nil
end

do -- Entry point for individual nameplates
    function addon:HandleNameplateEvent(nameplate)
        if not nameplate then return end
        
        self.settings.nameplateQueue[nameplate] = true
        
        local queueSize = 0
        for _ in pairs(self.settings.nameplateQueue) do
            queueSize = queueSize + 1
        end
        
        if not self.settings.queueTimer then
            self.settings.queueTimer = C_Timer.NewTimer(self.settings.batchInterval, function()
                self:ProcessNameplateQueue()
            end)
        end
    end
    
    function addon:ProcessNameplateQueue()
        local processed = 0
        local nameplateQueue = self.settings.nameplateQueue
        
        local queueSize = 0
        for _ in pairs(nameplateQueue) do
            queueSize = queueSize + 1
        end
        
        for nameplate, _ in pairs(nameplateQueue) do
            if processed >= self.settings.batchSize then
                break
            end
            
            if nameplate and nameplate.UnitFrame then
                self:UpdateNameplate(nameplate)
            end
            
            nameplateQueue[nameplate] = nil
            processed = processed + 1
        end
        
        local hasMore = next(nameplateQueue) ~= nil
        if hasMore then
            local remaining = 0
            for _ in pairs(nameplateQueue) do
                remaining = remaining + 1
            end
            
            self.settings.queueTimer = C_Timer.NewTimer(self.settings.batchInterval, function()
                self:ProcessNameplateQueue()
            end)
        else
            self.settings.queueTimer = nil
        end
    end
    
    function addon:UpdateNameplate(nameplate)
        self:HideMarker(nameplate)

        local unitFrame = nameplate and nameplate.UnitFrame
        local unit = unitFrame and unitFrame.unit
        local supportedZone = not tContains(self.settings.unsupportedZones, self.currentZone)
        local enabled = self:GetValue("zones", "enabledIn" .. self.currentZone)

        if not unit or
           not supportedZone or
           not enabled
           then return
        end
        
        self:ShowMarker(nameplate, unit)
    end
end

do -- Logic to show individual markers
    function addon:ShowMarker(nameplate, unit)
        local isHostilePlayerCharacter = UnitIsPlayer(unit) and not UnitIsUnit(unit, "player") and UnitIsEnemy("player", unit)
        local isFriendlyPlayerCharacter = UnitIsPlayer(unit) and not UnitIsUnit(unit, "player") and not UnitIsEnemy("player", unit)
        local inArena = self.currentZone == "arena"
        
        if isHostilePlayerCharacter and inArena then
            self:ShowArenaMarker(nameplate, unit)
        elseif isFriendlyPlayerCharacter then
            if inArena or self.currentZone == "battleground" then
                if not self:IsInPlayerGroup(unit) then return end
            end
            self:ShowFriendlyMarker(nameplate, unit)
        end
    end

    function addon:IsInPlayerGroup(unit)
        for i = 1, 4 do
            if UnitIsUnit(unit, "party" .. i) then
                return true
            end
        end
        for i = 1, 40 do
            if UnitIsUnit(unit, "raid" .. i) then
                return true
            end
        end
        return false
    end

    function addon:ShowArenaMarker(nameplate, unit)
        local arenaUnit = self:GetArenaUnitForNameplate(nameplate)
        if not arenaUnit then return end
        
        local healerMarkerIcon = self:GetHealerMarkerIcon(unit, "arenaMarkers", "enemyHealerIcon")
        local arenaNumberMarkerIcon = self:GetArenaNumberMarkerIcon(arenaUnit)
        
        if healerMarkerIcon then
            self:ShowArenaHealerFrame(nameplate, unit, healerMarkerIcon)
        elseif arenaNumberMarkerIcon then
            self:ShowArenaNumberFrame(nameplate, arenaNumberMarkerIcon)
        end
    end

    function addon:ShowFriendlyMarker(nameplate, unit)
        local healerMarkerIcon = self:GetHealerMarkerIcon(unit, "friendlyMarkers", "friendlyHealerIcon")
        local markerTexture = self:GetValue("friendlyMarkers", "markerTexture")
        local friendlyClassIcon = (markerTexture == "classIcon" or markerTexture == "specIcon")
        local friendlyMarkerIcon = self:GetFriendlyMarkerIcon()
        
        if healerMarkerIcon then
            self:ShowFriendlyHealerFrame(nameplate, unit, healerMarkerIcon)
        elseif friendlyClassIcon then
            self:ShowFriendlyClassFrame(nameplate, unit)
        elseif friendlyMarkerIcon then
            self:ShowFriendlyArrowFrame(nameplate, unit, friendlyMarkerIcon)
        end
        
        local showHealthBars = self:GetValue("friendlyMarkers", "showFriendlyHealthBars")
        self:UpdateHealthbarVisibility(nameplate, unit, showHealthBars)
    end

    function addon:HideMarker(nameplate)
        if nameplate.FriendlyClassIcon then
            nameplate.FriendlyClassIcon:Hide()
        end
        if nameplate.FriendlyClassArrow then
            nameplate.FriendlyClassArrow:Hide()
        end
        if nameplate.ArenaNumberMarker then
            nameplate.ArenaNumberMarker:Hide()
        end
        if nameplate.HealerMarker then
            nameplate.HealerMarker:Hide()
        end
        
        self:ResetHealthbarVisibility(nameplate)
    end
end

do -- Show Individual Icon Frames
    
    function addon:CalculateMarkerPosition(settingsCategory, settingName)
        local currentNameplateSize = tonumber(GetCVar("nameplateSize")) or 1
        local nameplateSizeOffset = currentNameplateSize * self.settings.nameplateSizeOffsetMultiplier
        local iconScale = self:GetValue(settingsCategory, settingName) / 100
        local verticalOffsetSetting = settingName:gsub("Size", "VerticalOffset")
        local verticalOffset = self:GetValue(settingsCategory, verticalOffsetSetting) + self.settings.defaultVerticalOffset + nameplateSizeOffset
        
        return iconScale, verticalOffset
    end
    
    function addon:ShowArenaNumberFrame(nameplate, arenaNumberMarkerIcon)
        local iconScale, verticalOffset = self:CalculateMarkerPosition("arenaMarkers", "arenaMarkerSize")
        local arenaFrame = self:CreateArenaMarker(nameplate, self.settings.iconWidth, self.settings.iconHeight)

        arenaFrame.icon:SetAtlas(arenaNumberMarkerIcon)
        arenaFrame:SetScale(iconScale)
        arenaFrame:ClearAllPoints()
        arenaFrame:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, verticalOffset)
        
        local unit = nameplate.UnitFrame and nameplate.UnitFrame.unit
        local highlightTarget = self:GetValue("arenaMarkers", "arenaHighlightTarget")
        if highlightTarget and unit and UnitIsUnit(unit, "target") then
            arenaFrame.glow:SetVertexColor(0.973, 0.788, 0.020, 0.7)
            arenaFrame.glow:Show()
        else
            arenaFrame.glow:Hide()
        end
        
        arenaFrame:Show()
    end
    
    function addon:ShowArenaHealerFrame(nameplate, unit, healerMarkerIcon)
        local iconScale, verticalOffset = self:CalculateMarkerPosition("arenaMarkers", "arenaMarkerSize")
        local healerFrame = self:CreateHealerMarker(nameplate, self.settings.iconWidth, self.settings.iconHeight)

        healerFrame.icon:SetAtlas(healerMarkerIcon)
        
        if healerMarkerIcon == "UI-LFG-RoleIcon-Healer-Disabled" then
            local _, class = UnitClass(unit)
            if class then
                local classColor = RAID_CLASS_COLORS[class]
                if classColor then
                    healerFrame.icon:SetDesaturated(true)
                    healerFrame.icon:SetVertexColor(classColor.r, classColor.g, classColor.b)
                end
            end
        end
        
        healerFrame:SetScale(iconScale)
        healerFrame:ClearAllPoints()
        healerFrame:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, verticalOffset)
        healerFrame:Show()
        
        if nameplate.ArenaNumberMarker then
            nameplate.ArenaNumberMarker:Hide()
        end
    end
    
    function addon:ShowFriendlyHealerFrame(nameplate, unit, healerMarkerIcon)
        local iconScale, verticalOffset = self:CalculateMarkerPosition("friendlyMarkers", "markerSize")
        local markerWidthValue = self:GetValue("friendlyMarkers", "markerWidth")
        local markerWidth = 1.0 + (markerWidthValue * 0.15)
        local width = self.settings.iconWidth * markerWidth
        local healerFrame = self:CreateHealerMarker(nameplate, width, self.settings.iconHeight)

        healerFrame.icon:SetAtlas(healerMarkerIcon)
        
        if healerMarkerIcon == "UI-LFG-RoleIcon-Healer-Disabled" then
            local _, class = UnitClass(unit)
            if class then
                local classColor = RAID_CLASS_COLORS[class]
                if classColor then
                    healerFrame.icon:SetDesaturated(true)
                    healerFrame.icon:SetVertexColor(classColor.r, classColor.g, classColor.b)
                end
            end
        end
        
        healerFrame:SetScale(iconScale)
        healerFrame:ClearAllPoints()
        healerFrame:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, verticalOffset)
        healerFrame:Show()
    end
    
    function addon:ShowFriendlyClassFrame(nameplate, unit)
        local _, class = UnitClass(unit)
        local classColor = RAID_CLASS_COLORS[class]
        
        if not class or not classColor then return end
        
        local iconScale, verticalOffset = self:CalculateMarkerPosition("friendlyMarkers", "markerSize")
        local markerWidthValue = self:GetValue("friendlyMarkers", "markerWidth")
        local markerWidth = 1.0 + (markerWidthValue * 0.15)
        local iconFrame = self:CreateClassIcon(nameplate)
        local markerTexture = self:GetValue("friendlyMarkers", "markerTexture")
        local specData = nil
        
        if markerTexture == "specIcon" then
            for _, partyUnit in ipairs({"party1", "party2"}) do
                if UnitIsUnit(unit, partyUnit) and self.unitSpecs[partyUnit] then
                    specData = self.unitSpecs[partyUnit]
                    break
                end
            end
        end
        
        if specData and specData.icon then
            iconFrame.icon:SetTexture(specData.icon)
            iconFrame.icon:SetTexCoord(0, 1, 0, 1)
        else
            iconFrame.icon:SetTexture(self.settings.classIconPath)
            iconFrame.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
        end
        iconFrame:SetSize(self.settings.iconSize * markerWidth, self.settings.iconSize)
        iconFrame.icon:SetSize(self.settings.iconSize * markerWidth, self.settings.iconSize)
        iconFrame.mask:SetSize(self.settings.iconSize * markerWidth, self.settings.iconSize)
        iconFrame.border:SetSize(self.settings.borderSize * markerWidth, self.settings.borderSize)
        iconFrame.border:SetDesaturated(true)
        iconFrame.border:SetVertexColor(classColor.r, classColor.g, classColor.b)
        iconFrame:SetScale(iconScale)
        iconFrame:ClearAllPoints()
        iconFrame:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, verticalOffset)
        
        local highlightTarget = self:GetValue("friendlyMarkers", "partyHighlightTarget")
        if highlightTarget and UnitIsUnit(unit, "target") then
            iconFrame.glow:SetVertexColor(0.973, 0.788, 0.020, 0.8)
            iconFrame.glow:Show()
        else
            iconFrame.glow:Hide()
        end
        
        iconFrame:Show()
    end
    
    function addon:ShowFriendlyArrowFrame(nameplate, unit, markerAtlas)
        local _, class = UnitClass(unit)
        local classColor = RAID_CLASS_COLORS[class]
        
        if not class or not classColor then return end
        
        local iconScale, verticalOffset = self:CalculateMarkerPosition("friendlyMarkers", "markerSize")
        local markerWidthValue = self:GetValue("friendlyMarkers", "markerWidth")
        local markerWidth = 1.0 + (markerWidthValue * 0.15)
        local styleInfo = nil

        for markerKey, markerData in pairs(self.settings.markers) do
            if markerData.atlas == markerAtlas then
                styleInfo = markerData
                break
            end
        end
        
        if not styleInfo then return end
        
        local width = self.settings.iconWidth
        local height = self.settings.iconHeight
        local isRotated90 = (styleInfo.rotation == math.pi / 2 or styleInfo.rotation == -math.pi / 2)
        local finalWidth = isRotated90 and width or (width * markerWidth)
        local finalHeight = isRotated90 and (height * markerWidth) or height
        local arrowFrame = self:CreateClassArrow(nameplate, finalWidth, finalHeight)

        arrowFrame.icon:SetAtlas(styleInfo.atlas)
        arrowFrame.icon:SetRotation(styleInfo.rotation)
        arrowFrame.icon:SetDesaturated(true)
        arrowFrame.icon:SetVertexColor(classColor.r, classColor.g, classColor.b)
        arrowFrame:SetScale(iconScale)
        arrowFrame:ClearAllPoints()
        arrowFrame:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, verticalOffset)
        
        local highlightTarget = self:GetValue("friendlyMarkers", "partyHighlightTarget")
        if highlightTarget and UnitIsUnit(unit, "target") then
            arrowFrame.glow:SetAtlas(styleInfo.atlas)
            arrowFrame.glow:SetRotation(styleInfo.rotation)
            arrowFrame.glow:SetDesaturated(true)
            arrowFrame.glow:SetVertexColor(0.973, 0.788, 0.020, 0.7)
            arrowFrame.glow:Show()
        else
            arrowFrame.glow:Hide()
        end
        
        arrowFrame:Show()
    end

    function addon:UpdateHealthbarVisibility(nameplate, unit, visible)
        local unitFrame = nameplate.UnitFrame
        if not unitFrame then return end
        
        if unitFrame.healthBar then
            unitFrame.healthBar:SetAlpha(visible and 1 or 0)
        end
        if unitFrame.RaidTargetFrame then
            unitFrame.RaidTargetFrame:SetAlpha(visible and 1 or 0)
        end
        
        if not visible and unit then
            if unitFrame.name then
                unitFrame.name:SetAlpha(0)
            end
            
            local _, class = UnitClass(unit)
            local classColor = RAID_CLASS_COLORS[class]
            if class and classColor then
                local markerFrame = nameplate.FriendlyClassIcon or nameplate.FriendlyClassArrow or nameplate.ArenaNumberMarker or nameplate.HealerMarker
                local nameText = self:CreateCustomNameText(nameplate, markerFrame)
                nameText:SetText(UnitName(unit))
                nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
                nameText:Show()
            end
        else
            if nameplate.CustomNameText then
                nameplate.CustomNameText:Hide()
            end
            
            if unitFrame.name then
                unitFrame.name:SetAlpha(1)
            end
        end
    end

    function addon:ResetHealthbarVisibility(nameplate)
        if nameplate.CustomNameText then
            nameplate.CustomNameText:Hide()
        end
        
        local unitFrame = nameplate.UnitFrame
        if unitFrame then
            if unitFrame.healthBar then
                unitFrame.healthBar:SetAlpha(1)
            end
            if unitFrame.RaidTargetFrame then
                unitFrame.RaidTargetFrame:SetAlpha(1)
            end
            if unitFrame.name then
                unitFrame.name:SetAlpha(1)
            end
        end
    end
end

do -- Additional functions

    function addon:CvarUpdate(cvarName)
        if cvarName == "nameplateSize" then
            self.settings.nameplateSizeOffset = tonumber(GetCVar(cvarName)) * self.settings.nameplateSizeOffsetMultiplier
            
            if self.settings.nameplateUpdateTimer then
                self.settings.nameplateUpdateTimer:Cancel()
            end
            
            self.settings.nameplateUpdateTimer = C_Timer.NewTimer(self.settings.updateDelay, function()
                self:RefreshAllNameplates()
                self.settings.nameplateUpdateTimer = nil
            end)
        end
    end
    
    function addon:GetArenaUnitForNameplate(nameplate)
        local unitFrame = nameplate and nameplate.UnitFrame
        local unit = unitFrame and unitFrame.unit
        if not unit then return nil end
        
        local plateName = UnitName(unit)
        if not plateName then return nil end
        
        for i = 1, 3 do
            local arenaUnit = "arena" .. i
            if self:SecureCall(UnitExists, arenaUnit) then
                local arenaName = UnitName(arenaUnit)
                if arenaName and arenaName == plateName then
                    return arenaUnit
                end
            end
        end
        return nil
    end
    
    function addon:GetHealerMarkerIcon(unit, settingsCategory, healerIconSetting)
        if UnitGroupRolesAssigned(unit) ~= "HEALER" then
            return nil
        end
        
        local healerMarkerKey = self:GetValue(settingsCategory, healerIconSetting)
        if not healerMarkerKey or healerMarkerKey == "none" then
            return nil
        end
        
        local markerInfo = self.settings.healerMarkers[healerMarkerKey]
        return markerInfo and markerInfo.atlas or nil
    end
    
    function addon:GetArenaNumberMarkerIcon(arenaUnit)
        local arenaMarkerTexture = self:GetValue("arenaMarkers", "arenaMarkerTexture")
        if arenaMarkerTexture == "numbers" then
            local markerInfo = self.settings.arenaMarkers[arenaUnit]
            return markerInfo and markerInfo.atlas or nil
        end
        return nil
    end
    
    function addon:GetFriendlyMarkerIcon()
        local markerTexture = self:GetValue("friendlyMarkers", "markerTexture")
        if not markerTexture or markerTexture == "none" or markerTexture == "classIcon" then
            return nil
        end
        
        local markerInfo = self.settings.markers[markerTexture]
        return markerInfo and markerInfo.atlas or nil
    end
    
    function addon:GetFriendlyClassIcon()
        local markerTexture = self:GetValue("friendlyMarkers", "markerTexture")
        return markerTexture == "classIcon"
    end
end

do -- Create UI Elements
    function addon:CreateCustomNameText(nameplate, markerFrame)
        if nameplate.CustomNameText then
            local fontSize = self:GetValue("friendlyMarkers", "friendlyCustomNameSize") or self.settings.defaultFriendlyCustomNameSize
            nameplate.CustomNameText:SetFont("Fonts\\ARIALN.TTF", fontSize, "OUTLINE")
            nameplate.CustomNameText:ClearAllPoints()
            if markerFrame then
                nameplate.CustomNameText:SetPoint("TOP", markerFrame, "BOTTOM", 0, -5)
            else
                local currentNameplateSize = tonumber(GetCVar("nameplateSize")) or 1
                local nameplateSizeOffset = currentNameplateSize * self.settings.nameplateSizeOffsetMultiplier
                local verticalOffset = self.settings.defaultVerticalOffset + nameplateSizeOffset
                nameplate.CustomNameText:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, verticalOffset)
            end
            return nameplate.CustomNameText
        end
        
        local nameText = nameplate:CreateFontString(nil, "OVERLAY")
        local fontSize = self:GetValue("friendlyMarkers", "friendlyCustomNameSize") or self.settings.defaultFriendlyCustomNameSize

        nameText:SetFont("Fonts\\ARIALN.TTF", fontSize, "OUTLINE")
        nameText:SetJustifyH("CENTER")
        
        if markerFrame then
            nameText:SetPoint("TOP", markerFrame, "BOTTOM", 0, -5)
        else
            local currentNameplateSize = tonumber(GetCVar("nameplateSize")) or 1
            local nameplateSizeOffset = currentNameplateSize * self.settings.nameplateSizeOffsetMultiplier
            local verticalOffset = self.settings.defaultVerticalOffset + nameplateSizeOffset

            nameText:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, verticalOffset)
        end
        
        nameplate.CustomNameText = nameText
        return nameText
    end

    function addon:CreateClassArrow(nameplate, width, height)
        if nameplate.FriendlyClassArrow then
            local w = width
            local h = height
            nameplate.FriendlyClassArrow:SetSize(h, w)
            nameplate.FriendlyClassArrow.icon:SetSize(w, h)
            nameplate.FriendlyClassArrow.glow:SetSize(w * 1.5, h * 1.5)
            return nameplate.FriendlyClassArrow
        end
        
        local w = width
        local h = height        
        local arrowFrame = CreateFrame("Frame", nil, nameplate)

        arrowFrame:SetMouseClickEnabled(false)
        arrowFrame:SetAlpha(1)
        arrowFrame:SetIgnoreParentAlpha(true)
        arrowFrame:SetSize(h, w)
        arrowFrame:SetFrameStrata("HIGH")
        arrowFrame:SetPoint("CENTER", nameplate, "CENTER")
        
        arrowFrame.glow = arrowFrame:CreateTexture(nil, "BACKGROUND")
        arrowFrame.glow:SetSize(w * 1.5, h * 1.5)
        arrowFrame.glow:SetPoint("CENTER", arrowFrame, "CENTER")
        arrowFrame.glow:SetBlendMode("ADD")
        arrowFrame.glow:SetDesaturated(true)
        arrowFrame.glow:Hide()
        
        arrowFrame.icon = arrowFrame:CreateTexture(nil, "BORDER")
        arrowFrame.icon:SetSize(w, h)
        arrowFrame.icon:SetDesaturated(false)
        arrowFrame.icon:SetPoint("CENTER", arrowFrame, "CENTER")        
        arrowFrame:Hide()
        nameplate.FriendlyClassArrow = arrowFrame

        return arrowFrame
    end

    function addon:CreateClassIcon(nameplate)
        if nameplate.FriendlyClassIcon then
            return nameplate.FriendlyClassIcon
        end
        
        local iconFrame = CreateFrame("Frame", nil, nameplate)

        iconFrame:SetMouseClickEnabled(false)
        iconFrame:SetAlpha(1)
        iconFrame:SetIgnoreParentAlpha(true)
        iconFrame:SetSize(self.settings.iconSize, self.settings.iconSize)
        iconFrame:SetFrameStrata("HIGH")
        iconFrame:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, 0)
        
        iconFrame.glow = iconFrame:CreateTexture(nil, "BACKGROUND")
        iconFrame.glow:SetTexture("Interface/Masks/CircleMaskScalable")
        iconFrame.glow:SetSize(self.settings.iconSize * 1.4, self.settings.iconSize * 1.4)
        iconFrame.glow:SetPoint("CENTER", iconFrame)
        iconFrame.glow:SetBlendMode("ADD")
        iconFrame.glow:Hide()
        
        iconFrame.icon = iconFrame:CreateTexture(nil, "BORDER")
        iconFrame.icon:SetSize(self.settings.iconSize, self.settings.iconSize)
        iconFrame.icon:SetAllPoints(iconFrame)        
        iconFrame.mask = iconFrame:CreateMaskTexture()
        iconFrame.mask:SetTexture("Interface/Masks/CircleMaskScalable")
        iconFrame.mask:SetSize(self.settings.iconSize, self.settings.iconSize)
        iconFrame.mask:SetAllPoints(iconFrame.icon)
        iconFrame.icon:AddMaskTexture(iconFrame.mask)        
        iconFrame.border = iconFrame:CreateTexture(nil, "OVERLAY")
        iconFrame.border:SetAtlas("charactercreate-ring-metallight")
        iconFrame.border:SetSize(self.settings.borderSize, self.settings.borderSize)
        iconFrame.border:SetPoint("CENTER", iconFrame)        
        iconFrame:Hide()

        nameplate.FriendlyClassIcon = iconFrame
        return iconFrame
    end

    function addon:CreateArenaMarker(nameplate, width, height)
        if nameplate.ArenaNumberMarker then
            nameplate.ArenaNumberMarker:SetSize(width, height)
            nameplate.ArenaNumberMarker.icon:SetSize(width, height)
            nameplate.ArenaNumberMarker.glow:SetSize(width * 1.15, height * 1.15)
            return nameplate.ArenaNumberMarker
        end
        
        local markerFrame = CreateFrame("Frame", nil, nameplate)
        markerFrame:SetMouseClickEnabled(false)
        markerFrame:SetAlpha(1)
        markerFrame:SetIgnoreParentAlpha(true)
        markerFrame:SetSize(width, height)
        markerFrame:SetFrameStrata("HIGH")
        markerFrame:SetPoint("CENTER", nameplate, "CENTER")
        
        markerFrame.glow = markerFrame:CreateTexture(nil, "BACKGROUND")
        markerFrame.glow:SetTexture("Interface/Masks/CircleMaskScalable")
        markerFrame.glow:SetSize(width * 1.15, height * 1.15)
        markerFrame.glow:SetPoint("CENTER", markerFrame, "CENTER")
        markerFrame.glow:SetBlendMode("ADD")
        markerFrame.glow:Hide()
        
        markerFrame.icon = markerFrame:CreateTexture(nil, "OVERLAY")
        markerFrame.icon:SetSize(width, height)
        markerFrame.icon:SetPoint("CENTER", markerFrame, "CENTER")        
        markerFrame:Hide()
        nameplate.ArenaNumberMarker = markerFrame
        return markerFrame
    end

    function addon:CreateHealerMarker(nameplate, width, height)
        if nameplate.HealerMarker then
            nameplate.HealerMarker:SetSize(width, height)
            nameplate.HealerMarker.icon:SetSize(width, height)
            return nameplate.HealerMarker
        end
        
        local markerFrame = CreateFrame("Frame", nil, nameplate)

        markerFrame:SetMouseClickEnabled(false)
        markerFrame:SetAlpha(1)
        markerFrame:SetIgnoreParentAlpha(true)
        markerFrame:SetSize(width, height)
        markerFrame:SetFrameStrata("HIGH")
        markerFrame:SetPoint("CENTER", nameplate, "CENTER")        
        markerFrame.icon = markerFrame:CreateTexture(nil, "OVERLAY")
        markerFrame.icon:SetSize(width, height)
        markerFrame.icon:SetPoint("CENTER", markerFrame, "CENTER")        
        markerFrame:Hide()
        nameplate.HealerMarker = markerFrame

        return markerFrame
    end
end
