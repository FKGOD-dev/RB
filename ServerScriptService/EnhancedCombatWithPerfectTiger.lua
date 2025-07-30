-- EnhancedCombatWithPerfectTiger.lua
-- Script en ServerScriptService
-- Sistema completo con TIGER perfecto según especificaciones

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")

print("🚀 INICIANDO SISTEMA DE COMBATE CON TIGER PERFECTO...")

-- Esperar remotes
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local basicAttackRemote = remotes:WaitForChild("BasicAttack")
local kiBlastRemote = remotes:WaitForChild("KiBlast")

-- Crear nuevos remotes para habilidades E y R
local eAbilityRemote = remotes:FindFirstChild("EAbility")
if not eAbilityRemote then
	eAbilityRemote = Instance.new("RemoteEvent")
	eAbilityRemote.Name = "EAbility"
	eAbilityRemote.Parent = remotes
end

local rAbilityRemote = remotes:FindFirstChild("RAbility")
if not rAbilityRemote then
	rAbilityRemote = Instance.new("RemoteEvent")
	rAbilityRemote.Name = "RAbility"
	rAbilityRemote.Parent = remotes
end

print("✅ RemoteEvents para habilidades E & R creados")

-- Configuración del sistema
local CONFIG = {
	ATTACK_RANGE = 8,
	KI_BLAST_DAMAGE = 25,
	BASIC_ATTACK_DAMAGE = 15,
	KI_PROJECTILE_SPEED = 50,
	ABILITY_E_COST = 30,
	ABILITY_R_COST = 50,
	ABILITY_E_COOLDOWN = 8,
	ABILITY_R_COOLDOWN = 15
}

-- Cooldowns por jugador
local playerCooldowns = {}

-- ========================================
-- 🐅 SISTEMA TIGER PERFECTO
-- ========================================

-- Función para crear efectos de garra de tigre
local function createTigerClawEffect(position, direction, intensity)
	intensity = intensity or 1

	for i = 1, 3 do
		spawn(function()
			wait(i * 0.05)

			local claw = Instance.new("Part")
			claw.Name = "TigerClaw"
			claw.Size = Vector3.new(6 * intensity, 0.5, 1)
			claw.Material = Enum.Material.Neon
			claw.BrickColor = BrickColor.new("Really red")
			claw.CanCollide = false
			claw.Anchored = true
			claw.Parent = workspace

			local offset = Vector3.new(0, (i-2) * 0.8, 0)
			claw.CFrame = CFrame.new(position + offset, position + direction) * 
				CFrame.Angles(0, 0, math.rad(45 + (i * 15)))

			-- Efecto de aparición dramática
			claw.Transparency = 1
			local appearTween = TweenService:Create(claw, 
				TweenInfo.new(0.1), {Transparency = 0.1})
			local fadeTween = TweenService:Create(claw, 
				TweenInfo.new(0.6), {Transparency = 1, Size = claw.Size * 1.5})

			appearTween:Play()
			appearTween.Completed:Connect(function()
				fadeTween:Play()
			end)

			Debris:AddItem(claw, 0.7)
		end)
	end
end

-- Función para efecto de sangrado
local function createBleedEffect(position)
	local blood = Instance.new("Part")
	blood.Name = "BloodEffect"
	blood.Size = Vector3.new(3, 0.1, 3)
	blood.Shape = Enum.PartType.Cylinder
	blood.Material = Enum.Material.Neon
	blood.BrickColor = BrickColor.new("Crimson")
	blood.CanCollide = false
	blood.Anchored = true
	blood.CFrame = CFrame.new(position) * CFrame.Angles(math.rad(90), 0, 0)
	blood.Parent = workspace

	local expandTween = TweenService:Create(blood, 
		TweenInfo.new(0.4), {Size = Vector3.new(5, 0.1, 5), Transparency = 0.9})
	expandTween:Play()

	Debris:AddItem(blood, 1.5)
end

-- Función para aplicar sangrado DoT
local function applyBleeding(character, damage, duration)
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid then return end

	spawn(function()
		for i = 1, duration do
			wait(1)
			if humanoid.Health > 0 then
				humanoid:TakeDamage(damage)

				local rootPart = character:FindFirstChild("HumanoidRootPart")
				if rootPart then
					createBleedEffect(rootPart.Position + Vector3.new(0, 1, 0))
				end

				print("🩸 Sangrado: " .. damage .. " damage a " .. character.Name)
			end
		end
	end)
