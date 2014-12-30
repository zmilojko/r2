@r2_module.controller 'TagPageController', [
  '$scope', '$routeParams', '$location', '$window', '$timeout', 'wordService', 
  ($scope, $routeParams, $location, $window, $timeout, wordService) ->
    $scope.page_items = null
    $scope.page_count = null
    $scope.error_message = null
    $scope._rememberPageItems = (resp) ->
      $scope.page_items = resp.items
      $scope.page_count = resp.page_count
      $scope.error_message = null
    $scope._errorHandler = (error) ->
      $scope.error_message = "An error has occured."
    $scope.prevPage = ->
      $location.path("tags/page/#{parseInt($routeParams.pageNo) - 1}")
    $scope.nextPage = ->
      $location.path("tags/page/#{parseInt($routeParams.pageNo) + 1}")
    $scope.is_first_page = ->
      parseInt($routeParams.pageNo) == 1
    $scope.is_last_page = ->
      parseInt($routeParams.pageNo) == $scope.page_count
    wordService.page_items(decodeURIComponent($routeParams.pageNo))
    .then($scope._rememberPageItems,$scope._errorHandler)
]