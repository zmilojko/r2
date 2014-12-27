@r2.service 'tagService', [
  '$http', '$q', 'localStorageService',
  ($http, $q, identComm, localStorageService) -> 
    service =
      constructor: ->
        # We will try to bring 1000 tags at a time.
        @tag_list = null
        service
      get_tag: ->
        $http.get('./my_var.json').then (server_response) ->
          me.my_variable = server_response.data
      quick: ->
        $q.when @my_variable
    service.constructor()
]
