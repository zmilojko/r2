@zt_module.directive 'ztfSubform', ->
  ret =
    restrict: 'E'      # also possible class C
    transclude: true    # set to false if ignoring content
    scope:
      ztField: '@'
      ztTitle: '@?'
    link: (scope, elem, attrs, ctrl, transclude) ->
      s while !(s = (s || scope).$parent).hasOwnProperty('isZtfForm')
      scope.form = s
      scope.canAdd = isDefined(attrs.ztAdd)
      scope.canRemove = isDefined(attrs.ztDelete)
      scope.editable = scope.form.editable
      scope.form.$watch ->
        scope.form.editable
      , ->
        scope.editable = scope.form.editable
    controller: ($scope) ->
      # this directive's scope is a 'form' for all underlying scopes.
      # However, to this directive, 'form' is a parent form scope.
      $scope.isZtfForm = true
      $scope.isZtfSubform = true
      $scope.superItem = -> 
        $scope.form.getItem()
      $scope.subitems = ->
        if $scope.superItem() then $scope.superItem().copy[$scope.ztField] else null
      $scope.getItem = (index) -> 
        if $scope.subitems() then $scope.subitems()[index] else null
      $scope.enable_button = (action) ->
        if action in ['add', 'delete']
          $scope.form.editable
        else
          false
      $scope.show_button = (action) ->
        if action in ['add', 'delete']
          $scope.form.editable
        else 
          false
      $scope.fieldValue = (ztField, index, data) ->
        if data
          if $scope.superItem().data[$scope.ztField].length > index
            $scope.superItem().data[$scope.ztField][index][ztField]
          else
            null
        else
          $scope.superItem().copy[$scope.ztField][index][ztField]
      $scope.itemCopy = (ztField, index) ->
        throw "Subform passed a null index, which is only allowed on top level forms" if index == null
        $scope.getItem(index)
      $scope.revertField = (ztSubField, index) ->
        throw "Subform passed a null index, which is only allowed on top level forms" if index == null
        $scope.superItem().copy[$scope.ztField][index][ztSubField] = $scope.fieldValue(ztSubField, index, true) unless $scope.fieldUpdating(ztSubField, index) or not $scope.fieldValue(ztSubField, index, true)
      $scope.fieldModified = (ztSubField, index) ->
        $scope.superItem() and $scope.fieldValue(ztSubField, index, false) != $scope.fieldValue(ztSubField, index, true)
      $scope.fieldUpdating = (ztSubField, index) ->
        $scope.form.updating and $scope.fieldUpdated(ztSubField, index)
      $scope.fieldError = (ztSubField, index) ->
        $scope.form.error_fields.indexOf("#{$scope.ztField}[#{index}].#{ztSubField}") > -1 and $scope.fieldModified(ztSubField, index)
      $scope.fieldUpdated = (ztSubField, index) ->
        $scope.form.updated_fields.indexOf("#{$scope.ztField}[#{index}].#{ztSubField}") > -1
      $scope.add = ->
        $scope.subitems().push new Object()
    templateUrl: "ztf-subform.html" 
