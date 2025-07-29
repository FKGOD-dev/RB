-- CompleteCombatSystem.lua
-- Script en ServerScriptService (VERSIÓN COMPLETA Y CORREGIDA)
-- Sistema de combate completo con integración de progresión

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

print("🚀 INICIANDO SISTEMA DE COMBATE COMPLETO...")

-- Esperar a que los remotes estén listos
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local basicAttackRemote = remotes:WaitForChild("BasicAttack")
local kiBlastRemote = remotes:WaitForChild("KiBlast")

print("✅ RemoteEvents conectados correctamente")

-- Configuración del sistema
local CONFIG = {
	ATTACK_RANGE = 8,
	KI_BLAST_DAMAGE = 25,
	BASIC_ATTACK_DAMAGE = 15,
	KI_PROJECTILE_SPEED = 50,
	KI_COST = 20
}

-- Función para obtener stats del jugador
local function getPlayerStats(character)
	local statsFolder = character:FindFirstChild("PlayerStats")
	if not statsFolder then return nil end

	return {
		martialStyle = statsFolder:FindFirstChild("MartialStyle"),
		ki = statsFolder:FindFirstChild("Ki"),
		fuerza = statsFolder:FindFirstChild("Fuerza"),
		velocidad = statsFolder:FindFirstChild("Velocidad"),
		control = statsFolder:FindFirstChild("Control"),
		Level = statsFolder:FindFirstChild("Level"),
		MaxKi = statsFolder:FindFirstChild("MaxKi")
	}
end

-- Función para calcular daño basado en nivel
local function calculateDamage(stats, baseDamage)
	local fuerza = stats.fuerza and stats.fuerza.Value or 5
	local level = stats.Level and stats.Level.Value or 1

	-- Escalado de daño por nivel (10% más daño por nivel)
	local levelMultiplier = 1 + ((level - 1) * 0.1)

	return math.floor(baseDamage * levelMultiplier + (fuerza * 2))
end

-- Función para encontrar enemigos cercanos
local function findNearbyEnemies(attackerCharacter, range)
	local enemies = {}
	local attackerRootPart = attackerCharacter:FindFirstChild("HumanoidRootPart")
	if not attackerRootPart then return enemies end

	local attackerPosition = attackerRootPart.Position

	for _, player in pairs(Players:GetPlayers()) do
		if player.Character and player.Character ~= attackerCharacter then
			local enemyCharacter = player.Character
			local enemyHumanoid = enemyCharacter:FindFirstChild("Humanoid")
			local enemyRootPart = enemyCharacter:FindFirstChild("HumanoidRootPart")

			if enemyHumanoid and enemyRootPart and enemyHumanoid.Health > 0 then
				local distance = (attackerPosition - enemyRootPart.Position).Magnitude
				if distance <= range then
					table.insert(enemies, {character = enemyCharacter, distance = distance})
				end
			end
		end
	end

	-- Ordenar por distancia
	table.sort(enemies, function(a, b) return a.distance < b.distance end)
	return enemies
end

-- Función para crear efectos visuales de impacto
local function createHitEffect(position, color)
	local effect = Instance.new("Part")
	effect.Name = "HitEffect"
	effect.Size = Vector3.new(3, 3, 3)
	effect.Shape = Enum.PartType.Ball
	effect.Material = Enum.Material.Neon
	effect.BrickColor = color or BrickColor.new("Bright red")
	effect.CanCollide = false
	effect.Anchored = true
	effect.CFrame = CFrame.new(position)
	effect.Parent = workspace

	-- Efecto de expansión y desvanecimiento
	local originalSize = effect.Size
	effect.Size = Vector3.new(0.1, 0.1, 0.1)

	local tween = TweenService:Create(effect, 
		TweenInfo.new(0.3, Enum.EasingStyle.Quad), 
		{Size = originalSize * 1.5, Transparency = 1}
	)
	tween:Play()

	-- Crear partículas de impacto
	local attachment = Instance.new("Attachment")
	attachment.Parent = effect

	local particle = Instance.new("ParticleEmitter")
	particle.Color = ColorSequence.new(color.Color)
	particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	particle.Rate = 100
	particle.Lifetime = NumberRange.new(0.3, 0.8)
	particle.Speed = NumberRange.new(10, 20)
	particle.SpreadAngle = Vector2.new(360, 360)
	particle.Parent = attachment

	-- Auto-destruir
	Debris:AddItem(effect, 0.5)

	spawn(function()
		wait(0.1)
		particle.Enabled = false
	end)
