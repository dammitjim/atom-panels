{CompositeDisposable} = require 'atom'
module.exports = Splitter =

  # Register commands
  # TODO refactor this to be nicer maybe?
  activate: (state) ->
    atom.commands.add "atom-workspace", "atom-panels:move-right": => @moveRight()
    atom.commands.add "atom-workspace", "atom-panels:move-left", => @moveLeft()
    atom.commands.add "atom-workspace", "atom-panels:move-down", => @moveDown()
    atom.commands.add "atom-workspace", "atom-panels:move-up", => @moveUp()
    atom.commands.add "atom-workspace", "atom-panels:split-right", => @splitRight()
    atom.commands.add "atom-workspace", "atom-panels:split-left", => @splitLeft()
    atom.commands.add "atom-workspace", "atom-panels:split-down", => @splitDown()
    atom.commands.add "atom-workspace", "atom-panels:split-up", => @splitUp()

  # TODO refactor this to be nicer
  moveRight: -> @move 'horizontal', +1
  moveLeft: -> @move 'horizontal', -1
  moveUp: -> @move 'vertical', -1
  moveDown: -> @move 'vertical', +1

  splitRight: -> @move 'horizontal', +1, true
  splitLeft: -> @move 'horizontal', -1, true
  splitUp: -> @move 'vertical', -1, true
  splitDown: -> @move 'vertical', +1, true

  # Moves to the associated pane
  # @param direction - horizontal or vertical
  # @param distance  - +1 for increase distance, -1 for decrease
  # @param split     - should we be splitting if there is no pane present
  move: (direction, distance, split) ->
    swapped = false
    pane = atom.workspace.getActivePane()
    if atom.workspace.getPanes().length > 1
      target = @getTarget(pane, direction, distance)
      if target?
        @swapEditor pane, target
        swapped = true

    # If we haven't already swapped and we want to split
    if !swapped && split
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

  getTarget: (pane, direction, distance) ->
    [axis, child] = @getAxis(pane, direction)
    if axis?
      return @getRelativePane axis, child, distance

  swapEditor: (source, target) ->
    target.activate()

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

  getRelativePane: (axis, source, delta) ->
    if axis.children?
      position = axis.children.indexOf source
      target = position + delta
      return unless target < axis.children.length
      if axis.children[target]?
        return axis.children[target].getPanes()[0]
    return null

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @panelsView.destroy()

  serialize: ->
    panelsViewState: @panelsView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
