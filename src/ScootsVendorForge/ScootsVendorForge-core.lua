ScootsVendorForge = ScootsVendorForge or {}
ScootsVendorForge.title = 'ScootsVendorForge'
ScootsVendorForge.frames = {
    ['events'] = CreateFrame('Frame', 'ScootsVendorForge-EventsFrame', UIParent)
}
ScootsVendorForge.vendorOpen = false
ScootsVendorForge.panelOpen = false
ScootsVendorForge.showEvent = false
ScootsVendorForge.merchantCached = false
ScootsVendorForge.merchantCacheFail = false
ScootsVendorForge.waitingForSoldItem = false
ScootsVendorForge.waitingForPurchasedItem = false

ScootsVendorForge.onLogout = function()
    if(ScootsVendorForge.optionsLoaded) then
        _G['SCOOTSVENDORFORGE_OPTIONS'] = ScootsVendorForge.options
    end
end

ScootsVendorForge.watchForVendor = function()
    if(ScootsVendorForge.vendorOpen == false) then
        if(MerchantFrame and MerchantFrame:IsVisible()) then
            ScootsVendorForge.vendorOpen = true
        end
    else
        if(not MerchantFrame or not MerchantFrame:IsVisible()) then
            ScootsVendorForge.vendorOpen = false
        end
    end
end

ScootsVendorForge.openPanel = function()
    ScootsVendorForge.showEvent = false
    
    if(ScootsVendorForge.frames.master:IsVisible() ~= 1) then
        ShowUIPanel(ScootsVendorForge.frames.master)
        MerchantFrame:Show()
        ScootsVendorForge.setLevels()
        ScootsVendorForge.panelOpen = true
    end
    
    ScootsVendorForge.quantityToPurchase = nil
    ScootsVendorForge.startedAutoPurchase = false
    ScootsVendorForge.cacheFailText:Hide()
    ScootsVendorForge.loadingIcon:Hide()
    ScootsVendorForge.loadingText:Hide()
end

ScootsVendorForge.quantityOnTextChanged = function()
    local check = ScootsVendorForge.frames.quantity:GetNumber()
    
    if(check ~= nil) then
        if(check <= 1) then
            ScootsVendorForge.frames.decrement:Disable()
        else
            ScootsVendorForge.frames.decrement:Enable()
        end
    else
        ScootsVendorForge.frames.quantity:SetText('1')
        ScootsVendorForge.frames.decrement:Disable()
    end
end

ScootsVendorForge.cacheMerchant = function(elapsed)
    if(ScootsVendorForge.merchantCacheFail) then
        ScootsVendorForge.cacheFailText:Hide()
        ScootsVendorForge.loadingIcon:Show()
        ScootsVendorForge.loadingText:Show()
        
        ScootsVendorForge.merchantCacheWait = ScootsVendorForge.merchantCacheWait + elapsed
        ScootsVendorForge.merchantCacheTotalWait = ScootsVendorForge.merchantCacheTotalWait + elapsed
        
        if(ScootsVendorForge.merchantCacheWait < 1) then
            return nil
        end
        
        ScootsVendorForge.merchantCacheWait = 0
        
        if(ScootsVendorForge.merchantCacheTotalWait > 10) then
            ScootsVendorForge.refreshPanelEvent = false
            ScootsVendorForge.cacheFailText:Show()
            ScootsVendorForge.loadingIcon:Hide()
            ScootsVendorForge.loadingText:Hide()
            ScootsVendorForge.merchantCacheWait = 0
            ScootsVendorForge.merchantCacheTotalWait = 0
            return nil
        end
    end
    
    if(not Custom_GetMerchantItem or not CanAttuneItemHelper or not GetItemAttuneForge or not GetItemTagsCustom or not GetItemLinkTitanforge) then
        ScootsVendorForge.merchantCacheFail = true
        ScootsVendorForge.merchantCacheWait = ScootsVendorForge.merchantCacheWait or 0
        ScootsVendorForge.merchantCacheTotalWait = ScootsVendorForge.merchantCacheTotalWait or 0
        return nil
    end
    
    for itemIndex = 1, GetMerchantNumItems() do
        local itemId, itemLink = Custom_GetMerchantItem(itemIndex)
        
        if(itemId == nil or itemLink == nil) then
            ScootsVendorForge.merchantCacheFail = true
            ScootsVendorForge.merchantCacheWait = ScootsVendorForge.merchantCacheWait or 0
            ScootsVendorForge.merchantCacheTotalWait = ScootsVendorForge.merchantCacheTotalWait or 0
            return nil
        end
    end
    
    ScootsVendorForge.merchantCached = true
    ScootsVendorForge.merchantCacheWait = 0
    ScootsVendorForge.merchantCacheTotalWait = 0
end

