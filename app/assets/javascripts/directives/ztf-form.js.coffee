@zt_module.directive 'ztfForm', ['$timeout', ($timeout) ->
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
      $scope.updated_fields = []
      $scope.error_fields = []
      $scope.getItem = ->
        $scope.ztItem or $scope.$parent.item
      $scope.commit = ->
        $scope.error_fields = []
        $scope.updated_fields = []
        $scope.updated_fields.push key  for own key of $scope.getItem().data when $scope.getItem().data[key] != $scope.getItem().copy[key] and key[0] != '_'
        $scope.updating = true
        $scope.getItem().save()
        .then ->
          $scope.updating = false
          if $scope.lockable
            $scope.editable = false
          $timeout ->
            $scope.updated_fields = []
          ,2000
        .catch ->
          $scope.updating = false
          $scope.error_fields = $scope.updated_fields
          $scope.updated_fields = []
      $scope.cancel = ->
        $scope.getItem().copy = angular.copy($scope.getItem().data)
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
  ]