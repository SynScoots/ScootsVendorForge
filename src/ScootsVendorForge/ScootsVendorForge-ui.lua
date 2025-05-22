ScootsVendorForge = ScootsVendorForge or {}

ScootsVendorForge.buildUi = function()
    ScootsVendorForge.uiBuilt = true
    ScootsVendorForge.panelWidth = 220
    ScootsVendorForge.frames.items = {}

    ScootsVendorForge.alterBase()
    ScootsVendorForge.createPanel()
    ScootsVendorForge.createOptions()
    ScootsVendorForge.setLevels()
end

ScootsVendorForge.alterBase = function()
    ScootsVendorForge.frames.master = CreateFrame('Frame', 'ScootsVendorForge-MasterFrame', UIParent)
    
    UIPanelWindows.MerchantFrame = nil
    UIPanelWindows[ScootsVendorForge.frames.master:GetName()] = {
        ['area'] = 'left',
        ['pushable'] = 0
    }
    
    ScootsVendorForge.frames.master:SetSize(MerchantFrame:GetWidth() + ScootsVendorForge.panelWidth - 30, MerchantFrame:GetHeight())
    ScootsVendorForge.frames.master:SetFrameStrata(MerchantFrame:GetFrameStrata())
    
    local point, relativeTo, relativePoint, xOfs, yOfs = MerchantFrame:GetPoint()
    ScootsVendorForge.frames.master:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
    
    ScootsVendorForge.frames.master:Hide()
    
    MerchantFrame:SetScript('OnHide', nil)
    MerchantFrame:SetParent(ScootsVendorForge.frames.master)
    MerchantFrame:SetPoint('TOPLEFT', ScootsVendorForge.frames.master, 'TOPLEFT', 0, 0)
    
    ShowUIPanel(ScootsVendorForge.frames.master)
    
    MerchantFrame:SetScript('OnHide', MerchantFrame_OnHide)
    MerchantFrame:HookScript('OnHide', function()
        HideUIPanel(ScootsVendorForge.frames.master)
    end)
    
    MerchantFrame:Show()
end

