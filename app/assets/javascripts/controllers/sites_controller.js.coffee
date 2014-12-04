@r2_module.controller 'SitesController', [
  '$scope', '$timeout', 'siteService', ($scope, $timeout, siteService) ->
    $scope.sites = []
    siteService.get_sites().then (sites)->
      $scope.sites = sites
    $scope.changeMode = (site, new_mode) ->
      siteService.changeMode(site, new_mode)
]