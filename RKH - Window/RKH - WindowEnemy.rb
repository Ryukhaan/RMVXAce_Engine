#==============================================================================
# ■ Window_BattleEnemy
#==============================================================================
class Window_BattleEnemy < Window_Selectable
#  #--------------------------------------------------------------------------
#  # ● 項目の描画
#  #--------------------------------------------------------------------------
#  alias draw_item_fv draw_item
#  def draw_item(index)
#    draw_hp(index)
#    draw_item_fv(index)
#  end
#  #--------------------------------------------------------------------------
#  # ● HPの描画
#  #--------------------------------------------------------------------------
#  def draw_hp(index)
#    rect = item_rect_for_text(index)
#    w = rect.width - 60
#    x = rect.x + 30
#    hp = $game_troop.alive_members[index].hp_rate
#    draw_gauge(x, rect.y, w, hp, hp_gauge_color1, hp_gauge_color2)
#  end
end