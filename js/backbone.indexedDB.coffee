define [
	'jquery'
	'underscore'
	'backbone'
	'jQuery.indexedDB'
], ($, _, Backbone) ->
	# Extend a method for ensure data being persisted in local db
	Backbone.Collection.prototype.getOrCreate = (filter) ->
		defer = do $.Deferred

		record = @find (rec) ->
			_.every filter, (val, prop) ->
				_.isEqual(rec.get(prop), val)

		if record
			if record.id
				defer.resolve record
			else
				@listenToOnce record, 'change:id', ->
					defer.resolve record
		else
			record = new @model
			record.set(filter)
			@add(record)
			record.save().done ->
				defer.resolve record

		do defer.promise

	Backbone.IndexedDB = class IndexedDB
		@DBName: 'defaultDB'

	Backbone.IndexedDB.Store = class Store
		constructor: (@name, @dataRoot = 'root') ->

		getStore: ->
			$.indexedDB(Backbone.IndexedDB.DBName).objectStore(@name, true)

		fetch: (model, options) ->
			if model.id != undefined
				$.Deferred (deferred) =>
					@getStore().get(model.id)
					.done (result, event) =>
						deferred.resolve($.extend((_.object [
							model.idAttribute or 'id'
						], [
							model.id
						]), result), event)
					.fail (error, event) =>
						deferred.reject(error, event)
			else
				$.Deferred (deferred) =>
					resources = []
					@getStore()
					.each (instance) =>
						resources.push $.extend((_.object [
							model.idAttribute or 'id'
						], [
							instance.key
						]), instance.value)
						undefined
					.done (result, event) =>
						response = @localFilter resources, options.data
						deferred.resolve(response, event)
					.fail (error, event) =>
						deferred.reject(error, event)

		localFilter: (resources, rules = {}) ->
			count = resources.length
			chain = _.chain(resources)
			_.each rules, (value, key, obj) =>
				switch key
					when 'page'
						limit = obj.limit or 10
						chain = _.chain(chain.value().slice((value - 1) * limit, value * limit))
			resources = chain.value()
			if rules.page then _.object [
				@dataRoot
				'totalLength'
			], [
				resources
				count
			] else resources

		saveChanges: (model, options) ->
			$.Deferred (deferred) =>
				resp = if model.id != undefined then @getStore().put model.toJSON(), model.id else @getStore().add model.toJSON()

				resp.done (key) =>
					@getStore().get(key).done (result, event) =>
						deferred.resolve($.extend((_.object [
							model.idAttribute or 'id'
						], [
							key
						]), result), event)
					.fail (error, event) =>
						deferred.reject(error, event)
				.fail (error, event) =>
					deferred.reject(error, event)

		destroy: (model, options) ->
			if model.id
				@getStore().delete model.id

		clear: ->
			do @getStore().clear

	Backbone.IndexedDB.Store.sync = Backbone.localSync = (method, model, options) ->
		store = model.store or model.collection.store
		syncDfd = do $.Deferred

		try
			switch method
				when "read"
					respDfd = store.fetch(model, options)
				when "create"
					respDfd = store.saveChanges(model, options)
				when "update"
					respDfd = store.saveChanges(model, options)
				when "delete"
					respDfd = store.destroy(model, options)
		catch error
			errorMessage = error.message

		if (respDfd)
			respDfd.done (response, event) ->
				if (options and options.success)
					options.success(response)
				syncDfd.resolve(response, event)
			.fail (error, event) ->
				if (options and options.error)
					options.error(error)
				syncDfd.reject(error)
		else
			errorMessage = if errorMessage then errorMessage else "Record Not Found"
			if (options and options.error)
				options.error(errorMessage)
			console.log errorMessage
			syncDfd.reject(errorMessage)

		syncDfd.promise()

	Backbone.ajaxSync = Backbone.sync

	Backbone.getSyncMethod = (model) ->
		if(model.store or (model.collection and model.collection.store))
			Backbone.localSync
		else
			Backbone.ajaxSync

	Backbone.sync = (method, model, options) ->
		Backbone.getSyncMethod(model).apply(@, [method, model, options])

	Backbone.IndexedDB
