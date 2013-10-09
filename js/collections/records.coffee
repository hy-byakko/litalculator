define [
	'underscore'
	'backbone'
	'models/record'
	'common'
], (_, Backbone, Record, Common) ->
	'use strict'

	Backbone.Collection.extend
		model: Record
