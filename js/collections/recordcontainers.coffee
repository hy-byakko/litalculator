define [
	'jquery'
	'underscore'
	'backbone'
	'models/recordcontainer'
	'collections/records'
	'common'
	'eventmgr'
	'backbone.indexedDB'
], ($, _, Backbone, RecordContainer, Records, Common, eventManager, moment) ->
	'use strict'

	Backbone.Collection.extend
		model: RecordContainer

		store: new Backbone.IndexedDB.Store 'recordContainers'

		remoteSync: ->
			@getLocal().done (localRec) =>
				# Do not really need call recordsFetch again when remote store already exist. It will update record before render it.
				localRec.remoteSync().done (rec, evt) =>
					@recordsFetch() if evt.type == 'localupdate'

		getLocal: () ->
			@getOrCreate
				contentTime: Common.targetDate.date

		initialize: ->
			@records = new Records

			@listenTo @records, 'write', @recordsUpdate
			@listenTo eventManager, 'change', =>
				do @recordsFetch
				do @remoteSync
			# @listenTo eventManager, 'remotesync', =>
			# 	console.log 'a'
			# @listenTo @, 'all', =>
			# 	console.log arguments
			# @listenTo @records, 'all', =>
			# 	console.log arguments
			@

		recordsUpdate: ->
			@getLocal().done (container) =>
				container.set('content', @records.toJSON())
				container.set('modifyTime', new Date)
				container.save().done =>
					container.remoteSync()

		recordsFetch: ->
			@getLocal().done (container) =>
				@records.reset(container.get('content'))
