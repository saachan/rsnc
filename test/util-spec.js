(() => {

  const expect = chai.expect;

  const require = __modules.__require;

  const UtilMethods = require('util/util_methods');

  describe('UtilMethods type check methods', function() {

    const util = UtilMethods.new();
    it('isFloat works as expected', done => {
      expect(util.isFloat('foo')).to.be.false;
      expect(util.isFloat(12.345)).to.be.true;
      expect(util.isFloat(12)).to.be.false;
      expect(util.isFloat('12.345')).to.be.false;
      expect(util.isFloat(3 / 3)).to.be.false;
      expect(util.isFloat(1 - 1.5)).to.be.true;
      expect(util.isFloat(null)).to.be.false;
      expect(util.isFloat(false)).to.be.false;
      expect(util.isFloat([])).to.be.false;
      expect(util.isFloat({})).to.be.false;
      done();
    });
    it('isntFloat works as expected', done => {
      expect(util.isntFloat('foo')).to.be.true;
      expect(util.isntFloat(12.345)).to.be.false;
      expect(util.isntFloat(12)).to.be.true;
      expect(util.isntFloat('12.345')).to.be.true;
      expect(util.isntFloat(3 / 3)).to.be.true;
      expect(util.isntFloat(1 - 1.5)).to.be.false;
      expect(util.isntFloat(null)).to.be.true;
      expect(util.isntFloat(false)).to.be.true;
      expect(util.isntFloat([])).to.be.true;
      expect(util.isntFloat({})).to.be.true;
      done();
    });
    const obj = {};
    const array = [];
    it('isNullOrUndefined works as expected', done => {
      expect(util.isNullOrUndefined(null)).to.be.true;
      expect(util.isNullOrUndefined(obj.foo)).to.be.true;
      expect(util.isNullOrUndefined(array.foo)).to.be.true;
      expect(util.isNullOrUndefined(12.345)).to.be.false;
      expect(util.isNullOrUndefined(12)).to.be.false;
      expect(util.isNullOrUndefined('12.345')).to.be.false;
      expect(util.isNullOrUndefined(false)).to.be.false;
      expect(util.isNullOrUndefined([])).to.be.false;
      expect(util.isNullOrUndefined({})).to.be.false;
      done();
    });
    it('isntNullOrUndefined works as expected', done => {
      expect(util.isntNullOrUndefined(null)).to.be.false;
      expect(util.isntNullOrUndefined(obj.foo)).to.be.false;
      expect(util.isntNullOrUndefined(array.foo)).to.be.false;
      expect(util.isntNullOrUndefined(12.345)).to.be.true;
      expect(util.isntNullOrUndefined(12)).to.be.true;
      expect(util.isntNullOrUndefined('12.345')).to.be.true;
      expect(util.isntNullOrUndefined(false)).to.be.true;
      expect(util.isntNullOrUndefined([])).to.be.true;
      expect(util.isntNullOrUndefined({})).to.be.true;
      done();
    });
    it('isUndefinedOrNull works as expected', done => {
      expect(util.isUndefinedOrNull(null)).to.be.true;
      expect(util.isUndefinedOrNull(obj.foo)).to.be.true;
      expect(util.isUndefinedOrNull(array.foo)).to.be.true;
      expect(util.isUndefinedOrNull(12.345)).to.be.false;
      expect(util.isUndefinedOrNull(12)).to.be.false;
      expect(util.isUndefinedOrNull('12.345')).to.be.false;
      expect(util.isUndefinedOrNull(false)).to.be.false;
      expect(util.isUndefinedOrNull([])).to.be.false;
      expect(util.isUndefinedOrNull({})).to.be.false;
      done();
    });
    it('isntUndefinedOrNull works as expected', done => {
      expect(util.isntUndefinedOrNull(null)).to.be.false;
      expect(util.isntUndefinedOrNull(obj.foo)).to.be.false;
      expect(util.isntUndefinedOrNull(array.foo)).to.be.false;
      expect(util.isntUndefinedOrNull(12.345)).to.be.true;
      expect(util.isntUndefinedOrNull(12)).to.be.true;
      expect(util.isntUndefinedOrNull('12.345')).to.be.true;
      expect(util.isntUndefinedOrNull(false)).to.be.true;
      expect(util.isntUndefinedOrNull([])).to.be.true;
      expect(util.isntUndefinedOrNull({})).to.be.true;
      done();
    });
    it('isFunction works as expected', done => {
      expect(util.isFunction(function() {})).to.be.true;
      expect(util.isFunction(() => {})).to.be.true;
      expect(util.isFunction(null)).to.be.false;
      expect(util.isFunction(obj.foo)).to.be.false;
      expect(util.isFunction(array.foo)).to.be.false;
      expect(util.isFunction(12.345)).to.be.false;
      expect(util.isFunction(12)).to.be.false;
      expect(util.isFunction('12.345')).to.be.false;
      expect(util.isFunction(false)).to.be.false;
      expect(util.isFunction([])).to.be.false;
      expect(util.isFunction({})).to.be.false;
      done();
    });
    it('isntFunction works as expected', done => {
      expect(util.isntFunction(function() {})).to.be.false;
      expect(util.isntFunction(() => {})).to.be.false;
      expect(util.isntFunction(null)).to.be.true;
      expect(util.isntFunction(obj.foo)).to.be.true;
      expect(util.isntFunction(array.foo)).to.be.true;
      expect(util.isntFunction(12.345)).to.be.true;
      expect(util.isntFunction(12)).to.be.true;
      expect(util.isntFunction('12.345')).to.be.true;
      expect(util.isntFunction(false)).to.be.true;
      expect(util.isntFunction([])).to.be.true;
      expect(util.isntFunction({})).to.be.true;
      done();
    });
    it('isNumber works as expected', done => {
      expect(util.isNumber('foo')).to.be.false;
      expect(util.isNumber(12.345)).to.be.true;
      expect(util.isNumber(12)).to.be.true;
      expect(util.isNumber('12.345')).to.be.false;
      expect(util.isNumber(3 / 3)).to.be.true;
      expect(util.isNumber(1 - 1.5)).to.be.true;
      expect(util.isNumber(null)).to.be.false;
      expect(util.isNumber(false)).to.be.false;
      expect(util.isNumber([])).to.be.false;
      expect(util.isNumber({})).to.be.false;
      done();
    });
    it('isntNumber works as expected', done => {
      expect(util.isntNumber('foo')).to.be.true;
      expect(util.isntNumber(12.345)).to.be.false;
      expect(util.isntNumber(12)).to.be.false;
      expect(util.isntNumber('12.345')).to.be.true;
      expect(util.isntNumber(3 / 3)).to.be.false;
      expect(util.isntNumber(1 - 1.5)).to.be.false;
      expect(util.isntNumber(null)).to.be.true;
      expect(util.isntNumber(false)).to.be.true;
      expect(util.isntNumber([])).to.be.true;
      expect(util.isntNumber({})).to.be.true;
      done();
    });
    it('isInteger works as expected', done => {
      expect(util.isInteger('foo')).to.be.false;
      expect(util.isInteger(12.345)).to.be.false;
      expect(util.isInteger(12)).to.be.true;
      expect(util.isInteger('12.345')).to.be.false;
      expect(util.isInteger(3 / 3)).to.be.true;
      expect(util.isInteger(1 - 1.5)).to.be.false;
      expect(util.isInteger(null)).to.be.false;
      expect(util.isInteger(false)).to.be.false;
      expect(util.isInteger([])).to.be.false;
      expect(util.isInteger({})).to.be.false;
      done();
    });
    it('isntInteger works as expected', done => {
      expect(util.isntInteger('foo')).to.be.true;
      expect(util.isntInteger(12.345)).to.be.true;
      expect(util.isntInteger(12)).to.be.false;
      expect(util.isntInteger('12.345')).to.be.true;
      expect(util.isntInteger(3 / 3)).to.be.false;
      expect(util.isntInteger(1 - 1.5)).to.be.true;
      expect(util.isntInteger(null)).to.be.true;
      expect(util.isntInteger(false)).to.be.true;
      expect(util.isntInteger([])).to.be.true;
      expect(util.isntInteger({})).to.be.true;
      done();
    });
    it('isString works as expected', done => {
      expect(util.isString('foo')).to.be.true;
      expect(util.isString(12.345)).to.be.false;
      expect(util.isString(12)).to.be.false;
      expect(util.isString('12.345')).to.be.true;
      expect(util.isString(3 / 3)).to.be.false;
      expect(util.isString(1 - 1.5)).to.be.false;
      expect(util.isString(null)).to.be.false;
      expect(util.isString(false)).to.be.false;
      expect(util.isString([])).to.be.false;
      expect(util.isString({})).to.be.false;
      done();
    });
    it('isntString works as expected', done => {
      expect(util.isntString('foo')).to.be.false;
      expect(util.isntString(12.345)).to.be.true;
      expect(util.isntString(12)).to.be.true;
      expect(util.isntString('12.345')).to.be.false;
      expect(util.isntString(3 / 3)).to.be.true;
      expect(util.isntString(1 - 1.5)).to.be.true;
      expect(util.isntString(null)).to.be.true;
      expect(util.isntString(false)).to.be.true;
      expect(util.isntString([])).to.be.true;
      expect(util.isntString({})).to.be.true;
      done();
    });
    it('isStringOrNumber works as expected', done => {
      expect(util.isStringOrNumber('foo')).to.be.true;
      expect(util.isStringOrNumber(12.345)).to.be.true;
      expect(util.isStringOrNumber(12)).to.be.true;
      expect(util.isStringOrNumber('12.345')).to.be.true;
      expect(util.isStringOrNumber(3 / 3)).to.be.true;
      expect(util.isStringOrNumber(1 - 1.5)).to.be.true;
      expect(util.isStringOrNumber(null)).to.be.false;
      expect(util.isStringOrNumber(false)).to.be.false;
      expect(util.isStringOrNumber([])).to.be.false;
      expect(util.isStringOrNumber({})).to.be.false;
      done();
    });
    it('isntStringOrNumber works as expected', done => {
      expect(util.isntStringOrNumber('foo')).to.be.false;
      expect(util.isntStringOrNumber(12.345)).to.be.false;
      expect(util.isntStringOrNumber(12)).to.be.false;
      expect(util.isntStringOrNumber('12.345')).to.be.false;
      expect(util.isntStringOrNumber(3 / 3)).to.be.false;
      expect(util.isntStringOrNumber(1 - 1.5)).to.be.false;
      expect(util.isntStringOrNumber(null)).to.be.true;
      expect(util.isntStringOrNumber(false)).to.be.true;
      expect(util.isntStringOrNumber([])).to.be.true;
      expect(util.isntStringOrNumber({})).to.be.true;
      done();
    });
    it('isNumberOrString works as expected', done => {
      expect(util.isNumberOrString('foo')).to.be.true;
      expect(util.isNumberOrString(12.345)).to.be.true;
      expect(util.isNumberOrString(12)).to.be.true;
      expect(util.isNumberOrString('12.345')).to.be.true;
      expect(util.isNumberOrString(3 / 3)).to.be.true;
      expect(util.isNumberOrString(1 - 1.5)).to.be.true;
      expect(util.isNumberOrString(null)).to.be.false;
      expect(util.isNumberOrString(false)).to.be.false;
      expect(util.isNumberOrString([])).to.be.false;
      expect(util.isNumberOrString({})).to.be.false;
      done();
    });
    it('isntNumberOrString works as expected', done => {
      expect(util.isntNumberOrString('foo')).to.be.false;
      expect(util.isntNumberOrString(12.345)).to.be.false;
      expect(util.isntNumberOrString(12)).to.be.false;
      expect(util.isntNumberOrString('12.345')).to.be.false;
      expect(util.isntNumberOrString(3 / 3)).to.be.false;
      expect(util.isntNumberOrString(1 - 1.5)).to.be.false;
      expect(util.isntNumberOrString(null)).to.be.true;
      expect(util.isntNumberOrString(false)).to.be.true;
      expect(util.isntNumberOrString([])).to.be.true;
      expect(util.isntNumberOrString({})).to.be.true;
      done();
    });
    it('isArray works as expected', done => {
      expect(util.isArray('foo')).to.be.false;
      expect(util.isArray(12.345)).to.be.false;
      expect(util.isArray(12)).to.be.false;
      expect(util.isArray('12.345')).to.be.false;
      expect(util.isArray(3 / 3)).to.be.false;
      expect(util.isArray(1 - 1.5)).to.be.false;
      expect(util.isArray(null)).to.be.false;
      expect(util.isArray(false)).to.be.false;
      expect(util.isArray([])).to.be.true;
      expect(util.isArray({})).to.be.false;
      done();
    });
    it('isntArray works as expected', done => {
      expect(util.isntArray('foo')).to.be.true;
      expect(util.isntArray(12.345)).to.be.true;
      expect(util.isntArray(12)).to.be.true;
      expect(util.isntArray('12.345')).to.be.true;
      expect(util.isntArray(3 / 3)).to.be.true;
      expect(util.isntArray(1 - 1.5)).to.be.true;
      expect(util.isntArray(null)).to.be.true;
      expect(util.isntArray(false)).to.be.true;
      expect(util.isntArray([])).to.be.false;
      expect(util.isntArray({})).to.be.true;
      done();
    });
    it('isObject works as expected', done => {
      expect(util.isObject('foo')).to.be.false;
      expect(util.isObject(12.345)).to.be.false;
      expect(util.isObject(12)).to.be.false;
      expect(util.isObject('12.345')).to.be.false;
      expect(util.isObject(3 / 3)).to.be.false;
      expect(util.isObject(1 - 1.5)).to.be.false;
      expect(util.isObject(null)).to.be.false;
      expect(util.isObject(false)).to.be.false;
      expect(util.isObject([])).to.be.false;
      expect(util.isObject({})).to.be.true;
      done();
    });
    it('isntObject works as expected', done => {
      expect(util.isntObject('foo')).to.be.true;
      expect(util.isntObject(12.345)).to.be.true;
      expect(util.isntObject(12)).to.be.true;
      expect(util.isntObject('12.345')).to.be.true;
      expect(util.isntObject(3 / 3)).to.be.true;
      expect(util.isntObject(1 - 1.5)).to.be.true;
      expect(util.isntObject(null)).to.be.true;
      expect(util.isntObject(false)).to.be.true;
      expect(util.isntObject([])).to.be.true;
      expect(util.isntObject({})).to.be.false;
      done();
    });
    it('isObjectOrArray works as expected', done => {
      expect(util.isObjectOrArray('foo')).to.be.false;
      expect(util.isObjectOrArray(12.345)).to.be.false;
      expect(util.isObjectOrArray(12)).to.be.false;
      expect(util.isObjectOrArray('12.345')).to.be.false;
      expect(util.isObjectOrArray(3 / 3)).to.be.false;
      expect(util.isObjectOrArray(1 - 1.5)).to.be.false;
      expect(util.isObjectOrArray(null)).to.be.false;
      expect(util.isObjectOrArray(false)).to.be.false;
      expect(util.isObjectOrArray([])).to.be.true;
      expect(util.isObjectOrArray({})).to.be.true;
      done();
    });
    it('isntObjectOrArray works as expected', done => {
      expect(util.isntObjectOrArray('foo')).to.be.true;
      expect(util.isntObjectOrArray(12.345)).to.be.true;
      expect(util.isntObjectOrArray(12)).to.be.true;
      expect(util.isntObjectOrArray('12.345')).to.be.true;
      expect(util.isntObjectOrArray(3 / 3)).to.be.true;
      expect(util.isntObjectOrArray(1 - 1.5)).to.be.true;
      expect(util.isntObjectOrArray(null)).to.be.true;
      expect(util.isntObjectOrArray(false)).to.be.true;
      expect(util.isntObjectOrArray([])).to.be.false;
      expect(util.isntObjectOrArray({})).to.be.false;
      done();
    });
    it('isArrayOrObject works as expected', done => {
      expect(util.isArrayOrObject('foo')).to.be.false;
      expect(util.isArrayOrObject(12.345)).to.be.false;
      expect(util.isArrayOrObject(12)).to.be.false;
      expect(util.isArrayOrObject('12.345')).to.be.false;
      expect(util.isArrayOrObject(3 / 3)).to.be.false;
      expect(util.isArrayOrObject(1 - 1.5)).to.be.false;
      expect(util.isArrayOrObject(null)).to.be.false;
      expect(util.isArrayOrObject(false)).to.be.false;
      expect(util.isArrayOrObject([])).to.be.true;
      expect(util.isArrayOrObject({})).to.be.true;
      done();
    });
    it('isntArrayOrObject works as expected', done => {
      expect(util.isntArrayOrObject('foo')).to.be.true;
      expect(util.isntArrayOrObject(12.345)).to.be.true;
      expect(util.isntArrayOrObject(12)).to.be.true;
      expect(util.isntArrayOrObject('12.345')).to.be.true;
      expect(util.isntArrayOrObject(3 / 3)).to.be.true;
      expect(util.isntArrayOrObject(1 - 1.5)).to.be.true;
      expect(util.isntArrayOrObject(null)).to.be.true;
      expect(util.isntArrayOrObject(false)).to.be.true;
      expect(util.isntArrayOrObject([])).to.be.false;
      expect(util.isntArrayOrObject({})).to.be.false;
      done();
    });
    it('isNull works as expected', done => {
      expect(util.isNull(null)).to.be.true;
      expect(util.isNull(obj.foo)).to.be.false;
      expect(util.isNull(array.foo)).to.be.false;
      expect(util.isNull(12.345)).to.be.false;
      expect(util.isNull(12)).to.be.false;
      expect(util.isNull('12.345')).to.be.false;
      expect(util.isNull(false)).to.be.false;
      expect(util.isNull([])).to.be.false;
      expect(util.isNull({})).to.be.false;
      done();
    });
    it('isntNull works as expected', done => {
      expect(util.isntNull(null)).to.be.false;
      expect(util.isntNull(obj.foo)).to.be.true;
      expect(util.isntNull(array.foo)).to.be.true;
      expect(util.isntNull(12.345)).to.be.true;
      expect(util.isntNull(12)).to.be.true;
      expect(util.isntNull('12.345')).to.be.true;
      expect(util.isntNull(false)).to.be.true;
      expect(util.isntNull([])).to.be.true;
      expect(util.isntNull({})).to.be.true;
      done();
    });
    it('isUndefined works as expected', done => {
      expect(util.isUndefined(null)).to.be.false;
      expect(util.isUndefined(obj.foo)).to.be.true;
      expect(util.isUndefined(array.foo)).to.be.true;
      expect(util.isUndefined(12.345)).to.be.false;
      expect(util.isUndefined(12)).to.be.false;
      expect(util.isUndefined('12.345')).to.be.false;
      expect(util.isUndefined(false)).to.be.false;
      expect(util.isUndefined([])).to.be.false;
      expect(util.isUndefined({})).to.be.false;
      done();
    });
    it('isntUndefined works as expected', done => {
      expect(util.isntUndefined(null)).to.be.true;
      expect(util.isntUndefined(obj.foo)).to.be.false;
      expect(util.isntUndefined(array.foo)).to.be.false;
      expect(util.isntUndefined(12.345)).to.be.true;
      expect(util.isntUndefined(12)).to.be.true;
      expect(util.isntUndefined('12.345')).to.be.true;
      expect(util.isntUndefined(false)).to.be.true;
      expect(util.isntUndefined([])).to.be.true;
      expect(util.isntUndefined({})).to.be.true;
      done();
    });
    it('isDate works as expected', done => {
      expect(util.isDate(null)).to.be.false;
      expect(util.isDate(obj.foo)).to.be.false;
      expect(util.isDate(array.foo)).to.be.false;
      expect(util.isDate(12.345)).to.be.false;
      expect(util.isDate(12)).to.be.false;
      expect(util.isDate('12.345')).to.be.false;
      expect(util.isDate(false)).to.be.false;
      expect(util.isDate([])).to.be.false;
      expect(util.isDate({})).to.be.false;
      expect(util.isDate(new Date())).to.be.true;
      done();
    });
    it('isntDate works as expected', done => {
      expect(util.isntDate(null)).to.be.true;
      expect(util.isntDate(obj.foo)).to.be.true;
      expect(util.isntDate(array.foo)).to.be.true;
      expect(util.isntDate(12.345)).to.be.true;
      expect(util.isntDate(12)).to.be.true;
      expect(util.isntDate('12.345')).to.be.true;
      expect(util.isntDate(false)).to.be.true;
      expect(util.isntDate([])).to.be.true;
      expect(util.isntDate({})).to.be.true;
      expect(util.isntDate(new Date())).to.be.false;
      done();
    });
    it('isBoolean works as expected', done => {
      expect(util.isBoolean(null)).to.be.false;
      expect(util.isBoolean(obj.foo)).to.be.false;
      expect(util.isBoolean(array.foo)).to.be.false;
      expect(util.isBoolean(12.345)).to.be.false;
      expect(util.isBoolean(12)).to.be.false;
      expect(util.isBoolean('12.345')).to.be.false;
      expect(util.isBoolean(false)).to.be.true;
      expect(util.isBoolean([])).to.be.false;
      expect(util.isBoolean({})).to.be.false;
      done();
    });
    it('isntBoolean works as expected', done => {
      expect(util.isntBoolean(null)).to.be.true;
      expect(util.isntBoolean(obj.foo)).to.be.true;
      expect(util.isntBoolean(array.foo)).to.be.true;
      expect(util.isntBoolean(12.345)).to.be.true;
      expect(util.isntBoolean(12)).to.be.true;
      expect(util.isntBoolean('12.345')).to.be.true;
      expect(util.isntBoolean(false)).to.be.false;
      expect(util.isntBoolean([])).to.be.true;
      expect(util.isntBoolean({})).to.be.true;
      done();
    });
    it('isClass works as expected', done => {
      class TestClass {}
      expect(util.isClass(null)).to.be.false;
      expect(util.isClass(obj.foo)).to.be.false;
      expect(util.isClass(array.foo)).to.be.false;
      expect(util.isClass(12.345)).to.be.false;
      expect(util.isClass(12)).to.be.false;
      expect(util.isClass('12.345')).to.be.false;
      expect(util.isClass(false)).to.be.false;
      expect(util.isClass([])).to.be.false;
      expect(util.isClass({})).to.be.false;
      expect(util.isClass(TestClass)).to.be.true;
      done();
    });
    it('isntClass works as expected', done => {
      class TestClass {}
      expect(util.isntClass(null)).to.be.true;
      expect(util.isntClass(obj.foo)).to.be.true;
      expect(util.isntClass(array.foo)).to.be.true;
      expect(util.isntClass(12.345)).to.be.true;
      expect(util.isntClass(12)).to.be.true;
      expect(util.isntClass('12.345')).to.be.true;
      expect(util.isntClass(false)).to.be.true;
      expect(util.isntClass([])).to.be.true;
      expect(util.isntClass({})).to.be.true;
      expect(util.isntClass(TestClass)).to.be.false;
      done();
    });
  });
})();
