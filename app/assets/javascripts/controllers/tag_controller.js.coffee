@r2_module.controller 'TagController', [
  '$scope', '$routeParams', '$location', '$window', 'wordService', 
  ($scope, $routeParams, $location, $window, wordService) ->
    $scope.item = null
    $scope.previousWord = ->
      console.log "previous clicked"
      wordService.item_relative($scope.item, -1)
      .then (resp) ->
        $scope._rememberItem(resp)
    $scope.nextWord = ->
      console.log "next clicked"
      wordService.item_relative($scope.item, +1)
      .then (resp) ->
        $scope._rememberItem(resp)
    wordService.item(decodeURIComponent($routeParams.tagName))
    .then (resp) ->
      $scope._rememberItem(resp)
    $scope._rememberItem = (resp) ->
      $scope.item = resp.item
      $scope.there_is_next = $scope.item.index < resp.total_count - 1
      $location.path("tags/#{encodeURIComponent($scope.item.name)}")
]