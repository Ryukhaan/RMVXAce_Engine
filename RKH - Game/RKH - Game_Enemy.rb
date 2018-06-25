#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It used within the Game_Troop class 
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Object Initialization
  #--------------------------------------------------------------------------
  alias initialize_ex initialize
  def initialize(index, enemy_id)
    initialize_ex(index, enemy_id)
    #@weapons = enemy.weapons
    #@armors = enemy.armors
    #@weak = enemy.weak
    #@strong = enemy.strong
    #@level = enemy.level
    @init = enemy.init
  end

  #def weapons;  @weapons; end
  #def armors;   @armors;  end
  #def level;    @level;   end
  def init;     @init;    end


  #--------------------------------------------------------------------------
  # *~ OVERWRITE Calculate Skill's TP Cost
  #--------------------------------------------------------------------------
  def skill_tp_cost(skill)
    return 0
  end
  
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  def skill_cost_payable?(skill)
    tp >= skill_tp_cost(skill) && mp >= skill_mp_cost(skill)
  end
end