if ( Tukui == nil ) then return; end

local T, C, L = Tukui:unpack();

--[[ Configuration functions - DO NOT TOUCH
	id - spell id
	castByAnyone - show if aura wasn't created by player
	color - bar color (nil for default color)
	unitType - 0 all, 1 friendly, 2 enemy
	castSpellId - fill only if you want to see line on bar that indicates if its safe to start casting spell and not clip the last tick, also note that this can be different from aura id 
]]--
local CreateSpellEntry = function( id, castByAnyone, color, unitType, castSpellId )
	return { id = id, castByAnyone = castByAnyone, color = color, unitType = unitType or 0, castSpellId = castSpellId };
end

local CreateColor = function( red, green, blue, alpha )
	return { red / 255, green / 255, blue / 255, alpha };
end

-- Configuration starts here:

-- Bar height
local BAR_HEIGHT = 20;

-- Distance between bars
local BAR_SPACING = 1;

--[[ Layouts
	1 - both player and target auras in one frame right above player frame
	2 - player and target auras separated into two frames above player frame
	3 - player, target and trinket auras separated into three frames above player frame
	4 - player and trinket auras are shown above player frame and target auras are shown above target frame
]]--
local LAYOUT = 3;

-- Background alpha (range from 0 to 1)
local BACKGROUND_ALPHA = 0.75;

--[[ Show icons outside of frame (flags - that means you can combine them - for example 3 means it will be outside the right edge)
	0 - left
	1 - right
	2 - outside
	4 - hide
]]--
local ICON_POSITION = 0;

-- Icon overlay color
local ICON_COLOR = CreateColor( 120, 120, 120, 1 );

-- Show spark
local SPARK = false;

-- Show cast separator
local CAST_SEPARATOR = true;

-- Sets cast separator color
local CAST_SEPARATOR_COLOR = CreateColor( 0, 0, 0, 0.5 );

-- Sets distance between right edge of bar and name and left edge of bar and time left
local TEXT_MARGIN = 5;

local MASTER_FONT, STACKS_FONT;
if ( C and C.Medias and C.Medias.Font ) then
	-- Sets font for all texts
	MASTER_FONT = { C.Medias.Font, 12, "" };

	-- Sets font for stack count
	STACKS_FONT = { C.Medias.Font, 11, "" };
else
	-- Sets font for all texts
	MASTER_FONT = { [=[Interface\Addons\Tukui\Medias\Fonts\uf_font.ttf]=], 12, "" };

	-- Sets font for stack count
	STACKS_FONT = { [=[Interface\Addons\Tukui\Medias\Fonts\uf_font.ttf]=], 11, "" };
end

--[[ Permanent aura bars
	1 filled 		
	0 empty
]]--
local PERMANENT_AURA_VALUE = 1;

