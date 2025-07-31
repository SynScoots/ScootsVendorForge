ScootsVendorForge = ScootsVendorForge or {}

ScootsVendorForge.frameStrata = 'MEDIUM'
ScootsVendorForge.textSize = 10
ScootsVendorForge.borderThickness = 0.7
ScootsVendorForge.currencyHeight = 10
ScootsVendorForge.currencySize = 14

ScootsVendorForge.totalAttuneCurrency = {}


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
    ScootsVendorForge.frames.scrollFrame:SetPoint('TOPLEFT', ScootsVendorForge.frames.panel, 'TOPLEFT', 0, -65)
    ScootsVendorForge.frames.scrollFrame:SetSize(ScootsVendorForge.panelWidth, 370)
    
    ScootsVendorForge.frames.scrollChild:SetWidth(ScootsVendorForge.frames.scrollFrame:GetWidth() - 23)
    
    -- Loading icon
    ScootsVendorForge.loadingIcon = ScootsVendorForge.frames.panel:CreateTexture(nil, 'BORDER')
    ScootsVendorForge.loadingIcon:SetTexture('Interface\\AddOns\\ScootsVendorForge\\Textures\\Loader')
    ScootsVendorForge.loadingIcon:SetPoint('TOPLEFT', 5, -61)
    ScootsVendorForge.loadingIcon:SetSize(10, 10)
    ScootsVendorForge.loadingIcon:Hide()
    
    ScootsVendorForge.frames.panel:SetScript('OnUpdate', function(self, elapsed)
        ScootsVendorForge.loadingIcon.rotation = ((ScootsVendorForge.loadingIcon.rotation or 0) - (elapsed * 6)) % 360
        ScootsVendorForge.loadingIcon:SetRotation(ScootsVendorForge.loadingIcon.rotation)
    end)
    
    ScootsVendorForge.loadingText = ScootsVendorForge.frames.panel:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.loadingText:SetFontObject('GameFontHighlightSmall')
    ScootsVendorForge.loadingText:SetPoint('TOPLEFT', 20, -61)
    ScootsVendorForge.loadingText:SetJustifyH('LEFT')
    ScootsVendorForge.loadingText:SetText('Loading...')
    ScootsVendorForge.loadingText:Hide()
    
    -- Failed loading
    ScootsVendorForge.cacheFailText = ScootsVendorForge.frames.panel:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.cacheFailText:SetFontObject('GameFontRedSmall')
    ScootsVendorForge.cacheFailText:SetPoint('TOPLEFT', 4, -61)
    ScootsVendorForge.cacheFailText:SetJustifyH('LEFT')
    ScootsVendorForge.cacheFailText:SetText('Failed to cache merchant.' .. '\n' .. '/reload your UI and try again.')
    ScootsVendorForge.cacheFailText:Hide()
end

