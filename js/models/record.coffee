define [
	'jquery'
	'underscore'
	'backbone'
	'common'
], ($, _, Backbone, Common) ->
	'use strict'

	Backbone.Model.extend
		categoryName: ->
			(_.findWhere Common.categories, value: @get('catgroy') or {}).name
				
			