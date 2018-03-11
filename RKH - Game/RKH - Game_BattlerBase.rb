# [125] 95829029: RKH - Game_BattlerBase
#==============================================================================
# ** Game_BattlerBase
#------------------------------------------------------------------------------
#  This base class handles battlers. It mainly contains methods for calculating
# parameters. It is used as a super class of the Game_Battler class.
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Access Method by Parameter Abbreviations
  #--------------------------------------------------------------------------  
  alias :for :atk
  alias :eva :def 
  alias :int :mat
  alias :foi :mdf
  alias :dex :agi
  alias :hon :luk

  #--------------------------------------------------------------------------
  # * Calculate Weapon's TP Cost
  #--------------------------------------------------------------------------
  def weapon_tp_cost(weapon, weapon2 = nil)
    return 5 if weapon.nil?
    return weapon.cost + state_bonuses(self, "WC") if !self.enemy? && weapon2.nil?
    return [weapon.cost, weapon2.cost].max + state_bonuses(self, "WC") unless self.enemy?
    return 0
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  alias skill_cost_payable_ex skill_cost_payable?
  def skill_cost_payable?(skill)
    payable = skill_cost_payable_ex(skill)
    return payable if skill.id == 2
    return payable && tp >= weapon_tp_cost(self.weapons[0]) if !dual_wield?
    return payable && tp >= weapon_tp_cost(self.weapons[0], self.weapons[1]) if dual_wield?
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Calculate Skill's TP Cost
  #--------------------------------------------------------------------------
  alias skill_tp_cost_ex skill_tp_cost
  def skill_tp_cost(skill)
    skill_cost = skill_tp_cost_ex(skill)
    return skill_cost if skill.id == 2 # Recharge
    return skill_cost + weapon_tp_cost(self.weapons[0]) 
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Parameter Mod.
  #--------------------------------------------------------------------------
  def modificateur(parameter)
    return parameter / 2
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Evade Rate
  #--------------------------------------------------------------------------
  def evasion
    value = eva + level
    value += state_bonuses(self, "EVA")
    [value, 1].max
  end
  
  #--------------------------------------------------------------------------
  # * Calculate States Bonuses according to a Parameter
  #--------------------------------------------------------------------------
  def state_bonuses(user, param)
    temp = 0
    user.states.each { |state|
      temp += state.bonuses[param] unless state.bonuses[param].nil?
    }
    temp
  end
end
