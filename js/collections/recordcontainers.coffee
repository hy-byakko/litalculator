define [
	'jquery'
	'underscore'
	'backbone'
	'models/recordcontainer'
	'collections/records'
	'common'
	'dropboxprovider'
	'eventmgr'
	'moment'
	'backbone.indexedDB'
], ($, _, Backbone, RecordContainer, Records, Common, DropboxProvider, eventManager, moment) ->
	'use strict'

	Backbone.Collection.extend
		model: RecordContainer

		store: new Backbone.IndexedDB.Store 'recordContainers'

		# TODO Glodal event
		initialize: ->
			@records = new Records

			@listenTo @records, 'write', @recordsUpdate
			@listenTo eventManager, 'change', =>
				DropboxProvider.datastoreManager.openDefaultDatastore (error, datastore) =>
					@remoteStore = datastore.getTable('recordContainers')
					do @recordsFetch

					localCntr = do @getContainer
					remoteCntr = @remoteStore.getOrInsert(localCntr.id.toString(), localCntr.toRemoteFormat())
					unless remoteCntr.has('lastModifyTime') and !moment(remoteCntr.get('lastModifyTime')).isBefore(localCntr.get('lastModifyTime'))
						remoteCntr.update localCntr.toRemoteFormat()
						localCntr.set('lastSyncTime', new Date)

			# @listenTo eventManager, 'remotesync', =>
			# 	console.log 'a'
			# @listenTo @, 'all', =>
			# 	console.log arguments
			# @listenTo @records, 'all', =>
			# 	console.log arguments
			@

		# TODO Cache container
		getContainer: ->
			container = @find (container) ->
				moment(container.get('contentTime')).isSame(Common.targetDate.date)
			return container if container
			container = new RecordContainer
			container.set('contentTime', Common.targetDate.date)
			@add(container)
			container.save()
			container

		recordsUpdate: ->
			container = @getContainer()
			container.set('content', @records.toJSON())
			container.set('lastModifyTime', new Date)
			container.save()

		recordsFetch: ->
			@records.reset(@getContainer().get('content'))