end

-- Función para crear proyectil de Ki
local function createKiProjectile(startPosition, direction, damage, owner)
	local projectile = Instance.new("Part")
	projectile.Name = "KiBlast"
	projectile.Size = Vector3.new(2, 2, 2)
	projectile.Shape = Enum.PartType.Ball
	projectile.Material = Enum.Material.Neon
	projectile.BrickColor = BrickColor.new("Bright blue")
	projectile.CanCollide = false
	projectile.Position = startPosition
	projectile.Parent = workspace

	-- Efecto de luz
	local light = Instance.new("PointLight")
	light.Color = Color3.new(0, 0.5, 1)
	light.Brightness = 2
	light.Range = 10
	light.Parent = projectile

	-- Partículas del proyectil
	local attachment = Instance.new("Attachment")
	attachment.Parent = projectile

	local particle = Instance.new("ParticleEmitter")
	particle.Color = ColorSequence.new(Color3.new(0, 0.8, 1))
	particle.Texture = "rbxasset://textures/particles/fire_main.dds"
	particle.Rate = 50
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Speed = NumberRange.new(5, 10)
	particle.Parent = attachment

	-- Movimiento del proyectil
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.Velocity = direction * CONFIG.KI_PROJECTILE_SPEED
	bodyVelocity.Parent = projectile

	-- Rotación para efecto visual
	local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
	bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
	bodyAngularVelocity.AngularVelocity = Vector3.new(0, 10, 0)
	bodyAngularVelocity.Parent = projectile

	-- Detección de colisión
	local connection
	connection = projectile.Touched:Connect(function(hit)
		local hitCharacter = hit.Parent
		local hitHumanoid = hitCharacter:FindFirstChild("Humanoid")

		if hitCharacter ~= owner and hitHumanoid and hitHumanoid.Health > 0 then
			-- Aplicar daño
			hitHumanoid:TakeDamage(damage)

			-- Dar XP por golpe exitoso
			local ownerPlayer = Players:GetPlayerFromCharacter(owner)
			if ownerPlayer and _G.GiveXP then
				_G.GiveXP(ownerPlayer, "hit")

				-- Verificar si eliminó al enemigo
				if hitHumanoid.Health <= 0 then
					_G.GiveXP(ownerPlayer, "kill")
				end
			end

			-- Efecto visual de impacto
			createHitEffect(projectile.Position, BrickColor.new("Bright blue"))

			-- Crear pequeña explosión
			local explosion = Instance.new("Explosion")
			explosion.Position = projectile.Position
			explosion.BlastRadius = 8
			explosion.BlastPressure = 0
			explosion.Parent = workspace

			print("💥 Ki Blast impactó a", hitCharacter.Name, "- Daño:", damage)

			-- Destruir proyectil
			connection:Disconnect()
			projectile:Destroy()
		end
	end)

	-- Auto-destruir después de 5 segundos
	Debris:AddItem(projectile, 5)

	return projectile
end

-- EVENTOS DE COMBATE

-- Ataque básico mejorado
basicAttackRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then return end

	local stats = getPlayerStats(character)
	if not stats then return end

	print("👊 Ataque básico de", player.Name, "(Nivel " .. (stats.Level and stats.Level.Value or 1) .. ")")

	-- Buscar enemigos cercanos
	local nearbyEnemies = findNearbyEnemies(character, CONFIG.ATTACK_RANGE)

	if #nearbyEnemies > 0 then
		local target = nearbyEnemies[1].character
		local targetHumanoid = target:FindFirstChild("Humanoid")
		local targetRootPart = target:FindFirstChild("HumanoidRootPart")

		if targetHumanoid and targetRootPart then
			-- Calcular daño
			local finalDamage = calculateDamage(stats, CONFIG.BASIC_ATTACK_DAMAGE)

			-- Aplicar daño
			targetHumanoid:TakeDamage(finalDamage)

			-- Dar XP por golpe exitoso
			if _G.GiveXP then
				_G.GiveXP(player, "hit")
			end

			-- Verificar si eliminó al enemigo
			if targetHumanoid.Health <= 0 and _G.GiveXP then
				_G.GiveXP(player, "kill")
			end

			-- Efecto visual en el objetivo
			createHitEffect(targetRootPart.Position, BrickColor.new("Bright red"))

			-- Efecto de knockback leve
			local knockback = Instance.new("BodyVelocity")
			knockback.MaxForce = Vector3.new(4000, 0, 4000)
			knockback.Velocity = (targetRootPart.Position - rootPart.Position).Unit * 20
			knockback.Parent = targetRootPart

			Debris:AddItem(knockback, 0.3)

			print("💥", player.Name, "golpeó a", target.Name, "- Daño:", finalDamage)
		end
	else
		print("💨 Ataque falló - Sin enemigos en rango de", player.Name)
	end
