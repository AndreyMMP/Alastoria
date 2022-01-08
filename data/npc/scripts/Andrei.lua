local keywordHandler = KeywordHandler:new()
local npcHandler = NpcHandler:new(keywordHandler)
NpcSystem.parseParameters(npcHandler)

local vocation = {}
local town = {}
local destination = {}
local mensagensIniciais = 
{
"Olá, você deve ser o novato que o rei disse que chegaria, você está atrasado…", 
"Seu treinamento precisa começar imediatamente.", "Vejo que você não possui nenhum equipamento, correto?", 
"Você deve procurar um {mentor} que mais combine com seu estilo de batalha, ele irá proporcionar o que você precisa para iniciar sua aventura.", 
"Em seguida você deve procurar por {Elliot} para descobrir qual será sua primeira tarefa de treinamento."
}

function onCreatureAppear(cid)              npcHandler:onCreatureAppear(cid)            end
function onCreatureDisappear(cid)           npcHandler:onCreatureDisappear(cid)         end
function onCreatureSay(cid, type, msg)      npcHandler:onCreatureSay(cid, type, msg)    end
function onThink()                          npcHandler:onThink()                        end

function selfSayDelay(messages, interval, cid)
	for i = 2, #messages do
		addEvent(doCreatureSay, interval * i, getNpcCid(), messages[i], TALKTYPE_PRIVATE_NP) 		
	end
end

local function greetCallback(cid)
	if(getPlayerStorageValue(cid,9001)~=1) then		
		setPlayerStorageValue(cid, 9001, 1) 
		selfSay(mensagensIniciais[1], cid)
		selfSayDelay(mensagensIniciais, 2500, cid)	
	return false
	else
		selfSay("Você já deveria ter ido procurar um {mentor}.", cid)
	return true		
	end
	return true
end

local function creatureSayCallback(cid, type, msg)
	if not npcHandler:isFocused(cid) then
		return false
	end

	if msgcontains(msg, "mentor") and npcHandler.topic[cid] == 0 then
		npcHandler:say("Nossos mentores são {Kizzie}, {Balmur}, {Amisha} e {Zurir}.", cid)
		npcHandler.topic[cid] = 1
	elseif npcHandler.topic[cid] == 1 then
		if msgcontains(msg, "Kizzie") then						
			npcHandler:say("Kizzie poderá te orientar se você preferir combate à distância. Adicionei uma marcação em seu mapa.", cid)			
			doPlayerAddMapMark(cid, { x = 1104, y = 979, z = 7 }, 2, "Kizzie")
			-- npcHandler.topic[cid] = 2
		elseif msgcontains(msg, "Balmur") then
			npcHandler:say("Se você prefere combate corpo a corpo, Balmur poderá te orientar. Adicionei uma marcação em seu mapa.", cid)
			doPlayerAddMapMark(cid, { x = 1076, y = 951, z = 7 }, 2, "Balmur")
		elseif msgcontains(msg, "Amisha") then
			npcHandler:say("Amisha ensina sobre artes mágicas de suporte e cura. Adicionei uma marcação em seu mapa.", cid)
			doPlayerAddMapMark(cid, { x = 1076, y = 951, z = 7 }, 2, "Amisha")
		elseif msgcontains(msg, "Zurir") then
			npcHandler:say("Zurir pode te ensinar sobre magias ofensivas. Adicionei uma marcação em seu mapa.", cid)
			doPlayerAddMapMark(cid, { x = 1076, y = 951, z = 7 }, 2, "Zurir")
		end
	elseif npcHandler.topic[cid] == 2 then
		if msgcontains(msg, "sorcerer") then
			npcHandler:say("A SORCERER! ARE YOU SURE? THIS DECISION IS IRREVERSIBLE!", cid)
			npcHandler.topic[cid] = 3
			vocation[cid] = 1
		elseif msgcontains(msg, "druid") then
			npcHandler:say("A DRUID! ARE YOU SURE? THIS DECISION IS IRREVERSIBLE!", cid)
			npcHandler.topic[cid] = 3
			vocation[cid] = 2
		elseif msgcontains(msg, "paladin") then
			npcHandler:say("A PALADIN! ARE YOU SURE? THIS DECISION IS IRREVERSIBLE!", cid)
			npcHandler.topic[cid] = 3
			vocation[cid] = 3
		elseif msgcontains(msg, "knight") then
			npcHandler:say("A KNIGHT! ARE YOU SURE? THIS DECISION IS IRREVERSIBLE!", cid)
			npcHandler.topic[cid] = 3
			vocation[cid] = 4
		else
			npcHandler:say("{KNIGHT}, {PALADIN}, {SORCERER}, OR {DRUID}?", cid)
		end
	elseif npcHandler.topic[cid] == 3 then
		if msgcontains(msg, "yes") then
			local player = Player(cid)
			npcHandler:say("SO BE IT!", cid)
			player:setVocation(Vocation(vocation[cid]))
			player:setTown(Town(town[cid]))

			local destination = destination[cid]
			npcHandler:releaseFocus(cid)
			player:teleportTo(destination)
			player:getPosition():sendMagicEffect(CONST_ME_TELEPORT)
			destination:sendMagicEffect(CONST_ME_TELEPORT)
		else
			npcHandler:say("THEN WHAT? {KNIGHT}, {PALADIN}, {SORCERER}, OR {DRUID}?", cid)
			npcHandler.topic[cid] = 2
		end
	end
	return true
end

local function onAddFocus(cid)
	town[cid] = 0
	vocation[cid] = 0
	destination[cid] = 0
end

local function onReleaseFocus(cid)
	town[cid] = nil
	vocation[cid] = nil
	destination[cid] = nil
end

npcHandler:setCallback(CALLBACK_ONADDFOCUS, onAddFocus)
npcHandler:setCallback(CALLBACK_ONRELEASEFOCUS, onReleaseFocus)

npcHandler:setCallback(CALLBACK_GREET, greetCallback)
npcHandler:setCallback(CALLBACK_MESSAGE_DEFAULT, creatureSayCallback)
npcHandler:addModule(FocusModule:new())
