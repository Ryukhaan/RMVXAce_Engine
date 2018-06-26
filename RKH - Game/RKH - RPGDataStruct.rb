module RKH
	module ITEM

		module REGEX
			DURABILITY 	= /<qty:[ ](\d+)>/i
		end
	end

	module WEAPON
		module REGEX
			DAMAGE_MIN 		= /<damage_min:[ ](\d+)>/i
			DAMAGE_MAX  	= /<damage_max:[ ](\d+)>/i
			ACCURACY 		= /<accuracy:[ ](\d+)>/i
			CRITIC_RATE 	= /<critic_rate:[ ](\d+)>/i
			CRITIC_EFFECT 	= /<critic_effect:[ ](\d+)>/i
			COST 			= /<ap_cost:[ ](\d+)>/i
			SKILLS_LIST 	= /<skills:[ ](.*)>/i
 		end

 		Default_Durability_Cost = 1
	end

	module ENEMY
		module REGEX
			INITIATIV   = /<init:[ ](\d+)/i
		end
	end

	module SKILL
		module REGEX
			PASSIV 	= /<passiv>/i
		end
	end

	module STATE
		module REGEX
		end

		ABR_BONUS = ["HP", "WC", "HIT", "DMG", "EVA"]
	end
end

#==============================================================================
# DataManager
#==============================================================================

module DataManager

  #--------------------------------------------------------------------------
  # alias method: load_database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_edr load_database; end
  def self.load_database
  	load_database_edr
  	load_notetags_edr
  end
  
  #--------------------------------------------------------------------------
  # new method: load_notetags_al
  #--------------------------------------------------------------------------
  def self.load_notetags_edr
  	for weapon in $data_weapons
  		next if weapon.nil?
  		weapon.load_notetags_edr
  	end
  	for armor in $data_armors
  		next if armor.nil?
  		armor.load_notetags_edr
  	end
  	for enemy in $data_enemies
  		next if enemy.nil?
  		enemy.load_notetags_edr
  	end
  	for skill in $data_skills
  		next if skill.nil?
  		skill.load_notetags_edr
  	end
  	for state in $data_states
  		next if state.nil?
  		state.load_notetags_edr
  	end
  end
  
end # DataManager

#==============================================================================
# RPG:BaseItem
#==============================================================================
class RPG::BaseItem 
	attr_accessor :init

	def is_weapon?;  @class == RPG::Weapon;  end
    
	alias initialize_ex initialize
	def initialize
		initialize_ex
		@init = 0
	end
end # BaseItem

#==============================================================================
# RPG::Item
#==============================================================================
class RPG::Item < RPG::UsableItem
end # RPG::Item

#==============================================================================
# RPG::EquipItem
#==============================================================================
class RPG::EquipItem < RPG::BaseItem
	def bhp;	params[0];	end
	def str;	params[2];	end
	def sta;	params[3];	end
	def wid;	params[4];	end
	def fai;	params[5];	end
	def acc;	params[6];	end
	def hon;	params[7];	end
end

#==============================================================================
# RPG::Weapon
#==============================================================================
class RPG::Weapon < RPG::EquipItem
	attr_accessor	:damage_min
	attr_accessor	:damage_max
	attr_accessor	:accuracy
	attr_accessor	:critic
	attr_accessor	:critic_effect
	attr_accessor 	:ap_cost
	attr_accessor	:skills_list
	attr_accessor 	:max_durability

	def cost;		@ap_cost;		end
	def dmin;		@damage_min;	end
	def dmax;		@damage_max;	end
	def skills; 	@skills_list;	end
	def quantity;	@durability;	end
	def mqty;		@max_durability;end

	def load_notetags_edr
		@damage_min 	= 0
		@damage_max 	= 0
		@accuracy 		= 0
		@critic 		= 0
		@critic_effect 	= nil
		@ap_cost 		= 0
		@skills_list 	= []
		lines = self.note.split(/[\r\n]+/).each { |line|
			case line
			when RKH::ITEM::REGEX::DURABILITY
				@max_durability		= $1.to_i if $1.to_i >= 0
				@durability 		= @max_durability
			when RKH::WEAPON::REGEX::DAMAGE_MIN
				@damage_min 	= $1.to_i if $1.to_i >= 0
			when RKH::WEAPON::REGEX::DAMAGE_MAX
				@damage_max 	= $1.to_i if $1.to_i >= 0
			when RKH::WEAPON::REGEX::ACCURACY
				@accuracy 	 	= $1.to_i if $1.to_i >= 0
			when RKH::WEAPON::REGEX::CRITIC_RATE
				@critic 		= $1.to_i if $1.to_i >= 0
			when RKH::WEAPON::REGEX::CRITIC_EFFECT
				@critic_effect 	= $1.to_i if $1.to_i > 0
			when RKH::WEAPON::REGEX::COST
				@ap_cost		= $1.to_i if $1.to_i >= 0
			when RKH::WEAPON::REGEX::SKILLS_LIST
				line.scan(/\d{1,3}/).each do |value|
					@skills_list.push(value.to_i) if value.to_i > 0
				end
			end
		}
	end
    
	def break_by_durability(actor)
		actor.equips.each_index do |i|
			if actor.equips[i] == self
				actor.change_equip(i, nil)
				$game_party.gain_item(self, -1)
				broken_weapon_text(actor)
				break
			end
		end
	end

	def broken_weapon_text(actor)
		message = "%s's %s broke!" % [actor.name, @non_durability_name]
		puts message
		#SceneManager.scene.log_window.add_text(message)
	end

	def can_repair?
		@durability < @max_durability
	end

	def repair
    	@durability = @max_durability
  	end

  	alias make_price_ex make_price
  	def make_price(price)
    	price = (price * (@durability.to_f / (@max_durability.to_f)))
    	price = (price * 1.20).to_i
    end

	def performance
		mean_dmg 	= 0.5 * (@damage_min + @damage_max) + self.str
		proba		= (@accuracy_rate.to_f + self.acc)/ 100.0
		n_turns		= 100.0 / (@ap_cost.to_f - self.sta + 100.0)
		return mean_dmg * proba * n_turns
	end
