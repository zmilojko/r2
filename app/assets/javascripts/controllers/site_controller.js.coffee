@r2_module.controller 'SiteController', [
  '$scope', '$routeParams', '$location', 'siteService', 
  ($scope, $routeParams, $location, siteService) ->
    $scope.site = null
    $scope.new_seed = {}
    $scope.site_name = $routeParams.siteName;
    $scope.tab = 'seeds'
    if $scope.site_name == 'new'
      $scope.site =
        rules: [ newRule =
          regex: "",
          positive: true,
          order: 10
        ]
    else
      siteService.get_sites()
      .then (sites)->
        $scope.site = angular.copy(site) for site in sites when site.name = $scope.site_name
        $scope.new_seed.site_name = $scope.site.site_name
        $scope.site.rules = [] unless $scope.site.rules
        siteService.getSeedsAndScans($scope.site)
        .then (seeds_and_scans) ->
          $scope.seeds_and_scans = seeds_and_scans
    $scope.save = ->
      if $scope.site_name == 'new'
        siteService.createSite($scope.site).then (newSite) ->
          $location.url("sites/#{newSite.name}")
      else
        siteService.saveSite($scope.site)
    $scope.cancel = ->
      $location.url("sites")
    $scope.removeRule = (rule) ->
      $scope.site.rules.splice($scope.site.rules.indexOf(rule),1)
    $scope.addRule = ->
      $scope.site.rules.push newRule =
        regex: "",
        positive: true,
        order: 10
    $scope.deleteSite = ->
      siteService.deleteSite($scope.site)
      .then ->
        $location.url("sites")
    $scope.removeSeed = (seed) ->
      siteService.removeSeed(seed)
    $scope.addNewSeed = ->
      siteService.addSeed($scope.new_seed)
      .then ->
        $scope.new_seed.url = ""
]