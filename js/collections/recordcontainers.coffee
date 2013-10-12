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
				do @recordsFetch
				DropboxProvider.getStore().done (store) =>
					remoteCntrs = store.getTable('recordContainers')

					localCntr = do @getContainer
					remoteCntr = remoteCntrs.query(
						contentTime: localCntr.get('contentTime')
					)[0]
					if !remoteCntr
						remoteCntrs.insert localCntr.toRemoteFormat()
					else if !moment(remoteCntr.get('createTime')).isSame(localCntr.get('createTime')) or moment(remoteCntr.get('lastModifyTime')).isAfter(localCntr.get('lastModifyTime'))
						localCntr.fetchRemote(remoteCntr.getFields())
						do @recordsFetch
					else if moment(remoteCntr.get('lastModifyTime')).isBefore(localCntr.get('lastModifyTime'))
							remoteCntr.update localCntr.toRemoteFormat()

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
