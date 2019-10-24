local TSMCT_AddonName, TSMCT = ...

TSMCT.util = {}

function TSMCT.util.unescape_link(str)
    local res = tostring(str)

    res = gsub(res, '|c........', '') -- Remove color start.
    res = gsub(res, '|r', '') -- Remove color end.
    res = gsub(res, '|H.-|h(.-)|h', '%1') -- Remove links.
    res = gsub(res, '|T.-|t', '') -- Remove textures.
    res = gsub(res, '{.-}', '') -- Remove raid target icons.

    return res
end
