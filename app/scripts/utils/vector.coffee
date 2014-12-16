Vector = (x, y, z) ->
  @x = x or 0
  @y = y or 0
  @z = z or 0
  return

Vector:: =
  negative: ->
    new Vector(-@x, -@y, -@z)

  add: (v) ->
    @x = @x + v.x
    @y = @y + v.y
    @z = @z + v.z

  subtract: (v) ->
    if v instanceof Vector
      new Vector(@x - v.x, @y - v.y, @z - v.z)
    else
      new Vector(@x - v, @y - v, @z - v)

  multiply: (v) ->
    if v instanceof Vector
      new Vector(@x * v.x, @y * v.y, @z * v.z)
    else
      new Vector(@x * v, @y * v, @z * v)

  divide: (v) ->
    if v instanceof Vector
      new Vector(@x / v.x, @y / v.y, @z / v.z)
    else
      new Vector(@x / v, @y / v, @z / v)

  equals: (v) ->
    @x is v.x and @y is v.y and @z is v.z

  dot: (v) ->
    @x * v.x + @y * v.y + @z * v.z

  cross: (v) ->
    new Vector(@y * v.z - @z * v.y, @z * v.x - @x * vagregar.z, @x * v.y - @y * v.x)

  length: ->
    Math.sqrt @dot(this)

  unit: ->
    @divide @length()

  min: ->
    Math.min Math.min(@x, @y), @z

  max: ->
    Math.max Math.max(@x, @y), @z

  toAngles: ->
    theta: Math.atan2(@z, @x)
    phi: Math.asin(@y / @length())

  toArray: (n) ->
    [
      this.x
      this.y
      this.z
    ].slice 0, n or 3

  clone: ->
    new Vector(@x, @y, @z)

  sphericalTo3D: (lat, lng) ->
    lat = lat * Math.PI / 180
    lng = lng * Math.PI / 180
    @x = Math.cos(lng) * Math.sin(lat)
    @y = Math.sin(lng) * Math.sin(lat)
    @z = Math.cos(lat)
    this

  toSpherical: ->
    lat = undefined
    lng = undefined
    lng = Math.atan2(@y, @x) * (180 / Math.PI)
    lat = Math.acos(@z) * (180 / Math.PI)
    [
      lat
      lng
    ]

  normalize: ->
    m = undefined
    m = @length()
    if m isnt 0
      @x = @x / m
      @y = @y / m
      @z = @z / m
    this

  init: (x, y, z) ->
    @x = x
    @y = y
    @z = z
    this
window.Vector = Vector;