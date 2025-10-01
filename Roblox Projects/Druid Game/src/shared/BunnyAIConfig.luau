-- BunnyAIConfig.luau
-- Configuration for bunny AI behavior per bunny type

local BunnyAIConfig = {}

-- Base AI configuration
BunnyAIConfig.DEFAULT = {
    HOP_ANIM_ID = 91072286761254,
    BASE_SPEED = 10,
    WALK_SPEED = 8,
    MOVE_INTERVAL = 4,
    MIN_DISTANCE = 15,
    MAX_DISTANCE = 25,
    PAUSE_CHANCE = 0.2,
    ROTATION_OFFSET = 90 -- degrees to rotate on spawn
}

-- Specific configurations per bunny type
BunnyAIConfig.BUNNY_CONFIGS = {
    BrownBunny = {
        WALK_SPEED = 8,
        MOVE_INTERVAL = 6, -- Increased from 4
        MIN_DISTANCE = 15,
        MAX_DISTANCE = 25,
        PAUSE_CHANCE = 0.4 -- Increased from 0.2
    },
    
    TanBunny = {
        WALK_SPEED = 9,
        MOVE_INTERVAL = 5.5, -- Increased from 3.5
        MIN_DISTANCE = 18,
        MAX_DISTANCE = 30,
        PAUSE_CHANCE = 0.35 -- Increased from 0.15
    },
    
    WhiteBunny = {
        WALK_SPEED = 7,
        MOVE_INTERVAL = 7, -- Increased from 5
        MIN_DISTANCE = 12,
        MAX_DISTANCE = 20,
        PAUSE_CHANCE = 0.5 -- Increased from 0.3
    },
    
    WhiteAndBlackBunny = {
        WALK_SPEED = 10,
        MOVE_INTERVAL = 5, -- Increased from 3
        MIN_DISTANCE = 20,
        MAX_DISTANCE = 35,
        PAUSE_CHANCE = 0.3 -- Increased from 0.1
    },
    
    EvilBunny = {
        WALK_SPEED = 12,  -- Evil bunnies are faster!
        MOVE_INTERVAL = 4, -- Increased from 2
        MIN_DISTANCE = 25,
        MAX_DISTANCE = 40,
        PAUSE_CHANCE = 0.25 -- Increased from 0.05 (evil bunnies now pause more)
    }
}

-- Get configuration for a specific bunny type
function BunnyAIConfig.getConfig(bunnyType: string)
    local specificConfig = BunnyAIConfig.BUNNY_CONFIGS[bunnyType] or {}
    local config = table.clone(BunnyAIConfig.DEFAULT)
    
    -- Override with specific settings
    for key, value in pairs(specificConfig) do
        config[key] = value
    end
    
    return config
end

-- Set the bunny type in the AI script (called from the AI script)
function BunnyAIConfig.setBunnyType(model: Model, bunnyType: string)
    local stringValue = Instance.new("StringValue")
    stringValue.Name = "BunnyType"
    stringValue.Value = bunnyType
    stringValue.Parent = model
end

return BunnyAIConfig
