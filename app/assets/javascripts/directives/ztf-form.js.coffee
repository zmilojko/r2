@zt_module.directive 'ztfForm', ->
  ret =
    restrict: 'AE'      # also possible class C
    transclude: true    # set to false if ignoring content
    scope:
      ztItem: '=?'
    link: (scope, elem, attrs) ->
      scope.lockable = isDefined(attrs.lockable)
      scope.editable = !scope.lockable
    controller: ($scope) ->
      $scope.isZtfForm = true
      $scope.getItem = ->
        $scope.ztItem or $scope.$parent.item
      $scope.commit = ->
        if $scope.lockable
          $scope.editable = false
      $scope.cancel = ->
        if $scope.lockable
          $scope.editable = false
      $scope.edit = ->
        if $scope.lockable
          $scope.editable = true
      $scope.enable_button = (action) ->
        if action in ['commit', 'cancel']
          return $scope.editable
        else if action == 'edit'
          return !$scope.editable
      $scope.show_button = (action) ->
        if action in ['commit', 'cancel']
          return $scope.editable
        else if action == 'edit'
          return !$scope.editable
    templateUrl: "ztf-form.html" 
