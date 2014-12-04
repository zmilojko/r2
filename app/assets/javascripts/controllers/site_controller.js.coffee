@r2_module.controller 'SiteController', [
  '$scope', '$routeParams', 'siteService', ($scope, $routeParams, siteService) ->
    $scope.site = null
    $scope.order_name = $routeParams.siteName;
    siteService.get_sites().then (sites)->
      $scope.site = site for site in sites when site.name = $scope.order_name
]