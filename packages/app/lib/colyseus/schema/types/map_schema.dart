import 'dart:core';

class MapSchema {
  ChangeTree $changes;

  MapSchema(Map obj) {
    for (var key in obj) {
      // TODO:
      this[key] = obj[key];
    }

    // TODO: port
    Object.defineProperties(this, {
      $changes: { value: undefined, enumerable: false, writable: true},

      onAdd: { value: undefined, enumerable: false, writable: true},
      onRemove: { value: undefined, enumerable: false, writable: true},
      onChange: { value: undefined, enumerable: false, writable: true},

      clone: {
        "value": (bool isDecoding) {
          MapSchema cloned;

          if (isDecoding) {
            // client-side
            cloned = Object.assign(new MapSchema(), this);
            cloned.onAdd = this.onAdd;
            cloned.onRemove = this.onRemove;
            cloned.onChange = this.onChange;
          } else {
            // server-side
            MapSchema cloned = new MapSchema();
            for (var key in this) {
              if (typeof (this[key]) === "object") {
                cloned[key] = this[key].clone();
              } else {
                cloned[key] = this[key];
              }
            }
          }
          return
          cloned;
        }
      },

      triggerAll: {
        "value": () {
          if (!this.onAdd) {
            return;
          }

          for (var key in this) {
            this.onAdd(this[key], key);
          }
        }
      },

      "toJSON": {
        "value": () {
          Map map = {};
          for (let key in this) {
            map[key] = (typeof(this[key].toJSON) == "function")
                ? this[key].toJSON()
                : this[key];
          }
          return map;
        }
      },

      _indexes: { "value": new Map(), "enumerable": false, "writable": true},
      _updateIndexes: {
        "value": (allKeys) {
          var int index = 0;
          Map indexes = new Map();
          for (let key of allKeys) {
            indexes.set(key, index++);
          }

          this._indexes = indexes;
        }
      },
    });
  }

  MapSchema clone = (bool isDecoding) => MapSchema;

  Function onAdd = () {};
  Function onRemove = () {};
  Function onChange = () {};

  triggerAll() {}

  Map _indexes;
  MapSchema _updateIndexes = () {};
}
