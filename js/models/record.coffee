define [
	'jquery'
	'underscore'
	'backbone'
	'moment'
	'common'
], ($, _, Backbone, moment, Common) ->
	'use strict'

	Backbone.Model.extend
		defaults:
			worker: 0
			createTime: new Date

		categoryName: ->
			(Common.getCategory(@get('category')) or {}).text
		detailName: ->
			(Common.getDetail(@get('category'), @get('detail')) or {}).text
		workerName: ->
			(Common.getWorker(@get('worker')) or {}).text

		isValid: ->
			@get('num') and (Common.getDetail(@get('category'), @get('detail')).value != undefined)

		isActived: ->
			moment(@get('createTime')).startOf('day').isSame(moment().startOf('day'))