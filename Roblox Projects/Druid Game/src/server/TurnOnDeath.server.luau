--[[

TurnOnDeath

This script turns the animal it is attached to into one of its normal types on death.
The normal animal types are:
- BrownBunny
- TanBunny  
- WhiteBunny
- WhiteAndBlackBunny

This script is specifically designed for EvilBunny - when an evil bunny dies,
it transforms into a random normal bunny type at the same position.

]]

-- Safety check: only run if parented to a model with Humanoid
if not script.Parent:IsA("Model") or not script.Parent:FindFirstChildOfClass("Humanoid") then
    return -- Don't run if not properly parented to a bunny
end

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local model = script.Parent
local humanoid = model:WaitForChild("Humanoid", 5)
local rootPart = model:WaitForChild("HumanoidRootPart", 5)

-- Exit if essential components aren't found
if not humanoid or not rootPart then
    warn("TurnOnDeath: Missing essential components, exiting")
    return
end

-- Wait for dependencies
local AnimalConfig = require(ReplicatedStorage.Shared.AnimalConfig)

-- Get BunnySpawner reference (need to wait for it to load)
local BunnySpawner
task.spawn(function()
    -- Wait a bit for the server scripts to load
    task.wait(1)
    local success = pcall(function()
        BunnySpawner = require(game.ServerScriptService.Server.BunnySpawner)
    end)
    if not success then
        warn("TurnOnDeath: Could not load BunnySpawner")
    end
end)

-- Normal bunny types (everything except EvilBunny)
local NORMAL_BUNNY_TYPES = {
    "BrownBunny",
    "TanBunny", 
    "WhiteBunny",
    "WhiteAndBlackBunny"
}

-- Function to get a random normal bunny type
local function getRandomNormalBunnyType()
    local randomIndex = math.random(1, #NORMAL_BUNNY_TYPES)
    return NORMAL_BUNNY_TYPES[randomIndex]
end

-- Function to check if the bunny is infected
local function isInfected()
    return CollectionService:HasTag(model, AnimalConfig.StatusTags.INFECTED)
end

-- Function to create sparkle explosion effect
local function createSparkleExplosion(position)
    -- Create an invisible part to attach the particle emitter and sound to
    local effectPart = Instance.new("Part")
    effectPart.Size = Vector3.new(0.1, 0.1, 0.1)
    effectPart.Position = position
    effectPart.Anchored = true
    effectPart.CanCollide = false
    effectPart.Transparency = 1
    effectPart.Parent = workspace
    
    -- Create and play transformation sound
    local transformSound = Instance.new("Sound")
    transformSound.SoundId = "rbxassetid://1289263994"
    transformSound.Volume = 0.5
    transformSound.Parent = effectPart
    transformSound:Play()
    
    -- Create sparkle particle emitter
    local particles = Instance.new("ParticleEmitter")
    particles.Parent = effectPart
    
    -- Sparkle effect properties
    particles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
    particles.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 100)), -- Yellow
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 255)), -- Pink
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 255, 255)) -- Cyan
    })
    
    particles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.5, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    
    particles.Lifetime = NumberRange.new(0.5, 1)
    particles.Rate = 100
    particles.Speed = NumberRange.new(10, 20)
    particles.SpreadAngle = Vector2.new(180, 180) -- Emit in all directions
    particles.Acceleration = Vector3.new(0, -20, 0) -- Gravity effect
    particles.Rotation = NumberRange.new(0, 360)
    particles.RotSpeed = NumberRange.new(-200, 200)
    particles.LightEmission = 1 -- Make them glow
    particles.LightInfluence = 0
    
    -- Burst of particles
    particles:Emit(50)
    
    -- Clean up after particles are done
    task.delay(2, function()
        effectPart:Destroy()
    end)
end

-- Function to handle transformation on death
local function transformOnDeath()
    if not BunnySpawner then
        warn("TurnOnDeath: BunnySpawner not available for transformation")
        -- Still despawn the evil bunny even if transformation fails
        task.wait(1)
        model:Destroy()
        return
    end
    
    -- Store current state before transformation
    local currentPosition = rootPart.Position
    local wasInfected = isInfected()
    local newBunnyType = getRandomNormalBunnyType()
    
    print("🔄 Evil bunny transforming into:", newBunnyType, "at position:", currentPosition)
    
    -- Create sparkle explosion effect
    createSparkleExplosion(currentPosition)
    
    -- Small delay to let the effect start
    task.wait(0.3)
    
    -- Spawn the new bunny at the same position with same infection status
    local success, newBunny = pcall(function()
        return BunnySpawner.spawnBunny(newBunnyType, currentPosition, wasInfected)
    end)
    
    if success and newBunny then
        print("✅ Evil bunny successfully transformed into:", newBunnyType)
    else
        warn("❌ Failed to transform evil bunny:", newBunny)
    end
    
    -- Despawn the evil bunny (remove it from the game)
    task.wait(0.2) -- Brief delay to let particles emit
    model:Destroy()
    print("💀 Evil bunny despawned")
end

-- Connect to the death event
humanoid.Died:Connect(transformOnDeath)

print("💀 TurnOnDeath script initialized for:", model.Name)
