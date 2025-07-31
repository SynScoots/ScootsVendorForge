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
                    
                    if(ScootsVendorForge.inventory[currencyItemLink] ~= nil) then
                        if(ScootsVendorForge.inventory[currencyItemLink] < (currencyCount * quantity)) then
                            return false
                        end
                    elseif(ScootsVendorForge.currencies[currencyItemName] ~= nil) then
                        if(ScootsVendorForge.currencies[currencyItemName] < (currencyCount * quantity)) then
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


function ScootsVendorForge.buildCurrencyArray(item,computeExpected)
    local currencies = {}
    local forgeMult = {
        (1/((1+(GetCustomGameData(29, 1494)/100))*0.05)),
        (1/((1+(GetCustomGameData(29, 1494)/100))*0.007)),
        (1/((1+(GetCustomGameData(29, 1494)/100))*0.001))
    }
    local mult = 1
    if computeExpected then mult = forgeMult[ScootsVendorForge.getOption('forgelevel')] end
    if(item.cost ~= nil and item.cost > 0) then
        local cost = item.cost * mult
        local gold = math.floor(cost / 10000)
        if(gold > 0) then
            table.insert(currencies, {
                ['name'] = 'Gold',
                ['icon'] = 'Interface/MoneyFrame/UI-GoldIcon',
                ['amnt'] = gold
            })
        end
        
        local silver = math.floor(cost / 100) % 100
        if(silver > 0) then
            table.insert(currencies, {
                ['name'] = 'Silver',
                ['icon'] = 'Interface/MoneyFrame/UI-SilverIcon',
                ['amnt'] = silver
            })
        end
        
        local copper = cost % 100
        copper = math.floor(copper + 0.5)
        if(copper > 0) then
            table.insert(currencies, {
                ['name'] = 'Copper',
                ['icon'] = 'Interface/MoneyFrame/UI-CopperIcon',
                ['amnt'] = copper
            })
        end
    end
    
    if(item.extCost == 1) then
        local honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(item.index) 
        
        if(honorPoints > 0) then
            table.insert(currencies, {
                ['name'] = 'Honor Points',
                ['icon'] = ScootsVendorForge.honorIcon,
                ['amnt'] = math.floor((honorPoints * mult) + 0.5)
            })
        end
        
        if(arenaPoints > 0) then
            table.insert(currencies, {
                ['name'] = 'Arena Points',
                ['icon'] = 'Interface/PVPFrame/PVP-ArenaPoints-Icon',
                ['amnt'] =  math.floor((arenaPoints * mult) + 0.5)
            })
        end
        
        if(itemCount > 0) then
            for currencyIndex = 1, 3 do
                local currencyTexture, currencyCount, currencyItemLink = GetMerchantItemCostItem(item.index, currencyIndex)
                
                if(currencyItemLink ~= nil) then
                    local itemName = GetItemInfo(currencyItemLink)
                    
                    table.insert(currencies, {
                        ['name'] = itemName,
                        ['icon'] = currencyTexture,
                        ['amnt'] =  math.floor((currencyCount * mult) +0.5)
                    })
                end
            end
        end
    end
    
    return currencies
end



function ScootsVendorForge.getCurrencyFrame(itemIndex,index)
    if(ScootsVendorForge.frames.items[itemIndex].currency[index] ~= nil) then
        ScootsVendorForge.frames.items[itemIndex].currency[index]:Show()
        return ScootsVendorForge.frames.items[itemIndex].currency[index]
    end
    
    ScootsVendorForge.frames.items[itemIndex].currency[index] = CreateFrame('Frame', 'ScootsVendorForgeCurrencyFrame' .. index)
    ScootsVendorForge.frames.items[itemIndex].currency[index]:SetFrameStrata(ScootsVendorForge.frameStrata)
    ScootsVendorForge.frames.items[itemIndex].currency[index]:EnableMouse(true)
    
    ScootsVendorForge.frames.items[itemIndex].currency[index].text = ScootsVendorForge.frames.items[itemIndex].currency[index]:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.frames.items[itemIndex].currency[index].text:SetFont('Fonts\\FRIZQT__.TTF', ScootsVendorForge.textSize)
    ScootsVendorForge.frames.items[itemIndex].currency[index].text:SetJustifyH('LEFT')
    ScootsVendorForge.frames.items[itemIndex].currency[index].text:SetPoint('BOTTOMLEFT', 0, 0)
    ScootsVendorForge.frames.items[itemIndex].currency[index].text:SetTextColor(1, 1, 1)
                
    ScootsVendorForge.frames.items[itemIndex].currency[index]:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:SetText(self.currencyName)
        GameTooltip:Show()
    end)
    
    ScootsVendorForge.frames.items[itemIndex].currency[index]:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    return ScootsVendorForge.frames.items[itemIndex].currency[index]
end

function ScootsVendorForge.getExpCurrencyFrame(itemIndex,index)
    if(ScootsVendorForge.frames.items[itemIndex].expCurrency[index] ~= nil) then
        ScootsVendorForge.frames.items[itemIndex].expCurrency[index]:Show()
        return ScootsVendorForge.frames.items[itemIndex].expCurrency[index]
    end
    
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index] = CreateFrame('Frame', 'ScootsVendorForgeCurrencyFrame' .. index)
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index]:SetFrameStrata(ScootsVendorForge.frameStrata)
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index]:EnableMouse(true)
    
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index].text = ScootsVendorForge.frames.items[itemIndex].expCurrency[index]:CreateFontString(nil, 'ARTWORK')
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index].text:SetFont('Fonts\\FRIZQT__.TTF', ScootsVendorForge.textSize)
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index].text:SetJustifyH('LEFT')
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index].text:SetPoint('BOTTOMLEFT', 0, 0)
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index].text:SetTextColor(1, 1, 1)
                
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index]:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
       GameTooltip:SetText(self.expCurrencyName)
        GameTooltip:Show()
    end)
    
    ScootsVendorForge.frames.items[itemIndex].expCurrency[index]:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    return ScootsVendorForge.frames.items[itemIndex].expCurrency[index]
end