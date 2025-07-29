-- TechniquesModule.lua
-- ModuleScript en ReplicatedStorage
-- Define todas las técnicas especiales por estilo marcial

local TechniquesModule = {}
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

-- Función para crear proyectil especial
local function createSpecialProjectile(startPos, direction, config, owner)
	local projectile = Instance.new("Part")
	projectile.Name = config.name or "SpecialProjectile"
	projectile.Size = config.size or Vector3.new(2, 2, 2)
	projectile.Shape = config.shape or Enum.PartType.Ball
	projectile.Material = Enum.Material.Neon
	projectile.BrickColor = config.color or BrickColor.new("Bright blue")
	projectile.CanCollide = false
	projectile.Position = startPos
	projectile.Parent = workspace

	-- Efectos visuales
	if config.light then
		local light = Instance.new("PointLight")
		light.Color = config.light.color or Color3.new(0, 0.5, 1)
		light.Brightness = config.light.brightness or 2
		light.Range = config.light.range or 10
		light.Parent = projectile
	end

	if config.particles then
		local attachment = Instance.new("Attachment")
		attachment.Parent = projectile

		local particle = Instance.new("ParticleEmitter")
		particle.Parent = attachment
		particle.Color = config.particles.color or ColorSequence.new(Color3.new(1, 0.5, 0))
		particle.Texture = config.particles.texture or "rbxasset://textures/particles/fire_main.dds"
		particle.Rate = config.particles.rate or 50
		particle.Lifetime = config.particles.lifetime or NumberRange.new(0.5, 1)
		particle.Speed = config.particles.speed or NumberRange.new(5, 8)
	end

	-- Movimiento
	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(4000, 4000, 4000)
	bodyVelocity.Velocity = direction * (config.speed or 50)
	bodyVelocity.Parent = projectile

	-- Detección de colisión
	local connection
	connection = projectile.Touched:Connect(function(hit)
		local hitCharacter = hit.Parent
		local hitHumanoid = hitCharacter:FindFirstChild("Humanoid")

		if hitCharacter ~= owner and hitHumanoid and hitHumanoid.Health > 0 then
			-- Aplicar daño
			hitHumanoid:TakeDamage(config.damage or 25)

			-- Efectos especiales
			if config.onHit then
				config.onHit(hitCharacter, projectile.Position)
			end

			-- Destruir proyectil
			connection:Disconnect()
			projectile:Destroy()
		end
	end)

	-- Auto-destruir
	Debris:AddItem(projectile, config.lifetime or 5)
	return projectile
end

-- Función para crear área de efecto
local function createAOEEffect(position, config)
	local aoe = Instance.new("Part")
	aoe.Name = "AOEEffect"
	aoe.Size = Vector3.new(0.1, 0.1, 0.1)
	aoe.Position = position
	aoe.Anchored = true
	aoe.CanCollide = false
	aoe.Transparency = 1
	aoe.Parent = workspace

	-- Crear esfera de efecto
	local sphere = Instance.new("Part")
	sphere.Name = "EffectSphere"
	sphere.Size = Vector3.new(1, 1, 1)
	sphere.Shape = Enum.PartType.Ball
	sphere.Material = Enum.Material.ForceField
	sphere.BrickColor = config.color or BrickColor.new("Bright red")
	sphere.CanCollide = false
	sphere.Anchored = true
	sphere.CFrame = CFrame.new(position)
	sphere.Parent = aoe

	-- Animar expansión
	local targetSize = Vector3.new(config.radius * 2, config.radius * 2, config.radius * 2)
	local expandTween = TweenService:Create(sphere, TweenInfo.new(0.3), {Size = targetSize})
	expandTween:Play()

	-- Detectar enemigos en área
	spawn(function()
		wait(0.3) -- Esperar expansión

		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				local character = player.Character
				local humanoid = character:FindFirstChild("Humanoid")
				local rootPart = character:FindFirstChild("HumanoidRootPart")

				if humanoid and rootPart and humanoid.Health > 0 then
					local distance = (position - rootPart.Position).Magnitude
					if distance <= config.radius then
						-- Aplicar efecto
						if config.onHit then
							config.onHit(character)
						end
					end
				end
			end
		end

		-- Efecto de desvanecimiento
		local fadeTween = TweenService:Create(sphere, TweenInfo.new(0.5), {Transparency = 1})
		fadeTween:Play()
		fadeTween.Completed:Connect(function()
			aoe:Destroy()
		end)
	end)
end

