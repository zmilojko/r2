#= require angular
#= require angular-route
#= require angular-resource
#= require angular-rails-templates
#= require_tree ./templates
#= require_self
#= require_tree ./includes
#= require_tree ./directives
#= require_tree ./services
#= require_tree ./controllers
#= require angular-ui-bootstrap

@r2_module = angular.module('r2', [
  'ngRoute', 
  'ngResource', 
  'templates',
  'ui.bootstrap',
  'LocalStorageModule',
  ])

@r2_module.config(['$routeProvider', ($routeProvider) ->
  $routeProvider.
    when('/sites', {
      templateUrl: 'sites.html',
    }).
    when('/sites/:siteName', {
      templateUrl: 'site.html',
    }).
    otherwise({
      templateUrl: 'home.html',
    }) 
])

@r2_module.config(['localStorageServiceProvider', (localStorageServiceProvider) ->
  localStorageServiceProvider
    .setPrefix('r2')
    .setStorageType('localStorage')
    .setStorageCookie(0, '<path>')
    .setNotify(true, true)
])
