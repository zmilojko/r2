@zt_module.directive 'ztfCheckbox', ['$timeout', ($timeout) ->
  ret =
    restrict: 'AE'      # also possible class C
    transclude: true    # set to false if ignoring content
    scope:
      cmd: '&ztfCheckbox'    # isolate scope of a function, passed as a value 
                              # of the attribute with the name of the directive
      disabled: '='     # isolate scope of a model (both ways), passed with an 
                        # attribute disabled="XXX", where XXX is a variable of 
                        # the scope
      glyph: '@'        # isolate scope of a variable (in only), passed with 
                        # an attribute disabled="123"
    link: (scope, elem, attr) ->
      scope.$watch (scope) ->
        scope.ztItem
      , ->
        scope.revertLocal() if scope.ztItem
      scope.$watch () ->
        element[0].focus() if scope.focusMe == 'true'
      plunker = ->
        $timeout ->
          scope.focuschange = !scope.focuschange
          plunker() 
        ,1000
      plunker()
    controller: ($scope) ->
      $scope.status = 0
      $scope.form = ->
        $scope.myItem or $scope.$parent.item
    templateUrl: "ztf-checkbox.html"
  ]
