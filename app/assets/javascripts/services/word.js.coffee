@r2_module.service 'wordService', [
  'ztBaseService',
  WordService = (ztBaseService) ->
    ztBaseService.extends_to(this)
    @identifier = 'name'
    @resource_url = 'tags'
    @resource_name = 'tag'
    this]