#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It used within the Game_Troop class 
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler

  alias initialize_ex initialize
  def initialize(index, enemy_id)
    initialize_ex(index, enemy_id)
    @weapons = enemy.weapons
    @armors = enemy.armors
    @weak = enemy.weak
    @strong = enemy.strong
    @level = enemy.level
    @init = enemy.init
  end

  def weapons;  @weapons; end
  def armors;   @armors;  end
  def level;    @level;   end
  def init;     @init;    end
  
end