-- Función para dash/teletransporte
local function performDash(character, distance, direction)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	local targetPosition = humanoidRootPart.Position + (direction * distance)

	-- Efecto visual de inicio
	local startEffect = Instance.new("Explosion")
	startEffect.Position = humanoidRootPart.Position
	startEffect.BlastRadius = 5
	startEffect.BlastPressure = 0
	startEffect.Visible = false
	startEffect.Parent = workspace

	-- Teletransportar
	humanoidRootPart.CFrame = CFrame.new(targetPosition, targetPosition + direction)

	-- Efecto visual de llegada
	local endEffect = Instance.new("Explosion")
	endEffect.Position = targetPosition
	endEffect.BlastRadius = 5
	endEffect.BlastPressure = 0
	endEffect.Visible = false
	endEffect.Parent = workspace
end

-- TÉCNICAS POR ESTILO MARCIAL

-- Técnicas TIGER
local TIGER_TECHNIQUES = {
	E = function(character, caster)
		-- Tiger Claw - Ataque en área frontal
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local frontPosition = rootPart.Position + rootPart.CFrame.LookVector * 8

		createAOEEffect(frontPosition, {
			radius = 6,
			color = BrickColor.new("Bright orange"),
			onHit = function(hitCharacter)
				local humanoid = hitCharacter:FindFirstChild("Humanoid")
				if humanoid and hitCharacter ~= character then
					humanoid:TakeDamage(45)
					print("🐅 Tiger Claw golpeó a", hitCharacter.Name)
				end
			end
		})
	end,

	R = function(character, caster)
		-- Roar of Rage - Aturde enemigos cercanos
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		createAOEEffect(rootPart.Position, {
			radius = 10,
			color = BrickColor.new("Really red"),
			onHit = function(hitCharacter)
				local humanoid = hitCharacter:FindFirstChild("Humanoid")
				if humanoid and hitCharacter ~= character then
					humanoid:TakeDamage(30)
					-- Efecto de miedo (ralentizar temporalmente)
					humanoid.WalkSpeed = humanoid.WalkSpeed * 0.5
					spawn(function()
						wait(3)
						humanoid.WalkSpeed = humanoid.WalkSpeed * 2
					end)
					print("🐅 Roar of Rage aterroriza a", hitCharacter.Name)
				end
			end
		})
	end,

	Ultimate = function(character, caster)
		-- Devastating Strike - Combo devastador
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		-- Múltiples ataques en secuencia
		for i = 1, 5 do
			spawn(function()
				wait(i * 0.2)
				local position = rootPart.Position + rootPart.CFrame.LookVector * (i * 3)
				createAOEEffect(position, {
					radius = 4,
					color = BrickColor.new("Neon orange"),
					onHit = function(hitCharacter)
						local humanoid = hitCharacter:FindFirstChild("Humanoid")
						if humanoid and hitCharacter ~= character then
							humanoid:TakeDamage(25)
						end
					end
				})
			end)
		end
	end
}

-- Técnicas CRANE
local CRANE_TECHNIQUES = {
	E = function(character, caster)
		-- Thousand Feathers - Múltiples proyectiles
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		for i = 1, 8 do
			local angle = (i - 1) * (math.pi * 2 / 8)
			local direction = Vector3.new(math.cos(angle), 0, math.sin(angle))

			spawn(function()
				wait(i * 0.1)
				createSpecialProjectile(rootPart.Position + Vector3.new(0, 2, 0), direction, {
					name = "Feather",
					size = Vector3.new(1, 0.2, 3),
					shape = Enum.PartType.Block,
					color = BrickColor.new("White"),
					speed = 40,
					damage = 20,
					particles = {
						color = ColorSequence.new(Color3.new(1, 1, 1)),
						texture = "rbxasset://textures/particles/sparkles_main.dds",
						rate = 30
					}
				}, character)
			end)
		end
	end,

	R = function(character, caster)
		-- Celestial Flight - Dash con curación
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not humanoid then return end

		-- Dash hacia adelante
		performDash(character, 20, rootPart.CFrame.LookVector)

		-- Curación
		local healAmount = humanoid.MaxHealth * 0.3
		humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)

		-- Efecto visual de curación
		local attachment = Instance.new("Attachment")
		attachment.Parent = rootPart

		local particle = Instance.new("ParticleEmitter")
		particle.Parent = attachment
		particle.Color = ColorSequence.new(Color3.new(0, 1, 0.5))
		particle.Texture = "rbxasset://textures/particles/sparkles_main.dds"
		particle.Rate = 100
		particle.Lifetime = NumberRange.new(1, 2)
		particle.Speed = NumberRange.new(5, 10)

		Debris:AddItem(attachment, 3)
		print("🕊️ Celestial Flight curó a", character.Name)
	end,

	Ultimate = function(character, caster)
		-- Graceful Storm - Tormenta de ataques aéreos
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		-- Elevar al jugador temporalmente
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
		bodyPosition.Position = rootPart.Position + Vector3.new(0, 20, 0)
		bodyPosition.Parent = rootPart

		-- Crear múltiples ataques desde arriba
		for i = 1, 15 do
			spawn(function()
				wait(i * 0.3)
				local randomPos = rootPart.Position + Vector3.new(
					math.random(-15, 15), -5, math.random(-15, 15)
				)
				createAOEEffect(randomPos, {
					radius = 5,
					color = BrickColor.new("Cyan"),
					onHit = function(hitCharacter)
						local humanoid = hitCharacter:FindFirstChild("Humanoid")
						if humanoid and hitCharacter ~= character then
							humanoid:TakeDamage(35)
						end
					end
				})
			end)
		end

		-- Bajar después de 5 segundos
		spawn(function()
			wait(5)
			bodyPosition:Destroy()
		end)
	end
}