ScootsVendorForge.refreshPanel = function()
    ScootsVendorForge.refreshPanelEvent = false
    ScootsVendorForge.hideAllItemFrames()
    ScootsVendorForge.loadingIcon:Hide()
    ScootsVendorForge.loadingText:Hide()
    
    -- Get inventory
    ScootsVendorForge.inventory = {}
    local inventoryEquipment = {}
    for bagIndex = 0, 4 do
        local bagSlots = GetContainerNumSlots(bagIndex)
        for slotIndex = 1, bagSlots do
            local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(bagIndex, slotIndex)
            local itemId = ScootsVendorForge.extractId(itemLink)
            
            if(itemLink ~= nil) then
                if(ScootsVendorForge.inventory[itemLink] == nil) then
                    ScootsVendorForge.inventory[itemLink] = 0
                end
                
                ScootsVendorForge.inventory[itemLink] = ScootsVendorForge.inventory[itemLink] + itemCount
                
                if(IsEquippableItem(itemId)) then
                    local forgeLevel = GetItemLinkTitanforge(itemLink)
                    
                    if(ScootsVendorForge.purchaseItemId and ScootsVendorForge.purchaseItemId == itemId and forgeLevel >= ScootsVendorForge.getOption('forgelevel')) then
                        ScootsVendorForge.purchaseItemId = nil
                        ScootsVendorForge.waitingForSoldItem = false
                        ScootsVendorForge.waitingForPurchasedItem = false
                        ScootsVendorForge.startedAutoPurchase = false
                    end
                
                    table.insert(inventoryEquipment, {
                        ['id'] = itemId, 
                        ['link'] = itemLink,
                        ['bag'] = bagIndex,
                        ['slot'] = slotIndex,
                        ['forge'] = forgeLevel
                    })
                end
            end
        end
    end
    
    -- Get currencies
    ScootsVendorForge.currencies = {}
    local numCurrencies = GetCurrencyListSize()
    for currencyIndex = 1, numCurrencies do
        local name, isHeader, _, _, _, count = GetCurrencyListInfo(currencyIndex)
        
        if(not isHeader) then
            ScootsVendorForge.currencies[name] = count
        end
    end
    
    -- Get applicable vendor items
    local purchasableItems = {}
    local frameIndex = 0
    local offset = 0
    for itemIndex = 1, GetMerchantNumItems() do
        local itemId, itemLink = Custom_GetMerchantItem(itemIndex)
        local tags = GetItemTagsCustom(itemId)
        local rarity = select(3, GetItemInfo(itemLink))
        
        if( rarity
        and rarity >= 2
        and rarity <= 4
        and tags
        and bit.band(tags, 96) == 64
        and CanAttuneItemHelper(itemId) > 0
        and GetItemAttuneForge(itemId) < 3
        and ScootsVendorForge.getInventoryAttuneLevel(itemId, inventoryEquipment) < 3
        and ScootsVendorForge.canAfford(itemIndex, 1)) then
            local item = {
                ['index'] = itemIndex,
                ['id'] = itemId,
                ['link'] = itemLink,
                ['forge'] = GetItemAttuneForge(itemId)
            }
            
            frameIndex = frameIndex + 1
            offset = ScootsVendorForge.setItemFrame(frameIndex, item, offset)
            table.insert(purchasableItems, item)
        end
    end
    
    ScootsVendorForge.frames.scrollChild:SetHeight(offset)
    
    if(ScootsVendorForge.purchaseItemId) then
        if(ScootsVendorForge.waitingForPurchasedItem ~= true) then
            local purchaseItemIndex = nil
            for _, item in pairs(purchasableItems) do
                if(item.id == ScootsVendorForge.purchaseItemId) then
                    purchaseItemIndex = item.index
                    break
                end
            end
        
            if(purchaseItemIndex == nil) then
                ScootsVendorForge.purchaseItemId = nil
                ScootsVendorForge.waitingForSoldItem = false
                ScootsVendorForge.waitingForPurchasedItem = false
                ScootsVendorForge.startedAutoPurchase = false
                return nil
            end
            
            for _, item in pairs(inventoryEquipment) do
                if(item.id == ScootsVendorForge.purchaseItemId) then
                    if(ScootsVendorForge.soldQuantity == nil) then
                        ScootsVendorForge.soldQuantity = 0
                    end
                
                    UseContainerItem(item.bag, item.slot)
                    ScootsVendorForge.soldQuantity = ScootsVendorForge.soldQuantity + 1
                    ScootsVendorForge.waitingForSoldItem = true
                end
            end
            
            if(not ScootsVendorForge.waitingForSoldItem) then
                if(ScootsVendorForge.startedAutoPurchase and ScootsVendorForge.soldQuantity < ScootsVendorForge.quantityToPurchase) then
                    ScootsVendorForge.waitingForSoldItem = true
                else
                    repeat
                        if(not ScootsVendorForge.startedAutoPurchase) then
                            if(not ScootsVendorForge.noRefundPerkEnabled()) then
                                print('\124cff' .. '98fb98' .. ScootsVendorForge.title .. '\124r' .. ' - ' .. '\124cff' .. 'ff3333' .. 'Perk "Disable Item Refund" not enabled.' .. '\124r')
                                break
                            elseif(ScootsVendorForge.frames.quantity:GetNumber() > ScootsVendorForge.getFreeBagSlots()) then
                                print('\124cff' .. '98fb98' .. ScootsVendorForge.title .. '\124r' .. ' - ' .. '\124cff' .. 'ff3333' .. 'Not enough free bag slots.' .. '\124r')
                                break
                            end
                        end
                        
                        if(not ScootsVendorForge.canAfford(purchaseItemIndex, ScootsVendorForge.frames.quantity:GetNumber())) then
                            print('\124cff' .. '98fb98' .. ScootsVendorForge.title .. '\124r' .. ' - ' .. '\124cff' .. 'ff3333' .. 'Unable to afford that quantity.' .. '\124r')
                            break
                        end
                        
                        ScootsVendorForge.soldQuantity = 0
                        ScootsVendorForge.purchasedQuantity = 0
                        ScootsVendorForge.quantityToPurchase = ScootsVendorForge.frames.quantity:GetNumber()
                        BuyMerchantItem(purchaseItemIndex, ScootsVendorForge.quantityToPurchase)
                        ScootsVendorForge.waitingForPurchasedItem = true
                        ScootsVendorForge.startedAutoPurchase = true
                    until true
                end
            end
        end
    end
