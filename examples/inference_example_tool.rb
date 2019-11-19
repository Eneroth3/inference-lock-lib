require_relative("../lib/inference_lock")

# Example tool showing how InferenceLock mixin can be used.
class InferenceExampleTool
  include InferenceLock

  # SketchUp Tool API

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def initialize
    @ip = Sketchup::InputPoint.new
    @ip_reference = Sketchup::InputPoint.new

    super
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def deactivate(view)
    reset(view)
    view.invalidate
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def draw(view)
    if @ip_reference.valid?
      view.line_width = view.inference_locked? ? 3 : 1
      view.set_color_from_line(@ip.position, @ip_reference.position)
      view.draw(GL_LINES, [@ip.position, @ip_reference.position])
    end

    view.line_width = 1
    # FIXME: @ip_reference keeps drawing with inference helper lines.
    # This is not how native tools draw InputPoints.
    @ip_reference.draw(view)
    @ip.draw(view)
    view.tooltip = @ip.tooltip
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def getExtents
    bb = Sketchup.active_model.bounds
    bb.add(@ip.position) if @ip.valid?
    bb.add(@ip_reference.position) if @ip_reference.valid?

    bb
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def onCancel(_reason, view)
    reset(view)
    view.invalidate
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def onLButtonDown(_flags, _x, _y, view)
    if !@ip_reference.valid?
      @ip_reference.copy!(@ip)
    else
      reset(view)
    end
    view.invalidate
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def onMouseMove(_flags, x, y, view)
    super

    @ip.pick(view, x, y, @ip_reference)
    view.invalidate
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def resume(view)
    view.invalidate
  end

  # @api
  # @see https://ruby.sketchup.com/Sketchup/Tool.html
  def suspend(view)
    view.invalidate
  end

  # InferenceLock

  # @api
  # @see `ToolInference`
  def current_ip
    @ip
  end

  # @api
  # @see `ToolInference`
  def start_ip
    @ip_reference
  end

  private

  def reset(view)
    @ip.clear
    @ip_reference.clear
    view.lock_inference
  end
end

Sketchup.active_model.select_tool(InferenceExampleTool.new)
