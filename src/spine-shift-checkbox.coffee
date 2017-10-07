Spine = require "spine"


class ShiftCheckbox extends Spine.Controller
  selectAllClass: "scb-select-all"
  selectedClass:  "scb-selected"
  lastIndex:      -1

  _targetFromEvent: (e) ->
    $ e.target

  allCheckboxes: ->
    @$ ":checkbox"

  checkboxes: ->
    @allCheckboxes().not ".#{@selectAllClass}"

  checked: ->
    @checkboxes().filter ":checked"

  selectAll: (e) ->
    @allCheckboxes().prop(checked: true)
      .trigger "change"

  deselectAll: (e) ->
    @allCheckboxes().prop(checked: false)
      .trigger "change"

  selectOrDeselectAll: (e) ->
    checkboxes = @checkboxes()
    if (checkboxes.not ":checked").length then @selectAll e
    else                                       @deselectAll e
    @trigger "change", checkboxes

  selectOneOrRange: (e) ->
    $target    = @_targetFromEvent e
    checkboxes = @checkboxes()
    index      = checkboxes.index $target
    changed    = $target

    if e.shiftKey and @lastIndex isnt -1
      di = if index > @lastIndex then 1 else -1
      i = @lastIndex
      while i isnt index
        checkbox = checkboxes.eq i
        checkbox.prop checked: "checked"
        checkbox.trigger "change"
        changed.add checkbox
        i += di

    @lastIndex = index
    @trigger "change", changed

  selectOneOrMany: (e) ->
    $target = @_targetFromEvent e
    if $target.hasClass @selectAllClass then @selectOrDeselectAll e
    else                                     @selectOneOrRange e

  updateParentClass: (e) ->
    $target = @_targetFromEvent e
    return if $target.hasClass @selectAllClass

    $parent = $target.closest @parentSelector
    if $target.is ":checked" then $parent.addClass @selectedClass
    else                          $parent.removeClass @selectedClass

  events:
    "click :checkbox":                 "selectOneOrMany"
    "change :checkbox":                "updateParentClass"

  constructor: (options, @callback) ->
    super

  selected: ->
    (@$ @parentSelector).has(":checkbox:checked").not(":has(.#{@selectAllClass})")

  destroy: ->
    (@$ @parentSelector).has(":checkbox").removeClass @selectedClass
    @stopListening()


module.exports = ShiftCheckbox
