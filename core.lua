-- Looks ugly when lower than 23
local BAR_HEIGHT = 23;

-- Background alpha (range from 0 to 1)
local BACKGROUND_ALPHA = 0.75

--[[ Permanent aura bars
	1 filled 		
	0 empty
]]--
local PERMANENT_AURA_VALUE  = 1

--[[ Layouts
	1 - both player and target buffs in one frame right above player frame
	2 - player and target buffs separated into two frames above player frame
]]--
local LAYOUT = 2

-- Global filter - mostly for trinket procs, delete or wrap into comment block --[[  ]] if you dont want to track those
local GLOBAL_FILTER = {
--		71432, -- Mote of Anger
--		72412, -- Frostforged Champion
		67703, 67708, 67772, 67773, -- Death Choice
	};
	
--[[ Class specific filters

Examples:

	Track "Frost Fever" and "Blood Plague" on target and "Bone Shield" on player:
	
		DEATHKNIGHT = { 
			target = { 
				"Frost Fever",
				"Blood Plague",
			},
			player = { 
				"Bone Shield",
			}
		},

	Track "Frost Fever" and "Blood Plague" on target and nothing on player:
	
		DEATHKNIGHT = { 
			target = { 
				"Frost Fever",
				"Blood Plague",
			},
		},

	Track nothing on target and nothing on player:
	
		DEATHKNIGHT = { 

		},
		
	or
	
				
		
		( ^^^ yes nothing ^^^ )
]]--
local CLASS_FILTERS = {
		DEATHKNIGHT = { 
			target = { 
				55095, -- Frost Fever
				55078, -- Blood Plague
			},
			player = { 
				49222, -- Bone Shield
			}
		},
		DRUID = { 
			target = { 
				48468, -- Insect Swarm
				48463, -- Moonfire
			},
			player = { 
				16870, -- Clearcasting
				48518, -- Eclipse starfire
				48517, -- Eclipse wrath
				53201, -- Starfall
			},
		},
		HUNTER = { 
			target = {
				49001, -- Serpent Sting
				63672, -- Black Arrow
			},
			player = {
				56453, -- Lock and Load
				34074, -- Aspect of the Viper
			},
		},
		MAGE = {
			target = { },
			player = { },
		},
		PALADIN = { 
			target = {
				31803, -- Holy Vengeance (Aliance)
				53742, -- Blood Corruption (Horde)
				61840, -- Righteous Vengeance
				20066, -- Repentance
				53563, -- Beacon of Light
				10308, -- Hammer of Justice
			},
			player = {
				642, -- Divine Shield
				498, -- Divine Protection
				31884, -- Avenging Wrath
				53601, -- Sacred Shield
				54428, -- Divine Plea
				53488, -- The Art of War
				71187, -- Libram of Three Truths
				25771, -- Debuff: Forbearance
			},
		},
		PRIEST = { 
			target = { 
				48066, -- Power Word: Shield
				6788, -- Weakened Soul
				48068, -- Renew
				48111, -- Prayer of Mending
				552, -- Abolish Disease
				33206, -- Pain Suppression
				10060, -- Power Infusion
				48160, -- Vampiric Touch
				48125, -- Shadow Word: Pain
				48300, -- Devouring Plague
			},
			player = {
				48168, -- Inner Fire
			},
		},
		ROGUE = { 
			target = { },
			player = { },
		},
		SHAMAN = {
			target = { },
			player = { },
		},
		WARLOCK = { 
			target = { },
			player = { },
		},
		WARRIOR = { 
			target = { },
			player = { },
		},
	};