ScootsVendorForge.createPanel = function()
    -- Main panel
    ScootsVendorForge.frames.panel = CreateFrame('Frame', 'ScootsVendorForge-FlyoutFrame', ScootsVendorForge.frames.master)
    ScootsVendorForge.frames.panel:SetSize(ScootsVendorForge.panelWidth, 437)
    ScootsVendorForge.frames.panel:SetFrameStrata(ScootsVendorForge.frames.master:GetFrameStrata())
    ScootsVendorForge.frames.panel:SetPoint('TOPLEFT', MerchantFrame, 'TOPRIGHT', -35, -14)
    ScootsVendorForge.frames.panel:EnableMouse(true)

    -- Background
    ScootsVendorForge.frames.panel.background = ScootsVendorForge.frames.panel:CreateTexture(nil, 'BACKGROUND')
    ScootsVendorForge.frames.panel.background:SetTexture('Interface\\AddOns\\ScootsVendorForge\\Textures\\Frame-Flyout')
    ScootsVendorForge.frames.panel.background:SetPoint('TOPRIGHT', 5, 13)
    ScootsVendorForge.frames.panel.background:SetSize(512, 512)
    
    -- Header
    ScootsVendorForge.frames.panel.title = ScootsVendorForge.frames.panel:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.frames.panel.title:SetFontObject('GameFontNormal')
    ScootsVendorForge.frames.panel.title:SetPoint('TOPLEFT', 4, -4)
    ScootsVendorForge.frames.panel.title:SetJustifyH('LEFT')
    ScootsVendorForge.frames.panel.title:SetText(ScootsVendorForge.title)
    
    -- Scroll frame
    ScootsVendorForge.frames.scrollFrame = CreateFrame('ScrollFrame', 'ScootsVendorForge-ScrollFrame', ScootsVendorForge.frames.panel, 'UIPanelScrollFrameTemplate')
    ScootsVendorForge.frames.scrollFrame:SetFrameStrata(ScootsVendorForge.frames.master:GetFrameStrata())
    
    ScootsVendorForge.frames.scrollChild = CreateFrame('Frame', 'ScootsVendorForge-ScrollChild', ScootsVendorForge.frames.scrollFrame)
    ScootsVendorForge.frames.scrollChild:SetFrameStrata(ScootsVendorForge.frames.master:GetFrameStrata())
    
    local scrollBarName = ScootsVendorForge.frames.scrollFrame:GetName()
    ScootsVendorForge.frames.scrollBar = _G[scrollBarName .. 'ScrollBar']
    ScootsVendorForge.frames.scrollUpButton = _G[scrollBarName .. 'ScrollBarScrollUpButton']
    ScootsVendorForge.frames.scrollDownButton = _G[scrollBarName .. 'ScrollBarScrollDownButton']

    ScootsVendorForge.frames.scrollUpButton:ClearAllPoints()
    ScootsVendorForge.frames.scrollUpButton:SetPoint('TOPRIGHT', ScootsVendorForge.frames.scrollFrame, 'TOPRIGHT', -2, -2)

    ScootsVendorForge.frames.scrollDownButton:ClearAllPoints()
    ScootsVendorForge.frames.scrollDownButton:SetPoint('BOTTOMRIGHT', ScootsVendorForge.frames.scrollFrame, 'BOTTOMRIGHT', -2, 2)

    ScootsVendorForge.frames.scrollBar:ClearAllPoints()
    ScootsVendorForge.frames.scrollBar:SetPoint('TOP', ScootsVendorForge.frames.scrollUpButton, 'BOTTOM', 0, -2)
    ScootsVendorForge.frames.scrollBar:SetPoint('BOTTOM', ScootsVendorForge.frames.scrollDownButton, 'TOP', 0, 2)

    ScootsVendorForge.frames.scrollFrame:SetScrollChild(ScootsVendorForge.frames.scrollChild)
    ScootsVendorForge.frames.scrollFrame:SetPoint('TOPLEFT', ScootsVendorForge.frames.panel, 'TOPLEFT', 0, -50)
    ScootsVendorForge.frames.scrollFrame:SetSize(ScootsVendorForge.panelWidth, 385)
    
    ScootsVendorForge.frames.scrollChild:SetWidth(ScootsVendorForge.frames.scrollFrame:GetWidth() - 23)
    
    -- Loading icon
    ScootsVendorForge.loadingIcon = ScootsVendorForge.frames.panel:CreateTexture(nil, 'BORDER')
    ScootsVendorForge.loadingIcon:SetTexture('Interface\\AddOns\\ScootsVendorForge\\Textures\\Loader')
    ScootsVendorForge.loadingIcon:SetPoint('TOPLEFT', 5, -56)
    ScootsVendorForge.loadingIcon:SetSize(10, 10)
    ScootsVendorForge.loadingIcon:Hide()
    
    ScootsVendorForge.frames.panel:SetScript('OnUpdate', function(self, elapsed)
        ScootsVendorForge.loadingIcon.rotation = ((ScootsVendorForge.loadingIcon.rotation or 0) - (elapsed * 6)) % 360
        ScootsVendorForge.loadingIcon:SetRotation(ScootsVendorForge.loadingIcon.rotation)
    end)
    
    ScootsVendorForge.loadingText = ScootsVendorForge.frames.panel:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.loadingText:SetFontObject('GameFontHighlightSmall')
    ScootsVendorForge.loadingText:SetPoint('TOPLEFT', 20, -56)
    ScootsVendorForge.loadingText:SetJustifyH('LEFT')
    ScootsVendorForge.loadingText:SetText('Loading...')
    ScootsVendorForge.loadingText:Hide()
    
    -- Failed loading
    ScootsVendorForge.cacheFailText = ScootsVendorForge.frames.panel:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.cacheFailText:SetFontObject('GameFontRedSmall')
    ScootsVendorForge.cacheFailText:SetPoint('TOPLEFT', 4, -56)
    ScootsVendorForge.cacheFailText:SetJustifyH('LEFT')
    ScootsVendorForge.cacheFailText:SetText('Failed to cache merchant.' .. '\n' .. '/reload your UI and try again.')
    ScootsVendorForge.cacheFailText:Hide()
end

