# [127] 78613186: RKH - Game_Actor
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It is used within the Game_Actors class
# ($game_actors) and is also referenced from the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler

  def learn?(skill)
    value = true
    value = value && (@level >= skill.level)
    unless skill.class_id.empty?
      temp = skill.class_id.map { |x| 
        x == @class_id
      }.any?
      value = value && temp
    end
    unless skill.skills.empty?
      temp = skill.skills.map { |x| 
        @skills.include?(x)
      }.all?
      value = value && temp
    end
    skill.params.each_with_index { |param, index|
      value = value && (param_alone(index) >= param)
    }
    value
  end
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Object Initialization
  #--------------------------------------------------------------------------
  alias initialize_ex initialize
  def initialize(actor_id)
    initialize_ex(actor_id)
    @init = 4
  end

  def param_alone(param_id)
    self.param(param_id)
  end
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Get Added Value of Parameter
  #--------------------------------------------------------------------------

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Get Equipment Slot Array
  #--------------------------------------------------------------------------
  def equip_slots
    return [0,0,3] if dual_wield?       # Dual wield
    return [0,1,3]                      # Normal
  end

  # *~ OVERWRITE
  def esquive
    if armors.length == 1
      return con + modificateur(dex) + level + armors[0].params[3]
    else
      return con + modificateur(dex) + level
    end
  end

  alias jet_attaque_ex jet_attaque
  def jet_attaque(user, item)
    value = jet_attaque_ex(user, item)
    unless user.enemy?
      user.skills.each { |skill|
        if skill.passiv?
          puts "Passiv Skill"
        end
      } 
    end
    return value
  end

  #--------------------------------------------------------------------------
  # * Learn Skill
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
        @skills.push(skill_id) if learn?($data_skills[skill_id])
        @skills.sort!
    end
  end
end