define [
	'underscore'
	'backbone'
	'moment'
	'dropboxprovider'
	'eventmgr'
	'jQuery.indexedDB'
], (_, Backbone, moment, DropboxProvider, eventManager) ->
	'use strict'

	selectExpend = (element) ->
		event = document.createEvent('MouseEvents')
		event.initMouseEvent('mousedown', true, true, window)
		element.dispatchEvent(event)

	defaultMetaData =
	categories: [
		{
			text: '-', value: undefined
		}
		{
			text: '常规款', value: 0
			details: [
				{
					text: '-'
					value: undefined
				}
				{
					text: '水款'
					value: 0
				}
				{
					text: '票款'
					value: 1
				}
				{
					text: '押桶'
					value: 2
				}
				{
					text: '退桶'
					value: 3
				}
			]
		}
		{
			text: '票', value: 1
			details: [
				{
					text: '-'
					value: undefined
				}
				{
					text: '矿物质'
					value: 0
				}
				{
					text: '纯净水'
					value: 1
				}
				{
					text: '九龙山水'
					value: 2
				}
				{
					text: '弱碱性'
					value: 3
				}
			]
		}
		{
			text: '销售款', value: 2
			details: [
				{
					text: '-'
					value: undefined
				}
				{
					text: '饮水机[万爱]'
					value: 0
				}
				{
					text: '饮水机[华生]'
					value: 1
				}
				{
					text: '饮水机[长城]'
					value: 2
				}
				{
					text: '饮水机[东瀛]'
					value: 3
				}
				{
					text: '压水器'
					value: 4
				}
				{
					text: '小水箱费'
					value: 5
				}
			]
		}
	]
	workers: [
		{
			text: '店内', value: 0
		}
		{
			text: '老金', value: 1
		}
		{
			text: '小华', value: 2
		}
		{
			text: '陆德其', value: 3
		}
		{
			text: '陈国伟', value: 4
		}
	]

	metaData = {}

	metaStore = $.indexedDB('litalculator').objectStore('metaData', true)
	metaStore.count().done (result) ->
		if result == 0
			metaStore.add(defaultMetaData).done (result) ->
				metaData = result
				eventManager.trigger('metaready')
		else
			metaStore.get(1).done (result) ->
				metaData = result
				eventManager.trigger('metaready')

	targetDate =
		$el: $('#target-date').on('change', ->
			return unless targetDate.$el.val()
			targetDate.date = moment(targetDate.$el.val()).toDate()
			eventManager.trigger('change', targetDate.date)
		).val(moment().format("YYYY-MM-DD"))

	eventManager.on 'appready', ->
		targetDate.$el.trigger('change')

	common = new class Common
		getCategories: =>
			metaData.categories
		getCategory: (value) =>
			_.findWhere metaData.categories, value: value
		getDetails: (categoryValue) =>
			(@getCategory(categoryValue) or {}).details
		getDetail: (categoryValue, detailValue) =>
			details = @getDetails(categoryValue)
			return unless details
			_.findWhere details, value: detailValue
		getWorkers: =>
			metaData.workers
		getWorker: (value) =>
			_.findWhere metaData.workers, value: value
		targetDate: targetDate
		selectExpend: selectExpend
		onLineState: navigator.onLine

	eventManager.on 'online', ->
		common.onLineState = 'online'
	eventManager.on 'offline', ->
		common.onLineState = 'offline'

	common