ScootsVendorForge.createOptions = function()
    -- Forge dropdown label
    ScootsVendorForge.frames.panel.forgeLabel = ScootsVendorForge.frames.panel:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.frames.panel.forgeLabel:SetFontObject('GameFontHighlightSmall')
    ScootsVendorForge.frames.panel.forgeLabel:SetPoint('TOPLEFT', 4, -28)
    ScootsVendorForge.frames.panel.forgeLabel:SetJustifyH('LEFT')
    ScootsVendorForge.frames.panel.forgeLabel:SetText('Stop at: ')
    
    -- Forge dropdown
    ScootsVendorForge.frames.forgeLevel = CreateFrame('Frame', 'ScootsVendorForge-ForgeLevel', ScootsVendorForge.frames.panel, 'UIDropDownMenuTemplate')
    ScootsVendorForge.frames.forgeLevel:SetPoint('TOPRIGHT', ScootsVendorForge.frames.panel, 'TOPRIGHT', -111, -20)
    ScootsVendorForge.frames.forgeLevel:SetFrameStrata(ScootsVendorForge.frames.master:GetFrameStrata())
    
    ScootsVendorForge.selectedForgeLevelChoiceIndex = 1
    ScootsVendorForge.forgeLevelChoices = {
        {1, '>= Titanforged'},
        {2, '>= Warforged'},
        {3, 'Lightforged'}
    }
    
    UIDropDownMenu_Initialize(ScootsVendorForge.frames.forgeLevel, ScootsVendorForge.setForgeLevelValues)
    UIDropDownMenu_SetSelectedValue(ScootsVendorForge.frames.forgeLevel, index)
    UIDropDownMenu_SetText(ScootsVendorForge.frames.forgeLevel, ScootsVendorForge.forgeLevelChoices[ScootsVendorForge.selectedForgeLevelChoiceIndex][2])
    
    -- Background
    ScootsVendorForge.frames.panel.forgeLevelBackground = ScootsVendorForge.frames.panel:CreateTexture(nil, 'BORDER')
    ScootsVendorForge.frames.panel.forgeLevelBackground:SetTexture(0.75, 0.75, 1, 0.1)
    ScootsVendorForge.frames.panel.forgeLevelBackground:SetPoint('TOPRIGHT', -2, -21)
    ScootsVendorForge.frames.panel.forgeLevelBackground:SetSize(ScootsVendorForge.panelWidth, 27)
    
    -- Border
    ScootsVendorForge.frames.panel.forgeLevelBorder = ScootsVendorForge.frames.panel:CreateTexture(nil, 'BORDER')
    ScootsVendorForge.frames.panel.forgeLevelBorder:SetTexture(0.95, 0.95, 1, 0.45)
    ScootsVendorForge.frames.panel.forgeLevelBorder:SetPoint('TOPRIGHT', -2, 0 - (21 + ScootsVendorForge.frames.panel.forgeLevelBackground:GetHeight()))
    ScootsVendorForge.frames.panel.forgeLevelBorder:SetSize(ScootsVendorForge.panelWidth, 2)
    
    -- Scrollbar border
    ScootsVendorForge.frames.panel.scrollBarBorder = ScootsVendorForge.frames.panel:CreateTexture(nil, 'BORDER')
    ScootsVendorForge.frames.panel.scrollBarBorder:SetTexture(0.95, 0.95, 1, 0.45)
    ScootsVendorForge.frames.panel.scrollBarBorder:SetPoint('TOPRIGHT', ScootsVendorForge.frames.panel.forgeLevelBorder, 'BOTTOMRIGHT', -19, 0)
    ScootsVendorForge.frames.panel.scrollBarBorder:SetSize(1.5, ScootsVendorForge.frames.scrollFrame:GetHeight())
end

ScootsVendorForge.setForgeLevelValues = function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    
    for choiceIndex, choice in ipairs(ScootsVendorForge.forgeLevelChoices) do
        if(ScootsVendorForge.getOption('forgelevel') == choice[1]) then
            ScootsVendorForge.selectedForgeLevelChoiceIndex = choiceIndex
        end
    
        info.text = choice[2]
        info.func = function()
            UIDropDownMenu_SetText(ScootsVendorForge.frames.forgeLevel, choice[2])
            ScootsVendorForge.setOption('forgelevel', choice[1])
        end
        
        UIDropDownMenu_AddButton(info, level)
    end
end

