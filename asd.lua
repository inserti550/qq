local disablebrus = true -- травушку отключить

local line = true -- Линии
local box = true -- коробка
local renderteam = false -- будут ли показываться союзники
local TeamColor = true -- Подсветка ESP цветом (красный противники / синий союзники)
local distance2target = true -- дистанция
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function g2db(entity, camera)
	if not entity or not entity:IsA("BasePart") and not entity:IsA("Model") then
		return nil
	end

	local cf, size
	if entity:IsA("Model") then
		cf, size = entity:GetBoundingBox()
	else
		cf = entity.CFrame
		size = entity.Size
	end

	local halfSize = size / 2
	local corners = {
		cf.Position + cf:VectorToWorldSpace(Vector3.new(-halfSize.X, -halfSize.Y, -halfSize.Z)),
		cf.Position + cf:VectorToWorldSpace(Vector3.new(-halfSize.X, halfSize.Y, -halfSize.Z)),
		cf.Position + cf:VectorToWorldSpace(Vector3.new(halfSize.X, halfSize.Y, -halfSize.Z)),
		cf.Position + cf:VectorToWorldSpace(Vector3.new(halfSize.X, -halfSize.Y, -halfSize.Z)),
		cf.Position + cf:VectorToWorldSpace(Vector3.new(halfSize.X, halfSize.Y, halfSize.Z)),
		cf.Position + cf:VectorToWorldSpace(Vector3.new(-halfSize.X, halfSize.Y, halfSize.Z)),
		cf.Position + cf:VectorToWorldSpace(Vector3.new(-halfSize.X, -halfSize.Y, halfSize.Z)),
		cf.Position + cf:VectorToWorldSpace(Vector3.new(halfSize.X, -halfSize.Y, halfSize.Z)),
	}

	local screenPoints = {}
	for _, corner in ipairs(corners) do
		local screenPos, onScreen = camera:WorldToViewportPoint(corner)
		if not onScreen then
			return nil
		end
		table.insert(screenPoints, screenPos)
	end

	local left = screenPoints[1].X
	local top = screenPoints[1].Y
	local right = screenPoints[1].X
	local bottom = screenPoints[1].Y

	for i = 2, #screenPoints do
		local pt = screenPoints[i]
		left = math.min(left, pt.X)
		top = math.min(top, pt.Y)
		right = math.max(right, pt.X)
		bottom = math.max(bottom, pt.Y)
	end

	return {
		Left = left,
		Top = top,
		Right = right,
		Bottom = bottom
	}
