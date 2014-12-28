@r2_module.controller 'TagController', [
  '$scope', '$routeParams', '$location', '$window', '$timeout', 'wordService', 
  ($scope, $routeParams, $location, $window, $timeout, wordService) ->
    $scope.item = null
    $scope.error_message = null
    $scope.handleSuccessfulNameChange = ->
      $timeout ->
        $location.replace()
        $scope.updateUrl()
      ,2010
    $scope.updateUrl = ->
      $location.path("tags/#{encodeURIComponent($scope.item.data.name)}")
    $scope._rememberItem = (resp) ->
      $scope.item = resp.item
      $location.path("tags/#{encodeURIComponent($scope.item.data.name)}")
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