end

-- Función para crear aura de furia
local function createRageAura(character, intensity)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	local existingAura = rootPart:FindFirstChild("TigerRageAura")
	if existingAura then existingAura:Destroy() end

	local aura = Instance.new("Attachment")
	aura.Name = "TigerRageAura"
	aura.Parent = rootPart

	local particle = Instance.new("ParticleEmitter")
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.new(1, 0, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.new(1, 0.3, 0)),
		ColorSequenceKeypoint.new(1, Color3.new(1, 0.8, 0))
	})
	particle.Texture = "rbxasset://textures/particles/fire_main.dds"
	particle.Rate = 100 * intensity
	particle.Lifetime = NumberRange.new(1, 2)
	particle.Speed = NumberRange.new(10, 20)
	particle.SpreadAngle = Vector2.new(45, 45)
	particle.Parent = aura

	local light = Instance.new("PointLight")
	light.Color = Color3.new(1, 0.2, 0)
	light.Brightness = 3 * intensity
	light.Range = 15 * intensity
	light.Parent = rootPart

	return aura, light
end

-- Función para rugido de tigre
local function tigerRoar(character)
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end

	-- Onda de choque visual épica
	local shockwave = Instance.new("Part")
	shockwave.Name = "RoarShockwave"
	shockwave.Size = Vector3.new(2, 0.5, 2)
	shockwave.Shape = Enum.PartType.Cylinder
	shockwave.Material = Enum.Material.ForceField
	shockwave.BrickColor = BrickColor.new("Really red")
	shockwave.CanCollide = false
	shockwave.Anchored = true
	shockwave.CFrame = rootPart.CFrame * CFrame.Angles(0, 0, math.rad(90))
	shockwave.Transparency = 0.3
	shockwave.Parent = workspace

	-- Expandir dramáticamente
	local expandTween = TweenService:Create(shockwave,
		TweenInfo.new(0.8), {
			Size = Vector3.new(40, 0.5, 40), 
			Transparency = 1
		})
	expandTween:Play()

	-- Partículas de rugido
	local roarEffect = Instance.new("Attachment")
	roarEffect.Parent = rootPart

	local roarParticles = Instance.new("ParticleEmitter")
	roarParticles.Color = ColorSequence.new(Color3.new(1, 0.5, 0))
	roarParticles.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	roarParticles.Rate = 200
	roarParticles.Lifetime = NumberRange.new(0.5, 1.5)
	roarParticles.Speed = NumberRange.new(20, 40)
	roarParticles.SpreadAngle = Vector2.new(90, 90)
	roarParticles.Parent = roarEffect

	spawn(function()
		wait(0.3)
		roarParticles.Enabled = false
		wait(2)
		roarEffect:Destroy()
	end)

	Debris:AddItem(shockwave, 1)
end

-- ========================================
-- 🛠️ FUNCIONES UTILITARIAS
-- ========================================

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

	table.sort(enemies, function(a, b) return a.distance < b.distance end)
	return enemies
end

local function checkCooldown(player, abilityType, cooldownTime)
	local playerId = player.UserId
	if not playerCooldowns[playerId] then
		playerCooldowns[playerId] = {}
	end

	local lastUsed = playerCooldowns[playerId][abilityType] or 0
	local currentTime = tick()

	if currentTime - lastUsed >= cooldownTime then
		playerCooldowns[playerId][abilityType] = currentTime
		return true
	else
		local remainingTime = cooldownTime - (currentTime - lastUsed)
		print("⏰ Cooldown activo para", player.Name, "- Espera", math.ceil(remainingTime), "segundos")
		return false
	end
end

-- ========================================
-- ⚔️ SISTEMA DE COMBATE TIGER ESPECÍFICO
-- ========================================

