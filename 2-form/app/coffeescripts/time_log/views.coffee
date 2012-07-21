# VIEWS

jQuery ->
  class AppView extends Backbone.View
    el: '#wrap'
    initialize: (options) ->
      @subviews = [
        new TasksView     collection: @collection
        new NewTaskView   collection: @collection
        ]
      @collection.bind 'reset', @render, @
    render: ->
      $(@el).empty()
      $(@el).append subview.render().el for subview in @subviews
      @


  class TasksView extends Backbone.View
    className: 'tasks'
    template: _.template($('#tasks-template').html())
    blankStateTemplate: _.template($('#blank-state-template').html())
    initialize: (options) ->
      @completedSubviews = [
        new CompletedTasksView collection: @collection
        ]
      @incompleteSubviews = [
        new IncompleteTasksView collection: @collection
        ]
    render: ->
      $(@el).html @template()
      $(@el).append subview.render().el for subview in @completedSubviews

      # In all cases, show IncompleteTaskView
      $(@el).append subview.render().el for subview in @incompleteSubviews

      @delegateEvents()
      @
    startTracking: ->
      @collection.createStartTask()
      $('#new-task').val('').focus()


  class CompletedTasksView extends Backbone.View
    id: 'completed-tasks'
    tagName: 'ul'
    render: ->
      $(@el).empty()
      for task in @collection.completedTasks()
        completedTaskView = new CompletedTaskView model: task
        $(@el).append completedTaskView.render().el
      @


  class CompletedTaskView extends Backbone.View
    className: 'task'
    tagName: 'li'
    template: _.template($('#completed-task-template').html())
    render: ->
      $(@el).html @template(@model.toJSON())
      @
    disable: ->
      @$('input').prop 'disabled', true
    enable: ->
      @$('input').prop 'disabled', false


  class IncompleteTasksView extends Backbone.View
    id: 'tasks-to-complete'
    tagName: 'ul'
    initialize: (options) ->
      @collection.bind 'add', @render, @
    render: ->
      $(@el).empty()
      for task in @collection.incompleteTasks()
        incompleteTaskView = new IncompleteTaskView model: task
        $(@el).append incompleteTaskView.render().el
      @


  class IncompleteTaskView extends Backbone.View
    className: 'task'
    tagName: 'li'
    template: _.template($('#incomplete-task-template').html())
    render: ->
      $(@el).html @template(@model.toJSON())
      @


  class NewTaskView extends Backbone.View
    tagName: 'form'
    template: _.template($('#new-task-template').html())
    events:
      'keypress #new-task': 'saveOnEnter'
    render: ->
      $(@el).html @template()
      @
    saveOnEnter: (event) ->
      if (event.keyCode is 13) # ENTER
        event.preventDefault()
        if @collection.create({title:$('#new-task').val()})
          @hideWarning()
          @focus()
        else
          @flashWarning()
    focus: ->
      $('#new-task').val('').focus()
    hideWarning: ->
      $('#warning').hide()
    flashWarning: ->
      $('#warning').fadeOut(100)
      $('#warning').fadeIn(400)


  @app = window.app ? {}
  @app.AppView = AppView

