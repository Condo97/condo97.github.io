-- EvilBunnyHealthBar.server.luau
-- Creates a health bar above evil bunnies when they take damage

-- Safety check: only run if parented to a model with Humanoid
if not script.Parent:IsA("Model") or not script.Parent:FindFirstChildOfClass("Humanoid") then
    return
end

local model = script.Parent
local humanoid = model:WaitForChild("Humanoid", 5)
local rootPart = model:WaitForChild("HumanoidRootPart", 5)

if not humanoid or not rootPart then
    warn("EvilBunnyHealthBar: Missing essential components")
    return
end

local healthBarGui = nil
local hideHealthBarTask = nil

-- Function to create the health bar GUI
local function createHealthBar()
    -- Create BillboardGui (appears above the bunny)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "HealthBar"
    billboard.Size = UDim2.new(4, 0, 0.5, 0)
    billboard.StudsOffset = Vector3.new(0, 3, 0) -- 3 studs above the bunny
    billboard.AlwaysOnTop = true
    billboard.Parent = rootPart
    
    -- Background frame
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    background.BorderSizePixel = 2
    background.BorderColor3 = Color3.fromRGB(0, 0, 0)
    background.Parent = billboard
    
    -- Health bar (red)
    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.new(1, 0, 1, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(220, 20, 20) -- Red
    healthBar.BorderSizePixel = 0
    healthBar.Parent = background
    
    -- Health text
    local healthText = Instance.new("TextLabel")
    healthText.Name = "HealthText"
    healthText.Size = UDim2.new(1, 0, 1, 0)
    healthText.BackgroundTransparency = 1
    healthText.Text = string.format("%d/%d", math.ceil(humanoid.Health), math.ceil(humanoid.MaxHealth))
    healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
    healthText.TextScaled = true
    healthText.Font = Enum.Font.SourceSansBold
    healthText.TextStrokeTransparency = 0.5
    healthText.Parent = background
    
    return billboard
end

-- Function to update the health bar
local function updateHealthBar()
    if not healthBarGui then
        return
    end
    
    local healthBar = healthBarGui:FindFirstChild("Background"):FindFirstChild("HealthBar")
    local healthText = healthBarGui:FindFirstChild("Background"):FindFirstChild("HealthText")
    
    if healthBar and healthText then
        -- Update size based on health percentage
        local healthPercent = humanoid.Health / humanoid.MaxHealth
        healthBar.Size = UDim2.new(healthPercent, 0, 1, 0)
        
        -- Update text
        healthText.Text = string.format("%d/%d", math.ceil(humanoid.Health), math.ceil(humanoid.MaxHealth))
        
        -- Change color based on health
        if healthPercent > 0.6 then
            healthBar.BackgroundColor3 = Color3.fromRGB(220, 20, 20) -- Red
        elseif healthPercent > 0.3 then
            healthBar.BackgroundColor3 = Color3.fromRGB(220, 100, 20) -- Orange
        else
            healthBar.BackgroundColor3 = Color3.fromRGB(150, 20, 20) -- Dark red
        end
    end
end

-- Function to show the health bar
local function showHealthBar()
    if not healthBarGui then
        healthBarGui = createHealthBar()
    else
        healthBarGui.Enabled = true
    end
    
    updateHealthBar()
    
    -- Cancel any existing hide task
    if hideHealthBarTask then
        task.cancel(hideHealthBarTask)
    end
    
    -- Hide the health bar after 5 seconds of no damage
    hideHealthBarTask = task.delay(5, function()
        if healthBarGui then
            healthBarGui.Enabled = false
        end
    end)
end

-- Function to hide the health bar
local function hideHealthBar()
    if healthBarGui then
        healthBarGui.Enabled = false
    end
end

-- Show health bar when the bunny takes damage
humanoid.HealthChanged:Connect(function(health)
    if health < humanoid.MaxHealth and health > 0 then
        showHealthBar()
    end
end)

-- Hide health bar when bunny dies
humanoid.Died:Connect(function()
    hideHealthBar()
end)

-- Clean up when the model is destroyed
model.AncestryChanged:Connect(function(_, parent)
    if not parent then
        if healthBarGui then
            healthBarGui:Destroy()
        end
    end
end)

print("💚 EvilBunnyHealthBar initialized for:", model.Name)

