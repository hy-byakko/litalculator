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

		categoryName: ->
			(Common.getCategory(@get('category')) or {}).text
		detailName: ->
			(Common.getDetail(@get('category'), @get('detail')) or {}).text
		workerName: ->
			(Common.getWorker(@get('worker')) or {}).text
		detailEditable: ->
			!_.isUndefined @get("category")
		isValid: ->
			@getNum() and !_.isUndefined(Common.getDetail(@get('category'), @get('detail')))
		setNum: (value) ->
			if /^\d+$/.test value
				@set('num', parseInt(value))
			else
				try
					evalVal = eval value
					if _.isNaN parseInt(evalVal)
						@set('num', undefined)
					else
						@set('num', value)
						@set('evalNum', evalVal)
				catch e
					console.log e
		getNum: ->
			unless _.isUndefined @get('num')
				if _.isNumber @get('num') then @get('num') else @get('evalNum')
