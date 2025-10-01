local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

--[[
	FireflyController - Blink Behavior Module
	
	This script handles the blinking behavior for firefly models.
	It looks for parts named "Light" within Firefly-tagged models and creates
	realistic random blinking patterns.
	
	Usage: Tag any Model with "Firefly" to start the blinking animation
--]]

-- ========================================================================================
-- CONFIGURATION
-- ========================================================================================

local BLINK_CONFIG = {
	ON_DURATION = 0.25,     -- How long the light stays on when blinking
	OFF_MIN = 2.0,          -- Minimum time between blinks
	OFF_MAX = 5.0,          -- Maximum time between blinks
	FADE_SPEED = 0.1,       -- How quickly lights fade in/out
	VISIBLE_TRANSPARENCY = 0.9,  -- Transparency when "on" (0.9 = slightly visible)
	INVISIBLE_TRANSPARENCY = 1.0  -- Transparency when "off" (1.0 = completely invisible)
}

-- ========================================================================================
-- STATE MANAGEMENT
-- ========================================================================================

local activeFireflies = {}     -- Track active firefly models
local blinkCoroutines = {}     -- Track running blink coroutines

-- ========================================================================================
-- TWEEN CONFIGURATIONS
-- ========================================================================================

local blinkOnTweenInfo = TweenInfo.new(
	BLINK_CONFIG.FADE_SPEED,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,     -- No repeat
	false  -- No reverse
)

local blinkOffTweenInfo = TweenInfo.new(
	BLINK_CONFIG.FADE_SPEED,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.InOut,
	0,     -- No repeat
	false  -- No reverse
)

-- ========================================================================================
-- UTILITY FUNCTIONS
-- ========================================================================================

-- Find all Light parts within a firefly model
local function findLightParts(fireflyModel)
	local lightParts = {}
	
	-- Search descendants for Light parts
	for _, descendant in pairs(fireflyModel:GetDescendants()) do
		if descendant:IsA("BasePart") and descendant.Name == "Light" then
			table.insert(lightParts, descendant)
		end
	end
	
	-- Search direct children as well
	for _, child in pairs(fireflyModel:GetChildren()) do
		if child:IsA("BasePart") and child.Name == "Light" then
			table.insert(lightParts, child)
		end
	end
	
	return lightParts
end

-- Generate random delay between blinks
local function getRandomBlinkDelay()
	return math.random() * (BLINK_CONFIG.OFF_MAX - BLINK_CONFIG.OFF_MIN) + BLINK_CONFIG.OFF_MIN
end

-- ========================================================================================
-- BLINK BEHAVIOR FUNCTIONS
-- ========================================================================================

-- Handle the blinking loop for a single light part
local function startBlinkingLoop(lightPart, fireflyModel)
	local blinkCoroutine = coroutine.create(function()
		while lightPart.Parent and activeFireflies[fireflyModel] do
			-- Random delay before next blink (light stays off)
			local randomDelay = getRandomBlinkDelay()
			wait(randomDelay)
			
			-- Check if still valid
			if not lightPart.Parent or not activeFireflies[fireflyModel] then break end
			
			-- Blink on (fade to visible)
			local blinkOnTween = TweenService:Create(lightPart, blinkOnTweenInfo, {
				Transparency = BLINK_CONFIG.VISIBLE_TRANSPARENCY
			})
			blinkOnTween:Play()
			blinkOnTween.Completed:Wait()
			
			-- Stay on for the blink duration
			wait(BLINK_CONFIG.ON_DURATION)
			
			-- Check if still valid
			if not lightPart.Parent or not activeFireflies[fireflyModel] then break end
			
			-- Blink off (fade to invisible)
			local blinkOffTween = TweenService:Create(lightPart, blinkOffTweenInfo, {
				Transparency = BLINK_CONFIG.INVISIBLE_TRANSPARENCY
			})
			blinkOffTween:Play()
			blinkOffTween.Completed:Wait()
		end
	end)
	
	-- Store the coroutine for cleanup
	if not blinkCoroutines[fireflyModel] then
		blinkCoroutines[fireflyModel] = {}
	end
	table.insert(blinkCoroutines[fireflyModel], blinkCoroutine)
	
	-- Start the coroutine
	coroutine.resume(blinkCoroutine)
end

-- ========================================================================================
-- MAIN FIREFLY CONTROL FUNCTIONS
-- ========================================================================================

-- Start blinking behavior for a firefly model
local function startFireflyBlink(fireflyModel)
	
	-- Find all Light parts in the firefly model
	local lightParts = findLightParts(fireflyModel)
	
	if #lightParts == 0 then
		return
	end
	
	-- Mark this firefly as active
	activeFireflies[fireflyModel] = true
	
	-- Initialize each Light part and start blinking
	for _, lightPart in pairs(lightParts) do
		-- Set initial state (invisible)
		lightPart.Transparency = BLINK_CONFIG.INVISIBLE_TRANSPARENCY
		
		-- Start the blinking loop for this light
		startBlinkingLoop(lightPart, fireflyModel)
	end
end

-- Stop blinking behavior for a firefly model
local function stopFireflyBlink(fireflyModel)
	
	-- Mark firefly as inactive (this will stop the coroutines)
	if activeFireflies[fireflyModel] then
		activeFireflies[fireflyModel] = nil
	end
	
	-- Clean up blinking coroutines
	if blinkCoroutines[fireflyModel] then
		blinkCoroutines[fireflyModel] = nil
	end
	
	-- Reset all Light parts to invisible state
	local lightParts = findLightParts(fireflyModel)
	for _, lightPart in pairs(lightParts) do
		if lightPart.Parent then
			lightPart.Transparency = BLINK_CONFIG.INVISIBLE_TRANSPARENCY
		end
	end
end

-- ========================================================================================
-- INITIALIZATION
-- ========================================================================================

-- Handle existing Firefly-tagged models
local existingFireflies = CollectionService:GetTagged("Firefly")

for _, object in pairs(existingFireflies) do
	if object:IsA("Model") then
		startFireflyBlink(object)
	end
end

-- ========================================================================================
-- EVENT HANDLERS
-- ========================================================================================

-- Handle new Firefly-tagged models
CollectionService:GetInstanceAddedSignal("Firefly"):Connect(function(object)
	if object:IsA("Model") then
		startFireflyBlink(object)
	end
end)

-- Handle removed Firefly-tagged models
CollectionService:GetInstanceRemovedSignal("Firefly"):Connect(function(object)
	if object:IsA("Model") then
		stopFireflyBlink(object)
	end
end)

-- Clean up when models are destroyed
workspace.DescendantRemoving:Connect(function(descendant)
	if activeFireflies[descendant] then
		stopFireflyBlink(descendant)
	end
end)
