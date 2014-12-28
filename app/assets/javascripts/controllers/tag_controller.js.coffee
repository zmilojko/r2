@r2_module.controller 'TagController', [
  '$scope', '$routeParams', '$location', '$window', 'wordService', 
  ($scope, $routeParams, $location, $window, wordService) ->
    $scope.item_orig = null
    $scope.item = null
    $scope.error_message = null
    $scope.editingWord = false
    $scope._rememberItem = (resp) ->
      $scope.item_orig = resp.item
      $scope.item = angular.copy($scope.item_orig)
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
    $scope.update = ->
      wordService.update($scope.item)
      .then ->
        $scope.item_orig = angular.copy($scope.item)
      .catch (e) ->
        $scope.item = angular.copy($scope.item_orig)
        throw e
]