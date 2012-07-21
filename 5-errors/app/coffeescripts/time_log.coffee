@app = window.app ? {}

jQuery ->
  setupErrorHandlers = ->
    $(document).ajaxError (error, xhr, settings, exception) ->
      console.log xhr.status, xhr.responseText, exception
      message = if xhr.status == 0
                  "The server could not be contacted."
                else if xhr.status == 403
                  "Login is required for this action."
                else if 500 <= xhr.status <=599
                  "There was an error on the server."
      $('#error-message span').text message
      $('#error-message').slideDown()
  setupErrorHandlers()
  @app.router = new app.TimeLogRouter
  Backbone.history.start({pushState:true})
