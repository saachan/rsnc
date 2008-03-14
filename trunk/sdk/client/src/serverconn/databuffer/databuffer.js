/***  HIMLE RIA SYSTEM
  ** 
  **  Copyright (C) 2008 HIMLE GROUP http://himle.sorsacode.com/
  **  Copyright (C) 2006-2007 Helmi Technologies Inc.
  ** 
  **  This program is free software; you can redistribute it and/or modify it under the terms
  **  of the GNU General Public License as published by the Free Software Foundation;
  **  either version 2 of the License, or (at your option) any later version. 
  **  This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
  **  without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  **  See the GNU General Public License for more details. 
  **  You should have received a copy of the GNU General Public License along with this program;
  **  if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  ***/

HDataBuffer = HClass.extend({
  constructor: function(_startingRow,_endingRow,_startingBufferRow,_endingBufferRow,_length) {
    this._startingRow = _startingRow;
    this._endingRow = _endingRow;
    this._startingBufferRow = _startingBufferRow;
    this._endingBufferRow = _endingBufferRow;
    this._bufferLenth = 3;
    this._length = _length;
  },
  startingRow: function() {
    return this._startingRow - this._length;
  },
  endingRow: function() {
    return this._endingRow + this._length;
  },
  lowerLimit: function() {
    return this._startingBufferRow + parseInt(this._length / 2);
  },
  upperLimit: function() {
    return this._startingBufferRow + (this._bufferLenth-1)*(this._endingRow - this._startingRow) - parseInt(this._length / 2);
  },
  endBufferStartRow: function() {
    return (this._bufferLenth - 1) * this._length;
  },
  getNewBottomRow: function() {
    return this._startingBufferRow + this._bufferLenth * this._length;
  },
  getNewBottomRowEnd: function() {
    return this._startingBufferRow + (this._bufferLenth + 1) * this._length;
  },
  getNewTopRow: function() {
    return this._startingBufferRow - this._length;
  },
  getNewTopRowEnd: function() {
    return this._startingBufferRow;
  },
  getNewDownBufferIndexes: function(_startIndex) {
    if (_startIndex == 0) {
      return [this._length,0];
    } else if (_startIndex == this._length) {
      return [2*this._length,this._length];
    } else if (_startIndex == 2*this._length) {
      return [0,2*this._length];
    }
  },
  getNewUpBufferIndexes: function(_startIndex) {
    if (_startIndex == 0) {
      return [2*this._length,this._length]
    } else if (_startIndex == 2*this._length) {
      return [this._length,0]
    } else if (_startIndex == this._length) {
      return [0,2*this._length];
    }
  }
});