ScootsVendorForge.createOptions = function()
    -- Quantity header
    ScootsVendorForge.frames.panel.countLabel = ScootsVendorForge.frames.panel:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.frames.panel.countLabel:SetFontObject('GameFontHighlightSmall')
    ScootsVendorForge.frames.panel.countLabel:SetPoint('TOPLEFT', 4, -22)
    ScootsVendorForge.frames.panel.countLabel:SetJustifyH('LEFT')
    ScootsVendorForge.frames.panel.countLabel:SetText('Buy:')
    
    -- Quantity: Decrement
    ScootsVendorForge.frames.decrement = CreateFrame('Button', 'ScootsVendorForge-Quantity-DecrementButton', ScootsVendorForge.frames.panel)
    ScootsVendorForge.frames.decrement:SetSize(19, 19)
    ScootsVendorForge.frames.decrement:SetPoint('TOPLEFT', ScootsVendorForge.frames.panel, 'TOPLEFT', 4, -38)
    ScootsVendorForge.frames.decrement:SetFrameStrata(ScootsVendorForge.frames.master:GetFrameStrata())
    
    ScootsVendorForge.frames.decrement:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up')
    ScootsVendorForge.frames.decrement:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down')
    ScootsVendorForge.frames.decrement:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled')
    ScootsVendorForge.frames.decrement:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
    
    ScootsVendorForge.frames.decrement:SetScript('OnClick', function()
        local check = ScootsVendorForge.frames.quantity:GetNumber()
        if(check > 1) then
            ScootsVendorForge.frames.quantity:SetText(tostring(check - 1))
        end
        
        ScootsVendorForge.setOption('quantity', ScootsVendorForge.frames.quantity:GetNumber())
    end)
    
    -- Quantity
    ScootsVendorForge.frames.quantity = CreateFrame('EditBox', 'ScootsVendorForge-Quantity', ScootsVendorForge.frames.panel)
    ScootsVendorForge.frames.quantity:SetSize(30, 19)
    ScootsVendorForge.frames.quantity:SetPoint('TOPLEFT', ScootsVendorForge.frames.decrement, 'TOPRIGHT', 0, 0)
    ScootsVendorForge.frames.quantity:SetFrameStrata(ScootsVendorForge.frames.master:GetFrameStrata())
    ScootsVendorForge.frames.quantity:SetAutoFocus(false)
    ScootsVendorForge.frames.quantity:SetMaxLetters(3)
    ScootsVendorForge.frames.quantity:SetNumeric(true)
    ScootsVendorForge.frames.quantity:SetFontObject('GameFontHighlightSmall')
    ScootsVendorForge.frames.quantity:SetText(tostring(ScootsVendorForge.getOption('quantity')))
    ScootsVendorForge.frames.quantity:SetJustifyH('CENTER')
    
    ScootsVendorForge.frames.quantity:SetScript('OnEnterPressed', EditBox_ClearFocus)
    ScootsVendorForge.frames.quantity:SetScript('OnEscapePressed', EditBox_ClearFocus)
    ScootsVendorForge.frames.quantity:SetScript('OnEditFocusGained', EditBox_HighlightText)
    
    ScootsVendorForge.frames.quantity:SetScript('OnEditFocusLost', function()
        EditBox_ClearHighlight(ScootsVendorForge.frames.quantity)
        
        if(ScootsVendorForge.frames.quantity:GetNumber() < 1) then
            ScootsVendorForge.frames.quantity:SetText('1')
        end
        
        ScootsVendorForge.setOption('quantity', ScootsVendorForge.frames.quantity:GetNumber())
    end)
    
    ScootsVendorForge.frames.quantity:SetScript('OnTextChanged', ScootsVendorForge.quantityOnTextChanged)
    
    ScootsVendorForge.frames.quantity.bgLeft = ScootsVendorForge.frames.quantity:CreateTexture(nil, 'BACKGROUND')
    ScootsVendorForge.frames.quantity.bgLeft:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsVendorForge.frames.quantity.bgLeft:SetSize(8, 19)
    ScootsVendorForge.frames.quantity.bgLeft:SetPoint('LEFT', 0, 0)
    ScootsVendorForge.frames.quantity.bgLeft:SetTexCoord(0, 0.0625, 0, 0.625)
    
    ScootsVendorForge.frames.quantity.bgRight = ScootsVendorForge.frames.quantity:CreateTexture(nil, 'BACKGROUND')
    ScootsVendorForge.frames.quantity.bgRight:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsVendorForge.frames.quantity.bgRight:SetSize(8, 19)
    ScootsVendorForge.frames.quantity.bgRight:SetPoint('RIGHT', 0, 0)
    ScootsVendorForge.frames.quantity.bgRight:SetTexCoord(0.9375, 1.0, 0, 0.625)
    
    ScootsVendorForge.frames.quantity.bgMiddle = ScootsVendorForge.frames.quantity:CreateTexture(nil, 'BACKGROUND')
    ScootsVendorForge.frames.quantity.bgMiddle:SetTexture('Interface\\Common\\Common-Input-Border')
    ScootsVendorForge.frames.quantity.bgMiddle:SetSize(10, 19)
    ScootsVendorForge.frames.quantity.bgMiddle:SetPoint('LEFT', ScootsVendorForge.frames.quantity.bgLeft, 'RIGHT', 0, 0)
    ScootsVendorForge.frames.quantity.bgMiddle:SetPoint('RIGHT', ScootsVendorForge.frames.quantity.bgRight, 'LEFT', 0, 0)
    ScootsVendorForge.frames.quantity.bgMiddle:SetTexCoord(0.0625, 0.9375, 0, 0.625)
    
    -- Quantity: Increment
    ScootsVendorForge.frames.increment = CreateFrame('Button', 'ScootsVendorForge-Quantity-IncrementButton', ScootsVendorForge.frames.panel)
    ScootsVendorForge.frames.increment:SetSize(19, 19)
    ScootsVendorForge.frames.increment:SetPoint('TOPLEFT', ScootsVendorForge.frames.quantity, 'TOPRIGHT', 0, 0)
    ScootsVendorForge.frames.increment:SetFrameStrata(ScootsVendorForge.frames.master:GetFrameStrata())
    
    ScootsVendorForge.frames.increment:SetNormalTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up')
    ScootsVendorForge.frames.increment:SetPushedTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down')
    ScootsVendorForge.frames.increment:SetDisabledTexture('Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled')
    ScootsVendorForge.frames.increment:SetHighlightTexture('Interface\\Buttons\\UI-Common-MouseHilight', 'ADD')
    
    ScootsVendorForge.frames.increment:SetScript('OnClick', function()
        ScootsVendorForge.frames.quantity:SetText(tostring(ScootsVendorForge.frames.quantity:GetNumber() + 1))
        ScootsVendorForge.setOption('quantity', ScootsVendorForge.frames.quantity:GetNumber())
    end)
    
    -- Forge dropdown label
    ScootsVendorForge.frames.panel.forgeLabel = ScootsVendorForge.frames.panel:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.frames.panel.forgeLabel:SetFontObject('GameFontHighlightSmall')
    ScootsVendorForge.frames.panel.forgeLabel:SetPoint('TOPLEFT', 86, -22)
    ScootsVendorForge.frames.panel.forgeLabel:SetJustifyH('LEFT')
    ScootsVendorForge.frames.panel.forgeLabel:SetText('Until:')
    
    -- Forge dropdown
    ScootsVendorForge.frames.forgeLevel = CreateFrame('Frame', 'ScootsVendorForge-ForgeLevel', ScootsVendorForge.frames.panel, 'UIDropDownMenuTemplate')
    ScootsVendorForge.frames.forgeLevel:SetPoint('TOPRIGHT', ScootsVendorForge.frames.panel, 'TOPRIGHT', -111, -34)
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
    ScootsVendorForge.frames.panel.forgeLevelBackground:SetSize(ScootsVendorForge.panelWidth, 42)
    
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
			ScootsVendorForge.refreshPanel()
        end
        
        UIDropDownMenu_AddButton(info, level)
    end