local CreateUnitAuraDataSource;
do
	-- private
	local CheckFilter = function( self, id, filter )
		if ( filter == nil ) then return false; end
	
		for _, v in ipairs( filter ) do
			if ( v == id ) then return true; end
		end
		
		return false;
	end
	
	local CheckUnit = function( self, unit, filter, result )
		if ( not UnitExists( unit ) ) then return 0; end
	
		local count = 0;
	
		for _, auraType in ipairs( { "HELPFUL", "HARMFUL" } ) do
			for index = 1, 40 do
				local name, rank, texture, stacks, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura( unit, index, auraType );		
				if ( name == nil ) then
					break;
				end
				
				if ( unitCaster == "player" or unitCaster == "pet" or unitCaster == "vehicle" ) then
					local globalFilter = ( self.unit ~= "target" or unit ~= "player" or not UnitIsUnit( "player", "target" ) ) and CheckFilter( self, spellId, self.globalFilter );
					if ( globalFilter or CheckFilter( self, spellId, filter ) ) then 
						tinsert( result, { name = name, texture = texture, duration = duration, expirationTime = expirationTime, stacks = stacks } );
						count = count + 1;
					end
				end
			end
		end
		
		return count;
	end

	-- public 
	local Update = function( self )
		result = { };
		count = 0;
		
		count = count + CheckUnit( self, self.unit, self.filter, result );
		if ( self.includePlayer ) then
			count = count + CheckUnit( self, "player", self.playerFilter, result );
		end
		
		self.count = count;
		self.table = result
	end

	local SetSortDirection = function( self, descending )
		self.sortDirection = descending;
	end
	
	local GetSortDirection = function( self )
		return self.sortDirection;
	end
	
	local Sort = function( self )
		local direction = self.sortDirection;
		local time = GetTime();
	
		local sorted;
		repeat
			sorted = true;
			for key, value in pairs( self.table ) do
				local nextKey = key + 1;
				local nextValue = self.table[ nextKey ];
				if ( nextValue == nil ) then break; end
				
				local currentRemaining = value.expirationTime == 0 and 4294967295 or math.max( value.expirationTime - time, 0 );
				local nextRemaining = nextValue.expirationTime == 0 and 4294967295 or math.max( nextValue.expirationTime - time, 0 );
				
				if ( ( direction and currentRemaining < nextRemaining ) or ( not direction and currentRemaining > nextRemaining ) ) then
					self.table[ key ] = nextValue;
					self.table[ nextKey ] = value;
					sorted = false;
				end				
			end			
		until ( sorted == true )
	end
	
	local Get = function( self )
		return self.table;
	end
	
	local Count = function( self )
		return self.count;
	end
	
	local SetFilter = function( self, filter )
		self.filter = filter;
	end
	
	local SetPlayerFilter = function( self, filter )
		self.playerFilter = filter;
	end
	
	local SetGlobalFilter = function( self, filter )
		self.globalFilter = filter;
	end
	
	local GetUnit = function( self )
		return self.unit;
	end
	
	local GetIncludePlayer = function( self )
		return self.includePlayer;
	end
	
	local SetIncludePlayer = function( self, value )
		self.includePlayer = value;
	end
	
	-- constructor
	CreateUnitAuraDataSource = function( unit )
		local result = { Sort = Sort, Update = Update, Get = Get, Count = Count, SetSortDirection = SetSortDirection, GetSortDirection = GetSortDirection, SetFilter = SetFilter, SetPlayerFilter = SetPlayerFilter, SetGlobalFilter = SetGlobalFilter, GetUnit = GetUnit, SetIncludePlayer = SetIncludePlayer, GetIncludePlayer = GetIncludePlayer, unit = unit, includePlayer = false };
		result:SetSortDirection( true );
		result:Update();
		result:Sort();
		return result;
	end
end

