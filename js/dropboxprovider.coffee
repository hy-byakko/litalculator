define [
	'jquery'
	'underscore'
	'backbone'
	'Dropbox'
	'eventmgr'
], ($, _, Backbone, Dropbox, eventManager) ->
	client = new Dropbox.Client key: 't35la3qyv5bvtry'
	client.authDriver new Dropbox.AuthDriver.Popup
	    receiverUrl: "http://localhost:4000/dropbox-oauth-receiver.html"
	    rememberUser: true

	client.authenticate
		interactive: false
	, (error) ->
        alert('Authentication error: ' + error) if error

	$view =	$('#dropbox-view')

	$login = $view.children('#dropbox-login').on 'click', ->
		DropboxProvider.client.authenticate undefined, ->
			signState(true)

	$sync = $view.children('#dropbox-sync')
	$signOut = $view.children('#dropbox-signout').on 'click', ->
		DropboxProvider.client.signOut undefined, ->
			signState(false)

	signState = (signIn) ->
		if signIn
			do $login.hide
			do $signOut.show
		else
			do $login.show
			do $signOut.hide

	if client.isAuthenticated()
		eventManager.trigger('remotesync')
		signState(true)
	else
		signState(false)

	do $view.show

	# Extend model
	Backbone.Model.prototype.remoteSync = ->
		defer = do $.Deferred

		if DropboxProvider.available()
			DropboxProvider.getStore().done (store) =>
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
				else if !moment(remoteRec.get('createTime')).isSame(@get('createTime')) or moment(remoteRec.get('modifyTime')).isAfter(@get('modifyTime'))
					console.log 'localupdate'
					@save @toLocalFormat remoteRec.getFields()
					defer.resolve @, new Event('localupdate')
				else if moment(remoteRec.get('modifyTime')).isBefore(@get('modifyTime'))
					console.log 'remoteupdate'
					defer.resolve @, new Event('remoteupdate')
					remoteRec.update @toRemoteFormat()
				else
					defer.resolve @, new Event('uptodate')
		else
			defer.reject(@, new Event('Store is not available.'))

		do defer.promise

	Backbone.Model.prototype.toRemoteFormat = (item) ->
		item = @toJSON()
		delete item.id
		item

	Backbone.Model.prototype.toLocalFormat = (item) ->
		item

	class DropboxProvider
		@client: client
		@available: ->
			do @client.isAuthenticated
		@getStore: ->
			$.Deferred (deferred) =>
				return deferred.resolve(@store) if @store
				client.getDatastoreManager().openDefaultDatastore (error, datastore) =>
					if error
						console.log('Error opening default datastore: ' + error)
						deferred.reject(error)
					else
						@store = datastore
						deferred.resolve(@store)
		@closeStore: ->
			do store.close if @store
		@cleanTable: (name) ->
			@getStore().done (store) ->
				records = store.getTable(name).query()
				_.each records, (record) ->
					do record.deleteRecord

	window.DropboxProvider = DropboxProvider

	DropboxProvider