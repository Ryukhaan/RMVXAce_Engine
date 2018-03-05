#==============================================================================
# ** Sprite_Character
#------------------------------------------------------------------------------
#  This sprite is used to display characters. It observes an instance of the
# Game_Character class and automatically changes sprite state.
#==============================================================================

class Sprite_Character < Sprite_Base

  #--------------------------------------------------------------------------
  # *~ OVERWRITE Set Character Bitmap
  #--------------------------------------------------------------------------
  def set_character_bitmap
    self.bitmap = Cache.character(@character_name)
    sign = @character_name[/^[\!\$]./]
    if sign && sign.include?('$')
      @cw = bitmap.width / 3
      @ch = bitmap.height / 4
    else
      #@cw = bitmap.width / 12
      # ADD ~ Didn't remember why I changed those lines x)
      @cw = bitmap.width / 12 # 32
      @ch = bitmap.height / 8 # 32
    end
    self.ox = @cw / 2
    self.oy = @ch
  end
  #--------------------------------------------------------------------------
  # *~ Update Transfer Origin Rectangle
  #--------------------------------------------------------------------------
  def update_src_rect
    if @tile_id == 0
      index = @character.character_index
      # We only want 2 pattern, not 3 !
      pattern = @character.pattern % 2
      #ADD ~
      sx = (index % 4 * 3 + pattern) * @cw
      sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
    end
  end
  #--------------------------------------------------------------------------
  # *~ OVERWRITE Move Animation
  #--------------------------------------------------------------------------
  def move_animation(dx, dy)
    # ADD ~ Because we have 2 pattern now !
    if @animation && @animation.position != 2
      @ani_ox += dx
      @ani_oy += dy
      @ani_sprites.each do |sprite|
        sprite.x += dx
        sprite.y += dy
      end
    end
  end
end