-- LMB: Garra feroz con sangrado
basicAttackRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then return end

	local stats = getPlayerStats(character)
	if not stats then return end

	-- Solo ejecutar si es TIGER
	if stats.martialStyle.Value ~= "TIGER" then
		print("❌ Esta función es solo para TIGER")
		return
	end

	if not checkCooldown(player, "BasicAttack", 0.8) then return end

	print("🐅 Garra Feroz de", player.Name)

	local nearbyEnemies = findNearbyEnemies(character, CONFIG.ATTACK_RANGE)

	if #nearbyEnemies > 0 then
		local target = nearbyEnemies[1].character
		local targetHumanoid = target:FindFirstChild("Humanoid")
		local targetRootPart = target:FindFirstChild("HumanoidRootPart")

		if targetHumanoid and targetRootPart then
			-- Calcular daño base
			local level = stats.Level.Value
			local fuerza = stats.fuerza.Value
			local baseDamage = CONFIG.BASIC_ATTACK_DAMAGE + (level * 2) + (fuerza * 3)

			-- Bonificación Tiger (20% más damage)
			local tigerDamage = baseDamage * 1.2

			-- PASIVA: Más daño cuando tienes poca vida
			local currentHPPercent = humanoid.Health / humanoid.MaxHealth
			if currentHPPercent <= 0.3 then -- 30% o menos de vida
				tigerDamage = tigerDamage * 1.75 -- +75% damage extra
				print("🐅 PASIVA ACTIVADA: Damage aumentado por vida baja!")
			end

			-- Aplicar daño
			targetHumanoid:TakeDamage(tigerDamage)

			-- Aplicar sangrado (5 damage por 4 segundos)
			applyBleeding(target, 8, 4)

			-- Efectos visuales épicos
			local direction = (targetRootPart.Position - rootPart.Position).Unit
			createTigerClawEffect(targetRootPart.Position, direction, 1.2)
			createBleedEffect(targetRootPart.Position)

			-- XP por golpe
			if _G.GiveXP then
				_G.GiveXP(player, "hit")
				if targetHumanoid.Health <= 0 then
					_G.GiveXP(player, "kill")

					-- CULTIVACIÓN TIGER: Ganar fuerza extra por kills
					local bonusStrength = math.random(1, 3)
					stats.fuerza.Value = stats.fuerza.Value + bonusStrength
					print("🐅 KILL BONUS: +" .. bonusStrength .. " Fuerza! (Total: " .. stats.fuerza.Value .. ")")
				end
			end

			print("🐅 Garra Feroz: " .. math.floor(tigerDamage) .. " damage + sangrado a " .. target.Name)
		end
	else
		print("💨 Garra falló - Sin enemigos en rango")
	end
end)

-- Q: Salto de tigre que atraviesa enemigos
kiBlastRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then return end

	local stats = getPlayerStats(character)
	if not stats or not stats.ki then return end

	-- Solo ejecutar si es TIGER
	if stats.martialStyle.Value ~= "TIGER" then
		print("❌ Esta función es solo para TIGER")
		return
	end

	if not checkCooldown(player, "KiBlast", 2) then return end

	-- Verificar Ki
	if stats.ki.Value < 20 then
		print("❌ Ki insuficiente para Salto de Tigre:", player.Name)
		return
	end

	stats.ki.Value = stats.ki.Value - 20

	print("🐅 SALTO DE TIGRE de", player.Name)

	-- Dirección del salto
	local direction = rootPart.CFrame.LookVector
	local leapDistance = 20

	-- Impulso del salto
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.Velocity = direction * 100 + Vector3.new(0, 30, 0)
	bodyVelocity.Parent = rootPart

	Debris:AddItem(bodyVelocity, 0.4)

	-- Detectar enemigos durante el salto
	spawn(function()
		local hitEnemies = {}

		for i = 1, 15 do
			wait(0.02)
			local currentPos = rootPart.Position

			for _, otherPlayer in pairs(Players:GetPlayers()) do
				if otherPlayer.Character and otherPlayer.Character ~= character and not hitEnemies[otherPlayer] then
					local enemyRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
					local enemyHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")

					if enemyRoot and enemyHumanoid then
						local distance = (currentPos - enemyRoot.Position).Magnitude
						if distance <= 6 then
							hitEnemies[otherPlayer] = true

							-- Damage por atravesar
							local damage = 40 + (stats.fuerza.Value * 2)
							enemyHumanoid:TakeDamage(damage)

							-- Aturdir brevemente
							local originalSpeed = enemyHumanoid.WalkSpeed
							enemyHumanoid.WalkSpeed = 0
							spawn(function()
								wait(1.5)
								if enemyHumanoid then
									enemyHumanoid.WalkSpeed = originalSpeed
								end
							end)

							-- Efectos visuales
							createTigerClawEffect(enemyRoot.Position, direction, 1.8)

							print("🐅 Salto atravesó a " .. otherPlayer.Name .. " por " .. damage .. " damage")
						end
					end
				end
			end
		end
	end)
