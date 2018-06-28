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
  alias :str  :atk
  alias :sta  :def 
  alias :wid  :mat
  alias :fai  :mdf
  alias :acc  :agi
  alias :hon  :luk

  #--------------------------------------------------------------------------
  # * Calculate Weapon's TP Cost
  #--------------------------------------------------------------------------
  def weapon_tp_cost(weapon, weapon2 = nil)
    unless self.enemy?
      # Dual wield and has a second weapon
      if dual_wield? && !weapon2.nil?
        return weapon.ap_cost + weapon2.ap_cost
      # Normal attack
      else
        return weapon.ap_cost unless weapon.nil?
      end
      # Add bonuses or maluses
      #cost += state_bonuses(self, "WC") 
    end
    return 0
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Determine if Cost of Using Skill Can Be Paid
  #--------------------------------------------------------------------------
  alias skill_cost_payable_ex skill_cost_payable?
  def skill_cost_payable?(skill)
    payable = skill_cost_payable_ex(skill)
    # Skill cost except for Repos (skill id 2) or a magical skill
    unless (skill.id == 2)
      if !dual_wield?
        return payable && tp >= weapon_tp_cost(self.weapons[0])
      else 
        return payable && tp >= weapon_tp_cost(self.weapons[0], self.weapons[1])
      end
    end
    return payable
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Calculate Skill's TP Cost
  #--------------------------------------------------------------------------
  alias skill_tp_cost_ex skill_tp_cost
  def skill_tp_cost(skill)
    skill_cost = skill_tp_cost_ex(skill)
    # Skill is Repos
    return 0 if skill.id == 2
    # Skill is physial and have no cost, then take weapon cost
    if skill.physical? && skill_cost == 0
      return weapon_tp_cost(self.weapons[0], self.weapons[1]) if dual_wield?
      return weapon_tp_cost(self.weapons[0]) if !dual_wield?
    end
    return skill_cost if skill.magical? || skill.certain?
    return 0
  end

  #--------------------------------------------------------------------------
  # * Calculate Evade Rate
  #--------------------------------------------------------------------------
  def evasion
    # Derivated Stat
    value = 0
    # Add bonuses or maluses
    value += state_bonuses(self, "EVA")
    [value, 0].max
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