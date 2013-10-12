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

	if client.isAuthenticated()
		eventManager.trigger('remotesync')

	class DropboxProvider
		@client: client
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
		@cleanTable: (name) ->
			@getStore().done (store) ->
				records = store.getTable(name).query()
				_.each records, (record) ->
					do record.deleteRecord