end)

-- E: Rugido que aturde en área + buff de daño
eAbilityRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then return end

	local stats = getPlayerStats(character)
	if not stats or not stats.ki then return end

	-- Solo ejecutar si es TIGER
	if stats.martialStyle.Value ~= "TIGER" then
		print("❌ Esta función es solo para TIGER")
		return
	end

	-- Verificar nivel
	if stats.Level.Value < 10 then
		print("❌ Nivel insuficiente para Rugido (Requiere nivel 10)")
		return
	end

	if not checkCooldown(player, "EAbility", CONFIG.ABILITY_E_COOLDOWN) then return end

	-- Verificar Ki
	if stats.ki.Value < CONFIG.ABILITY_E_COST then
		print("❌ Ki insuficiente para Rugido:", player.Name)
		return
	end

	stats.ki.Value = stats.ki.Value - CONFIG.ABILITY_E_COST

	print("🐅 RUGIDO BERSERKER de", player.Name)

	-- Efectos visuales del rugido
	tigerRoar(character)

	-- Aturdir enemigos en área (radio 15)
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer.Character and otherPlayer.Character ~= character then
			local enemyRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
			local enemyHumanoid = otherPlayer.Character:FindFirstChild("Humanoid")

			if enemyRoot and enemyHumanoid then
				local distance = (rootPart.Position - enemyRoot.Position).Magnitude
				if distance <= 15 then
					-- Damage + aturdir
					enemyHumanoid:TakeDamage(35)

					local originalSpeed = enemyHumanoid.WalkSpeed
					enemyHumanoid.WalkSpeed = originalSpeed * 0.1 -- Casi paralizado

					spawn(function()
						wait(3) -- 3 segundos de aturdimiento
						if enemyHumanoid then
							enemyHumanoid.WalkSpeed = originalSpeed
						end
					end)

					print("🐅 " .. otherPlayer.Name .. " aterrorizado por el rugido!")
				end
			end
		end
	end

	-- Buff de daño por 15 segundos (+50% damage)
	local buffValue = Instance.new("NumberValue")
	buffValue.Name = "TigerDamageBuff"
	buffValue.Value = 50 -- +50% damage
	buffValue.Parent = rootPart

	-- Aura de poder
	createRageAura(character, 1.5)

	spawn(function()
		wait(15) -- 15 segundos de buff
		if buffValue then buffValue:Destroy() end

		local aura = rootPart:FindFirstChild("TigerRageAura")
		if aura then aura:Destroy() end

		print("🐅 Buff de rugido terminó para " .. player.Name)
	end)
end)