local CreateAuraBarFrame;
do
	-- classes
	local CreateAuraBar;
	do
		-- private 
		local OnUpdate = function( self, elapsed )	
			local time = GetTime();
		
			if ( time > self.expirationTime ) then
				self.bar:SetScript( "OnUpdate", nil );
				self.bar:SetValue( 0 );
				self.time:SetText( "" );
			else
				local remaining = self.expirationTime - time;
				self.bar:SetValue( remaining );
				
				local timeText = "";
				if ( remaining >= 3600 ) then
					timeText = tostring( math.floor( remaining / 3600 ) ) .. "h";
				elseif ( remaining >= 60 ) then
					timeText = tostring( math.floor( remaining / 60 ) ) .. "m";
				elseif ( remaining > 1 ) then
					timeText = tostring( math.floor( remaining ) );
				elseif ( remaining > 0 ) then
					timeText = tostring( math.floor( remaining * 10 ) / 10 );
				end
				self.time:SetText( timeText );
			end
		end
		
		-- public
		local SetIcon = function( self, icon )
			self.icon:SetTexture( icon );
		end
		
		local SetTime = function( self, expirationTime, duration )
			self.expirationTime = expirationTime;
			self.duration = duration;
			
			if ( expirationTime > 0 and duration > 0 ) then		
				self.bar:SetMinMaxValues( 0, duration );
				OnUpdate( self, 0 );
		
				self:SetScript( "OnUpdate", OnUpdate );
			else
				self.bar:SetMinMaxValues( 0, 1 );
				self.bar:SetValue( PERMANENT_AURA_VALUE );
				self.time:SetText( "" );
				
				self:SetScript( "OnUpdate", nil );
			end
		end
		
		local SetName = function( self, name )
			self.name:SetText( name );
		end
		
		local SetStacks = function( self, stacks )
			if ( stacks ~= nil and stacks > 0 ) then
				self.stacks:SetText( stacks );
			else
				self.stacks:SetText( "" );
			end
		end
		
		local SetAuraInfo = function( self, auraInfo )
			self:SetName( auraInfo.name );
			self:SetIcon( auraInfo.texture );	
			self:SetTime( auraInfo.expirationTime, auraInfo.duration );
			self:SetStacks( auraInfo.stacks );
		end
		
		-- constructor
		CreateAuraBar = function( parent )
			local result = CreateFrame( "Frame", nil, parent, nil );
		
			local icon = result:CreateTexture( nil, "ARTWORK", nil );
			icon:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
			icon:SetPoint( "BOTTOMRIGHT", result, "TOPLEFT", BAR_HEIGHT, -BAR_HEIGHT );
			result.icon = icon;
			
			local iconOverlay = result:CreateTexture( nil, "OVERLAY", nil );
			iconOverlay:SetPoint( "TOPLEFT", icon, "TOPLEFT", -1.5, 1 );
			iconOverlay:SetPoint( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1 );
			iconOverlay:SetTexture( [=[Interface\Addons\Tukui\media\buttonTex]=] );
			iconOverlay:SetVertexColor( 1, 1, 1 );
			result.icon.overlay = iconOverlay;		
		
			local bar = CreateFrame( "StatusBar", nil, result, nil );
			bar:SetStatusBarTexture( [=[Interface\Addons\Tukui\media\normTex]=] );
			bar:SetPoint( "TOPLEFT", result.icon, "TOPRIGHT", 1, -1 );
			bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
			result.bar = bar;
			
			local name = bar:CreateFontString( nil, "OVERLAY", nil );
			name:SetFont( [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=], 12, "OUTLINE" );
			name:SetJustifyH( "LEFT" );
			name:SetShadowColor( 0, 0, 0 );
			name:SetShadowOffset( 1.25, -1.25 );
			name:SetPoint( "TOPLEFT", bar, "TOPLEFT", 0, 0 );
			name:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -40, 2 );
			result.name = name;
			
			local time = bar:CreateFontString( nil, "OVERLAY", nil );
			time:SetFont( [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=], 12, "OUTLINE" );
			time:SetJustifyH( "RIGHT" );
			time:SetShadowColor( 0, 0, 0 );
			time:SetShadowOffset( 1.25, -1.25 );
			time:SetPoint( "TOPLEFT", name, "TOPRIGHT", 0, 0 );
			time:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 2 );
			result.time = time;
			
			local stacks = result:CreateFontString( nil, "OVERLAY", nil );
			stacks:SetFont( [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=], 12, "OUTLINE" );
			stacks:SetJustifyH( "RIGHT" );
			stacks:SetJustifyV( "BOTTOM" );
			stacks:SetShadowColor( 0, 0, 0 );
			stacks:SetShadowOffset( 1.25, -1.25 );
			stacks:SetPoint( "TOPLEFT", icon, "TOPLEFT", 0, 0 );
			stacks:SetPoint( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 3 );
			result.stacks = stacks;
			
			result.SetIcon = SetIcon;
			result.SetTime = SetTime;
			result.SetName = SetName;
			result.SetStacks = SetStacks;
			result.SetAuraInfo = SetAuraInfo;
			
			return result;
		end
	end

	-- private
	local SetAuraBar = function( self, index, auraInfo )
		local line = self.lines[ index ]
		if ( line == nil ) then
			line = CreateAuraBar( self );
			if ( index == 1 ) then
				line:SetPoint( "TOPLEFT", self, "BOTTOMLEFT", 0, BAR_HEIGHT );
				line:SetPoint( "BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0 );
			else
				local anchor = self.lines[ index - 1 ];
				line:SetPoint( "TOPLEFT", anchor, "TOPLEFT", 0, BAR_HEIGHT );
				line:SetPoint( "BOTTOMRIGHT", anchor, "TOPRIGHT", 0, 0 );
			end
			tinsert( self.lines, index, line );
		end	
		
		line:SetAuraInfo( auraInfo );
		
		line:Show();
	end
	
	local function OnUnitAura( self, unit )
		if ( unit ~= self.unit and ( self.dataSource:GetIncludePlayer() == false or unit ~= "player" ) ) then
			return;
		end
		
		self:Render();
	end
	
	local function OnPlayerTargetChanged( self, method )
		self:Render();
	end
	
	local function OnPlayerEnteringWorld( self )
		self:Render();
	end
	
	local function OnEvent( self, event, ... )
		if ( event == "UNIT_AURA" ) then
			OnUnitAura( self, ... );
		elseif ( event == "PLAYER_TARGET_CHANGED" ) then
			OnPlayerTargetChanged( self, ... );
		elseif ( event == "PLAYER_ENTERING_WORLD" ) then
			OnPlayerEnteringWorld( self );
		else
			error( "Unhandled event " .. event );
		end
	end
	
	-- public
	local function Render( self )
		local dataSource = self.dataSource;	

		dataSource:Update();
		dataSource:Sort();
		
		local count = dataSource:Count();
		
		for index, auraInfo in pairs( self.dataSource:Get() ) do
			SetAuraBar( self, index, auraInfo );
		end
		
		for index = count + 1, 80 do
			local line = self.lines[ index ];
			if ( line == nil or not line:IsShown() ) then
				break;
			end
			line:Hide();
		end
		
		if ( count > 0 ) then
			self:SetHeight( BAR_HEIGHT * count - 1 );
			self:Show();
		else
			self:Hide();
			self:SetHeight( self.hiddenHeight or 1 );
		end
	end
	
	local function SetHiddenHeight( self, height )
		self.hiddenHeight = height;
	end
	
	-- constructor
	CreateAuraBarFrame = function( dataSource, parent )
		local result = CreateFrame( "Frame", nil, parent, nil );
		local unit = dataSource:GetUnit();
		
		result.unit = unit;
		
		result.lines = { };		
		result.dataSource = dataSource;
		
		local background = result:CreateTexture( nil, "BACKGROUND", nil );
		background:SetAlpha( BACKGROUND_ALPHA );
		background:SetTexture( [=[Interface\Addons\Tukui\media\normTex]=] );
		background:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
		background:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
		background:SetVertexColor( 0.15, 0.15, 0.15 );
		result.background = background;
		
		local border = CreateFrame( "Frame", nil, result, nil );
		border:SetAlpha( BACKGROUND_ALPHA );
		border:SetFrameStrata( "BACKGROUND" );
		border:SetBackdrop( {
			edgeFile = [=[Interface\Addons\Tukui\media\glowTex]=], 
			edgeSize = 5,
			insets = { left = 3, right = 3, top = 3, bottom = 3 }
		} );
		border:SetBackdropColor( 0, 0, 0, 0 );
		border:SetBackdropBorderColor( 0, 0, 0 );
		border:SetPoint( "TOPLEFT", result, "TOPLEFT", -4.5, 5 );
		border:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 4.5, -4.5 );
		result.border = border;		
		
		result:RegisterEvent( "PLAYER_ENTERING_WORLD" );
		result:RegisterEvent( "UNIT_AURA" );
		if ( unit == "target" ) then
			result:RegisterEvent( "PLAYER_TARGET_CHANGED" );
		end
		
		result:SetScript( "OnEvent", OnEvent );
		
		result.Render = Render;
		result.SetHiddenHeight = SetHiddenHeight;
		
		return result;
	end
