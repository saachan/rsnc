# Client -> Server push value buffer.
# Works like HValue, but only streams out changes
# instead of keeping only the last state.
# The nature of the buffer is volatile, so don't rely
# on re-transmission on failures.
# Ideal for event logging purposes.
HPushValue = HValue.extend
  constructor: (_id,_value)->
    @buffer = [_value]
    @base(_id,_value)
  toSync: ->
    _arr = []
    _histLen = @buffer.length
    for i in [0..(_histLen)]
      _arr.push( @buffer.shift() )
    _arr
  set: (_value)->
    @buffer.push(_value)
    @value = _value
    COMM.Values.changed(@)
    @refresh()
  die: ->
    @buffer = null
    delete @buffer
    @base()
