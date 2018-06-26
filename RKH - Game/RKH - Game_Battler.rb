# [126] 47381624: RKH - Game_Battler
#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  A battler class with methods for sprites and actions added. This class 
# is used as a super class of the Game_Actor class and Game_Enemy class.
#==============================================================================

class Game_Battler < Game_BattlerBase
  attr_accessor :init
  
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Addable State
  #--------------------------------------------------------------------------
  alias state_addable_ex state_addable?
  def state_addable?(state_id)
    possible  = state_addable_ex(state_id)
    nrand     = 1 + Random.rand(100)
    $data_states[state_id].type < 0 ? possible && (dice < resist) : possible
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Determine Action Speed
  #--------------------------------------------------------------------------
  def make_speed
    @speed = @init + (Random.rand(3) - 1)
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Initialize TP
  #--------------------------------------------------------------------------
  def init_tp
    self.tp = 100
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Charge TP by Damage Suffered
  #--------------------------------------------------------------------------
  def charge_tp_by_damage(damage_rate)
    0
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Regenerate TP
  #--------------------------------------------------------------------------
  def regenerate_tp
    self.tp = self.tp + self.stamina
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE  Apply Effect of Skill/Item
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)

    # Item Calculate
    if item.is_a?(RPG::Item) || item.nil?
      make_certain_value(user, item)
      execute_damage(user)
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      return item_user_effect(user, item)
    end

    # Skill Calculate Hit Rate
    if item.physical? || item.magical?
      @result.evaded = hit_rate(user, item)
    else
      @result.evaded = false
    end

    # Calculate and apply damage
    if @result.hit?
      unless item.damage.none?
        make_damage_value(user, item)
        execute_damage(user)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Damage
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value -= armors[0].damage_reduction unless armors.empty?
    value *= item_element_rate(user, item)
    if @result.critical
      value = apply_critical(value)
      unless user.weapons[0].nil?
        add_state(user.weapons[0].critic_effect) unless user.weapons[0].critic_effect.nil?
      end
    end
    @result.make_damage(value.to_i, item)
    user.process_weapon_durability(item) if user.actor? && @result.hit?
  end

  def process_weapon_durability(item)
    return unless item.is_a?(RPG::Skill)
    weapons.each do |i|
      next unless can_process_weapon_durability(i, item)
      process_individual_weapon_durability(i, item)
    end
  end

  def can_process_weapon_durability(weapon, skill)
    return weapon ? true : false
  end
  
  def process_individual_weapon_durability(weapon, skill)
    weapon.durability -= weapon_durability_cost(weapon, skill)
    weapon.durability = 0 if weapon.durability < 0
    weapon.refresh_name
    weapon.refresh_price
    weapon.break_by_durability(self) if weapon.durability.zero?
  end

  def weapon_durability_cost(weapon, skill)
    return weapon.skills_list.include?(skill.id) ? 1 : 0
    #cost = skill.weapon_durability_cost
    #cost += weapon.skill_durability_mod(skill.id)
    #cost = 0 if cost < 0 #Make sure no negatives
    #return cost
  end

  #--------------------------------------------------------------------------
  # *~ Calculate Hit Rate
  #--------------------------------------------------------------------------
  def hit_rate(user, item)
    # Critic hit
    is_critical?(user)

    # Hit Rate Estimation
    value  = 1 + Random.rand(100)
    return (value >= user.weapons[0].accuracy) unless user.weapons[0].nil?
    return false
  end


  #--------------------------------------------------------------------------
  # *~ Estimate if skill is a critical hit
  #--------------------------------------------------------------------------
  def is_critical?(user)
    value = 1 + Random.rand(100)
    @result.critical = (value <= user.honour) if user.enemy?
    if user.actor?
      if user.weapons[0].nil?
        @result.critical = false
      else
        @result.critical = (value <= user.weapons[0].critic + user.honour) 
      end
    end 
  end

end