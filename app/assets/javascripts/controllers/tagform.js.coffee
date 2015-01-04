@r2_module.controller 'TagFormController', [
  '$scope', '$routeParams', '$location', '$window', '$timeout', 'wordService'
  ($scope, $routeParams, $location, $window, $timeout, wordService) ->
    $scope.item = null
    $scope.error_message = null
    $scope._rememberItem = (resp) ->
      $scope.item = resp.item
      $location.path("tagform/#{encodeURIComponent($scope.item.data.name)}") unless $scope.item.clientOnly
      $scope.error_message = null
    $scope._errorHandler = (error) ->
      $scope.error_message = "An error has occured."
    $scope.previousWord = ->
      wordService.item_relative($scope.item, -1)
      .then($scope._rememberItem,$scope._errorHandler)
    $scope.nextWord = ->
      wordService.item_relative($scope.item, +1)
      .then($scope._rememberItem,$scope._errorHandler)
    if $routeParams.tagName == "new"
      wordService.newitem()
      .then($scope._rememberItem,$scope._errorHandler)
    else
      wordService.item(decodeURIComponent($routeParams.tagName))
      .then($scope._rememberItem,$scope._errorHandler)
  ]