-- Técnicas DRAGON
local DRAGON_TECHNIQUES = {
	E = function(character, caster)
		-- Dragon Fist - Proyectil de fuego masivo
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local direction = rootPart.CFrame.LookVector
		createSpecialProjectile(rootPart.Position + direction * 3, direction, {
			name = "DragonFist",
			size = Vector3.new(4, 4, 4),
			color = BrickColor.new("Bright red"),
			speed = 60,
			damage = 55,
			light = {
				color = Color3.new(1, 0.5, 0),
				brightness = 3,
				range = 15
			},
			particles = {
				color = ColorSequence.new(Color3.new(1, 0.2, 0)),
				texture = "rbxasset://textures/particles/fire_main.dds",
				rate = 100,
				lifetime = NumberRange.new(0.8, 1.5),
				speed = NumberRange.new(8, 12)
			},
			onHit = function(hitCharacter, position)
				-- Explosión de fuego
				createAOEEffect(position, {
					radius = 8,
					color = BrickColor.new("Bright orange"),
					onHit = function(character)
						local humanoid = character:FindFirstChild("Humanoid")
						if humanoid then
							humanoid:TakeDamage(20) -- Daño adicional por explosión
						end
					end
				})
			end
		}, character)
	end,

	R = function(character, caster)
		-- Fire Breath - Cono de fuego
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		-- Crear múltiples proyectiles en cono
		for i = -2, 2 do
			for j = 1, 3 do
				local angle = math.rad(i * 15) -- Ángulos de -30 a 30 grados
				local direction = rootPart.CFrame:VectorToWorldSpace(Vector3.new(
					math.sin(angle), 0, math.cos(angle)
					))

				spawn(function()
					wait(j * 0.1)
					createSpecialProjectile(rootPart.Position + direction * 2, direction, {
						name = "FireBreath",
						size = Vector3.new(2, 2, 2),
						color = BrickColor.new("Bright orange"),
						speed = 30 + (j * 10),
						damage = 25,
						lifetime = 2,
						particles = {
							color = ColorSequence.new(Color3.new(1, 0.5, 0)),
							texture = "rbxasset://textures/particles/fire_main.dds",
							rate = 80
						}
					}, character)
				end)
			end
		end
	end,

	Ultimate = function(character, caster)
		-- Ancestral Rage - Transformación temporal
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChild("Humanoid")
		if not rootPart or not humanoid then return end

		-- Aura de dragón
		local aura = Instance.new("Attachment")
		aura.Name = "DragonAura"
		aura.Parent = rootPart

		local particle = Instance.new("ParticleEmitter")
		particle.Parent = aura
		particle.Color = ColorSequence.new(Color3.new(1, 0, 0))
		particle.Texture = "rbxasset://textures/particles/fire_main.dds"
		particle.Rate = 150
		particle.Lifetime = NumberRange.new(1, 3)
		particle.Speed = NumberRange.new(10, 20)

		-- Buff temporal
		local originalWalkSpeed = humanoid.WalkSpeed
		local originalJumpPower = humanoid.JumpPower

		humanoid.WalkSpeed = originalWalkSpeed * 1.5
		humanoid.JumpPower = originalJumpPower * 1.5

		-- Ataques automáticos
		spawn(function()
			for i = 1, 10 do
				wait(0.5)
				if not character.Parent then break end

				-- Buscar enemigo más cercano
				local nearestEnemy = nil
				local nearestDistance = math.huge

				for _, player in pairs(Players:GetPlayers()) do
					if player.Character and player.Character ~= character then
						local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
						if distance < nearestDistance and distance <= 30 then
							nearestDistance = distance
							nearestEnemy = player.Character
						end
					end
				end

				if nearestEnemy then
					local direction = (nearestEnemy.HumanoidRootPart.Position - rootPart.Position).Unit
					createSpecialProjectile(rootPart.Position, direction, {
						name = "DragonRage",
						size = Vector3.new(3, 3, 3),
						color = BrickColor.new("Really red"),
						speed = 80,
						damage = 40,
						particles = {
							color = ColorSequence.new(Color3.new(1, 0, 0)),
							texture = "rbxasset://textures/particles/fire_main.dds",
							rate = 120
						}
					}, character)
				end
			end

			-- Restaurar stats originales
			humanoid.WalkSpeed = originalWalkSpeed
			humanoid.JumpPower = originalJumpPower
			aura:Destroy()
		end)
	end
}

