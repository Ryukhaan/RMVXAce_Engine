# [89] 73168615: Window_BattleStatus
#==============================================================================
# ** Window_BattleStatus
#------------------------------------------------------------------------------
#  This window is for displaying the status of party members on the battle
# screen.
#==============================================================================

class Window_BattlePartyStatus < Window_Base
    #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    self.openness = 0
    refresh
  end

  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - fitting_height(4)
  end

  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    fitting_height(visible_line_number)
  end

  #--------------------------------------------------------------------------
  # * Get Number of Lines to Show
  #--------------------------------------------------------------------------
  def visible_line_number
    return 8
  end

  #--------------------------------------------------------------------------
  # * Actor Settings
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end

  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    $game_party.battle_members.size
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_all_items
  end
  
  #--------------------------------------------------------------------------
  # * Draw All Items
  #--------------------------------------------------------------------------
  def draw_all_items
    item_max.times {|i| draw_item(i) }
  end

  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.battle_members[index]
    dy = (2 * index + 1)
    draw_actor_name(actor, 0, dx * line_height)
    draw_actor_image(actor, 32, (dx+1) * line_height)
    draw_actor_icons(actor,  96, dx * line_height)
    draw_actor_hp(actor, 130, dx * line_height)
    draw_actor_stamina(actor, 130, (dx+1) * line_height)
  end

  def draw_actor_image(actor, x, y)
    actor_name = actor.character_name
    actor_index = actor.character_index
    draw_character(actor_name, actor_index, x , y)
  end

  #--------------------------------------------------------------------------
  # * Draw HP
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y)
    change_color(system_color)
    rect = Rect.new(x, y, window_width - 16, line_height)
    draw_text(rect, actor.hp.to_s + "/" + actor.mhp.to_s, 1)
  end

  #--------------------------------------------------------------------------
  # * Draw Stamina
  #--------------------------------------------------------------------------
  def draw_actor_stamina(actor, x, y)
    change_color(system_color)
    rect = Rect.new(x, y, window_width - 16, line_height)
    draw_text(rect, actor.tp.to_s + "/" + 100.to_s, 1)
  end
end