ScootsVendorForge.hideAllItemFrames = function()
    for _, frame in pairs(ScootsVendorForge.frames.items) do
        frame:Hide()
    end
end

ScootsVendorForge.setItemFrame = function(index, item, offset)
    if(not ScootsVendorForge.frames.items[index]) then
        ScootsVendorForge.frames.items[index] = CreateFrame('Frame', 'ScootsVendorForge-itemFrame-' .. tostring(index), ScootsVendorForge.frames.scrollChild)
        ScootsVendorForge.frames.items[index]:SetWidth(ScootsVendorForge.frames.scrollChild:GetWidth())
        ScootsVendorForge.frames.items[index]:SetFrameStrata(ScootsVendorForge.frames.master:GetFrameStrata())
        ScootsVendorForge.frames.items[index]:EnableMouse(true)
        
        ScootsVendorForge.frames.items[index].background = ScootsVendorForge.frames.items[index]:CreateTexture(nil, 'BACKGROUND')
        ScootsVendorForge.frames.items[index].background:SetAllPoints()
        
        ScootsVendorForge.frames.items[index].borderTop = ScootsVendorForge.frames.items[index]:CreateTexture(nil, 'BORDER')
        ScootsVendorForge.frames.items[index].borderTop:SetSize(ScootsVendorForge.frames.scrollChild:GetWidth(), 1)
        ScootsVendorForge.frames.items[index].borderTop:SetPoint('TOPLEFT', ScootsVendorForge.frames.items[index], 'TOPLEFT', 0, 0)
        
        ScootsVendorForge.frames.items[index].borderBottom = ScootsVendorForge.frames.items[index]:CreateTexture(nil, 'BORDER')
        ScootsVendorForge.frames.items[index].borderBottom:SetSize(ScootsVendorForge.frames.scrollChild:GetWidth(), 1)
        ScootsVendorForge.frames.items[index].borderBottom:SetPoint('BOTTOMLEFT', ScootsVendorForge.frames.items[index], 'BOTTOMLEFT', 0, 0)
        
        ScootsVendorForge.frames.items[index].icon = ScootsVendorForge.frames.items[index]:CreateTexture(nil, 'ARTWORK')
        ScootsVendorForge.frames.items[index].icon:SetSize(24, 24)
        ScootsVendorForge.frames.items[index].icon:SetPoint('TOPLEFT', ScootsVendorForge.frames.items[index], 'TOPLEFT', 4, -4)
        
        ScootsVendorForge.frames.items[index].text = ScootsVendorForge.frames.items[index]:CreateFontString(nil, 'ARTWORK')
        ScootsVendorForge.frames.items[index].text:SetWidth(ScootsVendorForge.frames.scrollChild:GetWidth() - (12 + ScootsVendorForge.frames.items[index].icon:GetWidth()))
        ScootsVendorForge.frames.items[index].text:SetFontObject('GameFontNormal')
        ScootsVendorForge.frames.items[index].text:SetPoint('TOPLEFT', ScootsVendorForge.frames.items[index].icon:GetWidth() + 8, -4)
        ScootsVendorForge.frames.items[index].text:SetJustifyH('LEFT')
    end
    
    local colours = ScootsVendorForge.getAttunementColours(item.forge)
    
    ScootsVendorForge.frames.items[index].background:SetTexture(colours.back.r, colours.back.g, colours.back.b, colours.back.a)
    ScootsVendorForge.frames.items[index].borderTop:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a)
    ScootsVendorForge.frames.items[index].borderBottom:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a)
    
    ScootsVendorForge.frames.items[index].icon:SetTexture(select(10, GetItemInfo(item.link)))
    
    ScootsVendorForge.frames.items[index].text:SetTextColor(colours.front.r, colours.front.g, colours.front.b)
    ScootsVendorForge.frames.items[index].text:SetText(select(1, GetItemInfo(item.link)))
    
    ScootsVendorForge.frames.items[index]:SetHeight(math.max(ScootsVendorForge.frames.items[index].icon:GetHeight(), ScootsVendorForge.frames.items[index].text:GetHeight()) + 8)
    
    ScootsVendorForge.frames.items[index]:SetScript('OnEnter', function()
        ScootsVendorForge.frames.items[index].hover = true
        
        ScootsVendorForge.frames.items[index].background:SetTexture(colours.back.r, colours.back.g, colours.back.b, colours.back.a + 0.1)
        ScootsVendorForge.frames.items[index].borderTop:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a + 0.1)
        ScootsVendorForge.frames.items[index].borderBottom:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a + 0.1)
        
        GameTooltip:SetOwner(ScootsVendorForge.frames.items[index], 'ANCHOR_RIGHT')
        GameTooltip:SetHyperlink(item.link)
    end)
    
    ScootsVendorForge.frames.items[index]:SetScript('OnLeave', function()
        ScootsVendorForge.frames.items[index].hover = false
        
        ScootsVendorForge.frames.items[index].background:SetTexture(colours.back.r, colours.back.g, colours.back.b, colours.back.a)
        ScootsVendorForge.frames.items[index].borderTop:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a)
        ScootsVendorForge.frames.items[index].borderBottom:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a)
        
        GameTooltip_Hide(ScootsVendorForge.frames.items[index])
        SetCursor(nil)
    end)
    
    ScootsVendorForge.frames.items[index]:SetScript('OnMouseDown', function(self, button)
        if(button == 'RightButton') then
            StaticPopupDialogs['SCOOTSVENDORFORGE_CONFIRM'] = {
                ['text'] = table.concat({
                    'This will purchase ' .. item.link .. ' until it forges at the designated level, or you can no longer afford it.',
                    'Additionally, any ' .. item.link .. ' you have in your bags will be sold.',
                    'Do you wish to continue?'
                }, '\n\n'),
                ['button1'] = 'Yes',
                ['button2'] = 'No',
                ['OnAccept'] = function()
                    ScootsVendorForge.purchaseItemId = item.id
                    ScootsVendorForge.refreshPanelEvent = true
                end,
                ['timeout'] = 0,
                ['whileDead'] = true,
                ['hideOnEscape'] = true
            }
            StaticPopup_Show('SCOOTSVENDORFORGE_CONFIRM')
        end
    end)
        
    ScootsVendorForge.frames.items[index]:SetScript('OnUpdate', function()
        if(ScootsVendorForge.frames.items[index].hover) then
            ShowMerchantSellCursor(item.index)
        end
    end)
    
    ScootsVendorForge.frames.items[index]:SetPoint('TOPLEFT', ScootsVendorForge.frames.scrollChild, 'TOPLEFT', 0, 0 - offset)
    ScootsVendorForge.frames.items[index]:Show()
    
    return offset + ScootsVendorForge.frames.items[index]:GetHeight()
