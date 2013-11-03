define [
	'jquery'
	'underscore'
	'backbone'
	'common'
], ($, _, Backbone, common) ->
	'use strict'

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

	Meta = Backbone.Model.extend
		defaults: ->
			createTime: new Date
			modifyTime: new Date

		remote:
			table: 'metas'
			key: 'version'

		init: ->
			defer = do $.Deferred
			metas = new Metas
			metas.fetch().done =>
				metas.getOrCreate
					version: 1
				.done (meta) =>
					meta.remoteSync().done (meta) =>
						# Defend for first running when offline
						meta.set 'data', defaultMetaData if !meta.get 'data'
						@set meta.toJSON()
						defer.resolve @
			do defer.promise

		toRemoteFormat: ->
			item = @toJSON()
			item.data = JSON.stringify item.data if item.data
			delete item.id
			item

		toLocalFormat: (item) ->
			item.data = JSON.parse item.data if item.data
			item


	Metas = Backbone.Collection.extend
		model: Meta
		store: new Backbone.IndexedDB.Store 'metas'

	Meta