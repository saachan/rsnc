#### = Description
  ## HNumericTextControl is an extension of HTextControl that
  ## validates the input as a number. It supports value ranges.
  ##
  ## If you need decimal numbers (floating-point), pass the
  ## decimalNumber: true option to the constructor.
  ####
HNumericTextControl = HTextControl.extend

  defaultEvents:
    mouseWheel:  true
    contextMenu: true
    keyDown:     true
    textEnter:   false
    click:       true
    contextMenu: true

  controlDefaults: HTextControl.prototype.controlDefaults.extend
    numberIncrement: 1
    decimalNumber: false
    decimalPlaces: null
    decimalSeparator: null
    withStepper: false
    unit: false

  customOptions: (_options)->
    _options.decimalSeparator = HLocale.general.decimalSeparator unless _options.decimalSeparatator?

  ## Uses the mouseWheel event to step up/down the value.
  mouseWheel: (_delta)->
    _value = @value
    _value = parseInt(_value,10) if @typeChr(_value) == 's'
    if _delta < 0
      _value = _value-@options.numberIncrement
    else
      _value = _value+@options.numberIncrement
    _value = @validateNumber(_value)
    @setValue( _value )

  keyDown: (_key)->
    if _key == Event.KEY_UP
      @mouseWheel(1)
      return true
    else if _key == Event.KEY_DOWN
      @mouseWheel(-1)
      return true
    false

  _numbers: ['0','1','2','3','4','5','6','7','8','9']
  validateNumber: (_value)->
    if @options.decimalNumber
      _value = parseFloat(_value)
      if @options.decimalPlaces != null
        _decPlaces = Math.pow(10,@options.decimalPlaces)
        _value = Math.round(_value*_decPlaces)/_decPlaces
    else
      _value = parseInt( _value, 10 )
    if isNaN( _value )
      _value = @value
    if _value > @maxValue
      _value = @maxValue
    else if _value < @minValue
      _value = @minValue
    _value

  fieldToValue: (_unFilteredValue)->
    _value = ''
    for _chr, i in _unFilteredValue.split('')
      if _chr == '.' or _chr == @options.decimalSeparator
        _value += '.'
        continue
      if _chr == '-' and i == 0
        _value += '-'
      continue unless ~@_numbers.indexOf(_chr)
      _value += _chr
    @validateNumber( _value )
  valueToField: (_value)->
    _value = @validateNumber(_value)
    if @options.decimalNumber and @options.decimalPlaces != null
      if _value - Math.round(_value) == 0
        _value = _value+@options.decimalSeparator
        for n in [0...@options.decimalPlaces]
          _value += '0'
      else
        _value = _value.toString().replace('.',@options.decimalSeparator)
    _value

  refreshValue: ->
    @base()
    @stepper.setValue(@value) if @stepper?

  ### = Description
  ## Extends the validateText method to ensure the
  ## input is a number.
  ###
  # validateText: (_value)-> _value

  _extraLabelRight: 0
  drawSubviews: ->
    @base()
    @setStyleOfPart('value','textAlign','right')
    if @options.withStepper
      this._extraLabelRight += 14
      @setStyleOfPart('label','right',this._extraLabelRight+'px')
      _top = Math.round((@rect.height-22)/2)
      @stepper = HStepper.extend(
        refreshValue: ->
          @base()
          @parent.setValue(@value)
      ).new( [null,_top,14,24,0,null], @,
        value: @value
        valueObj: @valueObj
        minValue: @minValue
        maxValue: @maxValue
        stepSize: @options.numberIncrement
        enabled: @enabled
      )
      @stepper.bringToFront()
    if @options.unit
      _unitRect = [null,null,4,@rect.height,4,0]
      @unitSuffix = HLabel.new(_unitRect,@,
        pack: true
        label: @options.unit
        style:
          lineHeight: @rect.height+'px'
          verticalAlign: 'middle'
      )
      @_extraLabelRight += @unitSuffix.rect.width
      @setStyleOfPart('label','right',this._extraLabelRight+'px')

HNumberField = HNumericTextControl