end
local PlayerVeh = nil
local ESPL = {}
local ESPB = {}
local ESPD = {}
local function ESP()
	for i, line in pairs(ESPL) do
		line:Remove()
	end
	ESPL = {}

	for i, line in pairs(ESPB) do
		line:Remove()
	end
	ESPB = {}
    
    for i, line in pairs(ESPD) do
        line:Remove()
    end
    ESPD = {}


	for i, vehicle in ipairs(workspace:WaitForChild("Vehicles"):GetChildren()) do
		local hull = vehicle:FindFirstChild("Hull")
		local followHz = hull and hull:FindFirstChild("FollowHz")
		local ownerValue = vehicle:FindFirstChild("Owner")
		local owner = ownerValue and ownerValue.Value
        local box = g2db(vehicle,camera)
		if hull and followHz and owner then
			local screenPoint, onScreen = camera:WorldToViewportPoint(followHz.Position)
            if(ownerValue == localPlayer.Name) then
                PlayerVeh = vehicle
            end
			if line then
				if not ESPL[vehicle.Name] then
					local newLine = Drawing.new("Line")
					newLine.Thickness = 2
					newLine.Transparency = 1

					if TeamColor then
						if owner.Team == localPlayer.Team then
							newLine.Color = Color3.fromRGB(66, 76, 255)
						else
							newLine.Color = Color3.fromRGB(255, 0, 0)
						end
					else
						newLine.Color = Color3.fromRGB(255, 255, 255)
					end

					if owner.Team == localPlayer.Team and not renderteam then
						newLine.Visible = false
					end

					ESPL[vehicle.Name] = newLine
				end

				local l = ESPL[vehicle.Name]
				if onScreen then
					if owner.Team == localPlayer.Team and not renderteam then
						l.Visible = false
					else
						l.Visible = true
						l.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
						l.To = Vector2.new(screenPoint.X, screenPoint.Y)
					end
				else
					l.Visible = false
				end
			end
            if distance2target and box then
                if not ESPD[vehicle.Name] then
                    local newText = Drawing.new("Text")
                    newText.Size = 18
                    newText.Center = true
                    newText.Outline = true
                    newText.Transparency = 1

                    if TeamColor then
                        if owner.Team == localPlayer.Team then
                            newText.Color = Color3.fromRGB(66, 76, 255)
                        else
                            newText.Color = Color3.fromRGB(255, 0, 0)
                        end
                    else
                        newText.Color = Color3.fromRGB(255, 255, 255)
                    end

                    ESPD[vehicle.Name] = newText
                end

                local l = ESPD[vehicle.Name]
                if onScreen then
                    if owner.Team == localPlayer.Team and not renderteam then
                        l.Visible = false
                    else
                        l.Visible = true
                        l.Position = Vector2.new((box.Left + box.Right)/2, box.Bottom)
                        l.Text = math.floor(((camera.CFrame.Position - followHz.Position).Magnitude) * 0.28) .. " m"
                    end
                else
                    l.Visible = false
                end
            end
            if(box)then
                if(ownerValue ~= localPlayer.Name) then
                    if not ESPB[vehicle.Name] then
                        local newLine = Drawing.new("Square")
                        newLine.Thickness = 2
                        newLine.Transparency = 1

                        if TeamColor then
                            if owner.Team == localPlayer.Team then
                                newLine.Color = Color3.fromRGB(66, 76, 255)
                            else
                                newLine.Color = Color3.fromRGB(255, 0, 0)
                            end
                        else
                            newLine.Color = Color3.fromRGB(255, 255, 255)
                        end

                        if owner.Team == localPlayer.Team and not renderteam then
                            newLine.Visible = false
                        end

                        ESPB[vehicle.Name] = newLine
                    end

                    local l = ESPB[vehicle.Name]
                    if onScreen then
                        if owner.Team == localPlayer.Team and not renderteam then
                            l.Visible = false
                        else
                            l.Visible = true
                            l.Position = Vector2.new(box.Left, box.Top)
                            l.Size = Vector2.new(box.Right-box.Left,box.Bottom-box.Top)
                        end
                    else
                        l.Visible = false
                    end
                end
            end
		end
	end
end

for ii, r in ipairs(game:GetService("Workspace"):FindFirstChild("Map"):GetChildren()) do
    for i, a in ipairs(r:GetDescendants()) do
        if a.Name == "Bush" then
            a:Destroy()
        end
    end
end

local distance = Drawing.new("Text")
distance.Visible = true
distance.Center = true
distance.Outline = true
distance.Size = 18
distance.Color = Color3.fromRGB(255, 255, 255)
distance.Position = Vector2.new((workspace.CurrentCamera.ViewportSize.X / 2) + 45, (workspace.CurrentCamera.ViewportSize.y / 2) - 65)
local igray = {}

RunService.RenderStepped:Connect(function()
    local orig = camera.CFrame.Position + camera.CFrame.LookVector * 2
    local dir = camera.CFrame.LookVector * 99990

    local param = RaycastParams.new()
    param.FilterType = Enum.RaycastFilterType.Blacklist
    param.FilterDescendantsInstances = igray

    local result = workspace:Raycast(orig, dir, param)
    distance.Visible = true
    distance.Text = "Бобметр: " .. math.floor(((orig - result.Position).Magnitude) * 0.28) .. " m"
    igray = {}
    distance.Position = Vector2.new((workspace.CurrentCamera.ViewportSize.X / 2) + 45, (workspace.CurrentCamera.ViewportSize.y / 2) - 65)
    ESP()
end)
