{CompositeDisposable} = require 'atom'
module.exports = Splitter =

  activate: (state) ->
    atom.commands.add "atom-workspace", "splitter:move-right": => @moveRight()
    atom.commands.add "atom-workspace", "splitter:move-left", => @moveLeft()
    atom.commands.add "atom-workspace", "splitter:move-down", => @moveDown()
    atom.commands.add "atom-workspace", "splitter:move-up", => @moveUp()
  #end

  moveRight: -> @move 'horizontal', +1
  moveLeft: -> @move 'horizontal', -1
  moveUp: -> @move 'vertical', -1
  moveDown: -> @move 'vertical', +1

  move: (direction, distance) ->
    swapped = false
    pane = atom.workspace.getActivePane()
    if atom.workspace.getPanes().length > 1
      target = @getTarget(pane, direction, distance)
      if target?
        @swapEditor pane, target
        swapped = true
    #endif
    if !swapped
      buffer = pane.getActiveItem().buffer
      buffer.load()
      keys = {copyActiveItem: true}
      switch [direction, distance].join(' ')
        when 'horizontal 1'
          blankPane = pane.splitRight(keys)
          break
        when 'horizontal -1'
          blankPane = pane.splitLeft(keys)
          break
        when 'vertical 1'
          blankPane = pane.splitDown(keys)
          break
        when 'vertical -1'
          blankPane = pane.splitUp(keys)
          break
  #end

  getTarget: (pane, direction, distance) ->
    [axis, child] = @getAxis(pane, direction)
    if axis?
      return @getRelativePane axis, child, distance
  #end

  swapEditor: (source, target) ->
    target.activate()
  #end

  getAxis: (pane, direction) ->
    axis = pane.parent
    child = pane
    while true
      return unless axis.constructor.name == 'PaneAxis'
      break if axis.orientation == direction
      child = axis
      axis = axis.parent
      break
    return [axis,child]
  #end

  getRelativePane: (axis, source, delta) ->
    if axis.children?
      position = axis.children.indexOf source
      target = position + delta
      return unless target < axis.children.length
      if axis.children[target]?
        return axis.children[target].getPanes()[0]
    return null
  #end

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @splitterView.destroy()
  #end

  serialize: ->
    splitterViewState: @splitterView.serialize()
  #end

  toggle: ->
    console.log 'Splitter was toggled!'
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
  #end