end

ScootsVendorForge.setLevels = function()
    ScootsVendorForge.frames.master:SetFrameLevel(MerchantFrame:GetFrameLevel())
    ScootsVendorForge.frames.panel:SetFrameLevel(ScootsVendorForge.frames.master:GetFrameLevel() + 1)
    ScootsVendorForge.frames.forgeLevel:SetFrameLevel(ScootsVendorForge.frames.master:GetFrameLevel() + 2)
    ScootsVendorForge.frames.scrollFrame:SetFrameLevel(ScootsVendorForge.frames.master:GetFrameLevel() + 3)
    ScootsVendorForge.frames.scrollBar:SetFrameLevel(ScootsVendorForge.frames.master:GetFrameLevel() + 4)
    ScootsVendorForge.frames.scrollUpButton:SetFrameLevel(ScootsVendorForge.frames.master:GetFrameLevel() + 4)
    ScootsVendorForge.frames.scrollDownButton:SetFrameLevel(ScootsVendorForge.frames.master:GetFrameLevel() + 4)
    ScootsVendorForge.frames.scrollChild:SetFrameLevel(ScootsVendorForge.frames.master:GetFrameLevel() + 4)
    
    for _, frame in pairs(ScootsVendorForge.frames.items) do
        frame:SetFrameLevel(ScootsVendorForge.frames.master:GetFrameLevel() + 5)
    end
end

ScootsVendorForge.moveScootsTokens = function()
    if(STMasterFrame and STMasterFrame:IsVisible()) then
        STMasterFrame:SetPoint('TOPLEFT', ScootsVendorForge.frames.master, 'TOPRIGHT', 0, -12)
        ScootsVendorForge.ScootsTokensMoved = true
    end
end