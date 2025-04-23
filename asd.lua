local disablebrus = true -- травушку отключить

local line = true -- Линии
local box = true -- коробка
local renderteam = false -- будут ли показываться союзники
local TeamColor = true -- Подсветка ESP цветом (красный противники / синий союзники)

local camera = workspace.CurrentCamera
local vehiclesFolder = workspace:WaitForChild("Vehicles")
local runService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function g2db(object)
	local cf, size = object:GetBoundingBox()
	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local onScreen = false

	for x = -1, 1, 2 do
		for y = -1, 1, 2 do
			for z = -1, 1, 2 do
				local corner = (cf * CFrame.new(Vector3.new(x * size.X/2, y * size.Y/2, z * size.Z/2))).Position
				local screenPos, visible = camera:WorldToViewportPoint(corner)
				if visible then
					onScreen = true
					minX = math.min(minX, screenPos.X)
					minY = math.min(minY, screenPos.Y)
					maxX = math.max(maxX, screenPos.X)
					maxY = math.max(maxY, screenPos.Y)
				end
			end
		end
	end

	if onScreen then
		return Vector2.new(minX, minY), Vector2.new(maxX, maxY)
	else
		return nil, nil
	end
end

local ESPL = {}
local ESPB = {}

local function ESP()
	for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
		local hull = vehicle:FindFirstChild("Hull")
		local followHz = hull and hull:FindFirstChild("FollowHz")
		local ownerValue = vehicle:FindFirstChild("Owner")
		local owner = ownerValue and ownerValue.Value

		if hull and followHz and owner then
			local screenPoint, onScreen = camera:WorldToViewportPoint(followHz.Position)

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

            if(box)then
                if(ownerValue ~= localPlayer.Name) then
                    local min, max = g2db(vehicle)
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
                            l.Position = Vector2.new(min.X, max.Y)
                            l.Size = Vector2.new(max.X - min.X, min.Y - max.Y)
                        end
                    else
                        l.Visible = false
                    end
                end
            end
		end
	end
end

for _, r in ipairs(game:GetService("Workspace"):FindFirstChild("Map"):GetChildren()) do
    for _, a in ipairs(r:GetDescendants()) do
        if a.Name == "Bush" then
            a:Destroy()
        end
    end
end

runService.RenderStepped:Connect(function()
	ESP()
end)
