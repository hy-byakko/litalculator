define [
	'jquery'
	'underscore'
	'Dropbox'
	'eventmgr'
], ($, _, Dropbox, eventManager) ->
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