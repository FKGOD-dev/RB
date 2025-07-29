-- ConnectionTest.lua
-- Script temporal en ServerScriptService para probar la conexión
-- EJECUTAR PARA DIAGNOSTICAR, LUEGO ELIMINAR

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

print("🔗 INICIANDO TEST DE CONEXIÓN...")
print("===============================")

-- Verificar que existan los remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local basicAttackRemote = remotes:WaitForChild("BasicAttack")
local kiBlastRemote = remotes:WaitForChild("KiBlast")

print("✅ RemoteEvents encontrados")

-- Test de conexión básica
basicAttackRemote.OnServerEvent:Connect(function(player)
	print("🔥 BASIC ATTACK RECIBIDO DE:", player.Name)

	-- Crear efecto visual simple para probar
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local rootPart = player.Character.HumanoidRootPart

		-- Crear esfera de prueba
		local testSphere = Instance.new("Part")
		testSphere.Name = "TestAttack"
		testSphere.Size = Vector3.new(4, 4, 4)
		testSphere.Shape = Enum.PartType.Ball
		testSphere.Material = Enum.Material.Neon
		testSphere.BrickColor = BrickColor.new("Bright red")
		testSphere.CanCollide = false
		testSphere.Anchored = true
		testSphere.CFrame = rootPart.CFrame * CFrame.new(0, 0, -5)
		testSphere.Parent = workspace

		-- Auto-destruir después de 2 segundos
		game:GetService("Debris"):AddItem(testSphere, 2)

		print("🔴 Esfera de prueba creada")
	end
end)

kiBlastRemote.OnServerEvent:Connect(function(player)
	print("⚡ KI BLAST RECIBIDO DE:", player.Name)

	-- Crear proyectil de prueba
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local rootPart = player.Character.HumanoidRootPart

		local projectile = Instance.new("Part")
		projectile.Name = "TestKiBlast"
		projectile.Size = Vector3.new(2, 2, 2)
		projectile.Shape = Enum.PartType.Ball
		projectile.Material = Enum.Material.Neon
		projectile.BrickColor = BrickColor.new("Bright blue")
		projectile.CanCollide = false
		projectile.Position = rootPart.Position + rootPart.CFrame.LookVector * 3
		projectile.Parent = workspace

		-- Movimiento
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
		bodyVelocity.Velocity = rootPart.CFrame.LookVector * 50
		bodyVelocity.Parent = projectile

		-- Auto-destruir después de 5 segundos
		game:GetService("Debris"):AddItem(projectile, 5)

		print("🔵 Proyectil de prueba lanzado")
	end
end)

print("🎯 Listeners de prueba configurados")
print("Ahora presiona LMB o Q para probar...")

-- Auto-destruir después de 60 segundos
spawn(function()
	wait(60)
	print("🗑️ Auto-eliminando script de test...")
	script:Destroy()
end)