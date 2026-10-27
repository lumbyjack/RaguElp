-- Each rule:
--   match   = words to look for in a game message (not case-sensitive)
--   show    = the text to appear on the banner
--   graphic = optional: a graphic from `boxes.lua` to draw around you
-- A debuff rule has `debuff` (the icon's sprite ID) instead of `match`.
return {
    -- Chat Rules
    {
        match  = "accepts your challenge",
        show   = "mitigate the hit, bruh. Transfigure or something?"
    },
    { 
        match   = "has sent a bomb after you", 
        show    = "RED BOMB ON YOU! Run away from team!", 
        graphic = "RB"
    },
    {
        match   = "channels incoming damage to you",
        show    = "STOP ATTACKING! Damage being reflected to you"
    },
    {
        match   = "reflects incoming damage to",
        show    = "STOP ATTACKING! Damage being reflected to teammate"
    },
    {
        match   = "releases his mental link",
        show    = "Mental link released - ATTACK!"
    },
    {
        match   = "prepares to suffocate all those who aren't contained",
        show    = "suffocate - get contained or something."
    },
    {
        match   = "starts to charge all his power into a massive fire attack",
        show    = "fireattackorsomething"
    },
    {
        match   = "turns everyone into explosive Vitali",
        show    = "cool transmog"
    },
    {
        match   = "is invulnerable as he charges a massive fire attack"
    },
    -- Debuff Rules
    {
        debuff = 21239,
        show   = "Bleed on you"
    }
}