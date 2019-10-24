local TSMCT_AddonName, TSMCT = ...

TSMCT.core = {}
TSMCT.state = {}

function TSMCT.core.TryUpdateTsmTimestamp(tip)
    for i = 1, tip:NumLines() do
        local tipLeft = _G[tip:GetName() .. 'TextLeft' .. i]
        local tipTextLeft = TSMCT.util.unescape_link(tipLeft:GetText())

        if tipTextLeft and tipTextLeft == 'TSM AuctionDB' then
            local tipRight = _G[tip:GetName() .. 'TextRight' .. i]
            local tipTextRight = TSMCT.util.unescape_link(tipRight:GetText())

            local _, hrs, mins, secs

            -- parse line data
            for d in tipTextRight:gmatch('%d+') do
                if _ == nil then
                    _ = tonumber(d)
                elseif hrs == nil and tipTextRight:match('Std.') then
                    hrs = tonumber(d)
                elseif mins == nil and tipTextRight:match('Min.') then
                    mins = tonumber(d)
                elseif secs == nil and tipTextRight:match('Sek.') then
                    secs = tonumber(d)
                end
            end

            -- fix nils
            if hrs == nil then
                hrs = 0
            end

            if mins == nil then
                mins = 0
            end

            if secs == nil then
                secs = 0
            end

            -- update timestamp if data extracted successful
            if hrs or mins or secs then
                local timeDiff = (hrs * 3600) + (mins * 60) + secs
                local ts = time() - timeDiff

                TSMCT_TIMESTAMPS.tsm = ts
            end
        end
    end
end

function TSMCT.core.TryUpdateAtrTimestamp()
    if gAtr_FullScanState == 6 then -- scan is done
        if TSMCT.state.atrIsScanning then -- was scanning before
            TSMCT.state.atrIsScanning = false -- scan is done

            TSMCT_TIMESTAMPS.atr = time()
        end
    else
        TSMCT.state.atrIsScanning = true
    end
end

function TSMCT.core.TryUpdateTooltip(tip, itemLink, num)
    if type(itemLink) == 'string' then
        local itemStr = TSM_API.ToItemString(itemLink)
        local venBuy, venSell = TSM_API.GetCustomPriceValue('vendorbuy', itemStr), TSM_API.GetCustomPriceValue('vendorsell', itemStr)
        local tsmMin, tsmMar, tsmHis = TSM_API.GetCustomPriceValue('dbminbuyout', itemStr), TSM_API.GetCustomPriceValue('dbmarket', itemStr), TSM_API.GetCustomPriceValue('dbhistorical', itemStr)
        local atrMin, aucMin, priceSrcTsm = TSM_API.GetCustomPriceValue('atrvalue', itemStr), nil, false

        if (tsmMin or tsmMar or tsmHis) and IsAltKeyDown() then
            TSMCT.core.TryUpdateTsmTimestamp(tip)
        end

        if venBuy or venSell or tsmMar or aucMin then
            -- show stack price on shift down
            local stackSize = IsShiftKeyDown() and (num or 1) or 1
            local stackStr = stackSize > 1 and ' x' .. stackSize or ''

            if venBuy or venSell then
                tip:AddLine('\nHändler', nil, nil, nil, 1)

                if venBuy then
                    tip:AddDoubleLine(string.format('Kaufpreis%s', stackStr), TSM_API.FormatMoneyString(venBuy * stackSize), 1, 1, 1, 1, 1, 1)
                end

                if venSell then
                    tip:AddDoubleLine(string.format('Verkaufspreis%s', stackStr), TSM_API.FormatMoneyString(venSell * stackSize), 1, 1, 1, 1, 1, 1)
                end
            end

            -- get most up to date min buyout price
            if tsmMin and atrMin then
                priceSrcTsm = TSMCT_TIMESTAMPS.tsm > TSMCT_TIMESTAMPS.atr
                aucMin = priceSrcTsm and tsmMin or atrMin
            elseif tsmMin and not atrMin then
                aucMin = tsmMin
                priceSrcTsm = true
            elseif not tsmMin and atrMin then
                aucMin = atrMin
                priceSrcTsm = false
            end

            if aucMin or tsmMar or tsmHis then
                local timeDiff = time() - (priceSrcTsm and TSMCT_TIMESTAMPS.tsm or TSMCT_TIMESTAMPS.atr)
                local hrs = math.floor(timeDiff / 3600)
                local mins = math.floor((timeDiff / 60) - (hrs * 60))
                local secs = math.floor(timeDiff - (hrs * 3600) - (mins * 60))
                local hrsStr = hrs > 0 and string.format(' %d Std.', hrs) or ''
                local minsStr = mins > 0 and string.format(' %d Min.', mins) or ''
                local secsStr = secs > 0 and (hrs < 1 and mins < 1) and string.format(' %d Sek.', secs) or ''

                tip:AddLine(' ') -- spacer line

                tip:AddDoubleLine('Auktionshaus', string.format('(%s vor%s%s%s)', (priceSrcTsm and 'TSM' or 'ATR'), hrsStr, minsStr, secsStr), nil, nil, nil, 0.5, 0.5, 0.5)

                if aucMin then
                    tip:AddDoubleLine(string.format('Sofortkaufpreis%s', stackStr), TSM_API.FormatMoneyString(aucMin * stackSize), 1, 1, 1, 1, 1, 1)
                end

                if tsmMar then
                    tip:AddDoubleLine(string.format('Marktwert%s', stackStr), TSM_API.FormatMoneyString(tsmMar * stackSize), 1, 1, 1, 1, 1, 1)
                end

                if tsmHis then
                    tip:AddDoubleLine(string.format('Historischer Preis%s', stackStr), TSM_API.FormatMoneyString(tsmHis * stackSize), 1, 1, 1, 1, 1, 1)
                end
            end

            tip:Show()
        end
    end
end

function TSMCT.core.Init()
    TSMCT_TIMESTAMPS = TSMCT_TIMESTAMPS or {}
    TSMCT_TIMESTAMPS.tsm = TSMCT_TIMESTAMPS.tsm or 0
    TSMCT_TIMESTAMPS.atr = TSMCT_TIMESTAMPS.atr or 0

    TSMCT.state.atrIsScanning = false
end

--[[function TSMCT.TSM_UpdateTimestamp_OLD() -- descreparted
    local tsmChecksumItems = {13466, 13463, 12363, 12360, 14256, 14047, 4338, 3860, 12359, 8170, 4304} -- items with high price change rate

    -- create checksum from common items with heavy price shifting to detect data changes
    local sum = 0

    for i, id in ipairs(tsmChecksumItems) do
        local val = TSM_API.GetCustomPriceValue('dbminbuyout', string.format('i:%i', id))

        if val then
            sum = sum + val
        end
    end

    sum = tostring(sum)

    local checksum = 0

    for n in sum:gmatch('.') do
        checksum = checksum + n
    end

    -- price data from checksum items is different
    if checksum ~= TSMCT_TIMESTAMPS['tsm_checksum'] then
        TSMCT_TIMESTAMPS['tsm_checksum'] = checksum
        TSMCT_TIMESTAMPS['tsm_timestamp'] = time()
    end
end]]
