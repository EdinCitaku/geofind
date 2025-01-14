/**
 * Copyright (c) 2018 Endel Dreyer
 * Copyright (c) 2014 Ion Drive Software Ltd.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE
 */

/**
 * msgpack implementation highly based on notepack.io
 * https://github.com/darrachequesne/notepack
 */


function utf8Length(str) {
  var c = 0, length = 0;
  for (var i = 0, l = str.length; i < l; i++) {
    c = str.charCodeAt(i);
    if (c < 0x80) {
      length += 1;
    }
    else if (c < 0x800) {
      length += 2;
    }
    else if (c < 0xd800 || c >= 0xe000) {
      length += 3;
    }
    else {
      i++;
      length += 4;
    }
  }
  return length;
}

export function utf8Write(view, offset, str) {
  var c = 0;
  for (var i = 0, l = str.length; i < l; i++) {
    c = str.charCodeAt(i);
    if (c < 0x80) {
      view[offset++] = c;
    }
    else if (c < 0x800) {
      view[offset++] = 0xc0 | (c >> 6);
      view[offset++] = 0x80 | (c & 0x3f);
    }
    else if (c < 0xd800 || c >= 0xe000) {
      view[offset++] = 0xe0 | (c >> 12);
      view[offset++] = 0x80 | (c >> 6 & 0x3f);
      view[offset++] = 0x80 | (c & 0x3f);
    }
    else {
      i++;
      c = 0x10000 + (((c & 0x3ff) << 10) | (str.charCodeAt(i) & 0x3ff));
      view[offset++] = 0xf0 | (c >> 18);
      view[offset++] = 0x80 | (c >> 12 & 0x3f);
      view[offset++] = 0x80 | (c >> 6 & 0x3f);
      view[offset++] = 0x80 | (c & 0x3f);
    }
  }
}

export function int8(bytes, value) {
  bytes.push(value & 255);
};

export function uint8(bytes, value) {
  bytes.push(value & 255);
};

export function int16(bytes, value) {
  bytes.push(value & 255);
  bytes.push((value >> 8) & 255);
};

export function uint16(bytes, value) {
  bytes.push(value & 255);
  bytes.push((value >> 8) & 255);
};

export function int32(bytes, value) {
  bytes.push(value & 255);
  bytes.push((value >> 8) & 255);
  bytes.push((value >> 16) & 255);
  bytes.push((value >> 24) & 255);
};

export function uint32(bytes, value) {
  const b4 = value >> 24;
  const b3 = value >> 16;
  const b2 = value >> 8;
  const b1 = value;
  bytes.push(b1 & 255);
  bytes.push(b2 & 255);
  bytes.push(b3 & 255);
  bytes.push(b4 & 255);
};

export function int64(bytes, value) {
  const high = Math.floor(value / Math.pow(2, 32));
  const low = value >>> 0;
  uint32(bytes, low);
  uint32(bytes, high);
};

export function uint64(bytes, value) {
  const high = (value / Math.pow(2, 32)) >> 0;
  const low = value >>> 0;
  uint32(bytes, low);
  uint32(bytes, high);
};

export function float32(bytes, value) {
  writeFloat32(bytes, value);
}

export function float64(bytes, value) {
  writeFloat64(bytes, value);
}

// force little endian to facilitate decoding on multiple implementations
const _isLittleEndian = true;  // new Uint16Array(new Uint8Array([1, 0]).buffer)[0] === 1;
const _int32 = new Int32Array(2);
const _float32 = new Float32Array(_int32.buffer);
const _float64 = new Float64Array(_int32.buffer);

export function writeFloat32(bytes, value) {
  _float32[0] = value;
  int32(bytes, _int32[0]);
};

export function writeFloat64(bytes, value) {
  _float64[0] = value;
  int32(bytes, _int32[_isLittleEndian ? 0 : 1]);
  int32(bytes, _int32[_isLittleEndian ? 1 : 0]);
};

export function boolean(bytes, value) {
  return uint8(bytes, value ? 1 : 0);
};

export function string(bytes, value) {
  // encode `null` strings as empty.
  if (!value) { value = ""; }

  let length = utf8Length(value);
  let size = 0;

  // fixstr
  if (length < 0x20) {
    bytes.push(length | 0xa0);
    size = 1;
  }
  // str 8
  else if (length < 0x100) {
    bytes.push(0xd9);
    uint8(bytes, length);
    size = 2;
  }
  // str 16
  else if (length < 0x10000) {
    bytes.push(0xda);
    uint16(bytes, length);
    size = 3;
  }
  // str 32
  else if (length < 0x100000000) {
    bytes.push(0xdb);
    uint32(bytes, length);
    size = 5;
  } else {
    throw new Error('String too long');
  }

  utf8Write(bytes, bytes.length, value);

  return size + length;
}

export function number(bytes, value) {
  if (isNaN(value)) {
    return number(bytes, 0);

  } else if (!isFinite(value)) {
    return number(bytes, (value > 0) ? Number.MAX_SAFE_INTEGER : -Number.MAX_SAFE_INTEGER);

  } else if (value !== (value|0)) {
  bytes.push(0xcb);
  writeFloat64(bytes, value);
  return 9;

  // TODO: encode float 32?
  // is it possible to differentiate between float32 / float64 here?

  // // float 32
  // bytes.push(0xca);
  // writeFloat32(bytes, value);
  // return 5;
  }

  if (value >= 0) {
  // positive fixnum
  if (value < 0x80) {
  uint8(bytes, value);
  return 1;
  }

  // uint 8
  if (value < 0x100) {
  bytes.push(0xcc);
  uint8(bytes, value);
  return 2;
  }

  // uint 16
  if (value < 0x10000) {
  bytes.push(0xcd);
  uint16(bytes, value);
  return 3;
  }

  // uint 32
  if (value < 0x100000000) {
  bytes.push(0xce);
  uint32(bytes, value);
  return 5;
  }

  // uint 64
  bytes.push(0xcf);
  uint64(bytes, value);
  return 9;

  } else {

  // negative fixnum
  if (value >= -0x20) {
  bytes.push(value);
  return 1;
  }

  // int 8
  if (value >= -0x80) {
  bytes.push(0xd0);
  int8(bytes, value);
  return 2;
  }

  // int 16
  if (value >= -0x8000) {
  bytes.push(0xd1);
  int16(bytes, value);
  return 3;
  }

  // int 32
  if (value >= -0x80000000) {
  bytes.push(0xd2);
  int32(bytes, value);
  return 5;
  }

  // int 64
  bytes.push(0xd3);
  int64(bytes, value);
  return 9;
  }
}
