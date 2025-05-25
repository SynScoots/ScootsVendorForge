ScootsVendorForge = ScootsVendorForge or {}

ScootsVendorForge.loadOptions = function()
    if(ScootsVendorForge.optionsLoaded) then
        return nil
    end
    
    ScootsVendorForge.options = {
        ['quantity'] = 1,
        ['forgelevel'] = 1
    }
    
    if(ScootsVendorForge.addonLoaded and _G['SCOOTSVENDORFORGE_OPTIONS'] ~= nil) then
        for key, value in pairs(_G['SCOOTSVENDORFORGE_OPTIONS']) do
            ScootsVendorForge.options[key] = value
        end
        
        ScootsVendorForge.optionsLoaded = true
    end
end

ScootsVendorForge.setOption = function(key, value)
    if(not ScootsVendorForge.optionsLoaded) then
        ScootsVendorForge.loadOptions()
    end
    
    ScootsVendorForge.options[key] = value
    
    if(ScootsVendorForge.addonLoaded) then
        _G['SCOOTSVENDORFORGE_OPTIONS'] = ScootsVendorForge.options
    end
end

ScootsVendorForge.getOption = function(key)
    if(not ScootsVendorForge.optionsLoaded) then
        ScootsVendorForge.loadOptions()
    end
    
    return ScootsVendorForge.options[key]
end

ScootsVendorForge.extractId = function(link)
    if(link) then
        local subString = string.match(link, 'item:%d+')
        if(subString) then
            return tonumber(string.match(subString, '%d+'))
        end
    end
    
    return nil
end

ScootsVendorForge.getInventoryAttuneLevel = function(itemId, inventoryEquipment)
    local output = -1
    
    for _, item in pairs(inventoryEquipment) do
        if(item.id == itemId) then
            if(item.forge == 3) then
                return 3
            end
            
            output = math.max(output, item.forge)
        end
    end
    
    return output
end

function ScootsVendorForge.getAttunementColours(forgeLevel)
    local colours = {
        ['front'] = {
            ['r'] = 1,
            ['g'] = 1,
            ['b'] = 1,
            ['a'] = 0.4
        },
        ['back'] = {
            ['r'] = 0,
            ['g'] = 0,
            ['b'] = 0,
            ['a'] = 0.1
        }
    }
    
    if(forgeLevel == -1) then
        colours.back.r = 1
        colours.back.g = 1
        colours.back.b = 1
        colours.back.a = 0
    elseif(forgeLevel == 0) then
        colours.front.r = 0.65
        colours.front.g = 1
        colours.front.b = 0.5
        colours.back.r = 0.5
        colours.back.g = 1
        colours.back.b = 0.5
    elseif(forgeLevel == 1) then
        colours.front.r = 0.5
        colours.front.g = 0.5
        colours.front.b = 1
        colours.back.r = 0.5
        colours.back.g = 0.5
        colours.back.b = 1
    elseif(forgeLevel == 2) then
        colours.front.r = 1
        colours.front.g = 0.65
        colours.front.b = 0.5
        colours.back.r = 1
        colours.back.g = 0.5
        colours.back.b = 0.5
    elseif(forgeLevel == 3) then
        colours.front.r = 1
        colours.front.g = 1
        colours.front.b = 0.65
        colours.back.r = 1
        colours.back.g = 1
        colours.back.b = 0.5
    end
    
    return colours
end

ScootsVendorForge.noRefundPerkEnabled = function()
    if(PerkMgrPerks) then
        for perkId, perkData in pairs(PerkMgrPerks) do
            if(perkData.name == 'Disable Item Refund') then
                return GetPerkActive(perkId) == true
            end
        end
    end

    return false
end

ScootsVendorForge.getFreeBagSlots = function()
    local freeSlots = 0

    for bagIndex = 0, 4 do
        local bagSlots = GetContainerNumSlots(bagIndex)
        for slotIndex = 1, bagSlots do
            local itemLink = select(7, GetContainerItemInfo(bagIndex, slotIndex))
            
            if(itemLink == nil) then
                freeSlots = freeSlots + 1
            end
        end
    end
    
    return freeSlots
end

ScootsVendorForge.canAfford = function(itemIndex, quantity)
    local _, _, copperPrice, _, _, _, extendedCost = GetMerchantItemInfo(itemIndex)
    
    if(GetMoney() < (copperPrice * quantity)) then
        return false
    end
    
    if(extendedCost == 1) then
        local _, _, itemCount = GetMerchantItemCostInfo(itemIndex)
        
        if(itemCount > 0) then
            for currencyIndex = 1, 3 do
                local _, currencyCount, currencyItemLink = GetMerchantItemCostItem(itemIndex, currencyIndex)
                
                if(currencyItemLink) then
                    local currencyItemName = GetItemInfo(currencyItemLink)
                    
                    if(inventory[currencyItemLink] ~= nil) then
                        if(inventory[currencyItemLink] < (currencyCount * quantity)) then
                            return false
                        end
                    elseif(currencies[currencyItemName] ~= nil) then
                        if(currencies[currencyItemName] < currencyCount) then
                            return false
                        end
                    else
                        return false
                    end
                end
            end
        end
    end
    
    return true
end