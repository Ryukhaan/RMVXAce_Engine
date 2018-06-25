# [114] 40350342: Scene_Shop
#==============================================================================
# ** Scene_Shop
#------------------------------------------------------------------------------
#  This class performs shop screen processing.
#==============================================================================

class Scene_Shop < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * Prepare
  #--------------------------------------------------------------------------
  def prepare(goods, purchase_only)
    @goods = goods
    @purchase_only = purchase_only
  end
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  alias start_ex start
  def start
    start_ex
    create_repair_window
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
    @repair_window = Window_ShopRepair.new(0, wy, wh, @goods)
    @repair_window.viewport = @viewport
    @repair_window.help_window = @help_window
    @repair_window.status_window = @status_window
    @repair_window.hide
    @repair_window.set_handler(:ok,     method(:on_repair_ok))
    @repair_window.set_handler(:cancel, method(:on_repair_cancel))
    @repair_window.category = :item
  end

  #--------------------------------------------------------------------------
  # * [Sell] Command
  #--------------------------------------------------------------------------
  def command_repair
    @dummy_window.hide
    @category_window.show.activate
    @repair_window.show
    @repair_window.unselect
    @repair_window.refresh
  end
  #--------------------------------------------------------------------------
  # * Buy [OK]
  #--------------------------------------------------------------------------
  def on_repair_ok
    @item = @repair_window.item
    $game_party.lose_gold(@item.make_price(@item.price))
    @item.repair
    @gold_window.refresh
    on_item_sound
    activate_item_window
    #@buy_window.hide
    #@number_window.set(@item, max_buy, buying_price, currency_unit)
    #@number_window.show.activate
  end
  #--------------------------------------------------------------------------
  # * Buy [Cancel]
  #--------------------------------------------------------------------------
  def on_repair_cancel
    @command_window.activate
    @dummy_window.show
    @repair_window.hide
    @status_window.hide
    @status_window.item = nil
    @help_window.clear
  end
end