end

local _, playerClass = UnitClass( "player" );
local classFilter = CLASS_FILTERS[ playerClass ];

if ( LAYOUT == 1 ) then
	local dataSource = CreateUnitAuraDataSource( "target" );

	if ( GLOBAL_FILTER ) then
		dataSource:SetGlobalFilter( GLOBAL_FILTER );	
	end

	if ( classFilter ) then
		dataSource:SetFilter( classFilter.target );
		dataSource:SetPlayerFilter( classFilter.player );
		dataSource:SetIncludePlayer( classFilter.player ~= nil );
	end

	local frame = CreateAuraBarFrame( dataSource, oUF_Tukz_player );

	local yOffset = 1;

	if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" ) then
		yOffset = yOffset + 8;
	end

	frame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset );
	frame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset );
	frame:Show(); 
elseif ( LAYOUT == 2 ) then
	local targetDataSource = CreateUnitAuraDataSource( "target" );
	local playerDataSource = CreateUnitAuraDataSource( "player" );

	if ( GLOBAL_FILTER ) then
		targetDataSource:SetGlobalFilter( GLOBAL_FILTER );
		playerDataSource:SetGlobalFilter( GLOBAL_FILTER );
	end

	if ( classFilter ) then
		targetDataSource:SetFilter( classFilter.target );
		targetDataSource:SetIncludePlayer( false );
		
		playerDataSource:SetFilter( classFilter.player );
		playerDataSource:SetIncludePlayer( false );
	end

	local playerFrame = CreateAuraBarFrame( playerDataSource, oUF_Tukz_player );
	
	local yOffset = 10;
	if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" ) then
		yOffset = yOffset + 8;
	end

	playerFrame:SetHiddenHeight( -10 );
	playerFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset );
	playerFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset );
	playerFrame:Show();

	local targetFrame = CreateAuraBarFrame( targetDataSource, oUF_Tukz_player );
	targetFrame:SetPoint( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, 10 );
	targetFrame:SetPoint( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, 10 );
	targetFrame:Show();
else
	error( "Undefined layout " .. tostring( LAYOUT ) );
end