-- Técnicas PHOENIX (Estilo raro)
local PHOENIX_TECHNIQUES = {
	E = function(character, caster)
		-- Reborn Flames - Curación en área
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		createAOEEffect(rootPart.Position, {
			radius = 12,
			color = BrickColor.new("Bright yellow"),
			onHit = function(hitCharacter)
				local humanoid = hitCharacter:FindFirstChild("Humanoid")
				if humanoid then
					if hitCharacter == character then
						-- Curación mayor para el caster
						local healAmount = humanoid.MaxHealth * 0.5
						humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)
					else
						-- Daño a enemigos o curación menor a aliados (simplificado: solo curación)
						local healAmount = humanoid.MaxHealth * 0.2
						humanoid.Health = math.min(humanoid.Health + healAmount, humanoid.MaxHealth)
					end
					print("🔥 Phoenix Flames afectó a", hitCharacter.Name)
				end
			end
		})
	end,

	R = function(character, caster)
		-- Healing Light - Resurrección
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid then return end

		-- Curación completa
		humanoid.Health = humanoid.MaxHealth

		-- Inmunidad temporal
		spawn(function()
			local originalTakeDamage = humanoid.TakeDamage
			humanoid.TakeDamage = function() end -- Inmune al daño

			wait(3) -- 3 segundos de inmunidad
			humanoid.TakeDamage = originalTakeDamage
		end)

		print("✨ Phoenix se regeneró completamente")
	end,

	Ultimate = function(character, caster)
		-- Inferno Wings - Vuelo y lluvia de fuego
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		-- Vuelo
		local bodyPosition = Instance.new("BodyPosition")
		bodyPosition.MaxForce = Vector3.new(4000, 4000, 4000)
		bodyPosition.Position = rootPart.Position + Vector3.new(0, 25, 0)
		bodyPosition.Parent = rootPart

		-- Lluvia de meteoritos de fuego
		for i = 1, 20 do
			spawn(function()
				wait(i * 0.2)
				local randomPos = rootPart.Position + Vector3.new(
					math.random(-20, 20), 0, math.random(-20, 20)
				)

				createSpecialProjectile(rootPart.Position, (randomPos - rootPart.Position).Unit, {
					name = "PhoenixMeteor",
					size = Vector3.new(3, 3, 3),
					color = BrickColor.new("Bright yellow"),
					speed = 50,
					damage = 45,
					onHit = function(hitCharacter, position)
						createAOEEffect(position, {
							radius = 6,
							color = BrickColor.new("Bright orange"),
							onHit = function(character)
								local humanoid = character:FindFirstChild("Humanoid")
								if humanoid then
									humanoid:TakeDamage(25)
								end
							end
						})
					end
				}, character)
			end)
		end

		-- Bajar después de 6 segundos
		spawn(function()
			wait(6)
			bodyPosition:Destroy()
		end)
	end
}

