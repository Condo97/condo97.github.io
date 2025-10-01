local CollectionService = game:GetService("CollectionService")

local function tagWater(part: BasePart)
	if not part or not part:IsA("BasePart") then return end
	if part.Name == "Water" or CollectionService:HasTag(part, "Water") then
		if not CollectionService:HasTag(part, "Water") then
			CollectionService:AddTag(part, "Water")
		end
	end
end

for _, descendant in ipairs(workspace:GetDescendants()) do
	if descendant:IsA("BasePart") and (descendant.Name == "Water" or CollectionService:HasTag(descendant, "Water")) then
		tagWater(descendant)
	end
end

workspace.DescendantAdded:Connect(function(descendant)
	if descendant:IsA("BasePart") and (descendant.Name == "Water" or CollectionService:HasTag(descendant, "Water")) then
		tagWater(descendant)
	end
end)


