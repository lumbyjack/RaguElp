-- Each rule:
--   match   = words to look for in a game message (not case-sensitive)
--   show    = the text to appear on the banner
--   graphic = optional: a graphic from `boxes.lua` to draw around you
-- A debuff rule has `debuff` (the icon's sprite ID) instead of `match`.
return {
    -- Chat Rules
    { 
        match   = "has sent a bomb after you", 
        show    = "Red bomb on you, get away from other players!", 
        graphic = "RB"
    },
    {
        match   = "channels incoming damage to you",
        show    = "Damage being channeled to you - STOP ATTACKING!"
    },
    {
        match   = "reflects incoming damage to",
        show    = "Damage being reflected - STOP ATTACKING!"
    },
    {
        match   = "releases his mental link",
        show    = "Mental link released - ATTACK!"
    },
    -- Debuff Rules
    {
        debuff = 21239,
        show   = "Bleed on you"
    }
}