-- Técnicas VOID (Estilo legendario)
local VOID_TECHNIQUES = {
	E = function(character, caster)
		-- Void Slash - Corte dimensional
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local direction = rootPart.CFrame.LookVector

		-- Crear línea de corte
		for i = 1, 15 do
			spawn(function()
				wait(i * 0.05)
				local position = rootPart.Position + (direction * i * 2)
				createAOEEffect(position, {
					radius = 3,
					color = BrickColor.new("Really black"),
					onHit = function(hitCharacter)
						local humanoid = hitCharacter:FindFirstChild("Humanoid")
						if humanoid and hitCharacter ~= character then
							humanoid:TakeDamage(60) -- Daño muy alto
							print("🌌 Void Slash cortó a", hitCharacter.Name)
						end
					end
				})
			end)
		end
	end,

	R = function(character, caster)
		-- Teleport - Teletransporte a cursor
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		-- Buscar jugador más cercano para teletransportarse detrás
		local nearestEnemy = nil
		local nearestDistance = math.huge

		for _, player in pairs(Players:GetPlayers()) do
			if player.Character and player.Character ~= character then
				local distance = (player.Character.HumanoidRootPart.Position - rootPart.Position).Magnitude
				if distance < nearestDistance and distance <= 50 then
					nearestDistance = distance
					nearestEnemy = player.Character
				end
			end
		end

		if nearestEnemy then
			local enemyRoot = nearestEnemy:FindFirstChild("HumanoidRootPart")
			if enemyRoot then
				-- Teletransportarse detrás del enemigo
				local behindPosition = enemyRoot.Position - enemyRoot.CFrame.LookVector * 5
				performDash(character, 0, Vector3.new(0, 0, 0)) -- Efecto visual
				rootPart.CFrame = CFrame.new(behindPosition, enemyRoot.Position)

				print("🌌 Void Teleport detrás de", nearestEnemy.Name)
			end
		end
	end,

	Ultimate = function(character, caster)
		-- Dimension Rift - Crear agujero negro
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		if not rootPart then return end

		local riftPosition = rootPart.Position + rootPart.CFrame.LookVector * 10

		-- Crear agujero negro visual
		local rift = Instance.new("Part")
		rift.Name = "DimensionRift"
		rift.Size = Vector3.new(1, 1, 1)
		rift.Shape = Enum.PartType.Ball
		rift.Material = Enum.Material.Neon
		rift.BrickColor = BrickColor.new("Really black")
		rift.CanCollide = false
		rift.Anchored = true
		rift.CFrame = CFrame.new(riftPosition)
		rift.Parent = workspace

		-- Expandir el agujero negro
		local expandTween = TweenService:Create(rift, TweenInfo.new(2), {Size = Vector3.new(20, 20, 20)})
		expandTween:Play()

		-- Atraer y dañar enemigos durante 5 segundos
		spawn(function()
			for duration = 1, 50 do -- 5 segundos
				wait(0.1)

				for _, player in pairs(Players:GetPlayers()) do
					if player.Character and player.Character ~= character then
						local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
						local enemyHumanoid = player.Character:FindFirstChild("Humanoid")

						if enemyRoot and enemyHumanoid then
							local distance = (riftPosition - enemyRoot.Position).Magnitude
							if distance <= 25 then
								-- Atraer hacia el agujero negro
								local direction = (riftPosition - enemyRoot.Position).Unit
								local pullForce = 50 - distance -- Más cerca = más fuerza

								local bodyVelocity = enemyRoot:FindFirstChild("VoidPull")
								if not bodyVelocity then
									bodyVelocity = Instance.new("BodyVelocity")
									bodyVelocity.Name = "VoidPull"
									bodyVelocity.MaxForce = Vector3.new(4000, 0, 4000)
									bodyVelocity.Parent = enemyRoot
								end

								bodyVelocity.Velocity = direction * pullForce

								-- Daño continuo si está muy cerca
								if distance <= 10 then
									enemyHumanoid:TakeDamage(5)
								end
							end
						end
					end
				end
			end

			-- Limpiar efectos
			for _, player in pairs(Players:GetPlayers()) do
				if player.Character then
					local bodyVel = player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChild("VoidPull")
					if bodyVel then bodyVel:Destroy() end
				end
			end

			-- Explosión final
			createAOEEffect(riftPosition, {
				radius = 30,
				color = BrickColor.new("Dark stone grey"),
				onHit = function(hitCharacter)
					local humanoid = hitCharacter:FindFirstChild("Humanoid")
					if humanoid and hitCharacter ~= character then
						humanoid:TakeDamage(80) -- Daño masivo final
					end
				end
			})

			rift:Destroy()
		end)
	end
}

-- Función principal para ejecutar técnicas
function TechniquesModule:ExecuteTechnique(character, martialStyle, techniqueType)
	local techniques = {
		TIGER = TIGER_TECHNIQUES,
		CRANE = CRANE_TECHNIQUES,
		DRAGON = DRAGON_TECHNIQUES,
		PHOENIX = PHOENIX_TECHNIQUES,
		VOID = VOID_TECHNIQUES
	}

	local styleTable = techniques[martialStyle]
	if styleTable and styleTable[techniqueType] then
		styleTable[techniqueType](character)
		print("⚡ Ejecutando técnica", techniqueType, "del estilo", martialStyle)
	else
		print("❌ Técnica no encontrada:", martialStyle, techniqueType)
	end
end

return TechniquesModule