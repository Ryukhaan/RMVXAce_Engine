#==============================================================================
# ** All Window and Scene for Shop
#------------------------------------------------------------------------------
#  This window is for selecting buy/sell on the shop screen.
#==============================================================================
module Vocab
  ShopRepair = "Réparer"
end

class Window_ShopBuy 
end

class Window_ShopCommand < Window_HorzCommand
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::ShopBuy,    :buy)
    add_command(Vocab::ShopRepair, :repair)
    add_command(Vocab::ShopSell,   :sell,   !@purchase_only)
    add_command(Vocab::ShopCancel, :cancel)
  end
end

# [75] 52413940: Window_ShopRepair
#==============================================================================
# ** Window_ShopRepair
#------------------------------------------------------------------------------
#  This window displays a list of items in possession for repairing on the shop
# screen.
#==============================================================================
class Window_ShopRepair < Window_ItemList

  def enable?(item)
    return true if item.is_a?(RPG::Weapon) && $game_party.gold >= item.price
    return false
  end
  
  def update_help
    unless item
      @help_window.set_text("Aucun objet seletionné")
    else
      if item.price.zero?
        @help_window.set_text("Non reparabe")
      else
        @help_window.set_text("Coute " + item.price.to_s + Vocab.currency_unit)
      end
    end
  end
  
  #def include?(item)
  #  !item.is_a?(RPG::Item) && !item.nil? && item.use_durability
  #end
end

# [114] 40350342: Scene_Shop
#==============================================================================
# ** Scene_Shop
#------------------------------------------------------------------------------
#  This class performs shop screen processing.
#==============================================================================

class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  alias start_ex start
  def start
    start_ex
    create_repair_window
  end

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Create Dummy Window
  #--------------------------------------------------------------------------
  def create_dummy_window
    wy = @command_window.y + @command_window.height
    wh = Graphics.height - wy
    @dummy_window = Window_Base.new(0, wy, Graphics.width, wh)
    @dummy_window.viewport = @viewport
    @dummy_window.hide
  end
  #--------------------------------------------------------------------------
  # *~OVERWRITE Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_ShopCommand.new(@gold_window.x, @purchase_only)
    @command_window.viewport = @viewport
    @command_window.y = @help_window.height
    @command_window.set_handler(:buy,    method(:command_buy))
    @command_window.set_handler(:repair, method(:command_repair))
    @command_window.set_handler(:sell,   method(:command_sell))
    @command_window.set_handler(:cancel, method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * Create Repair Window
  #--------------------------------------------------------------------------
  def create_repair_window
    wy = @dummy_window.y
    wh = @dummy_window.height
    @repair_window = Window_ShopRepair.new(0, wy, Graphics.width, wh)
    @repair_window.viewport = @viewport
    @repair_window.help_window = @help_window
    @repair_window.hide
    @repair_window.set_handler(:ok,     method(:on_repair_ok))
    @repair_window.set_handler(:cancel, method(:on_repair_cancel))
    @repair_window.category = :weapon
  end
  
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Buy [Cancel]
  #--------------------------------------------------------------------------
  def on_buy_cancel
    @command_window.activate
    #@dummy_window.show
    @buy_window.hide
    @status_window.hide
    @status_window.item = nil
    @help_window.clear
  end
  
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Category [Cancel]
  #--------------------------------------------------------------------------
  def on_category_cancel
    @command_window.activate
    #@dummy_window.show
    @category_window.hide
    @sell_window.hide
  end
  
  #--------------------------------------------------------------------------
  # * [Repair] Command
  #--------------------------------------------------------------------------
  def command_repair
    #@category_window.show
    #@category_window.activate
    @repair_window.refresh
    @repair_window.show.activate
    @status_window.hide
    @dummy_window.hide
    @repair_window.select(0)
  end
  ##--------------------------------------------------------------------------
  ## * Repair [OK]
  ##--------------------------------------------------------------------------
  def on_repair_ok
    @item = @repair_window.item
    $game_party.lose_gold(@item.make_price(@item.price))
    @item.repair
    @gold_window.refresh
    on_item_sound
    @repair_window.refresh
  end
  ##--------------------------------------------------------------------------
  ## * Repair [Cancel]
  ##--------------------------------------------------------------------------
  def on_repair_cancel
    @repair_window.unselect
    @repair_window.hide
    #@category_window.hide
    @status_window.item = nil
    @help_window.clear
    @dummy_window.hide
    @command_window.activate
  end
  
  def on_item_sound
    RPG::SE.stop
    sound_effect = ['Bell2',100,100]
    RPG::SE.new(sound_effect[0], sound_effect[1], sound_effect[2]).play
  end
end