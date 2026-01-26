local addonName = ...
local SAdCore = LibStub("SAdCore-1")
local addon = SAdCore:GetAddon(addonName)

addon.sadCore.savedVarsGlobalName = "SAdArenaMarkers_Settings_Global"
addon.sadCore.savedVarsPerCharName = "SAdArenaMarkers_Settings_Char"
addon.sadCore.compartmentFuncName = "SAdArenaMarkers_Compartment_Func"

addon.settings = {}
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
                type = "dropdown",
                name = "friendlyHealerIcon",
                default = "none",
                options = healerMarkerOptions,
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
        self:EnableFriendlyPlayers()
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
end

function addon:OnZoneChange(currentZone)
    self:RefreshAllNameplates()
end

function addon:RefreshAllNameplates()
    local nameplates = C_NamePlate.GetNamePlates()
    for _, nameplate in ipairs(nameplates) do
        self:HandleNameplateEvent(nameplate)
    end
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
            self:ShowFriendlyMarker(nameplate, unit)
        end
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
        local friendlyClassIcon = self:GetFriendlyClassIcon()
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

        iconFrame.icon:SetTexture(self.settings.classIconPath)
        iconFrame.icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
        iconFrame:SetSize(self.settings.iconSize * markerWidth, self.settings.iconSize)
        iconFrame.icon:SetSize(self.settings.iconSize * markerWidth, self.settings.iconSize)
        iconFrame.mask:SetSize(self.settings.iconSize * markerWidth, self.settings.iconSize)
        iconFrame.border:SetSize(self.settings.borderSize * markerWidth, self.settings.borderSize)
        iconFrame.border:SetDesaturated(true)
        iconFrame.border:SetVertexColor(classColor.r, classColor.g, classColor.b)
        iconFrame:SetScale(iconScale)
        iconFrame:ClearAllPoints()
        iconFrame:SetPoint("BOTTOM", nameplate, "BOTTOM", 0, verticalOffset)
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
    
    function addon:EnableFriendlyPlayers()
        local showFriendlyPlayers = GetCVar("nameplateShowFriendlyPlayers")
            
        C_Timer.After(0.5, function()
            if showFriendlyPlayers ~= "1" then
                addon:CombatSafe(function()
                    SetCVar("nameplateShowFriendlyPlayers", "1")
                end)
            end
            self:CvarUpdate("nameplateSize")
        end)
    end

    function addon:GetArenaUnitForNameplate(nameplate)
        for i = 1, 3 do
            local arenaNameplate = C_NamePlate.GetNamePlateForUnit("arena" .. i)
            if arenaNameplate == nameplate then
                return "arena" .. i
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
        
        local anchorFrame = markerFrame or nameplate
        local nameText = anchorFrame:CreateFontString(nil, "OVERLAY")

        nameText:SetFont("Fonts\\ARIALN.TTF", 16, "OUTLINE")
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
            return nameplate.ArenaNumberMarker
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
