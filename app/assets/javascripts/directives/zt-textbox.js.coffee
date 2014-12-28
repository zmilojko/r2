@r2_module.directive 'ztTextbox', ->
  directive_object =
    restrict: 'E'       # also possible attribute A and class C
    transclude: true    # set to false if ignoring content
    scope:
      ztItem: '=?'
      ztField: '@'
      ztUpdateSuccess: '&?'
    controller: ['$timeout', '$scope', ($timeout, $scope) ->
      $scope.editingWord = false
      $scope.updateInProgress = false
      $scope.updateSuccess = false
      $scope.updateFail = false
      $scope.randomCounter = 0
      $scope.randomCounter2 = 0
      $scope.getItem = ->
        $scope.acItem or $scope.$parent.item
      $scope.startEditing = ->
        $scope.editingWord = true
      $scope.cancelEditing = ->
        $scope.getItem().revert()
        $scope.editingWord = false
        $scope.updateInProgress = false
        $scope.updateSuccess = false
        $scope.updateFail = false
      $scope.completeEditing = ->
        $scope.updateInProgress = true
        $scope.updateSuccess = false
        $scope.updateFail = false
        $scope.randomCounter2++
        randomCounter2 = $scope.randomCounter2
        $scope.getItem().save()
        .then ->
          if randomCounter2 == $scope.randomCounter2
            $scope.form.$setPristine()
            $scope.updateInProgress = false
            $scope.updateSuccess = true
            $scope.updateFail = false
            $scope.randomCounter++
            randomCounter = $scope.randomCounter
            $scope.editingWord = false
            if $scope.ztUpdateSuccess?
              $scope.ztUpdateSuccess()
            $timeout ->
              if randomCounter == $scope.randomCounter
                $scope.updateSuccess = false
            ,2000
        .catch ->
          $scope.updateInProgress = false
          $scope.updateFail = true
          $scope.updateSuccess = false
    ]
    templateUrl: "zt-textbox.html" 