end

ScootsVendorForge.hideAllItemFrames = function()
    for _, frame in pairs(ScootsVendorForge.frames.items) do
        frame:Hide()
		if frame.currency then
			for _, subframe in pairs(frame.currency) do
				subframe:Hide()
			end
		end
		if frame.expCurrency then
			for _, subframe in pairs(frame.expCurrency) do
				subframe:Hide()
			end
		end
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
		ScootsVendorForge.frames.items[index].text:SetWordWrap(false)
		ScootsVendorForge.frames.items[index].text:SetNonSpaceWrap(false)
		
		
		ScootsVendorForge.frames.items[index].expCostText = ScootsVendorForge.frames.items[index]:CreateFontString(nil, 'ARTWORK')
        ScootsVendorForge.frames.items[index].expCostText:SetWidth(ScootsVendorForge.frames.scrollChild:GetWidth() - (12 + ScootsVendorForge.frames.items[index].icon:GetWidth()))
        ScootsVendorForge.frames.items[index].expCostText:SetFontObject('GameFontNormal')
        ScootsVendorForge.frames.items[index].expCostText:SetPoint('BOTTOMLEFT', ScootsVendorForge.frames.items[index], 'BOTTOMLEFT', 30, ScootsVendorForge.borderThickness * 5)
        ScootsVendorForge.frames.items[index].expCostText:SetJustifyH('LEFT')
    end
    
    local colours = ScootsVendorForge.getAttunementColours(item.forge)
    
    ScootsVendorForge.frames.items[index].background:SetTexture(colours.back.r, colours.back.g, colours.back.b, colours.back.a)
    ScootsVendorForge.frames.items[index].borderTop:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a)
    ScootsVendorForge.frames.items[index].borderBottom:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a)
    
    ScootsVendorForge.frames.items[index].icon:SetTexture(select(10, GetItemInfo(item.link)))
    
    ScootsVendorForge.frames.items[index].text:SetTextColor(colours.front.r, colours.front.g, colours.front.b)
    ScootsVendorForge.frames.items[index].text:SetText(select(1, GetItemInfo(item.link)))
	
	ScootsVendorForge.frames.items[index].expCostText:SetText("Exp. Cost: ")
	ScootsVendorForge.frames.items[index].expCostText:Hide()
    
    ScootsVendorForge.frames.items[index]:SetHeight(math.max(ScootsVendorForge.frames.items[index].icon:GetHeight(), ScootsVendorForge.frames.items[index].text:GetHeight()) + 8)
    
	
	local currencies = ScootsVendorForge.buildCurrencyArray(item,false)
    ScootsVendorForge.frames.items[index].currency ={}
	ScootsVendorForge.currencyIndex = 0
    leftOffset = 30
    for currencyIndex, currency in ipairs(currencies) do
        ScootsVendorForge.currencyIndex = ScootsVendorForge.currencyIndex + 1
        local currencyFrame =  ScootsVendorForge.getCurrencyFrame(index,ScootsVendorForge.currencyIndex)
        
        currencyFrame:SetParent(ScootsVendorForge.frames.items[index])
        currencyFrame.currencyName = currency.name
		
        currencyFrame.text:SetText('|T' .. currency.icon .. ':' .. ScootsVendorForge.currencySize .. ':' ..  ScootsVendorForge.currencySize .. '|t' .. currency.amnt)
        currencyFrame:SetSize(currencyFrame.text:GetStringWidth(), ScootsVendorForge.currencySize)
        
        currencyFrame:SetPoint('BOTTOMLEFT', ScootsVendorForge.frames.items[index], 'BOTTOMLEFT', leftOffset, ScootsVendorForge.borderThickness * 5)
        leftOffset = leftOffset + currencyFrame:GetWidth() + 3
        
        if(CanAttuneItemHelper ~= nil and CanAttuneItemHelper(tonumber(item.id)) == 1) then
            if(ScootsVendorForge.totalAttuneCurrency[currency.name] == nil) then
                table.insert(ScootsVendorForge.allAttuneCurrencies, currency.name)
                
                ScootsVendorForge.totalAttuneCurrency[currency.name] = {
                    ['name'] = currency.name,
                    ['icon'] = currency.icon,
                    ['total'] = 0
                }
            end
            
            ScootsVendorForge.totalAttuneCurrency[currency.name].total = ScootsVendorForge.totalAttuneCurrency[currency.name].total + currency.amnt
        end
    end
	
	local expCurrencies = ScootsVendorForge.buildCurrencyArray(item,true)
    ScootsVendorForge.frames.items[index].expCurrency ={}
	ScootsVendorForge.currencyIndex = 0
    leftOffset = 92
    for currencyIndex, expCurrency in ipairs(expCurrencies) do
        ScootsVendorForge.currencyIndex = ScootsVendorForge.currencyIndex + 1
        local expCurrencyFrame =  ScootsVendorForge.getExpCurrencyFrame(index,ScootsVendorForge.currencyIndex)
        
        expCurrencyFrame:SetParent(ScootsVendorForge.frames.items[index])
        expCurrencyFrame.expCurrencyName = expCurrency.name
		
        expCurrencyFrame.text:SetText('|T' .. expCurrency.icon .. ':' .. ScootsVendorForge.currencySize .. ':' ..  ScootsVendorForge.currencySize .. '|t' .. expCurrency.amnt)
        expCurrencyFrame:SetSize(expCurrencyFrame.text:GetStringWidth(), ScootsVendorForge.currencySize)
        
        expCurrencyFrame:SetPoint('BOTTOMLEFT', ScootsVendorForge.frames.items[index], 'BOTTOMLEFT', leftOffset, ScootsVendorForge.borderThickness * 5)
        leftOffset = leftOffset + expCurrencyFrame:GetWidth() + 3
        
        if(CanAttuneItemHelper ~= nil and CanAttuneItemHelper(tonumber(item.id)) == 1) then
            if(ScootsVendorForge.totalAttuneCurrency[expCurrency.name] == nil) then
                table.insert(ScootsVendorForge.allAttuneCurrencies, expCurrency.name)
                
                ScootsVendorForge.totalAttuneCurrency[expCurrency.name] = {
                    ['name'] = expCurrency.name,
                    ['icon'] = expCurrency.icon,
                    ['total'] = 0
                }
            end
            
            ScootsVendorForge.totalAttuneCurrency[expCurrency.name].total = ScootsVendorForge.totalAttuneCurrency[expCurrency.name].total + expCurrency.amnt
        end
		expCurrencyFrame:Hide()
    end
	
    ScootsVendorForge.frames.items[index]:SetScript('OnEnter', function()
        ScootsVendorForge.frames.items[index].hover = true
        
        GameTooltip:SetOwner(ScootsVendorForge.frames.items[index], 'ANCHOR_RIGHT')
        GameTooltip:SetHyperlink(item.link)
    end)
	
    ScootsVendorForge.frames.items[index]:SetScript('OnLeave', function()
        ScootsVendorForge.frames.items[index].hover = false
       
        
        GameTooltip_Hide(ScootsVendorForge.frames.items[index])
        SetCursor(nil)
    end)
    
    ScootsVendorForge.frames.items[index]:SetScript('OnMouseDown', function(self, button)
        if(button == 'RightButton') then
            EditBox_ClearFocus(ScootsVendorForge.frames.quantity)
            
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
		if(ScootsVendorForge.frames.items[index]:IsMouseOver() and not ScootsVendorForge.frames.items[index].expCostText:IsVisible()) then
				
			ScootsVendorForge.frames.items[index].background:SetTexture(colours.back.r, colours.back.g, colours.back.b, colours.back.a + 0.1)
			ScootsVendorForge.frames.items[index].borderTop:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a + 0.1)
			ScootsVendorForge.frames.items[index].borderBottom:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a + 0.1)
			
            for _, frame in pairs(ScootsVendorForge.frames.items[index].currency) do
				frame:Hide()
			end
			
			ScootsVendorForge.frames.items[index].expCostText:Show()
			for _, frame in pairs(ScootsVendorForge.frames.items[index].expCurrency) do
				frame:Show()
			end
        end
           
        if(not ScootsVendorForge.frames.items[index]:IsMouseOver() and ScootsVendorForge.frames.items[index].expCostText:IsVisible()) then
		
			ScootsVendorForge.frames.items[index].background:SetTexture(colours.back.r, colours.back.g, colours.back.b, colours.back.a)
			ScootsVendorForge.frames.items[index].borderTop:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a)
			ScootsVendorForge.frames.items[index].borderBottom:SetTexture(colours.front.r, colours.front.g, colours.front.b, colours.front.a)
			
            ScootsVendorForge.frames.items[index].expCostText:Hide()
			for _, frame in pairs(ScootsVendorForge.frames.items[index].expCurrency) do
				frame:Hide()
			end
			
			for _, frame in pairs(ScootsVendorForge.frames.items[index].currency) do
				frame:Show()
			end
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
    STMasterFrame:SetPoint('TOPLEFT', ScootsVendorForge.frames.master, 'TOPRIGHT', 0, -12)
end