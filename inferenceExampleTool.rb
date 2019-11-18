class InferenceExampleTool
  def initialize
    @ip = Sketchup::InputPoint.new
    @axis_lock = nil
  end

  def draw(view)
    @ip.draw(view)
    view.tooltip = @ip.tooltip
  end

  def onMouseMove(_flags, x, y, view)
    @ip.pick(view, x, y)
    view.invalidate
  end

  def onKeyDown(key, _repeat, _flags, view)
    case key
    when CONSTRAIN_MODIFIER_KEY
      view.lock_inference(@ip)
    when VK_RIGHT
      lock_inference_axis([@ip.position, view.model.axes.xaxis], view)
    when VK_LEFT
      lock_inference_axis([@ip.position, view.model.axes.yaxis], view)
    when VK_UP
      lock_inference_axis([@ip.position, view.model.axes.zaxis], view)
    end

    # TODO: Pick @ip anew.
    view.invalidate
  end

  def onKeyUp(key, _repeat, _flags, view)
    return unless key == CONSTRAIN_MODIFIER_KEY
    return if @axis_lock

    view.lock_inference
    # TODO: Pick @ip anew.
    view.invalidate
  end

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
    return unlock_axis if line == @axis_lock

    @axis_lock = line
    view.lock_inference(
      Sketchup::InputPoint.new(line[0]),
      Sketchup::InputPoint.new(line[0].offset(line[1]))
    )
  end
end

Sketchup.active_model.select_tool(InferenceExampleTool.new)
