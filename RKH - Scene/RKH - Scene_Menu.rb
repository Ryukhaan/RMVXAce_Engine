#==============================================================================
# ** Window_MenuStatus
#------------------------------------------------------------------------------
#  This window displays party member status on the menu screen.
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :pending_index            # Pending position (for formation)
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, window_width, window_height)
    @pending_index = -1
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width - 
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    Graphics.height - 260
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items
  #--------------------------------------------------------------------------
  def item_max
    $game_party.members.size
  end
  #--------------------------------------------------------------------------
  # * Get Item Height
  #--------------------------------------------------------------------------
  def item_height
    (height - standard_padding * 2) / 4
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #--------------------------------------------------------------------------
  def draw_item(index)
    actor = $game_party.members[index]
    enabled = $game_party.battle_members.include?(actor)
    rect = item_rect(index)
    draw_item_background(index)
    draw_actor_simple_status(actor, rect.x, rect.y)
  end
  #--------------------------------------------------------------------------
  # * Draw Background for Item
  #--------------------------------------------------------------------------
  def draw_item_background(index)
    if index == @pending_index
      contents.fill_rect(item_rect(index), pending_color)
    end
  end
  #--------------------------------------------------------------------------
  # * Processing When OK Button Is Pressed
  #--------------------------------------------------------------------------
  def process_ok
    super
    $game_party.menu_actor = $game_party.members[index]
  end
  #--------------------------------------------------------------------------
  # * Restore Previous Selection Position
  #--------------------------------------------------------------------------
  def select_last
    select($game_party.menu_actor.index || 0)
  end
  #--------------------------------------------------------------------------
  # * Set Pending Position (for Formation)
  #--------------------------------------------------------------------------
  def pending_index=(index)
    last_pending_index = @pending_index
    @pending_index = index
    redraw_item(@pending_index)
    redraw_item(last_pending_index)
  end

  def draw_actor_simple_status(actor, x, y)
  	draw_actor_name(actor, x, y)
    draw_actor_icons(actor, x, y + line_height * 2)
    draw_actor_class(actor, x, y + line_height * 1)
    draw_actor_hp(actor, x + 120, y)
  end

  def draw_actor_hp(actor, x, y, width = 94)
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    draw_current_and_max_values(x, y, width, actor.hp, actor.mhp)
  end

  def draw_current_and_max_values(x, y, width, current, max)    
    xr = x + width
    draw_text(xr - 92, y, 42, line_height, current, 2)
    draw_text(xr - 52, y, 12, line_height, "/", 2)
    draw_text(xr - 42, y, 42, line_height, max, 1)
  end

  def item_rect(index)
    rect = super
    rect.x = index * (item_width * 3 + spacing)
    rect.y = 0
    rect
  end

  #--------------------------------------------------------------------------
  # * Move Cursor Down
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Up
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Right
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if index < item_max - col_max || (wrap && col_max == 1)
      select((index + col_max) % item_max)
  	end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Left
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if index >= col_max || (wrap && col_max == 1)
      select((index - col_max + item_max) % item_max)
    end
  end

  #--------------------------------------------------------------------------
  # * Get Leading Digits
  #--------------------------------------------------------------------------
  def top_col
    ox / (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # * Set Leading Digits
  #--------------------------------------------------------------------------
  def top_col=(col)
    col = 0 if col < 0
    col = col_max - 1 if col > col_max - 1
    self.ox = col * (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # * Get Trailing Digits
  #--------------------------------------------------------------------------
  def bottom_col
    top_col + col_max - 1
  end
  #--------------------------------------------------------------------------
  # * Set Trailing Digits
  #--------------------------------------------------------------------------
  def bottom_col=(col)
    self.top_col = col - (col_max - 1)
  end
  #--------------------------------------------------------------------------
  # * Scroll Cursor to Position Within Screen
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_col = index if index < top_col
    self.bottom_col = index if index > bottom_col
  end

  def col_max
    return 3
  end
  #--------------------------------------------------------------------------
  # * Update Cursor
  #--------------------------------------------------------------------------
  def update_cursor
    if @cursor_all
      cursor_rect.set(0, 0, col_max * item_width, contents.height)
      self.top_row = 0
    elsif @index < 0
      cursor_rect.empty
    else
      ensure_cursor_visible
      cursor_rect.set(item_rect(@index))
    end
  end

end

class Scene_Menu < Scene_MenuBase

	def start
		super
		create_background
		create_menu_command
		create_status_window
	end

	#--------------------------------------------------------------------------
	# * Create Background
	#--------------------------------------------------------------------------
	def create_background
		@background_sprite = Sprite.new
		@background_sprite.bitmap = SceneManager.background_bitmap
		@background_sprite.color.set(0, 0, 0, 0)
	end

	#--------------------------------------------------------------------------
	# * Create Menu Command Window
	#--------------------------------------------------------------------------
	def create_menu_command
	    @command_window = Window_MenuCommand.new
	    @command_window.set_handler(:item,      method(:command_item))
	    @command_window.set_handler(:skill,     method(:command_personal))
	    @command_window.set_handler(:equip,     method(:command_personal))
	    @command_window.set_handler(:status,    method(:command_personal))
	    @command_window.set_handler(:save,      method(:command_save))
	    @command_window.set_handler(:game_end,  method(:command_game_end))
	    @command_window.set_handler(:cancel,    method(:return_scene))	
	end
	#--------------------------------------------------------------------------
	# * Create Status Window
	#--------------------------------------------------------------------------
	def create_status_window
		@status_window = Window_MenuStatus.new(0, 0)
		@status_window.y = Graphics.height - @status_window.height
	end

end