-- TestEvilBunnyTransformation.server.luau
-- DISABLED for production

--[[ DISABLED
-- Test script to demonstrate evil bunny transformation on death

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Wait for dependencies
task.wait(5) -- Give time for other scripts to load

-- Wait for AssetLoader to be ready
local AssetLoader = require(script.Parent.AssetLoader)
while not AssetLoader.isReady() do
    task.wait(1)
    print("Waiting for AssetLoader to be ready...")
end

local BunnySpawner = require(script.Parent.BunnySpawner)

print("🔥 ====== EVIL BUNNY TRANSFORMATION TEST ======")

-- Test function to spawn and kill an evil bunny
local function testEvilBunnyTransformation()
    print("\n🐰 Spawning Evil Bunny for transformation test...")
    
    -- Spawn an evil bunny (infected for extra drama)
    local evilBunny = BunnySpawner.spawnBunny("EvilBunny", Vector3.new(0, 10, 0), true)
    
    if not evilBunny then
        warn("❌ Failed to spawn evil bunny")
        return
    end
    
    print("✅ Evil bunny spawned successfully!")
    
    -- Wait a moment for everything to initialize
    task.wait(2)
    
    print("💀 Killing evil bunny in 3 seconds...")
    print("🔄 It should transform into a random normal bunny type!")
    
    task.wait(3)
    
    -- Kill the evil bunny to trigger transformation
    local humanoid = evilBunny:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.Health = 0
        print("💥 Evil bunny eliminated!")
        print("⏳ Waiting for transformation...")
    else
        warn("❌ Could not find humanoid to kill evil bunny")
    end
end

-- Test function to monitor counter changes
local function monitorCounters()
    local countersFolder = ReplicatedStorage:FindFirstChild("AnimalCounters")
    if not countersFolder then
        warn("❌ AnimalCounters folder not found")
        return
    end
    
    print("\n📊 Monitoring counter changes...")
    
    -- Monitor evil bunny counters
    local function logCounters()
        local evilTotal = countersFolder:GetAttribute("animalEvilBunny_Total") or 0
        local evilInfected = countersFolder:GetAttribute("animalEvilBunny_Infected") or 0
        local evilCured = countersFolder:GetAttribute("animalEvilBunny_Cured") or 0
        
        print("🔥 Evil Bunnies - Total:", evilTotal, "Infected:", evilInfected, "Cured:", evilCured)
        
        -- Also show normal bunny totals
        local brownTotal = countersFolder:GetAttribute("animalBrownBunny_Total") or 0
        local tanTotal = countersFolder:GetAttribute("animalTanBunny_Total") or 0
        local whiteTotal = countersFolder:GetAttribute("animalWhiteBunny_Total") or 0
        local whiteBlackTotal = countersFolder:GetAttribute("animalWhiteAndBlackBunny_Total") or 0
        
        print("🐰 Normal Bunnies - Brown:", brownTotal, "Tan:", tanTotal, "White:", whiteTotal, "W&B:", whiteBlackTotal)
    end
    
    -- Log initial state
    print("📊 Initial Counters:")
    logCounters()
    
    -- Monitor for changes
    local connection
    connection = task.spawn(function()
        while true do
            task.wait(1)
            logCounters()
        end
    end)
    
    -- Stop monitoring after 30 seconds
    task.wait(30)
    task.cancel(connection)
    print("📊 Counter monitoring ended")
end

-- Run the test
print("🚀 Starting transformation test...")

-- Start monitoring in parallel
task.spawn(monitorCounters)

-- Run the transformation test
testEvilBunnyTransformation()

print("\n🏁 Test complete! Check the output above to see the transformation.")
print("Expected: Evil bunny dies → Transforms into random normal bunny → Counters update")
--]]
