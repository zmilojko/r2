@r2_module.controller 'TagController', [
  '$scope', '$routeParams', '$location', '$window', 'wordService', 
  ($scope, $routeParams, $location, $window, wordService) ->
    $scope.item = null
    $scope.error_message = null
    $scope._rememberItem = (resp) ->
      $scope.item = resp.item
      $scope.there_is_next = $scope.item.index < resp.total_count - 1
      $location.path("tags/#{encodeURIComponent($scope.item.name)}")
      $scope.error_message = null
    $scope._errorHandler = (error) ->
      $scope.error_message = "An error has occured."
    $scope.previousWord = ->
      wordService.item_relative($scope.item, -1)
      .then($scope._rememberItem,$scope._errorHandler)
    $scope.nextWord = ->
      wordService.item_relative($scope.item, +1)
      .then($scope._rememberItem,$scope._errorHandler)
    wordService.item(decodeURIComponent($routeParams.tagName))
    .then($scope._rememberItem,$scope._errorHandler)
]