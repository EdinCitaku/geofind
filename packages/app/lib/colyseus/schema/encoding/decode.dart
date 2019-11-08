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

export interface
Iterator { offset: number; }

utf8Read(bytes, offset, length) {
  var string = '',
      chr = 0;
  for (var i = offset, end = offset + length; i < end; i++) {
    var byte = bytes[i];
    if ((byte & 0x80) === 0x00) {
      string += String.fromCharCode(byte);
      continue;
    }
    if ((byte & 0xe0) === 0xc0) {
      string += String.fromCharCode(
          ((byte & 0x1f) << 6) |
          (bytes[++i] & 0x3f)
      );
      continue;
    }
    if ((byte & 0xf0) === 0xe0) {
      string += String.fromCharCode(
          ((byte & 0x0f) << 12) |
          ((bytes[++i] & 0x3f) << 6) |
          ((bytes[++i] & 0x3f) << 0)
      );
      continue;
    }
    if ((byte & 0xf8) === 0xf0) {
      chr = ((byte & 0x07) << 18) |
      ((bytes[++i] & 0x3f) << 12) |
      ((bytes[++i] & 0x3f) << 6) |
      ((bytes[++i] & 0x3f) << 0);
      if (chr >= 0x010000) { // surrogate pair
        chr -= 0x010000;
        string +=
            String.fromCharCode((chr >>> 10) + 0xD800, (chr & 0x3FF) + 0xDC00);
      } else {
        string += String.fromCharCode(chr);
      }
      continue;
    }
    throw new Error('Invalid byte ' + byte.toString(16));
  }
  return string;
}

int8(List<int> bytes, Iterator it) {
  return uint8(bytes, it) << 24 >> 24;
};

uint8(List<int> bytes, Iterator it) {
  return bytes[it.offset++];
};

int16(List<int> bytes, Iterator it) {
  return uint16(bytes, it) << 16 >> 16;
};

uint16(List<int> bytes, Iterator it) {
  return bytes[it.offset++] | bytes[it.offset++] << 8;
};

int32(List<int> bytes, Iterator it) {
  return bytes[it.offset++] | bytes[it.offset++] << 8 | bytes[it.offset++] <<
      16 | bytes[it.offset++] << 24;
};

uint32(List<int> bytes, Iterator it) {
  return int32(bytes, it)
  >
  >
  >
  0;
};

float32(List<int> bytes, Iterator it) {
  return readFloat32(bytes, it);
}

float64(List<int> bytes, Iterator it) {
  return readFloat64(bytes, it);
}

int64(List<int> bytes, Iterator it) {
  const low = uint32(bytes, it);
  const high = int32(bytes, it) * Math.pow(2, 32);
  return high + low;
};

uint64(List<int> bytes, Iterator it) {
  const low = uint32(bytes, it);
  const high = uint32(bytes, it) * Math.pow(2, 32);
  return high + low;
};

// force little endian to facilitate decoding on multiple implementations
const _isLittleEndian = true; // new Uint16Array(new Uint8Array([1, 0]).buffer)[0] === 1;
const _int32 = new Int32Array(2);
const _float32 = new Float32Array(_int32.buffer);
const _float64 = new Float64Array(_int32.buffer);

readFloat32(List<int> bytes, Iterator it) {
  _int32[0] = int32(bytes, it);
  return _float32[0];
};

readFloat64(List<int> bytes, Iterator it) {
  _int32[_isLittleEndian ? 0 : 1] = int32(bytes, it);
  _int32[_isLittleEndian ? 1 : 0] = int32(bytes, it);
  return _float64[0];
};

boolean(List<int> bytes, Iterator it) {
  return uint8(bytes, it) > 0;
};

string(bytes, Iterator it) {
  var prefix = bytes[it.offset++];
  var length
  : number;

  if (prefix < 0xc0) {
// fixstr
  length = prefix & 0x1f;

  } else if (prefix === 0xd9) {
  length = uint8(bytes, it);

  } else if (prefix === 0xda) {
  length = uint16(bytes, it);

  } else if (prefix === 0xdb) {
  length = uint32(bytes, it);
  }

  const value = utf8Read(bytes, it.offset, length);
  it.offset += length;

  return
  value;
}

stringCheck(bytes, Iterator it) {
  const prefix = bytes[it.offset];
  return (
// fixstr
      (prefix < 0xc0 && prefix > 0xa0) ||
// str 8
          prefix === 0xd9 ||
// str 16
      prefix === 0xda ||
// str 32
      prefix === 0xdb
  );
}

number(bytes, Iterator it) {
  const prefix = bytes[it.offset++];

  if (prefix < 0x80) {
// positive fixint
    return prefix;
  } else if (prefix === 0xca) {
// float 32
    return readFloat32(bytes, it);
  } else if (prefix === 0xcb) {
// float 64
    return readFloat64(bytes, it);
  } else if (prefix === 0xcc) {
// uint 8
    return uint8(bytes, it);
  } else if (prefix === 0xcd) {
// uint 16
    return uint16(bytes, it);
  } else if (prefix === 0xce) {
// uint 32
    return uint32(bytes, it);
  } else if (prefix === 0xcf) {
// uint 64
    return uint64(bytes, it);
  } else if (prefix === 0xd0) {
// int 8
    return int8(bytes, it);
  } else if (prefix === 0xd1) {
// int 16
    return int16(bytes, it);
  } else if (prefix === 0xd2) {
// int 32
    return int32(bytes, it);
  } else if (prefix === 0xd3) {
// int 64
    return int64(bytes, it);
  } else if (prefix > 0xdf) {
// negative fixint
    return (0xff - prefix + 1) * -1
  }
};

numberCheck(bytes, Iterator it) {
  var prefix = bytes[it.offset];
// positive fixint - 0x00 - 0x7f
// float 32        - 0xca
// float 64        - 0xcb
// uint 8          - 0xcc
// uint 16         - 0xcd
// uint 32         - 0xce
// uint 64         - 0xcf
// int 8           - 0xd0
// int 16          - 0xd1
// int 32          - 0xd2
// int 64          - 0xd3
  return (
      prefix < 0x80 ||
          (prefix >= 0xca && prefix <= 0xd3)
  );
}

arrayCheck(bytes, Iterator it) {
  return bytes[it.offset] < 0xa0;

// const prefix = bytes[it.offset] ;

// if (prefix < 0xa0) {
//   return prefix;

// // array
// } else if (prefix === 0xdc) {
//   it.offset += 2;

// } else if (0xdd) {
//   it.offset += 4;
// }

// return prefix;
}

nilCheck(bytes, Iterator it) {
  return bytes[it.offset] === NIL

}

indexChangeCheck(bytes, Iterator it) {
  return bytes[it.offset] === INDEX_CHANGE;
}
