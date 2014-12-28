@r2_module.directive 'autoCheckbox', ->
  directive_object =
    restrict: 'E'       # also possible attribute A and class C
    transclude: true    # set to false if ignoring content
    scope:
      #func: '&reName' # isolate scope of a function, passed as a value 
                       # of the attribute with the name of the directive
      acItem: '='      # isolate scope of a model (both ways), passed with an 
                       # attribute disabled="XXX", where XXX is a variable of 
                       # the scope
      acField: '@'     # isolate scope of a variable (in only), passed with 
                       # an attribute disabled="123"
    controller: ($timeout, $scope) ->
      $scope.updateSuccess = false
      $scope.updateFail = false
      $scope.updateInProgress = false
      $scope.randomCounter = 0
      $scope.doPerformUpdate = ->
        $scope.updateInProgress = true
        $scope.updateSuccess = false
        $scope.updateFail = false
        $scope.acItem.save()
        .then ->
          $scope.updateInProgress = false
          $scope.updateSuccess = true
          $scope.updateFail = false
          $scope.randomCounter++
          randomCounter = $scope.randomCounter
          $timeout ->
            if randomCounter == $scope.randomCounter
              $scope.updateSuccess = false
          ,2000
        .catch ->
          $scope.updateInProgress = false
          $scope.updateFail = true
          $scope.updateSuccess = false
    templateUrl: "auto-checkbox.html" 
