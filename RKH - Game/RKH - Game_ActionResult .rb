# [22] 34130116: Game_ActionResult
#==============================================================================
# ** Game_ActionResult
#------------------------------------------------------------------------------
#  This class handles the results of battle actions. It is used internally for
# the Game_Battler class. 
#==============================================================================

class Game_ActionResult
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Determine Final Hit 
  #--------------------------------------------------------------------------
  def hit?
    (@used && !@missed && !@evaded ) || @critical
  end
end