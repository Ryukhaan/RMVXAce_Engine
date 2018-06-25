# [127] 78613186: RKH - Game_Actor
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It is used within the Game_Actors class
# ($game_actors) and is also referenced from the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler


  #--------------------------------------------------------------------------
  # *~ OVERWRITE Equippable 
  #--------------------------------------------------------------------------
  alias :equippable_ex :equippable?
  def equippable?(item)
    return equippable_ex(item) if item.is_a?(RPG::EquipItem) #&& item.is_template?
    return false if item.is_a?(RPG::Weapon) && item.durability.zero?
    return equippable_ex(item)
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Object Initialization
  #--------------------------------------------------------------------------
  alias initialize_ex initialize
  def initialize(actor_id)
    initialize_ex(actor_id)
    @init = 4
  end


  #--------------------------------------------------------------------------
  # *~ OVERWRITE Get Equipment Slot Array
  #--------------------------------------------------------------------------
  def equip_slots
    #return [0,0,3] if dual_wield?       # Dual wield
    return [0,0,3]                      # Normal
  end

  
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Hit Rate
  #--------------------------------------------------------------------------
  def hit_rate(user, item)
        # Critic hit
    is_critical?(user)

    # Hit Rate Estimation
    value = 1 + Random.rand(100)
    eva   = 90 - physical_evasion
    puts "Enemy : " + value.to_s + " vs " + eva.to_s
    return (value >= eva)
  end
  
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Calculate Damage
  #--------------------------------------------------------------------------
  def make_damage_value(user, item)
    value = item.damage.eval(user, self, $game_variables)
    puts "Damage : " + value.to_s
    value *= item_element_rate(user, item)
    if @result.critical
      value = apply_critical(value)
    end
    @result.make_damage(value.to_i, item)
  end
end