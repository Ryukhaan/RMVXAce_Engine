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
  # *~ OVERWRITE Test Effect
  #--------------------------------------------------------------------------
  def item_effect_test(user, item, effect)
    case effect.code
    when EFFECT_RECOVER_HP
      hp < mhp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_RECOVER_MP
      mp < mmp || effect.value1 < 0 || effect.value2 < 0
    when EFFECT_ADD_STATE
      !state?(effect.data_id)
    when EFFECT_REMOVE_STATE
      state?(effect.data_id)
    when EFFECT_ADD_BUFF
      !buff_max?(effect.data_id)
    when EFFECT_ADD_DEBUFF
      !debuff_max?(effect.data_id)
    when EFFECT_REMOVE_BUFF
      buff?(effect.data_id)
    when EFFECT_REMOVE_DEBUFF
      debuff?(effect.data_id)
    when EFFECT_LEARN_SKILL
      actor? && !skills.include?($data_skills[effect.data_id]) &&
        learn?($data_skills[effect.data_id])
    else
      true
    end
  end
  
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Addable State
  #--------------------------------------------------------------------------
  alias state_addable_ex state_addable?
  def state_addable?(state_id)
    possible = state_addable_ex(state_id)
    dice = 1 + Random.rand(20)
    resist = modificateur(foi) + 4
    $data_states[state_id].type < 0 ? possible && (dice > resist) : possible
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Use Skill/Item
  #    Called for the acting side and applies the effect to other than the user.
  #--------------------------------------------------------------------------
  def use_item(item)
    pay_skill_cost(item) if item.is_a?(RPG::Skill)
    consume_item(item)   if item.is_a?(RPG::Item)
    item.effects.each {|effect| item_global_effect_apply(effect) }
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Determine Action Speed
  #--------------------------------------------------------------------------
  def make_speed
    @speed = @init + Random.rand(10)
    #@speed = 4 + Random.rand(5)
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
    self.tp = self.tp
    self.tp += self.level if foi > 8
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE  Apply Effect of Skill/Item
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    @result.clear
    @result.used = item_test(user, item)
    if item.is_a?(RPG::Item) || item.nil?
      make_heal_value(user, item)
      execute_damage(user)
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      return item_user_effect(user, item)
    elsif item.magical? || item.physical?
      hit_rate = item_estimate_hit_rate(user, item)
      @result.evaded = (hit_rate < evasion)
    end

    if @result.hit?
      unless item.damage.none? 
        if item.physical?
          make_physical_damage(user, item)
        elsif item.magical?
          make_magical_damage(user, item)
        else
          make_heal_value(user, item)
        end
        execute_damage(user)
      end
      item.effects.each {|effect| item_effect_apply(user, item, effect) }
      item_user_effect(user, item)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Calculate Heal
  #--------------------------------------------------------------------------
  def make_heal_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value *= rec if item.damage.recover?
    @result.make_damage(value.to_i, item)
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Calculate Magical Damage
  #--------------------------------------------------------------------------
  def make_magical_damage(user, item)
    value = item.damage.eval(user, self, $game_variables)
    value += modificateur(user.int)
    if @result.critical
      2.times do 
        value += item.damage.eval(user, self, $game_variables)
        value += modificateur(user.foi)
      end
    end
    value *= rec if item.damage.recover?
    value *= item_element_rate(user, item)
    @result.make_damage(value.to_i, item)
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Calculate Physical Damage
  #--------------------------------------------------------------------------
  def make_physical_damage(user, item)
    if user.weapons[0].nil?
      return 1
    end
    weapon = user.weapons[0]
    value = 1 + Random.rand(weapon.damage)
    value += 1 + Random.rand(user.weapons[1].damage) if user.dual_wield? && !user.weapons[1].nil?
    value += modificateur(user.for) if (weapon.range <= 2) # Melee=2, Both=1
    if @result.critical
      (weapon.critic_damage - 1).times do 
        value += 1 + Random.rand(weapon.damage)
        value += modificateur(user.hon)
      end
      add_state(weapon.critic_effect) unless weapon.critic_effect.nil?
    end
    value -= 4 if user.dual_wield? # && !passiv.dual_wield
    value += state_bonuses(user, "DMG")
    value += armors[0].damage_reduction if !armors.empty?
    value = [value, 1].max
    @result.make_damage(value.to_i, item)
  end

  #--------------------------------------------------------------------------
  # *~ Calculate Hit Rate
  #--------------------------------------------------------------------------
  def item_estimate_hit_rate(user, item)
    weapon = user.weapons[0]
    # Dice throw
    value = 1 + Random.rand(20) 
    # Critic or Fumble ?
    value = item_cri_or_fumble(value, weapon)
    # Real Hit Rate
    value = user.dex + user.level
    value += item_range_physical(user, item, weapon) if !weapon.nil?
    value += modificateur(user.foi) if item.magical? 
    value += state_bonuses(user, "HIT")
    if evasion - value > 0
      value += 1 + Random.rand(6)
    else
      value -= 1 + Random.rand(6)
    end
    puts "EVA : " + evasion.to_s + " vs HIT : " + value.to_s
    return value
  end

  def item_cri_or_fumble(value, weapon)
    @result.critical = true if weapon.critic_range.include? value
    @result.fumble = true if value == 0
    value
  end

  def item_range_physical(user, item, weapon)
    # If weapon is Range or Both
    if item.physical? and (weapon.range == 1 or weapon.range == 3)
      return modificateur(user.dex)
    end
    return 0
  end

end