local TSMCT_AddonName, TSMCT = ...

-- create coreframe and register events
local frame = CreateFrame('Frame')
frame:RegisterEvent('AUCTION_ITEM_LIST_UPDATE')
frame:RegisterEvent('PLAYER_ENTERING_WORLD')
frame:RegisterEvent('ADDON_LOADED')
frame:SetScript(
    'OnEvent',
    function(self, event, ...)
        if event == 'ADDON_LOADED' then
            local name = ...

            if name == TSMCT_AddonName then
                TSMCT.core.Init()
            end
        elseif event == 'AUCTION_ITEM_LIST_UPDATE' then
            TSMCT.core.TryUpdateAtrTimestamp()
        end
    end
)

hooksecurefunc(
    GameTooltip,
    'SetMerchantItem',
    function(tip, index)
        local _, _, _, num = GetMerchantItemInfo(index)
        TSMCT.core.TryUpdateTooltip(tip, GetMerchantItemLink(index), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetBuybackItem',
    function(tip, index)
        local _, _, _, num = GetBuybackItemInfo(index)
        TSMCT.core.TryUpdateTooltip(tip, GetBuybackItemLink(index), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetBagItem',
    function(tip, bag, slot)
        local _, num = GetContainerItemInfo(bag, slot)
        TSMCT.core.TryUpdateTooltip(tip, GetContainerItemLink(bag, slot), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetAuctionItem',
    function(tip, type, index)
        local _, _, num = GetAuctionItemInfo(type, index)
        TSMCT.core.TryUpdateTooltip(tip, GetAuctionItemLink(type, index), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetAuctionSellItem',
    function(tip)
        local name, _, count = GetAuctionSellItemInfo()
        local __, link = GetItemInfo(name)
        TSMCT.core.TryUpdateTooltip(tip, link, num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetLootItem',
    function(tip, slot)
        if LootSlotHasItem(slot) then
            local link, _, num = GetLootSlotLink(slot)
            TSMCT.core.TryUpdateTooltip(tip, link, num)
        end
    end
)

hooksecurefunc(
    GameTooltip,
    'SetLootRollItem',
    function(tip, slot)
        local _, _, num = GetLootRollItemInfo(slot)
        TSMCT.core.TryUpdateTooltip(tip, GetLootRollItemLink(slot), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetInventoryItem',
    function(tip, unit, slot)
        TSMCT.core.TryUpdateTooltip(tip, GetInventoryItemLink(unit, slot), GetInventoryItemCount(unit, slot))
    end
)

hooksecurefunc(
    GameTooltip,
    'SetTradeSkillItem',
    function(tip, index)
        local _, _, num = GetTradeSkillInfo(index)
        TSMCT.core.TryUpdateTooltip(tip, GetTradeSkillItemLink(index), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetAction',
    function(tip, index)
        local _, link = tip:GetItem()

        if link then
            TSMCT.core.TryUpdateTooltip(tip, link, num)
        end
    end
)

hooksecurefunc(
    GameTooltip,
    'SetTradePlayerItem',
    function(tip, id)
        local _, _, num = GetTradePlayerItemInfo(id)
        TSMCT.core.TryUpdateTooltip(tip, GetTradePlayerItemLink(id), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetTradeTargetItem',
    function(tip, id)
        local _, _, num = GetTradeTargetItemInfo(id)
        TSMCT.core.TryUpdateTooltip(tip, GetTradeTargetItemLink(id), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetQuestItem',
    function(tip, type, index)
        local _, _, num = GetQuestItemInfo(type, index)
        TSMCT.core.TryUpdateTooltip(tip, GetQuestItemLink(type, index), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetQuestLogItem',
    function(tip, type, index)
        local num, _
        if type == 'choice' then
            _, _, num = GetQuestLogChoiceInfo(index)
        else
            _, _, num = GetQuestLogRewardInfo(index)
        end

        TSMCT.core.TryUpdateTooltip(tip, GetQuestLogItemLink(type, index), num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetInboxItem',
    function(tip, index, attachIndex)
        if AUCTIONATOR_SHOW_MAILBOX_TIPS == 1 then
            local attachmentIndex = attachIndex or 1
            local _, _, _, num = GetInboxItem(index, attachmentIndex)

            TSMCT.core.TryUpdateTooltip(tip, GetInboxItemLink(index, attachmentIndex), num)
        end
    end
)

hooksecurefunc(
    'InboxFrameItem_OnEnter',
    function(self)
        local itemCount = select(8, GetInboxHeaderInfo(self.index))
        local tooltipEnabled = AUCTIONATOR_SHOW_MAILBOX_TIPS == 1 and (AUCTIONATOR_V_TIPS == 1 or AUCTIONATOR_A_TIPS == 1 or AUCTIONATOR_D_TIPS == 1)

        if tooltipEnabled and itemCount and itemCount > 1 then
            for numIndex = 1, ATTACHMENTS_MAX_RECEIVE do
                local name, _, _, num = GetInboxItem(self.index, numIndex)

                if name then
                    local attachLink = GetInboxItemLink(self.index, numIndex) or name

                    GameTooltip:AddLine(attachLink)

                    if num > 1 then
                        TSMCT.core.TryUpdateTooltip(GameTooltip, attachLink, num)
                    else
                        TSMCT.core.TryUpdateTooltip(GameTooltip, attachLink)
                    end
                end
            end
        end
    end
)

hooksecurefunc(
    GameTooltip,
    'SetSendMailItem',
    function(tip, id)
        local name, _, _, num = GetSendMailItem(id)
        local name, link = GetItemInfo(name)
        TSMCT.core.TryUpdateTooltip(tip, link, num)
    end
)

hooksecurefunc(
    GameTooltip,
    'SetHyperlink',
    function(tip, itemstring, num)
        local name, link = GetItemInfo(itemstring)
        TSMCT.core.TryUpdateTooltip(tip, link, num)
    end
)

hooksecurefunc(
    ItemRefTooltip,
    'SetHyperlink',
    function(tip, itemstring)
        local name, link = GetItemInfo(itemstring)
        TSMCT.core.TryUpdateTooltip(tip, link)
    end
)

--[[
    GameTooltip:HookScript(
    'OnTooltipSetItem',
    function(self)
        TSMCT.core.TryUpdateTooltip(self, 'Tooltip Custom Itemprice')
    end
)
]]

--[[
hooksecurefunc (GameTooltip, "SetGuildBankItem",
  function (tip, tab, slot)
    local _, num = GetGuildBankItemInfo(tab, slot);
    TSMCT.core.TryUpdateTooltip (tip, GetGuildBankItemLink(tab, slot), num);
  end
)

hooksecurefunc( GameTooltip, 'SetRecipeResultItem',
  function( tip, itemId )
    local link = C_TradeSkillUI.GetRecipeItemLink( itemId )
    local count  = C_TradeSkillUI.GetRecipeNumItemsProduced( itemId )

    TSMCT.core.TryUpdateTooltip( tip, link, count )
  end
)

hooksecurefunc( GameTooltip, 'SetRecipeReagentItem',
  function( tip, itemId, index )
    local link = C_TradeSkillUI.GetRecipeReagentItemLink( itemId, index )
    local count = select( 3, C_TradeSkillUI.GetRecipeReagentInfo( itemId, index ) )

    TSMCT.core.TryUpdateTooltip( tip, link, count )
  end
)
]]
