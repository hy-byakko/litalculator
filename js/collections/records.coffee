define [
	'underscore'
	'backbone'
	'models/record'
	'store'
], (_, Backbone, Record, Store) ->
	'use strict'

	Backbone.Collection.extend
		model: Record

		localStorage: new Store('Records')