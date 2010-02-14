-- Configuration functions - DO NOT TOUCH
local CreateSpellEntry = function( id, castByAnyone, overrideColor )
	return { id = id, castByAnyone = castByAnyone, overrideColor = overrideColor };
end

local CreateColor = function( red, green, blue, alpha )
	return { red / 255, green / 255, blue / 255, alpha };
end

-- Configuration starts here:

-- Looks ugly when lower than 23
local BAR_HEIGHT = 23;

-- Background alpha (range from 0 to 1)
local BACKGROUND_ALPHA = 0.75;

--[[ Show icons outside of frame (flags - that means you can combine them - for example 3 means it will be outside the right edge)
	0 - left
	1 - right
	2 - outside
	4 - hide
]]--
local ICON_POSITION = 2;

-- Sets distance between right edge of bar and name and left edge of bar and time left
local TEXT_MARGIN = 5;

--[[ Permanent aura bars
	1 filled 		
	0 empty
]]--
local PERMANENT_AURA_VALUE = 1;

--[[ Player bar color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local PLAYER_BAR_COLOR = CreateColor( 255, 255, 255, 1 );

--[[ Target bar color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local TARGET_BAR_COLOR = CreateColor( 255, 255, 255, 1 );

--[[ Layouts
	1 - both player and target buffs in one frame right above player frame
	2 - player and target buffs separated into two frames above player frame
]]--
local LAYOUT = 2;

-- Global filter - mostly for trinket procs, delete or wrap into comment block --[[  ]] if you dont want to track those
local GLOBAL_FILTER = {
--		CreateSpellEntry( 71432 ), -- Mote of Anger
		CreateSpellEntry( 72412 ), -- Frostforged Champion
		CreateSpellEntry( 67703 ), CreateSpellEntry( 67708 ), CreateSpellEntry( 67772 ), CreateSpellEntry( 67773 ), -- Death Choice
		CreateSpellEntry( 2825, true ), -- Bloodlust
		CreateSpellEntry( 32182, true ), -- Heroism
	};
	
--[[ Class specific filters

Examples:

	Track "Frost Fever" and "Blood Plague" on target and "Bone Shield" on player:
	
		DEATHKNIGHT = { 
			target = { 
				CreateSpellEntry( "Frost Fever" ),
				CreateSpellEntry( "Blood Plague" ),
			},
			player = { 
				CreateSpellEntry( "Bone Shield" ),
			}
		},

	Track "Frost Fever" and "Blood Plague" on target and nothing on player:
	
		DEATHKNIGHT = { 
			target = { 
				CreateSpellEntry( "Frost Fever" ),
				CreateSpellEntry( "Blood Plague" ),
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
				CreateSpellEntry( 55095 ), -- Frost Fever
				CreateSpellEntry( 55078 ), -- Blood Plague
			},
			player = { 
				CreateSpellEntry( 49222 ), -- Bone Shield
				CreateSpellEntry( 53365 ), -- Unholy Strength
			}
		},
		DRUID = { 
			target = { 
				CreateSpellEntry( 53251 ), -- Wild Growth
				CreateSpellEntry( 48441 ), -- Rejuvenation
				CreateSpellEntry( 48443 ), -- Regrowth
				CreateSpellEntry( 48468 ), -- Insect Swarm
				CreateSpellEntry( 48463 ), -- Moonfire
			},
			player = { 
				CreateSpellEntry( 16870 ), -- Clearcasting
				CreateSpellEntry( 48518 ), -- Eclipse starfire
				CreateSpellEntry( 48517 ), -- Eclipse wrath
				CreateSpellEntry( 53201 ), -- Starfall
				CreateSpellEntry( 29166 ), -- Innervate
				CreateSpellEntry( 22812 ), -- Barkskin
			},
		},
		HUNTER = { 
			target = {
				CreateSpellEntry( 49050 ), -- Aimed Shot
				CreateSpellEntry( 49001 ), -- Serpent Sting
				CreateSpellEntry( 63672 ), -- Black Arrow
			},
			player = {
				CreateSpellEntry( 56453 ), -- Lock and Load
				CreateSpellEntry( 34074 ), -- Aspect of the Viper
			},
		},
		MAGE = {
			target = { },
			player = { },
		},
		PALADIN = { 
			target = {
				CreateSpellEntry( 31803 ), -- Holy Vengeance (Aliance)
				CreateSpellEntry( 53742 ), -- Blood Corruption (Horde)
				CreateSpellEntry( 61840 ), -- Righteous Vengeance
				CreateSpellEntry( 20066 ), -- Repentance
				CreateSpellEntry( 53563 ), -- Beacon of Light
				CreateSpellEntry( 10308 ), -- Hammer of Justice
			},
			player = {
				CreateSpellEntry( 642 ), -- Divine Shield
				CreateSpellEntry( 498 ), -- Divine Protection
				CreateSpellEntry( 31884 ), -- Avenging Wrath
				CreateSpellEntry( 53601 ), -- Sacred Shield
				CreateSpellEntry( 54428 ), -- Divine Plea
				CreateSpellEntry( 53488 ), -- The Art of War
				CreateSpellEntry( 71187 ), -- Libram of Three Truths
				CreateSpellEntry( 25771 ), -- Debuff: Forbearance
			},
		},
		PRIEST = { 
			target = { 
				CreateSpellEntry( 48066 ), -- Power Word: Shield
				CreateSpellEntry( 6788, true ), -- Weakened Soul
				CreateSpellEntry( 48068 ), -- Renew
				CreateSpellEntry( 48111 ), -- Prayer of Mending
				CreateSpellEntry( 552 ), -- Abolish Disease
				CreateSpellEntry( 33206 ), -- Pain Suppression
				CreateSpellEntry( 10060 ), -- Power Infusion
				CreateSpellEntry( 48160 ), -- Vampiric Touch
				CreateSpellEntry( 48125 ), -- Shadow Word: Pain
				CreateSpellEntry( 48300 ), -- Devouring Plague
			},
			player = {
				CreateSpellEntry( 48168 ), -- Inner Fire
				CreateSpellEntry( 47585 ), -- Dispersion
			},
		},
		ROGUE = { 
			target = { 
				CreateSpellEntry( 48672 ), -- Rupture
				CreateSpellEntry( 48676 ), -- Garrote
				CreateSpellEntry( 57969 ), -- Deadly Poison
				CreateSpellEntry( 5760 ), -- Mind-numbing Poison
				CreateSpellEntry( 57975 ), -- Wound Poison
				CreateSpellEntry( 3409 ), -- Crippling Poison
			},
			player = { 
				CreateSpellEntry( 57993 ), -- Envenom
				CreateSpellEntry( 8647 ), -- Expose Armor
				CreateSpellEntry( 6774 ), -- Slice and Dice				
			},
		},
		SHAMAN = {
			target = { },
			player = { },
		},
		WARLOCK = { 
			target = { 
				CreateSpellEntry( 17962 ), -- Conflagration
				CreateSpellEntry( 47811 ), -- Immolation
				CreateSpellEntry( 47867 ), -- Curse of Doom
				CreateSpellEntry( 47836 ), -- Seed of Corruption
			},
			player = {            
				CreateSpellEntry( 54277 ), -- Backdraft
			},
		},
		WARRIOR = { 
			target = {
				CreateSpellEntry( 47465 ), -- Rend
				CreateSpellEntry( 47486 ), -- Mortal Strike
				CreateSpellEntry( 47437 ), -- Demoralizing Shout
				CreateSpellEntry( 64382 ), -- Shattering Throw
			},
			player = { 
				CreateSpellEntry( 47440 ), -- Commanding Shout
				CreateSpellEntry( 47436 ), -- Battle Shout
				CreateSpellEntry( 55694 ), -- Enraged Regeneration
				CreateSpellEntry( 23920 ), -- Spell Reflection
				CreateSpellEntry( 871 ), -- Shield Wall
				CreateSpellEntry( 1719 ), -- Recklessness
				CreateSpellEntry( 20230 ), -- Retaliation
			},
		},
	};

local CreateUnitAuraDataSource;
do
	-- private
	local CheckFilter = function( self, id, caster, filter )
		if ( filter == nil ) then return false; end
			
		local byPlayer = caster == "player" or caster == "pet" or caster == "vehicle";
			
		for _, v in ipairs( filter ) do
			if ( v.id == id and ( v.castByAnyone or byPlayer ) ) then return v; end
		end
		
		return false;
	end
	
	local CheckUnit = function( self, unit, filter, result )
		if ( not UnitExists( unit ) ) then return 0; end
	
		local count = 0;
	
		for _, auraType in ipairs( { "HELPFUL", "HARMFUL" } ) do
			for index = 1, 40 do
				local name, rank, texture, stacks, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellId = UnitAura( unit, index, auraType );		
				if ( name == nil ) then
					break;
				end							
				
				local filterInfo = ( ( self.unit ~= "target" or unit ~= "player" or not UnitIsUnit( "player", "target" ) ) and CheckFilter( self, spellId, caster, self.globalFilter ) )or CheckFilter( self, spellId, caster, filter );
				if ( filterInfo ) then 
					tinsert( result, { name = name, texture = texture, duration = duration, expirationTime = expirationTime, stacks = stacks, unit = unit, overrideColor = filterInfo.overrideColor } );
					count = count + 1;
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
			if ( not self.icon ) then return; end
			
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
		
		local SetColor = function( self, color )
			self.bar:SetStatusBarColor( unpack( color ) );
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

			if ( bit.band( ICON_POSITION, 4 ) == 0 ) then
				local iconAnchor1;
				local iconAnchor2;
				local iconOffset;
				if ( bit.band( ICON_POSITION, 1 ) == 1 ) then
					iconAnchor1 = "TOPLEFT";
					iconAnchor2 = "TOPRIGHT";
					iconOffset = 1;
				else
					iconAnchor1 = "TOPRIGHT";
					iconAnchor2 = "TOPLEFT";
					iconOffset = -1;
				end			
				if ( bit.band( ICON_POSITION, 2 ) == 2 ) then
					icon:SetPoint( iconAnchor1, result, iconAnchor2, iconOffset * 6, 0 );
				else
					icon:SetPoint( iconAnchor1, result, iconAnchor2, iconOffset * -BAR_HEIGHT, 0 );
				end			
				icon:SetWidth( BAR_HEIGHT );
				icon:SetHeight( BAR_HEIGHT );			
				result.icon = icon;
			
				local iconOverlay = result:CreateTexture( nil, "OVERLAY", nil );
				iconOverlay:SetPoint( "TOPLEFT", icon, "TOPLEFT", -1.5, 1 );
				iconOverlay:SetPoint( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1 );
				iconOverlay:SetTexture( [=[Interface\Addons\Tukui\media\buttonTex]=] );
				iconOverlay:SetVertexColor( 1, 1, 1 );
				result.icon.overlay = iconOverlay;		
			end
			
			local bar = CreateFrame( "StatusBar", nil, result, nil );
			bar:SetStatusBarTexture( [=[Interface\Addons\Tukui\media\normTex]=] );
			if ( bit.band( ICON_POSITION, 2 ) == 2 or bit.band( ICON_POSITION, 4 ) == 4 ) then
				bar:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, -1 );
				bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
			else
				if ( bit.band( ICON_POSITION, 1 ) == 1 ) then
					bar:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, -1 );
					bar:SetPoint( "BOTTOMRIGHT", result.icon, "BOTTOMLEFT", -1, 0 );
				else
					bar:SetPoint( "TOPLEFT", result.icon, "TOPRIGHT", 1, -1 );
					bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
				end	
			end
			result.bar = bar;
			
			local name = bar:CreateFontString( nil, "OVERLAY", nil );
			name:SetFont( [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=], 12, "OUTLINE" );
			name:SetJustifyH( "LEFT" );
			name:SetShadowColor( 0, 0, 0 );
			name:SetShadowOffset( 1.25, -1.25 );
			name:SetPoint( "TOPLEFT", bar, "TOPLEFT", TEXT_MARGIN, 0 );
			name:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -45, 2 );
			result.name = name;
			
			local time = bar:CreateFontString( nil, "OVERLAY", nil );
			time:SetFont( [=[Interface\Addons\Tukui\media\Russel Square LT.ttf]=], 12, "OUTLINE" );
			time:SetJustifyH( "RIGHT" );
			time:SetShadowColor( 0, 0, 0 );
			time:SetShadowOffset( 1.25, -1.25 );
			time:SetPoint( "TOPLEFT", name, "TOPRIGHT", 0, 0 );
			time:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -TEXT_MARGIN, 2 );
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
			result.SetColor = SetColor;
			
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
		if ( auraInfo.overrideColor ) then
			line:SetColor( auraInfo.overrideColor );
		elseif ( auraInfo.unit == "player" and self.playerAuraColor ) then
			line:SetColor( self.playerAuraColor );
		elseif ( self.unitAuraColor ) then
			line:SetColor( self.unitAuraColor );
		end
		
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
	
	local function SetPlayerAuraColor( self, color )
		self.playerAuraColor = color;
	end

	local function SetUnitAuraColor( self, color )
		self.unitAuraColor = color;
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
		border:SetPoint( "TOPLEFT", result, "TOPLEFT", -5, 5 );
		border:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 5, -5 );
		result.border = border;		
		
		result:RegisterEvent( "PLAYER_ENTERING_WORLD" );
		result:RegisterEvent( "UNIT_AURA" );
		if ( unit == "target" ) then
			result:RegisterEvent( "PLAYER_TARGET_CHANGED" );
		end
		
		result:SetScript( "OnEvent", OnEvent );
		
		result.Render = Render;
		result.SetHiddenHeight = SetHiddenHeight;
		result.SetPlayerAuraColor = SetPlayerAuraColor;
		result.SetUnitAuraColor = SetUnitAuraColor;
		
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
	frame:SetPlayerAuraColor( PLAYER_BAR_COLOR );
	frame:SetUnitAuraColor( TARGET_BAR_COLOR );

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
	playerFrame:SetUnitAuraColor( PLAYER_BAR_COLOR );
	
	local yOffset = 6;
	playerFrame:SetHiddenHeight( -yOffset );

	if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" ) then
		yOffset = yOffset + 8;
	end

	playerFrame:SetPoint( "BOTTOMLEFT", oUF_Tukz_player, "TOPLEFT", 0, yOffset );
	playerFrame:SetPoint( "BOTTOMRIGHT", oUF_Tukz_player, "TOPRIGHT", 0, yOffset );
	playerFrame:Show();

	local targetFrame = CreateAuraBarFrame( targetDataSource, oUF_Tukz_player );
	targetFrame:SetUnitAuraColor( TARGET_BAR_COLOR );
	targetFrame:SetPoint( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, 6 );
	targetFrame:SetPoint( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, 6 );
	targetFrame:Show();
else
	error( "Undefined layout " .. tostring( LAYOUT ) );
end