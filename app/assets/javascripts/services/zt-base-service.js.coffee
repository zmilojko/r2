# Since there can be way too many documents, what we do try is to keep on client side aout 1000
# around the current one, whatever it is, or the midian one if more than one are active.
#
# Same principal might be used later for other types of objects, as long as they are
# ordered in some way. Documents are ordered always by a @identifier, which must be defined
# in the child service.
#
# This system is assumed to work with the following limits:
#
#   - In the database, any kind of amount is possible, but oading will depend
#     on that amount. Whatever it can be filtered or sorted on must be indexed.
#
#   - What is retrieved is up to 1000 records (defined by @front_end_buffer_size),
#     each not bigger than 1-5k, making it up to 1-5M. That should be transfered
#     within a second.
#
#   - What is shown should never be more than 20-50 record@



@zt_module.service 'ztBaseService', [
  '$http', '$q',
  ($http, $q) -> 
    @front_end_buffer_size = 200
    @eagerness = 30
    @page_size = 10
    # Following is the key by which sorting is done
    @front_end_buffer = null
    @front_end_buffer_limit_low = null
    @front_end_buffer_limit_high = null
    @front_end_buffer_index_low = null
    @front_end_buffer_index_high = null
    @total_count = null
    # Method 'item' return the item with given id or the first item available
    # meaning, essentially, any item.
    @item = (id) ->
      if @front_end_buffer? and @front_end_buffer_limit_low <= id <= @front_end_buffer_limit_high
        $q.when { item: @_find_item(id), total_count: @total_count }
      else
        me = this
        @_reload_around_id(id)
        .then ->
          { item: me._find_item(id), total_count: me.total_count }
    # Method relative returns item with given offset from current item
    # Normally this would be used with -1 or 1.
    @item_relative = (item, offset) ->
      if @front_end_buffer? and @front_end_buffer_index_low <= item.data.index + offset <= @front_end_buffer_index_high
        #eager loading
        if (offset < 0 and @front_end_buffer_index_low + @eagerness > item.data.index + offset) or 
            (offset > 0 and item.data.index + offset > @front_end_buffer_index_high - @eagerness)
          @_reload_by_index(item.data.index, offset)
        $q.when { item: @_find_by_index(item.data.index + offset), total_count: @total_count }
      else
        me = this
        @_reload_by_index(item.data.index, offset)
        .then ->
          { item: me._find_by_index(item.data.index + offset), total_count: me.total_count }
    @page_items = (page_no, direction) ->
      if @front_end_buffer? and @front_end_buffer_index_low <= (page_no - 1) * @page_size and page_no * @page_size<= @front_end_buffer_index_high
        #eager loading
        if @front_end_buffer_index_low + @eagerness > (page_no - 1) * @page_size or
            page_no * @page_size > @front_end_buffer_index_high - @eagerness
          @_reload_by_index((page_no - 1) * @page_size + @page_size / 2, 0)
        $q.when { items: @_find_page_items(page_no), page_count: @_total_page_count() }
      else
        me = this
        @_reload_by_index((page_no - 1) * @page_size + @page_size / 2, 0)
        .then ->
          { items: me._find_page_items(page_no), page_count: me._total_page_count() }
    @range = (low_id, high_id) ->
      null
    @update = (item) ->
      data = new Object()
      data[@resource_name] = item.copy
      $http.put "./#{@resource_url}/#{item.data._id.$oid}.json", data
    @create = (item) ->
      data = new Object()
      data[@resource_name] = item.copy
      $http.post "./#{@resource_url}.json", data
    @newitem = ->
      container = this
      newly_created_item =
        data: null
        copy: {}
        clientOnly: true
        saved: false
        save: ->
          me = this
          container.create(me)
          .then ->
            me.saved = true
        revert: ->
          throw "Cannot call revert on new object"
        is_first: true
        is_last: true
      mynewitem =
        item:
          newly_created_item
      if isDefined(@initialize_new_object)
        @initialize_new_object(mynewitem.item.copy)
      $q.when mynewitem
    # private helpers
    @_find_item = (id) ->
      id = null if id == "undefined"
      return item for item in @front_end_buffer when (not id?) or item.data[@identifier] == id
    @_find_by_index = (index) ->
      return item for item in @front_end_buffer when item.data.index == index
    @_reload_around_id = (id) ->
      id = null if id == "undefined"
      me = this
      $http.get("./#{@resource_url}.json?count=#{@front_end_buffer_size}" + (if id? then "&around=#{id}" else "" ))
      .then (resp) ->
        me._save_results(resp)
    @_find_page_items = (page_no) ->
      skipped = @front_end_buffer_index_low
      @front_end_buffer.slice (page_no - 1) * @page_size - skipped,
        page_no * @page_size - skipped
    @_total_page_count = () ->
      Math.trunc((@total_count + @page_size - 1) / @page_size)
    @_reload_by_index = (index, offset) ->
      me = this
      $http.get("./#{@resource_url}.json?count=#{@front_end_buffer_size}&index=#{index}" + (if offset then "&offset=#{offset}" else "" ))
      .then (resp) ->
        me._save_results(resp)
    @_save_results = (resp) ->
      @front_end_buffer = []
      container = this
      for d, i in resp.data.list
        # add indexes to each array
        for own field of d when d[field] instanceof Array
          for list_item, i2 in d[field]
            list_item._index = i2
        @front_end_buffer.push
          data: d
          copy: angular.copy(d)
          save: ->
            me = this
            container.update(me)
            .then ->
              for own field of me.copy when me.copy[field] instanceof Array
                for list_item, i2 in me.copy[field]
                  list_item._index = i2
              me.data = angular.copy(me.copy)
          revert: ->
            this.copy = angular.copy(this.data)
          is_first: i == 0
          is_last: i == resp.data.list.length - 1
      @front_end_buffer_limit_low = resp.data.list[0][@identifier]
      @front_end_buffer_limit_high = resp.data.list[-1..][0][@identifier]
      @front_end_buffer_index_low = resp.data.list[0].index
      @front_end_buffer_index_high = resp.data.list[-1..][0].index
      @total_count = resp.data.total_count
      resp.data
    @extends_to = (obj) ->
      angular.copy(this, obj)
    this]
