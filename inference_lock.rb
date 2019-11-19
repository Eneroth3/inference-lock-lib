# Mixin for inference lock in tools.
#
# If any of the following Tool API methods are defined in the Tool class,
# they must call `super` for this mixin to function:
# * `activate`
# * `onKeyDown`
# * `onKeyUp`
# * `onKeyUp`
# * `onMouseMove`
#
# `current_ip` must be implemented by the Tool class for this mixin to function.
#
# `start_ip` may be implemented for finer control.
module InferenceLock
  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def activate
    @axis_lock = nil
    @mouse_x = nil
    @mouse_y = nil
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def onKeyDown(key, _repeat, _flags, view)
    axes = view.model.axes
    case key
    when CONSTRAIN_MODIFIER_KEY
      view.lock_inference(current_ip) if current_ip && !@axis_lock
    when VK_RIGHT
      lock_inference_axis([start_ip.position, axes.xaxis], view) if start_ip
    when VK_LEFT
      lock_inference_axis([start_ip.position, axes.yaxis], view) if start_ip
    when VK_UP
      lock_inference_axis([start_ip.position, axes.zaxis], view) if start_ip
    end
    onMouseMove(0, @mouse_x, @mouse_y, view)
    view.invalidate
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def onKeyUp(key, _repeat, _flags, view)
    return unless key == CONSTRAIN_MODIFIER_KEY
    return if @axis_lock

    # Unlock inference.
    view.lock_inference
    onMouseMove(0, @mouse_x, @mouse_y, view)
    view.invalidate
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def onMouseMove(_flags, x, y, _view)
    # Memorize mouse positions to emulate a mouse move when inference is locked
    # or unlocked.
    @mouse_x = x
    @mouse_y = y
  end

  # Get reference to currently active InputPoint
  # (the one picking a position onMouseMove).
  # Used for constraint (Shift) lock.
  #
  # This method MUST be overridden with a method in your tool class.
  #
  # @return [Sketchup::InputPoint, nil]
  #   nil denotes constraint lock isn't currently available.
  def current_ip
    raise NotImplementedError "Override this method in class using mixin."
  end

  # Get reference to currently InputPoint of operation start.
  # Used for axis lock.
  #
  # This method MAY be overridden with a method in your tool class.
  #
  # @return [Sketchup::InputPoint, nil] Defaults to `current_ip`.
  #   nil denotes axis lock isn't currently available.
  #   For instance, in native Move tool axis lock isn't available until the
  #   first point is selected.
  def start_ip
    current_ip
  end

  private

  # Unlock inference lock to axis if there is any.
  #
  # @param view [Sketchup::view]
  def unlock_axis(view)
    # Any inference lock not done with `lock_inference_axis`, e.g. to the
    # tool's primary InputPoint, should be kept.
    return unless @axis_lock
    @axis_lock = nil
    view.lock_inference
  end

  # Lock inference to an axis or unlock if already locked to that very axis.
  #
  # @param line [Array<(Geom::Point3d, Geom::Vector3d)>]
  # @param view [Sketchup::View]
  def lock_inference_axis(line, view)
    return unlock_axis(view) if line == @axis_lock

    @axis_lock = line
    view.lock_inference(
      Sketchup::InputPoint.new(line[0]),
      Sketchup::InputPoint.new(line[0].offset(line[1]))
    )
  end
end