end

ScootsVendorForge.watchForSoldItem = function()
    for bagIndex = 0, 4 do
        local bagSlots = GetContainerNumSlots(bagIndex)
        for slotIndex = 1, bagSlots do
            local itemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
            local itemId = ScootsVendorForge.extractId(itemLink)
            
            if(itemId == ScootsVendorForge.purchaseItemId) then
                return nil
            end
        end
    end
    
    ScootsVendorForge.waitingForSoldItem = false
    ScootsVendorForge.refreshPanelEvent = true
end

ScootsVendorForge.watchForPurchasedItem = function()
    for bagIndex = 0, 4 do
        local bagSlots = GetContainerNumSlots(bagIndex)
        for slotIndex = 1, bagSlots do
            local itemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
            local itemId = ScootsVendorForge.extractId(itemLink)
            
            if(itemId == ScootsVendorForge.purchaseItemId) then
                ScootsVendorForge.purchasedQuantity = ScootsVendorForge.purchasedQuantity + 1
            end
        end
    end
    
    if(ScootsVendorForge.purchasedQuantity >= ScootsVendorForge.quantityToPurchase) then
        ScootsVendorForge.waitingForPurchasedItem = false
        ScootsVendorForge.refreshPanelEvent = true
    end
end

ScootsVendorForge.updateLoop = function(self, elapsed)
    ScootsVendorForge.watchForVendor()
    
    if(ScootsVendorForge.vendorOpen and not ScootsVendorForge.panelOpen and not ScootsVendorForge.uiBuilt) then
        ScootsVendorForge.buildUi()
        ScootsVendorForge.quantityOnTextChanged(ScootsVendorForge.frames.quantity)
        ScootsVendorForge.showEvent = true
        ScootsVendorForge.refreshPanelEvent = true
    end
    
    if(ScootsVendorForge.uiBuilt) then
        if(ScootsVendorForge.showEvent) then
            ScootsVendorForge.openPanel()
        end
        
        if(ScootsVendorForge.waitingForSoldItem) then
            ScootsVendorForge.watchForSoldItem()
        elseif(ScootsVendorForge.waitingForPurchasedItem) then
            ScootsVendorForge.watchForPurchasedItem()
        end
        
        if(ScootsVendorForge.refreshPanelEvent) then
            if(ScootsVendorForge.merchantCached == false) then
                ScootsVendorForge.cacheMerchant(elapsed)
            else
                ScootsVendorForge.refreshPanel()
            end
        end
        
        if(IsAddOnLoaded('ScootsTokens')) then
            ScootsVendorForge.moveScootsTokens()
        end
    end
end

ScootsVendorForge.eventHandler = function(self, event)
    if(event == 'ADDON_LOADED') then
        ScootsVendorForge.addonLoaded = true
    elseif(event == 'MERCHANT_SHOW') then
        ScootsVendorForge.showEvent = true
        ScootsVendorForge.refreshPanelEvent = true
        ScootsVendorForge.purchaseItemId = nil
    elseif(event == 'MERCHANT_UPDATE') then
        ScootsVendorForge.refreshPanelEvent = true
    elseif(event == 'MERCHANT_CLOSED') then
        ScootsVendorForge.merchantCached = false
        ScootsVendorForge.merchantCacheFail = false
        ScootsVendorForge.purchaseItemId = nil
    elseif(event == 'PLAYER_LOGOUT') then
        ScootsVendorForge.onLogout()
    end
end

ScootsVendorForge.frames.events:SetScript('OnUpdate', ScootsVendorForge.updateLoop)
ScootsVendorForge.frames.events:SetScript('OnEvent', ScootsVendorForge.eventHandler)

ScootsVendorForge.frames.events:RegisterEvent('ADDON_LOADED')
ScootsVendorForge.frames.events:RegisterEvent('MERCHANT_SHOW')
ScootsVendorForge.frames.events:RegisterEvent('MERCHANT_UPDATE')
ScootsVendorForge.frames.events:RegisterEvent('MERCHANT_CLOSED')
ScootsVendorForge.frames.events:RegisterEvent('PLAYER_LOGOUT')