end)

-- Ki Blast mejorado
kiBlastRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then return end

	local stats = getPlayerStats(character)
	if not stats or not stats.ki then return end

	-- Verificar Ki suficiente
	local maxKi = stats.MaxKi and stats.MaxKi.Value or 100
	if stats.ki.Value < CONFIG.KI_COST then
		print("❌ Ki insuficiente para", player.Name, "(" .. stats.ki.Value .. "/" .. CONFIG.KI_COST .. ")")
		return
	end

	-- Consumir Ki
	stats.ki.Value = stats.ki.Value - CONFIG.KI_COST

	print("⚡ Ki Blast de", player.Name, "(Nivel " .. (stats.Level and stats.Level.Value or 1) .. ") - Ki restante:", stats.ki.Value .. "/" .. maxKi)

	-- Calcular posición y dirección del proyectil
	local startPosition = rootPart.Position + rootPart.CFrame.LookVector * 3 + Vector3.new(0, 2, 0)
	local direction = rootPart.CFrame.LookVector

	-- Calcular daño basado en nivel
	local finalDamage = calculateDamage(stats, CONFIG.KI_BLAST_DAMAGE)

	-- Crear proyectil de Ki
	createKiProjectile(startPosition, direction, finalDamage, character)

	-- Efecto visual en el lanzador
	createHitEffect(rootPart.Position + rootPart.CFrame.LookVector * 2, BrickColor.new("Cyan"))
end)

-- Regeneración pasiva de Ki (coordinada con el sistema de progresión)
spawn(function()
	while true do
		wait(5) -- Cada 5 segundos (más espaciado para evitar conflictos)

		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				local stats = getPlayerStats(player.Character)
				if stats and stats.ki and stats.MaxKi then
					local currentKi = stats.ki.Value
					local maxKi = stats.MaxKi.Value

					if currentKi < maxKi then
						local newKi = math.min(currentKi + 1, maxKi) -- Regeneración muy lenta
						stats.ki.Value = newKi
					end
				end
			end
		end
	end
end)

-- Sistema de estadísticas de combate
spawn(function()
	while true do
		wait(30) -- Cada 30 segundos mostrar stats

		local totalPlayers = #Players:GetPlayers()
		if totalPlayers > 0 then
			print("⚔️ COMBAT STATS:")
			for _, player in pairs(Players:GetPlayers()) do
				if player.Character then
					local stats = getPlayerStats(player.Character)
					if stats then
						local level = stats.Level and stats.Level.Value or 1
						local ki = stats.ki and stats.ki.Value or 0
						local maxKi = stats.MaxKi and stats.MaxKi.Value or 100
						local style = stats.martialStyle and stats.martialStyle.Value or "UNKNOWN"

						print("   👤", player.Name, "- Lv." .. level, "| Ki:", ki .. "/" .. maxKi, "| Style:", style)
					end
				end
			end
			print("=====================================")
		end
	end
end)

print("✅ Sistema de Combate Completo cargado correctamente!")
print("🎮 Características activas:")
print("   ✅ Ataques básicos con daño escalado por nivel")
print("   ✅ Ki Blasts con efectos visuales mejorados")
print("   ✅ Sistema de XP integrado por combate")
print("   ✅ Efectos de impacto y partículas")
print("   ✅ Knockback y explosiones")
print("   ✅ Regeneración pasiva de Ki")
print("   ✅ Estadísticas de combate en tiempo real")
print("🎯 Controles: LMB (Ataque), Q (Ki Blast)")
print("=====================================")