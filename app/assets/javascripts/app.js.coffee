#= require angular
#= require angular-route
#= require angular-resource
#= require angular-rails-templates
#= require zwr
#= require_tree ./templates
#= require_tree ./includes
#= require_self
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
  'hljs',
  'zt',
  ])

@r2_module.config(['$routeProvider', ($routeProvider) ->
  $routeProvider.
    when('/sites', {
      templateUrl: 'sites.html',
    }).
    when('/sites/:siteName', {
      templateUrl: 'site.html',
    }).
    when('/tags/page/:pageNo', {
      templateUrl: 'tagpage.html',
    }).
    when('/tags/:tagName?', {
      templateUrl: 'tag.html',
    }).
    when('/404', {
      templateUrl: '404.html',
    }).
    when('/', {
      templateUrl: 'home.html',
    }).
    when('/tagform/:tagName?', {
      templateUrl: 'tagform.html',
    }).
    when('/tagform/page/:pageNo', {
      templateUrl: 'tagformpage.html',
    }).
    otherwise({
      templateUrl: '404.html',
    }) 
])

@r2_module.config(['localStorageServiceProvider', 'hljsServiceProvider',
  (localStorageServiceProvider, hljsServiceProvider) ->
    localStorageServiceProvider
      .setPrefix('r2')
      .setStorageType('localStorage')
      .setStorageCookie(0, '<path>')
      .setNotify(true, true)
    hljsServiceProvider.setOptions {
      tabReplace: '  '
    }
])
