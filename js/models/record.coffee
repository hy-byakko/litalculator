define [
	'jquery'
	'underscore'
	'backbone'
	'moment'
	'common'
], ($, _, Backbone, moment, Common) ->
	'use strict'

	Backbone.Model.extend
		defaults: ->
			worker: 0
			createTime: Common.targetDate.date

		categoryName: ->
			(Common.getCategory(@get('category')) or {}).text
		detailName: ->
			(Common.getDetail(@get('category'), @get('detail')) or {}).text
		workerName: ->
			(Common.getWorker(@get('worker')) or {}).text
		detailEditable: ->
			!_.isUndefined @get("category")
		isValid: ->
			@get('num') and !_.isUndefined(Common.getDetail(@get('category'), @get('detail')))
		isActived: ->
			moment(@get('createTime')).startOf('day').isSame(moment(Common.targetDate.date).startOf('day'))