-- R: Modo furia - velocidad +200%, daño +150% por 10s
rAbilityRemote.OnServerEvent:Connect(function(player)
	local character = player.Character
	if not character then return end

	local humanoid = character:FindFirstChild("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart or humanoid.Health <= 0 then return end

	local stats = getPlayerStats(character)
	if not stats or not stats.ki then return end

	-- Solo ejecutar si es TIGER
	if stats.martialStyle.Value ~= "TIGER" then
		print("❌ Esta función es solo para TIGER")
		return
	end

	-- Verificar nivel
	if stats.Level.Value < 25 then
		print("❌ Nivel insuficiente para Modo Furia (Requiere nivel 25)")
		return
	end

	if not checkCooldown(player, "RAbility", CONFIG.ABILITY_R_COOLDOWN) then return end

	-- Verificar Ki
	if stats.ki.Value < CONFIG.ABILITY_R_COST then
		print("❌ Ki insuficiente para Modo Furia:", player.Name)
		return
	end

	stats.ki.Value = stats.ki.Value - CONFIG.ABILITY_R_COST

	print("🐅 MODO FURIA ACTIVADO para", player.Name)

	-- Guardar stats originales
	local originalSpeed = humanoid.WalkSpeed
	local originalJump = humanoid.JumpPower

	-- Aplicar buffs masivos
	humanoid.WalkSpeed = originalSpeed * 3 -- +200% velocidad
	humanoid.JumpPower = originalJump * 2

	-- Buff de daño masivo (+150%)
	local furyBuff = Instance.new("NumberValue")
	furyBuff.Name = "TigerFuryBuff"
	furyBuff.Value = 150 -- +150% damage
	furyBuff.Parent = rootPart

	-- Aura de furia épica
	local aura, light = createRageAura(character, 3)

	-- Efectos durante la furia
	spawn(function()
		for i = 1, 10 do -- 10 segundos
			wait(1)
			if not character.Parent then break end

			-- Regenerar Ki durante la furia
			if stats.Ki then
				stats.Ki.Value = math.min(stats.Ki.Value + 15, stats.MaxKi.Value)
			end

			-- Efecto de pulso de luz
			if light then
				local pulse = TweenService:Create(light, 
					TweenInfo.new(0.3), {Brightness = light.Brightness * 1.8})
				local pulseBack = TweenService:Create(light, 
					TweenInfo.new(0.3), {Brightness = light.Brightness})

				pulse:Play()
				pulse.Completed:Connect(function() pulseBack:Play() end)
			end
		end

		-- Restaurar todo después de 10 segundos
		humanoid.WalkSpeed = originalSpeed
		humanoid.JumpPower = originalJump

		if furyBuff then furyBuff:Destroy() end
		if aura then aura:Destroy() end
		if light then light:Destroy() end

		print("🐅 Modo Furia terminó para " .. player.Name)
	end)
end)

-- ========================================
-- 🔧 COMANDOS DE TESTEO ARREGLADOS
-- ========================================

-- Conectar comandos para jugadores ya en el servidor
for _, player in pairs(Players:GetPlayers()) do
	player.Chatted:Connect(function(message)
		local msg = message:lower()

		if msg == "/tiger" then
			if player.Character then
				local stats = getPlayerStats(player.Character)
				if stats then
					stats.martialStyle.Value = "TIGER"
					stats.ki.Value = 9999
					stats.Level.Value = 50
					stats.fuerza.Value = 50
					print("🐅 " .. player.Name .. " ahora es TIGER con stats altos")
				end
			end

		elseif msg == "/godmode" then
			if player.Character then
				local stats = getPlayerStats(player.Character)
				if stats then
					stats.ki.Value = 9999
					stats.Level.Value = 100
					stats.fuerza.Value = 100
					stats.velocidad.Value = 100
					stats.control.Value = 100
					print("👑 God mode para " .. player.Name)
				end
			end

		elseif msg == "/teste" then
			-- Simular habilidad E
			eAbilityRemote:FireServer()
			print("🧪 Testeando habilidad E para " .. player.Name)

		elseif msg == "/testr" then
			-- Simular habilidad R
			rAbilityRemote:FireServer()
			print("🧪 Testeando habilidad R para " .. player.Name)

		elseif msg == "/stats" then
			if player.Character then
				local stats = getPlayerStats(player.Character)
				if stats then
					print("📊 STATS de " .. player.Name .. ":")
					print("   Estilo: " .. stats.martialStyle.Value)
					print("   Nivel: " .. stats.Level.Value)
					print("   Ki: " .. stats.ki.Value .. "/" .. stats.MaxKi.Value)
					print("   Fuerza: " .. stats.fuerza.Value)
				end
			end
		end
	end)
end

-- Conectar comandos para nuevos jugadores
Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		local msg = message:lower()

		if msg == "/tiger" then
			if player.Character then
				local stats = getPlayerStats(player.Character)
				if stats then
					stats.martialStyle.Value = "TIGER"
					stats.ki.Value = 9999
					stats.Level.Value = 50
					stats.fuerza.Value = 50
					print("🐅 " .. player.Name .. " ahora es TIGER con stats altos")
				end
			end

		elseif msg == "/godmode" then
			if player.Character then
				local stats = getPlayerStats(player.Character)
				if stats then
					stats.ki.Value = 9999
					stats.Level.Value = 100
					stats.fuerza.Value = 100
					stats.velocidad.Value = 100
					stats.control.Value = 100
					print("👑 God mode para " .. player.Name)
				end
			end

		elseif msg == "/teste" then
			eAbilityRemote:FireServer()
			print("🧪 Testeando habilidad E para " .. player.Name)

		elseif msg == "/testr" then
			rAbilityRemote:FireServer()
			print("🧪 Testeando habilidad R para " .. player.Name)

		elseif msg == "/stats" then
			if player.Character then
				local stats = getPlayerStats(player.Character)
				if stats then
					print("📊 STATS de " .. player.Name .. ":")
					print("   Estilo: " .. stats.martialStyle.Value)
					print("   Nivel: " .. stats.Level.Value)
					print("   Ki: " .. stats.ki.Value .. "/" .. stats.MaxKi.Value)
					print("   Fuerza: " .. stats.fuerza.Value)
				end
			end
		end
	end)
