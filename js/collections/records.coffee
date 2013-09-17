define [
	'underscore'
	'backbone'
	'models/record'
	'store'
	'common'
], (_, Backbone, Record, Store, Common) ->
	'use strict'

	Backbone.Collection.extend
		model: Record

		localStorage: new Store('Records')

		initialize: ->
			@listenTo Common.targetDate, 'change', =>
				@trigger('filter')
			@