end # RPG::Weapon

#==============================================================================
# RPG::Armor
#==============================================================================
class RPG::Armor < RPG::EquipItem

  	def load_notetags_edr
  		@armor = 0
  		self.note[/<armor:[ ](-?\d+)>/i]
  		@armor = $1.to_i if !$1.nil?
  	end

  	def armor;	@armor;	end
end # RPG::Armor

#==============================================================================
# RPG::Skill
#==============================================================================
class RPG::Skill < RPG::UsableItem
	#attr_accessor :passiv

	def load_notetags_edr
		@passiv = false
		self.note[RKH::SKILL::REGEX::PASSIV]
		@passiv = $1 ? true : false
		#lines = self.note.split(/[\r\n]+/).each { |line|
		#	case line
		#	when RKH::SKILL::REGEX::PASSIV
		#		@passiv = true
			#when RKH::SKILL::REGEX::SKILLS
			#	line.scan(/\d{1,3}/).each do |value|
			#		@require_skills.push(value.to_i) if value.to_i > 0
			#	end
			#when RKH::SKILL::REGEX::LEVEL
			#	@require_level = $1.to_i
			#when RKH::SKILL::REGEX::PARAMS
			#	line.scan(/\d{1,2}/).each do |value|
			#		@require_params.push(value.to_i)
			#	end
			#when RKH::SKILL::REGEX::CLASS
			#	line.scan(/\d{1,2}/).each do |class_id|
			#		@require_class.push($data_classes[class_id.to_i]) if class_id.to_i > 0
			#	end
		#	end
		#}
	end

	def passiv?;	@passiv 	;end

end # RPG::Skill



#==============================================================================
# RPG::Enemy
#==============================================================================
class RPG::Enemy < RPG::BaseItem
	#attr_accessor :weapons 
	#attr_accessor :armors
	#attr_accessor :weak
	#attr_accessor :strong
	#attr_accessor :level

	def load_notetags_edr
		@init = 4
		self.note[RKH::ENEMY::REGEX::INITIATIV]
		@init = $1.to_i unless $1.nil?
		#@weapons = []
		#@armors = []
		#lines = self.note.split(/[\r\n]+/).each { |line|
		#	case line
			#when RKH::ENEMY::REGEX::WEAPONS
			#	@weapons.push($data_weapons[$1.to_i]) 
			#when RKH::ENEMY::REGEX::ARMORS
			#	@armors.push($data_armors[$1.to_i]) if $1.to_i < 999
			#when RKH::ENEMY::REGEX::WEAK
			#	case $1
			#	when "C"; @weak = RKH::ENEMY::BLUNT
			#	when "P"; @weak = RKH::ENEMY::PIERCE
			#	when "T"; @weak = RKH::ENEMY::SHARP
			#	else; next
			#	end
			#when RKH::ENEMY::REGEX::STRONG
			#	case $1
			#	when "C"; @strong = RKH::ENEMY::BLUNT
			#	when "P"; @strong = RKH::ENEMY::PIERCE
			#	when "T"; @strong = RKH::ENEMY::SHARP
			#	else; next
			#	end
			#when RKH::ENEMY::REGEX::LEVEL
			#	@level = $1.to_i
			#when RKH::ENEMY::REGEX::INITIATIV
			#	@init = $1.to_i
			#end
		#}			
	end

	def init;	@init;	end
end # RPG::Enemy

#==============================================================================
# RPG::State
#==============================================================================
class RPG::State < RPG::BaseItem
	attr_accessor :bonuses
	attr_accessor :type

	def load_notetags_edr
		@type = 1
		@bonuses = Hash.new
		RKH::STATE::ABR_BONUS.each_with_index { |param, i|
			self.note[/<param_#{param}:[ ](-?\d+)>/]
			@bonuses[param] = $1.to_i if !$1.nil?
		}
		@type = -1 if self.note[/<negativ>/i]
	end

	def bonuses;	@bonuses;	end
end # RPG::State

#==============================================================================
# RPG::Class
#==============================================================================
class RPG::Class < RPG::BaseItem
end