end)

-- ========================================
-- 🔋 SISTEMA DE REGENERACIÓN DE KI
-- ========================================

-- Regeneración pasiva de Ki
spawn(function()
	while true do
		wait(3) -- Cada 3 segundos

		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				local stats = getPlayerStats(player.Character)
				if stats and stats.ki and stats.MaxKi then
					local currentKi = stats.ki.Value
					local maxKi = stats.MaxKi.Value

					if currentKi < maxKi then
						-- Regeneración base: 3 Ki cada 3 segundos
						local regenAmount = 3

						-- PASIVA CRANE: Regenera Ki 50% más rápido
						if stats.martialStyle.Value == "CRANE" then
							regenAmount = regenAmount * 1.5
						end

						local newKi = math.min(currentKi + regenAmount, maxKi)
						stats.ki.Value = newKi
					end
				end
			end
		end
	end
end)

-- Integración con sistema de meditación existente
local meditationRemote = remotes:FindFirstChild("Meditation")
if meditationRemote then
	local meditatingPlayers = {}

	meditationRemote.OnServerEvent:Connect(function(player, isStarting)
		local character = player.Character
		if not character then return end

		if isStarting then
			meditatingPlayers[player] = {
				startTime = tick(),
				character = character
			}
			print("🧘 " .. player.Name .. " comenzó a meditar")
		else
			local meditationData = meditatingPlayers[player]
			if meditationData then
				local meditationTime = tick() - meditationData.startTime
				local stats = getPlayerStats(character)

				if stats then
					-- XP por meditación
					local baseXP = math.floor(meditationTime * 5)

					-- CULTIVACIÓN TIGER: Normal (1x XP)
					-- CULTIVACIÓN CRANE: 2x XP por meditación
					local xpMultiplier = 1
					if stats.martialStyle.Value == "CRANE" then
						xpMultiplier = 2

						-- Crane también restaura HP al meditar
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid then
							humanoid.Health = humanoid.MaxHealth
							print("🕊️ CRANE: HP restaurado por meditación")
						end
					end

					local finalXP = baseXP * xpMultiplier

					if _G.GiveXP and finalXP > 0 then
						_G.GiveXP(player, finalXP, "meditation")
					end

					-- Regeneración extra de Ki por meditación
					if stats.ki and stats.MaxKi then
						local kiRegenAmount = math.floor(meditationTime * 8)
						local newKi = math.min(stats.ki.Value + kiRegenAmount, stats.MaxKi.Value)
						stats.ki.Value = newKi
						print("⚡ Ki regenerado: " .. kiRegenAmount)
					end
				end

				meditatingPlayers[player] = nil
			end
			print("🧘 " .. player.Name .. " terminó de meditar")
		end
	end)

	print("✅ Sistema de meditación integrado")
else
	print("⚠️ RemoteEvent 'Meditation' no encontrado")
end

-- Limpiar cooldowns cuando el jugador se va
Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
end)

print("✅ Sistema de Combate con TIGER PERFECTO cargado!")
print("🎮 Comandos de testeo ARREGLADOS:")
print("   /tiger - Convertirse en Tiger con stats altos")
print("   /godmode - Stats máximos")
print("   /teste - Testear habilidad E")
print("   /testr - Testear habilidad R")
print("   /stats - Ver tus estadísticas")
print("🐅 Habilidades TIGER:")
print("   LMB: Garra feroz + sangrado + pasiva vida baja")
print("   Q: Salto de tigre que atraviesa enemigos")
print("   E: Rugido que aturde + buff daño (Lv.10+)")
print("   R: Modo furia +200% speed +150% damage (Lv.25+)")
print("   PASIVA: +75% damage cuando HP < 30%")
print("   CULTIVACIÓN: +1-3 Fuerza por kill")
print("🔋 Sistema de Ki:")
print("   ✅ Regeneración pasiva: 3 Ki cada 3 segundos")
print("   ✅ Regeneración por meditación: 8 Ki por segundo")
print("   ✅ CRANE regenera 50% más rápido")
print("   ✅ CRANE obtiene 2x XP por meditación")
print("=========================================")