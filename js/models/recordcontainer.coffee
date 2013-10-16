define [
	'jquery'
	'underscore'
	'backbone'
	'common'
	'dropboxprovider'
], ($, _, Backbone, common, DropboxProvider) ->
	'use strict'

	Backbone.Model.extend
		defaults: ->
			createTime: new Date
			lastModifyTime: new Date
			contentTime: undefined
			content: []

		remote:
			table: 'recordContainers'
			key: 'contentTime'

		provider: DropboxProvider

		remoteSync: ->
			defer = do $.Deferred

			if @provider.available()
				@provider.getStore().done (store) =>
					remoteRecs = store.getTable(@remote.table)
					remoteRec = remoteRecs.query(_.object([
							@remote.key
						], [
							@get(@remote.key)
						]
					))[0]
					if !remoteRec
						remoteRecs.insert @toRemoteFormat()
						defer.resolve @, new Event('remotecreate')
					else if !moment(remoteRec.get('createTime')).isSame(@get('createTime')) or moment(remoteRec.get('lastModifyTime')).isAfter(@get('lastModifyTime'))
						console.log 'localupdate'
						@fetchRemote(remoteRec.getFields())
						defer.resolve @, new Event('localupdate')
					else if moment(remoteRec.get('lastModifyTime')).isBefore(@get('lastModifyTime'))
						console.log 'remoteupdate'
						defer.resolve @, new Event('remoteupdate')
						remoteRec.update @toRemoteFormat()
					else
						defer.resolve @, new Event('uptodate')
			else
				defer.reject(@, new Event('Store is not available.'))

			do defer.promise

		toRemoteFormat: ->
			recCntr = @toJSON()
			recCntr.content = JSON.stringify recCntr.content
			delete recCntr.id
			recCntr

		fetchRemote: (recCntr) ->
			recCntr.content = JSON.parse recCntr.content
			@save(recCntr)
