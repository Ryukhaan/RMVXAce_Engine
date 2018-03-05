# [22] 34130116: Game_ActionResult
#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  This class handles the results of battle actions. It is used internally for
# the Game_Battler class. 
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :fumble   # Fumble Flag
  
  #--------------------------------------------------------------------------
  # * Clear Hit Flags
  #--------------------------------------------------------------------------
  alias clear_hit_flags_ex clear_hit_flags
  def clear_hit_flags
    clear_hit_flags_ex
    @fumble = false
  end

  #--------------------------------------------------------------------------
  # * Determine Final Hit 
  #--------------------------------------------------------------------------
  def hit?
    @used && !@missed && !@evaded && !@fumble
  end
end
