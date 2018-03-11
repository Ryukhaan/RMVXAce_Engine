module RKH
	module WEAPON
		BOTH 	= 1
		MELEE 	= 2
		RANGE 	= 3


		MAGIC 	= 0
		PIERCE 	= 1
		SHARP 	= 2

		module REGEX
			TYPE 			= /<type:[ ]([MPT])>/i
			DAMAGE  		= /<damage:[ ](\d+)>/i
			RANGE 			= /<range:[ ]([BMR])>/i
			CRITIC_RANGE 	= /<critic_range:[ ].*>/i
			CRITIC_DAMAGE 	= /<critic_damage:[ ](\d+)>/i
			CRITIC_EFFECT 	= /<critic_effect:[ ](-?\d+)>/i
			COST 			= /<cost:[ ](\d+)>/i
		end
	end

	module ENEMY
		BLUNT 	= "C"
		PIERCE 	= "P"
		SHARP	= "T"
		module REGEX
			WEAPONS 	= /<weapons:[ ](\d+)>/i
			ARMORS 		= /<armors:[ ](\d+)>/i
			WEAK 		= /<weak:[ ]([CPT])>/i
			STRONG 		= /<strong:[ ]([CPT])>/i 
			LEVEL 		= /<level:[ ](\d+)>/i  
			INITIATIV   = /<init:[ ](\d+)/i
		end
	end

	module SKILL
		module REGEX
			PASSIV 	= /<passiv>/i
			LEVEL 	= /<level:[ ](\d+)>/i
			SKILLS 	= /<skills:[ ].*>/i
			PARAMS 	= /<params:[ ].*>/i
			CLASS 	= /<class:[ ](\w+)>/i
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
# RPG::Weapon
#==============================================================================
class RPG::Weapon < RPG::EquipItem
	attr_accessor :range
	attr_accessor :damage
	attr_accessor :type
	attr_accessor :critic_range
	attr_accessor :critic_damage
	attr_accessor :critic_effect
	attr_accessor :cost

	def load_notetags_edr
		@critic_range = []
		@critic_effect = nil
		@type = nil
		@range = nil
		lines = self.note.split(/[\r\n]+/).each { |line|
			case line
			when RKH::WEAPON::REGEX::TYPE
				case $1
				when "M"; @type = RKH::WEAPON::MAGIC
				when "P"; @type = RKH::WEAPON::PIERCE
				when "T"; @type = RKH::WEAPON::SHARP
				else; next
				end
			when RKH::WEAPON::REGEX::RANGE
				case $1
				when "B"; @range = RKH::WEAPON::BOTH
				when "M"; @range = RKH::WEAPON::MELEE
				when "R"; @range = RKH::WEAPON::RANGE
				else; next
				end
			when RKH::WEAPON::REGEX::DAMAGE
				@damage = $1.to_i
			when RKH::WEAPON::REGEX::CRITIC_RANGE
				line.scan(/\d{2}/).each do |value|
					@critic_range.push(value.to_i) if !value.nil?
				end
			when RKH::WEAPON::REGEX::CRITIC_DAMAGE
				@critic_damage = $1.to_i
			when RKH::WEAPON::REGEX::CRITIC_EFFECT
				@critic_effect = $1.to_i if $1.to_i >= 0
			when RKH::WEAPON::REGEX::COST
				@cost = $1.to_i
			end
		}
	end

	def performance
		turns = (100 / @cost.to_f)
		(1 + @damage) / 2 * (turns / (turns + 1.0))
	end
end # RPG::Weapon

#==============================================================================
# RPG::Skill
#==============================================================================
class RPG::Skill < RPG::UsableItem
	attr_accessor :passiv
	attr_accessor :require_skills
	attr_accessor :require_level
	attr_accessor :require_params
	attr_accessor :require_class

	def load_notetags_edr
		@passiv = false
		@require_skills = []
		@require_level = 0
		@require_params = []
		@require_class = []
		lines = self.note.split(/[\r\n]+/).each { |line|
			case line
			when RKH::SKILL::REGEX::PASSIV
				@passiv = true
			when RKH::SKILL::REGEX::SKILLS
				line.scan(/\d{1,3}/).each do |value|
					@require_skills.push(value.to_i) if value.to_i > 0
				end
			when RKH::SKILL::REGEX::LEVEL
				@require_level = $1.to_i
			when RKH::SKILL::REGEX::PARAMS
				line.scan(/\d{1,2}/).each do |value|
					@require_params.push(value.to_i)
				end
			when RKH::SKILL::REGEX::CLASS
				line.scan(/\d{1,2}/).each do |class_id|
					@require_class.push($data_classes[class_id.to_i]) if class_id.to_i > 0
				end
			end
		}
	end

	def is_passiv?	;	@passiv 		;end
	def level 		;	@require_level	;end
	def class_id	;	@require_class	;end
	def params 		;	@require_params	;end
	def skills 		;	@require_skills	;end

end # RPG::Skill

#==============================================================================
# RPG::Item
#==============================================================================
class RPG::Item < RPG::UsableItem
end # RPG::Item

#==============================================================================
# RPG::Armor
#==============================================================================
class RPG::Armor < RPG::EquipItem
	attr_accessor :damage_reduction
  
  	def load_notetags_edr
  		@damage_reduction = 0
  		self.note[/<DR:[ ](-?\d+)>/i]
  		@damage_reduction = $1.to_i if !$1.nil?
  	end
end # RPG::Armor


#==============================================================================
# RPG:BaseItem
#==============================================================================
class RPG::BaseItem 
	attr_accessor :init

	alias initialize_ex initialize
	def initialize
		initialize_ex
		@init = 0
	end
end # BaseItem

#==============================================================================
# RPG::Enemy
#==============================================================================
class RPG::Enemy < RPG::BaseItem
	attr_accessor :weapons 
	attr_accessor :armors
	attr_accessor :weak
	attr_accessor :strong
	attr_accessor :level

	def load_notetags_edr
		@weapons = []
		@armors = []
		lines = self.note.split(/[\r\n]+/).each { |line|
			case line
			when RKH::ENEMY::REGEX::WEAPONS
				@weapons.push($data_weapons[$1.to_i]) 
			when RKH::ENEMY::REGEX::ARMORS
				@armors.push($data_armors[$1.to_i]) if $1.to_i < 999
			when RKH::ENEMY::REGEX::WEAK
				case $1
				when "C"; @weak = RKH::ENEMY::BLUNT
				when "P"; @weak = RKH::ENEMY::PIERCE
				when "T"; @weak = RKH::ENEMY::SHARP
				else; next
				end
			when RKH::ENEMY::REGEX::STRONG
				case $1
				when "C"; @strong = RKH::ENEMY::BLUNT
				when "P"; @strong = RKH::ENEMY::PIERCE
				when "T"; @strong = RKH::ENEMY::SHARP
				else; next
				end
			when RKH::ENEMY::REGEX::LEVEL
				@level = $1.to_i
			when RKH::ENEMY::REGEX::INITIATIV
				@init = $1.to_i
			end
		}			
	end
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