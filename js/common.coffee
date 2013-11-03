define [
	'underscore'
	'backbone'
	'moment'
	'eventmgr'
	'models/meta'
	'jQuery.indexedDB'
], (_, Backbone, moment, eventManager, Meta) ->
	'use strict'

	selectExpend = (element) ->
		event = document.createEvent('MouseEvents')
		event.initMouseEvent('mousedown', true, true, window)
		element.dispatchEvent(event)

	Backbone.IndexedDB.DBName = 'litalculator'

	targetDate =
		$el: $('#target-date').on('change', ->
			return unless targetDate.$el.val()
			targetDate.date = moment(targetDate.$el.val()).toDate()
			eventManager.trigger('change', targetDate.date)
		).val(moment().format("YYYY-MM-DD"))

	eventManager.on 'appready', ->
		targetDate.$el.trigger('change')

	common = new class Common
		constructor: ->
			meta = new Meta
			meta.init().done =>
				@metaData = meta.get('data')
				eventManager.trigger('metaready')
		getCategories: =>
			@metaData.categories
		getCategory: (value) =>
			_.findWhere @metaData.categories, value: value
		getDetails: (categoryValue) =>
			(@getCategory(categoryValue) or {}).details
		getDetail: (categoryValue, detailValue) =>
			details = @getDetails(categoryValue)
			return unless details
			_.findWhere details, value: detailValue
		getWorkers: =>
			@metaData.workers
		getWorker: (value) =>
			_.findWhere @metaData.workers, value: value
		targetDate: targetDate
		selectExpend: selectExpend
		onLineState: navigator.onLine

	eventManager.on 'online', ->
		common.onLineState = 'online'
	eventManager.on 'offline', ->
		common.onLineState = 'offline'

	common