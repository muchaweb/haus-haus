"use strict"


BASE_API_URL = 'http://192.168.1.6:8000/api/'
window.vent         = _.extend {}, Backbone.Events

window.template = (idTemplate)->
  source   = $("#" + idTemplate).html()
  template = Handlebars.compile source
  return template

App            = App or {}
App.Model      = App.Model or {}
App.Collection = App.Collection or {}
App.View       = App.View or {}


App.View.Map = Backbone.View.extend
  el : '#map-container'
  latlng : []

  initialize : ->
    vent.on 'map:render' , @render , @

  render : ( latlng )->
    @$el.gmap3
      map :
        options :
          center : latlng
          zoom : 14
      clear :
        name : [ 'marker' ]
        last : true
      marker :
        values :[ latLng : latlng ]

    @

# Model for a single Town
App.Model.Town = Backbone.Model.extend
  urlRoot : BASE_API_URL + 'town'

# Collection for  Towns
App.Collection.Town = Backbone.Collection.extend
  model : App.Model.Town
  url   : BASE_API_URL + 'town'

#View for Towns
App.View.Town = Backbone.View.extend
  el       : '#town'
  template : template 'option-select-template'
  towns    : null,

  initialize : ->
    @towns = new App.Collection.Town()
    @render()
    @towns.fetch reset:true
    @listenTo @towns, 'reset', @render
    return

  render : ->
    if @towns.models.length > 0
      output = @template option: @.towns.toJSON()
      @$el.append output
    return @

  events :
    'change' : 'fetchall'

  fetchall : ->
    town = @towns.get( @$el.val() )
    latlng = [ town.get('lat') ,  town.get('lng') ]

    vent.trigger 'map:render' , latlng
    vent.trigger 'fetch:zipcode:town', @$el.val()
    vent.trigger 'fetch:settlement:town', @$el.val()
    return

# Model for a single ZipCode
App.Model.ZipCode = Backbone.Model.extend()

# Collection for ZipCodes
App.Collection.ZipCode = Backbone.Collection.extend
  model : App.Model.ZipCode
  url: ''

# View for ZipCodes
App.View.ZipCode = Backbone.View.extend
  el       : '#zipcode'
  template : template 'option-select-template'
  zipcodes : null
  oldID : ''

  initialize : ->
    @zipcodes = new App.Collection.ZipCode()
    vent.on 'fetch:zipcode:town', @zipCodeOfTown, @
    vent.on 'fetch:zipcode:settlement' , @zipCodeOfSettlement, @
    return

  zipCodeOfTown : ( townId )->
    @zipcodes.url = BASE_API_URL + 'town/' + townId + '/zipcodes/'
    @zipcodes.fetch reset:true
    @listenTo @zipcodes, 'reset', @render
    return

  zipCodeOfSettlement : ( idZipCode )->
    idZipCode = idZipCode
    opt = @$el.find("option[value=#{idZipCode}]")

    html = $("<div>").append(opt.clone()).html()
    html = html.replace(/\>/, " selected=\"selected\">")
    opt.replaceWith html
    ###if @zipcodes.url.indexOf('settlement') > 1
      @zipcodes.url = @zipcodes.url.replace(@oldID,settlementId)
    else
      @zipcodes.url = @zipcodes.url.replace('zipcodes','settlement') +
        settlementId + '/zipcodes/'

    @oldID = settlementId
    @zipcodes.fetch reset:true###
    return

  render : ->
    @$el.empty()
    if @zipcodes.models.length > 0
      output = @template option: @.zipcodes.toJSON()
      @$el.append output
    return

  events :
    'change' : 'fetchSettlements'

  fetchSettlements : ()->
    vent.trigger 'fetch:settlement:zipcode' , @$el.val()
    return

# Model for a single Suburb/Settlement
App.Model.Settlement = Backbone.Model.extend()

# Collection for Settlements/Settlement
App.Collection.Settlement = Backbone.Collection.extend
  model : App.Model.Settlement

  initialize : (options)->
    @url = options.url
    return

# View for Settlements/Settlements
App.View.Settlement = Backbone.View.extend
  el          : '#settlement'
  template    : template 'option-select-template'
  settlements : null
  oldID       : ''

  initialize : ->
    vent.on 'fetch:settlement:town', @settlementOfTown, @
    vent.on 'fetch:settlement:zipcode' , @settlementOfZipCode, @
    return

  settlementOfTown : ( townId ) ->
    @settlements = new App.Collection.Settlement
      url : BASE_API_URL + 'town/' + townId + '/settlement/'
    @settlements.fetch reset:true
    @listenTo @settlements , 'reset' , @render
    return

  settlementOfZipCode : (idZipCode)->
    @settlements.reset()

    if @settlements.url.indexOf('zipcodes') > 1
      @settlements.url = @settlements.url.replace(@oldID,idZipCode)
    else
      @settlements.url = @settlements.url.replace('settlement','zipcodes') +
      idZipCode + '/settlement/'

    @oldID = idZipCode
    @settlements.fetch reset:true
    return

  render : ->
    @$el.empty()
    centralVector = new Vector
    if @settlements.models.length > 0
      _.each @.settlements.models , (model)->
        model.set 'name' ,  model.get('settlement_type') + ' - ' +
        model.get( 'settlement')

        if model.get('lat')? and model.get('lng')?
          console.log 'exsiten coordenadas..'
          settlementVector = new Vector
          settlementVector.sphericalTo3D(model.get('lat'), model.get('lng'))
          centralVector.add settlementVector
          return

      centralVector.normalize()
      output = @template option: @.settlements.toJSON()
      @$el.append output
      #vent.trigger 'map:render' , centralVector.toSpherical()
    return

  events :
    'change' : 'fetchZipCode'

  fetchZipCode : ->

    settlement = @settlements.get @$el.val()

    vent.trigger 'fetch:zipcode:settlement' , settlement.get('_fakezip')
    if settlement.get('lat')? and settlement.get('lng')?
      vent.trigger 'map:render' , [settlement.get('lat'), settlement.get('lng')]
      return
    else
      alert 'No existe Latitud - Longitud'
      return

new App.View.ZipCode
new App.View.Settlement
new App.View.Town
new App.View.Map