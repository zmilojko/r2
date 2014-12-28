# Since there can be way too many tags, what we do try is to keep on client side aout 1000
# around the current one, whatever it is, or the midian one if more than one are active.
#
# Smae principal might be used later for other types of objects, as long as they are
# ordered in some way. Tags are ordered always by name.
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
#   - What is shown should never be more than 20-50 records.



@r2_module.service 'wordService', [
  '$http', '$q',
  ($http, $q) -> 
    s =
      constructor: ->
        @front_end_buffer_size = 20
        @eagerness = 3
        # Following is the key by which sorting is done
        @identifier = 'name'
        @front_end_buffer = null
        @front_end_buffer_limit_low = null
        @front_end_buffer_limit_high = null
        @front_end_buffer_index_low = null
        @front_end_buffer_index_high = null
        @total_count = null
      # Method 'item' return the item with given id or the first item available
      # meaning, essentially, any item.
      item: (id) ->
        if @front_end_buffer? and @front_end_buffer_limit_low <= id <= @front_end_buffer_limit_high
          $q.when { item: s._find_item(id), total_count: s.total_count }
        else
          s._reload_around_id(id)
          .then ->
            { item: s._find_item(id), total_count: s.total_count }
      # Method relative returns item with given offset from current item
      # Normally this would be used with -1 or 1.
      item_relative: (item, offset) ->
        if @front_end_buffer? and @front_end_buffer_index_low <= item.data.index + offset <= @front_end_buffer_index_high
          #eager loading
          if (offset < 0 and @front_end_buffer_index_low + @eagerness > item.data.index + offset) or 
              (offset > 0 and item.data.index + offset > @front_end_buffer_index_high - @eagerness)
            s._reload_by_index(item.data.index, offset)
          $q.when { item: s._find_by_index(item.data.index + offset), total_count: s.total_count }
        else
          s._reload_by_index(item.data.index, offset)
          .then ->
            { item: s._find_by_index(item.data.index + offset), total_count: s.total_count }
      range: (low_id, high_id) ->
        null
      update: (item) ->
        $http.put "./tags/#{item.data._id.$oid}.json", {"tag": item.copy}
      # private helpers
      _find_item: (id) ->
        id = null if id == "undefined"
        return item for item in s.front_end_buffer when (not id?) or item.data[s.identifier] == id
      _find_by_index: (index) ->
        return item for item in s.front_end_buffer when item.data.index == index
      _reload_around_id: (id) ->
        $http.get("./tags.json?count=#{s.front_end_buffer_size}" + (if id then "&around=#{id}" else "" ))
        .then (resp) ->
          s._save_results(resp)
      _reload_by_index: (index, offset) ->
        $http.get("./tags.json?count=#{s.front_end_buffer_size}&index=#{index}" + (if offset then "&offset=#{offset}" else "" ))
        .then (resp) ->
          s._save_results(resp)
      _save_results: (resp) ->
        s.front_end_buffer = []
        for d, i in resp.data.list
          s.front_end_buffer.push
            data: d
            copy: angular.copy(d)
            save: ->
              me = this
              s.update(me)
              .then ->
                me.data = angular.copy(me.copy)
              .catch (e) ->
                me.copy = angular.copy(me.data)
                throw e
            is_first: i == 0
            is_last: i == resp.data.list.length - 1
        s.front_end_buffer_limit_low = resp.data.list[0][s.identifier]
        s.front_end_buffer_limit_high = resp.data.list[-1..][0][s.identifier]
        s.front_end_buffer_index_low = resp.data.list[0].index
        s.front_end_buffer_index_high = resp.data.list[-1..][0].index
        s.total_count = resp.data.total_count
        resp.data
    s.constructor(); s
]