--[[ Player bar color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local PLAYER_BAR_COLOR = CreateColor( 70, 70, 150, 1 );

--[[ Player debuff color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local PLAYER_DEBUFF_COLOR = nil;

--[[ Target bar color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local TARGET_BAR_COLOR = CreateColor( 70, 150, 70, 1 );

--[[ Target debuff color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local TARGET_DEBUFF_COLOR = CreateColor( 150, 70, 70, 1 );

--[[ Trinket bar color
	red, green, blue - range from 0 to 255
	alpha - range from 0 to 1
]]--
local TRINKET_BAR_COLOR = CreateColor( 150, 150, 70, 1 );

--[[ Sort direction
	false - ascending
	true - descending
]]--
local SORT_DIRECTION = true;

-- Timer tenths threshold - range from 1 to 60
local TENTHS_TRESHOLD = 1

-- Trinket filter - mostly for trinket procs, delete or wrap into comment block --[[  ]] if you dont want to track those
local TRINKET_FILTER = {
		-- CreateSpellEntry( 67671 ), -- Fury(Banner of Victory)

		-- CreateSpellEntry( 60229 ), -- Greatness (Greatness - Strength)
		-- CreateSpellEntry( 60233 ), -- Greatness (Greatness - Agility)
		-- CreateSpellEntry( 60234 ), -- Greatness (Greatness - Intellect)
		-- CreateSpellEntry( 60235 ), -- Greatness (Greatness - Spirit)
		
		-- CreateSpellEntry( 67703 ), CreateSpellEntry( 67708 ), CreateSpellEntry( 67772 ), CreateSpellEntry( 67773 ), -- Paragon (Death Choice)
		-- CreateSpellEntry( 67684 ), -- Hospitality (Talisman of Resurgence)
		
		-- CreateSpellEntry( 71432 ), -- Mote of Anger (Tiny Abomination in a Jar)	
		-- CreateSpellEntry( 71485 ), CreateSpellEntry( 71556 ), -- Agility of the Vrykul (Deathbringer's Will)
		-- CreateSpellEntry( 71492 ), CreateSpellEntry( 71560 ), -- Speed of the Vrykul (Deathbringer's Will)
		-- CreateSpellEntry( 71487 ), CreateSpellEntry( 71557 ), -- Precision of the Iron Dwarves (Deathbringer's Will)
		-- CreateSpellEntry( 71491 ), CreateSpellEntry( 71559 ), -- Aim of the Iron Dwarves (Deathbringer's Will)
		-- CreateSpellEntry( 71486 ), CreateSpellEntry( 71558 ), -- Power of the Taunka (Deathbringer's Will)
		-- CreateSpellEntry( 71484 ), CreateSpellEntry( 71561 ), -- Strength of the Taunka (Deathbringer's Will)
		-- CreateSpellEntry( 71570 ), CreateSpellEntry( 71572 ), -- Cultivated Power (Muradin's Spyglass)
		-- CreateSpellEntry( 71605 ), CreateSpellEntry( 71636 ), -- Phylactery of the Nameless Lich
		-- CreateSpellEntry( 71401 ), CreateSpellEntry( 71541 ), -- Icy Rage (Whispering Fanged Skull)
		-- CreateSpellEntry( 71396 ), -- Herkuml War Token
		-- CreateSpellEntry( 72412 ), -- Frostforged Champion (Ashen Band of Unmatched/Endless Might/Vengeance)
	
		-- CreateSpellEntry( 59626 ), -- Black Magic
		-- CreateSpellEntry( 54758 ), -- Hyperspeed Acceleration (Hyperspeed Accelerators)
		-- CreateSpellEntry( 55637 ), -- Lightweave
		-- CreateSpellEntry( 59620 ), -- Berserking
		
		-- CreateSpellEntry( 2825, true ), CreateSpellEntry( 32182, true ), -- Bloodlust/Heroism
		-- CreateSpellEntry( 26297 ), -- Berserking (troll racial)
		-- CreateSpellEntry( 33702 ), CreateSpellEntry( 33697 ), CreateSpellEntry( 20572 ), -- Blood Fury (orc racial)
		-- CreateSpellEntry( 57933 ), -- Tricks of Trade (15% dmg buff)
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

			},
			player = { 

			},
			procs = {
		
			}
		},
		DRUID = { 
			target = { 

			},
			player = { 

			},
			procs = {

			}
		},
		HUNTER = { 
			target = {

			},
			player = {

			},
			procs = {

			},
		},
		MAGE = {
			target = { 

			},
			player = {

			},
			procs = {

			},
		},
		PALADIN = {
			target = {
				CreateSpellEntry(183218), -- Hand of Hindrance
				CreateSpellEntry(197277), -- Judgment
				CreateSpellEntry(196941), -- Judgment of the Light
				CreateSpellEntry(204242), -- Consecration (Holy, Protection)
				CreateSpellEntry(205228), -- Consecration (Retribution)
				CreateSpellEntry(1044), -- Blessing of Freedom
				CreateSpellEntry(204013), -- Blessing of Salvation
				CreateSpellEntry(204018), -- Blessing of Spellwarding
				CreateSpellEntry(6940), -- Blessing of Sacrifice
				CreateSpellEntry(1022), -- Blessing of Protection
				CreateSpellEntry(213757), -- Execution Sentence
				CreateSpellEntry(853), -- Hammer of Justice
				CreateSpellEntry(20066), -- Repentance
				CreateSpellEntry(105421), -- Blinding Light
			},
			player = {
				CreateSpellEntry(184092), -- Light of the Protector
				CreateSpellEntry(210191), -- Word of Glory
				CreateSpellEntry(205191), -- Eye for an Eye
				CreateSpellEntry(1044), -- Blessing of Freedom
				CreateSpellEntry(204013), -- Blessing of Salvation
				CreateSpellEntry(204018), -- Blessing of Spellwarding
				CreateSpellEntry(6940), -- Blessing of Sacrifice
				CreateSpellEntry(1022), -- Blessing of Protection
				CreateSpellEntry(86659), -- Guardian of Ancient Kings
				CreateSpellEntry(105809), -- Holy Avenger
				CreateSpellEntry(31884), -- Avenging Wrath
				CreateSpellEntry(31842), -- Avenging Wrath (Holy)
				CreateSpellEntry(31850), -- Ardent defender
				CreateSpellEntry(6940), -- Blessing of Sacrifice
				CreateSpellEntry(132403), -- Shield of the Righteous
				CreateSpellEntry(642), -- Divine Shield
				CreateSpellEntry(184662), -- Shield of Vengeance
				CreateSpellEntry(204150), -- Aegis of Light
				CreateSpellEntry(202273), -- Seal of Light
				CreateSpellEntry(224668), -- Crusade
				CreateSpellEntry(498), -- Divine Protection
				CreateSpellEntry(221883), -- Divine Steed
				CreateSpellEntry(31821), -- Aura Mastery
			},
			procs = {
				CreateSpellEntry(152262), -- Seraphim
			},
		},
		PRIEST = { 
			target = { 
				CreateSpellEntry(194384), -- Atonement
			},
			player = {
				CreateSpellEntry(194384), -- Atonement
			},
			procs = {

			},
		},
		ROGUE = { 
			target = { 

			},
			player = { 

			},
			procs = {
				
			},
		},
		SHAMAN = {
			target = { 

			},
			player = { 

			},
			procs = {
		
			},
		},
		WARLOCK = { 
			target = {

			},
			player = {            

			},
			procs = {
          
			},
		},
		WARRIOR = { 
			target = {

			},
			player = { 

			},
			procs = {
				
			},
		},
	};

local CreateUnitAuraDataSource;
do
	local auraTypes = { "HELPFUL", "HARMFUL" };

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

		local unitIsFriend = UnitIsFriend( "player", unit );

		for _, auraType in ipairs( auraTypes ) do
			local isDebuff = auraType == "HARMFUL";
		
			for index = 1, 40 do
				local name, _, texture, stacks, _, duration, expirationTime, caster, _, _, spellId = UnitAura( unit, index, auraType );		
				if ( name == nil ) then
					break;
				end							
				
				local filterInfo = CheckFilter( self, spellId, caster, filter );
				if ( filterInfo and ( filterInfo.unitType ~= 1 or unitIsFriend ) and ( filterInfo.unitType ~= 2 or not unitIsFriend ) ) then 					
					filterInfo.name = name;
					filterInfo.texture = texture;
					filterInfo.duration = duration;
					filterInfo.expirationTime = expirationTime;
					filterInfo.stacks = stacks;
					filterInfo.unit = unit;
					filterInfo.isDebuff = isDebuff;
					table.insert( result, filterInfo );
				end
			end
		end
	end

	-- public 
	local Update = function( self )
		local result = self.table;

		for index = 1, #result do
			table.remove( result );
		end				

		CheckUnit( self, self.unit, self.filter, result );
		if ( self.includePlayer ) then
			CheckUnit( self, "player", self.playerFilter, result );
		end
		
		self.table = result;
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
		return #self.table;
	end
	
	local AddFilter = function( self, filter, defaultColor, debuffColor )
		if ( filter == nil ) then return; end
		
		for _, v in pairs( filter ) do
			local clone = { };
			
			clone.id = v.id;
			clone.castByAnyone = v.castByAnyone;
			clone.color = v.color;
			clone.unitType = v.unitType;
			clone.castSpellId = v.castSpellId;
			
			clone.defaultColor = defaultColor;
			clone.debuffColor = debuffColor;
			
			table.insert( self.filter, clone );
		end
	end
	
	local AddPlayerFilter = function( self, filter, defaultColor, debuffColor )
		if ( filter == nil ) then return; end

		for _, v in pairs( filter ) do
			local clone = { };
			
			clone.id = v.id;
			clone.castByAnyone = v.castByAnyone;
			clone.color = v.color;
			clone.unitType = v.unitType;
			clone.castSpellId = v.castSpellId;
			
			clone.defaultColor = defaultColor;
			clone.debuffColor = debuffColor;
			
			table.insert( self.playerFilter, clone );
		end
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
		local result = {  };

		result.Sort = Sort;
		result.Update = Update;
		result.Get = Get;
		result.Count = Count;
		result.SetSortDirection = SetSortDirection;
		result.GetSortDirection = GetSortDirection;
		result.AddFilter = AddFilter;
		result.AddPlayerFilter = AddPlayerFilter;
		result.GetUnit = GetUnit; 
		result.SetIncludePlayer = SetIncludePlayer; 
		result.GetIncludePlayer = GetIncludePlayer; 
		
		result.unit = unit;
		result.includePlayer = false;
		result.filter = { };
		result.playerFilter = { };
		result.table = { };
		
		return result;
	end
end

local CreateFramedTexture;
do
	-- public
	local SetTexture = function( self, ... )
		return self.texture:SetTexture( ... );
	end
	
	local GetTexture = function( self )
		return self.texture:GetTexture();
	end
	
	local GetTexCoord = function( self )
		return self.texture:GetTexCoord();
	end
	
	local SetTexCoord = function( self, ... )
		return self.texture:SetTexCoord( ... );
	end
	
	local SetBorderColor = function( self, ... )
		return self.border:SetVertexColor( ... );
	end
	
	-- constructor
	CreateFramedTexture = function( parent )
		local result = parent:CreateTexture( nil, "ARTWORK", nil, -2 );
		local border = parent:CreateTexture( nil, "ARTWORK", nil, -1 );
		local background = parent:CreateTexture( nil, "ARTWORK", nil, 0 );
		local texture = parent:CreateTexture( nil, "ARTWORK", nil, 1 );		
		
		result:SetTexture( 0.1, 0.1, 0.1, 1 );
		border:SetTexture( 0.5, 0.5, 0.5, 1 );
		background:SetTexture( 0.1, 0.1, 0.1, 1 );
			
		border:SetPoint( "TOPLEFT", result, "TOPLEFT", 1, -1 );
		border:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", -1, 1 );
		
		background:SetPoint( "TOPLEFT", border, "TOPLEFT", 1, -1 );
		background:SetPoint( "BOTTOMRIGHT", border, "BOTTOMRIGHT", -1, 1 );

		texture:SetPoint( "TOPLEFT", background, "TOPLEFT", 1, -1 );
		texture:SetPoint( "BOTTOMRIGHT", background, "BOTTOMRIGHT", -1, 1 );
			
		result.border = border;
		result.background = background;
		result.texture = texture;
			
		result.SetBorderColor = SetBorderColor;
		
		result.SetTexture = SetTexture;
		result.GetTexture = GetTexture;
		result.SetTexCoord = SetTexCoord;
		result.GetTexCoord = GetTexCoord;
			
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
				
				local spark = self.spark;
				if ( spark ) then			
					spark:Hide();
				end
			else
				local remaining = self.expirationTime - time;
				self.bar:SetValue( remaining );
				
				local timeText = "";
				if ( remaining >= 3600 ) then
					timeText = tostring( math.floor( remaining / 3600 ) ) .. "h";
				elseif ( remaining >= 60 ) then
					timeText = tostring( math.floor( remaining / 60 ) ) .. "m";
				elseif ( remaining > TENTHS_TRESHOLD ) then
					timeText = tostring( math.floor( remaining ) );
				elseif ( remaining > 0 ) then
					timeText = tostring( math.floor( remaining * 10 ) / 10 );
				end
				self.time:SetText( timeText );
				
				local barWidth = self.bar:GetWidth();
				
				local spark = self.spark;
				if ( spark ) then			
					spark:SetPoint( "CENTER", self.bar, "LEFT", barWidth * remaining / self.duration, 0 );
				end
				
				local castSeparator = self.castSeparator;
				if ( castSeparator and self.castSpellId ) then
					local _, _, _, _, _, _, castTime, _, _ = GetSpellInfo( self.castSpellId );

					castTime = castTime / 1000;
					if ( castTime and remaining > castTime ) then
						castSeparator:SetPoint( "CENTER", self.bar, "LEFT", barWidth * ( remaining - castTime ) / self.duration, 0 );
					else
						castSeparator:Hide();
					end
				end
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
		
				local spark = self.spark;
				if ( spark ) then 
					spark:Show();
				end
		
				self:SetScript( "OnUpdate", OnUpdate );
			else
				self.bar:SetMinMaxValues( 0, 1 );
				self.bar:SetValue( PERMANENT_AURA_VALUE );
				self.time:SetText( "" );
				
				local spark = self.spark;
				if ( spark ) then 
					spark:Hide();
				end
				
				self:SetScript( "OnUpdate", nil );
			end
		end
		
		local SetName = function( self, name )
			self.name:SetText( name );
		end
		
		local SetStacks = function( self, stacks )
			if ( not self.stacks ) then
				if ( stacks ~= nil and stacks > 1 ) then
					local name = self.name;
					
					name:SetText( tostring( stacks ) .. "  " .. name:GetText() );
				end
			else			
				if ( stacks ~= nil and stacks > 1 ) then
					self.stacks:SetText( stacks );
				else
					self.stacks:SetText( "" );
				end
			end
		end
		
		local SetColor = function( self, color )
			self.bar:SetStatusBarColor( unpack( color ) );
		end
		
		local SetCastSpellId = function( self, id )
			self.castSpellId = id;
			
			local castSeparator = self.castSeparator;
			if ( castSeparator ) then
				if ( id ) then
					self.castSeparator:Show();
				else
					self.castSeparator:Hide();
				end
			end
		end
		
		local SetAuraInfo = function( self, auraInfo )
			self:SetName( auraInfo.name );
			self:SetIcon( auraInfo.texture );	
			self:SetTime( auraInfo.expirationTime, auraInfo.duration );
			self:SetStacks( auraInfo.stacks );
			self:SetCastSpellId( auraInfo.castSpellId );
		end
		
		-- constructor
		CreateAuraBar = function( parent )
			local result = CreateFrame( "Frame", nil, parent, nil );

			if ( bit.band( ICON_POSITION, 4 ) == 0 ) then		
				local icon = CreateFramedTexture( result, "ARTWORK" );
				icon:SetTexCoord( 0.15, 0.85, 0.15, 0.85 );
				icon:SetBorderColor( unpack( ICON_COLOR ) );
				
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
					icon:SetPoint( iconAnchor1, result, iconAnchor2, iconOffset * 6, 1 );
				else
					icon:SetPoint( iconAnchor1, result, iconAnchor2, iconOffset * ( -BAR_HEIGHT - 1 ), 1 );
				end			
				icon:SetWidth( BAR_HEIGHT + 2 );
				icon:SetHeight( BAR_HEIGHT + 2 );	

				result.icon = icon;
				
				local stacks = result:CreateFontString( nil, "OVERLAY", nil );
				stacks:SetFont( unpack( STACKS_FONT ) );
				stacks:SetShadowColor( 0, 0, 0 );
				stacks:SetShadowOffset( 1.25, -1.25 );
				stacks:SetJustifyH( "RIGHT" );
				stacks:SetJustifyV( "BOTTOM" );
				stacks:SetPoint( "TOPLEFT", icon, "TOPLEFT", 0, 0 );
				stacks:SetPoint( "BOTTOMRIGHT", icon, "BOTTOMRIGHT", 0, 3 );
				result.stacks = stacks;
			end
			
			local bar = CreateFrame( "StatusBar", nil, result, nil );
			bar:SetStatusBarTexture( [=[Interface\Addons\Tukui\Medias\Textures\normTex]=] );
			if ( bit.band( ICON_POSITION, 2 ) == 2 or bit.band( ICON_POSITION, 4 ) == 4 ) then
				bar:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
				bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
			else
				if ( bit.band( ICON_POSITION, 1 ) == 1 ) then
					bar:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
					bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", -BAR_HEIGHT - 1, 0 );
				else
					bar:SetPoint( "TOPLEFT", result, "TOPLEFT", BAR_HEIGHT + 1, 0 );
					bar:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );					
				end	
			end
			result.bar = bar;
			
			if ( SPARK ) then
				local spark = bar:CreateTexture( nil, "OVERLAY", nil );
				spark:SetTexture( [[Interface\CastingBar\UI-CastingBar-Spark]] );
				spark:SetWidth( 12 );
				spark:SetBlendMode( "ADD" );
				spark:Show();
				result.spark = spark;
			end
			
			if ( CAST_SEPARATOR ) then
				local castSeparator = bar:CreateTexture( nil, "OVERLAY", nil );
				castSeparator:SetTexture( unpack( CAST_SEPARATOR_COLOR ) );
				castSeparator:SetWidth( 1 );
				castSeparator:SetHeight( BAR_HEIGHT );
				castSeparator:Show();
				result.castSeparator = castSeparator;
			end
						
			local name = bar:CreateFontString( nil, "OVERLAY", nil );
			name:SetFont( unpack( MASTER_FONT ) );
			name:SetJustifyH( "LEFT" );
			name:SetJustifyV( "CENTER" );
			name:SetShadowColor( 0, 0, 0 );
			name:SetShadowOffset( 1.25, -1.25 );
			name:SetPoint( "TOPLEFT", bar, "TOPLEFT", TEXT_MARGIN, -1 );
			name:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -45, 0 );
			result.name = name;
			
			local time = bar:CreateFontString( nil, "OVERLAY", nil );
			time:SetFont( unpack( MASTER_FONT ) );
			time:SetJustifyH( "RIGHT" );
			time:SetJustifyV( "CENTER" );
			time:SetShadowColor( 0, 0, 0 );
			time:SetShadowOffset( 1.25, -1.25 );
			time:SetPoint( "TOPLEFT", name, "TOPRIGHT", 0, 0 );
			time:SetPoint( "BOTTOMRIGHT", bar, "BOTTOMRIGHT", -TEXT_MARGIN, 0 );
			result.time = time;
			
			result.SetIcon = SetIcon;
			result.SetTime = SetTime;
			result.SetName = SetName;
			result.SetStacks = SetStacks;
			result.SetAuraInfo = SetAuraInfo;
			result.SetColor = SetColor;
			result.SetCastSpellId = SetCastSpellId;
			
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
				line:SetPoint( "TOPLEFT", anchor, "TOPLEFT", 0, BAR_HEIGHT + BAR_SPACING );
				line:SetPoint( "BOTTOMRIGHT", anchor, "TOPRIGHT", 0, BAR_SPACING );
			end
			tinsert( self.lines, index, line );
		end	
		
		line:SetAuraInfo( auraInfo );
		if ( auraInfo.color ) then
			line:SetColor( auraInfo.color );
		elseif ( auraInfo.debuffColor and auraInfo.isDebuff ) then
			line:SetColor( auraInfo.debuffColor );
		elseif ( auraInfo.defaultColor ) then
			line:SetColor( auraInfo.defaultColor );
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

		for index, auraInfo in ipairs( dataSource:Get() ) do
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
			self:SetHeight( ( BAR_HEIGHT + BAR_SPACING ) * count - BAR_SPACING );
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
		background:SetTexture( [=[Interface\Addons\Tukui\Medias\Textures\normTex]=] );
		background:SetPoint( "TOPLEFT", result, "TOPLEFT", 0, 0 );
		background:SetPoint( "BOTTOMRIGHT", result, "BOTTOMRIGHT", 0, 0 );
		background:SetVertexColor( 0.15, 0.15, 0.15 );
		result.background = background;
		
		local border = CreateFrame( "Frame", nil, result, nil );
		border:SetAlpha( BACKGROUND_ALPHA );
		border:SetFrameStrata( "BACKGROUND" );
		border:SetBackdrop( {
			edgeFile = [=[Interface\Addons\Tukui\Medias\Textures\glowTex]=], 
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
		
		return result;
	end
end

local init = function()
	local _, playerClass = UnitClass( "player" );
	local classFilter = CLASS_FILTERS[ playerClass ];

	if ( LAYOUT == 1 ) then
		local dataSource = CreateUnitAuraDataSource( "target" );

		dataSource:SetSortDirection( SORT_DIRECTION );
		
		dataSource:AddPlayerFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );
		
		if ( classFilter ) then
			dataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );
			dataSource:AddPlayerFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			dataSource:AddPlayerFilter( classFilter.procs, TRINKET_BAR_COLOR );
			dataSource:SetIncludePlayer( classFilter.player ~= nil );
		end

		local frame = CreateAuraBarFrame( dataSource, oUF_TukuiPlayer );
		local yOffset = 1;
		if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" or playerClass == "PALADIN" ) then
			yOffset = yOffset + 8;
		end
		frame:SetPoint( "BOTTOMLEFT", oUF_TukuiPlayer, "TOPLEFT", 0, yOffset );
		frame:SetPoint( "BOTTOMRIGHT", oUF_TukuiPlayer, "TOPRIGHT", 0, yOffset );
		frame:Show(); 
	elseif ( LAYOUT == 2 ) then
		local targetDataSource = CreateUnitAuraDataSource( "target" );
		local playerDataSource = CreateUnitAuraDataSource( "player" );

		targetDataSource:SetSortDirection( SORT_DIRECTION );
		playerDataSource:SetSortDirection( SORT_DIRECTION );
		
		playerDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

		if ( classFilter ) then
			targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );
			playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			playerDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
		end

		local yOffset = 6;
		
		local playerFrame = CreateAuraBarFrame( playerDataSource, oUF_TukuiPlayer );	
		playerFrame:SetHiddenHeight( -yOffset );
		if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" or playerClass == "PALADIN" ) then
			playerFrame:SetPoint( "BOTTOMLEFT", oUF_TukuiPlayer, "TOPLEFT", 0, yOffset + 8 );
			playerFrame:SetPoint( "BOTTOMRIGHT", oUF_TukuiPlayer, "TOPRIGHT", 0, yOffset + 8 );
		else
			playerFrame:SetPoint( "BOTTOMLEFT", oUF_TukuiPlayer, "TOPLEFT", 0, yOffset );
			playerFrame:SetPoint( "BOTTOMRIGHT", oUF_TukuiPlayer, "TOPRIGHT", 0, yOffset );
		end
		playerFrame:Show();

		local targetFrame = CreateAuraBarFrame( targetDataSource, oUF_TukuiPlayer );
		targetFrame:SetPoint( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, yOffset );
		targetFrame:SetPoint( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, yOffset );
		targetFrame:Show();
	elseif ( LAYOUT == 3 ) then
		local yOffset = 6;

		local targetDataSource = CreateUnitAuraDataSource( "target" );
		local playerDataSource = CreateUnitAuraDataSource( "player" );
		local trinketDataSource = CreateUnitAuraDataSource( "player" );
		
		targetDataSource:SetSortDirection( SORT_DIRECTION );
		playerDataSource:SetSortDirection( SORT_DIRECTION );
		trinketDataSource:SetSortDirection( SORT_DIRECTION );
		
		if ( classFilter ) then
			targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );		
			playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			trinketDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
		end
		trinketDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

		local playerFrame = CreateAuraBarFrame( playerDataSource, oUF_TukuiPlayer );
		playerFrame:SetHiddenHeight( -yOffset );
		if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" or playerClass == "PALADIN" ) then
			playerFrame:SetPoint( "BOTTOMLEFT", oUF_TukuiPlayer, "TOPLEFT", 0, yOffset + 8 );
			playerFrame:SetPoint( "BOTTOMRIGHT", oUF_TukuiPlayer, "TOPRIGHT", 0, yOffset + 8 );
		else
			playerFrame:SetPoint( "BOTTOMLEFT", oUF_TukuiPlayer, "TOPLEFT", 0, yOffset );
			playerFrame:SetPoint( "BOTTOMRIGHT", oUF_TukuiPlayer, "TOPRIGHT", 0, yOffset );
		end
		playerFrame:Show();

		local trinketFrame = CreateAuraBarFrame( trinketDataSource, oUF_TukuiPlayer );
		trinketFrame:SetHiddenHeight( -yOffset );
		trinketFrame:SetPoint( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, yOffset );
		trinketFrame:SetPoint( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, yOffset );
		trinketFrame:Show();
		
		local targetFrame = CreateAuraBarFrame( targetDataSource, oUF_TukuiPlayer );
		targetFrame:SetHiddenHeight( -yOffset );
		targetFrame:SetPoint( "BOTTOMLEFT", trinketFrame, "TOPLEFT", 0, yOffset );
		targetFrame:SetPoint( "BOTTOMRIGHT", trinketFrame, "TOPRIGHT", 0, yOffset );
		targetFrame:Show();
	elseif ( LAYOUT == 4 ) then
		local yOffset = 6;

		local targetDataSource = CreateUnitAuraDataSource( "target" );
		local playerDataSource = CreateUnitAuraDataSource( "player" );
		local trinketDataSource = CreateUnitAuraDataSource( "player" );
		
		targetDataSource:SetSortDirection( SORT_DIRECTION );
		playerDataSource:SetSortDirection( SORT_DIRECTION );
		trinketDataSource:SetSortDirection( SORT_DIRECTION );
		
		if ( classFilter ) then
			targetDataSource:AddFilter( classFilter.target, TARGET_BAR_COLOR, TARGET_DEBUFF_COLOR );		
			playerDataSource:AddFilter( classFilter.player, PLAYER_BAR_COLOR, PLAYER_DEBUFF_COLOR );
			trinketDataSource:AddFilter( classFilter.procs, TRINKET_BAR_COLOR );
		end
		trinketDataSource:AddFilter( TRINKET_FILTER, TRINKET_BAR_COLOR );

		local playerFrame = CreateAuraBarFrame( playerDataSource, oUF_TukuiPlayer );
		playerFrame:SetHiddenHeight( -yOffset );
		if ( playerClass == "DEATHKNIGHT" or playerClass == "SHAMAN" or playerClass == "PALADIN" ) then
			playerFrame:SetPoint( "BOTTOMLEFT", oUF_TukuiPlayer, "TOPLEFT", 0, yOffset + 8 );
			playerFrame:SetPoint( "BOTTOMRIGHT", oUF_TukuiPlayer, "TOPRIGHT", 0, yOffset + 8 );
		else
			playerFrame:SetPoint( "BOTTOMLEFT", oUF_TukuiPlayer, "TOPLEFT", 0, yOffset );
			playerFrame:SetPoint( "BOTTOMRIGHT", oUF_TukuiPlayer, "TOPRIGHT", 0, yOffset );
		end
		playerFrame:Show();

		local trinketFrame = CreateAuraBarFrame( trinketDataSource, oUF_TukuiPlayer );
		trinketFrame:SetHiddenHeight( -yOffset );
		trinketFrame:SetPoint( "BOTTOMLEFT", playerFrame, "TOPLEFT", 0, yOffset );
		trinketFrame:SetPoint( "BOTTOMRIGHT", playerFrame, "TOPRIGHT", 0, yOffset );
		trinketFrame:Show();
		
		local targetFrame = CreateAuraBarFrame( targetDataSource, oUF_TukuiTarget );
		targetFrame:SetPoint( "BOTTOMLEFT", oUF_TukuiTarget, "TOPLEFT", 0, 8 + ( 32 * 3 ) );
		targetFrame:SetPoint( "BOTTOMRIGHT", oUF_TukuiTarget, "TOPRIGHT", 0, 8 + ( 32 * 3 ) );
		targetFrame:Show();
	else
		error( "Undefined layout " .. tostring( LAYOUT ) );
	end
end

local setup = CreateFrame( "Frame", nil, UIParent );
setup:RegisterEvent( "PLAYER_ENTERING_WORLD" );
setup:SetScript( "OnEvent", function ( self, event )
	if (event == "PLAYER_ENTERING_WORLD") then
		init();
		setup:SetScript( "OnEvent", nil );
	end
end );