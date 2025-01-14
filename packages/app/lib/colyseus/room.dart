import 'package:app/colyseus/connection.dart';
import 'package:app/colyseus/protocol.dart';
import 'package:app/colyseus/serializer/schema_serializer.dart';
import 'package:app/colyseus/serializer/serializer.dart';
import 'package:app/colyseus/signal.dart';

class Room {
  String id;
  String sessionId;
  String name;

  Signal onJoin = createSignal();
  Signal onStateChange = createSignal();
  Signal onMessage = createSignal();
  Signal onError = createSignal();
  Signal onLeave = createSignal();

  Connection connection;

  String serializerId;

  Serializer serializer;
  Protocol previousCode;
  RootSchema rootSchema;

  Room(String name, RootSchema rootSchema) {
    this.id = null;
    this.name = name;

    this.serializer = (getSerializer("schema"));
    this.rootSchema = rootSchema;
    (this.serializer as SchemaSerializer).state = new RootSchema();

    this.onError.add((message) { print(message); });
    this.onLeave.add(() => this.removeAllListeners());
  }

  connect(String endpoint) {
    this.connection = new Connection(endpoint);
    this.connection.reconnectEnabled = false;
    this.connection.onmessage = this.onMessageCallback.bind(this);
    this.connection.onclose = (var e)
    {
      this.onLeave.invoke(code: e.code)
    };

    this.connection.onerror = (var e)
    {
      this.onError.invoke(code: e.reason);
    };

    this.connection.open();
  }

  leave({bool consented = true}) {
    if (this.connection != null) {
      if (consented) {
        this.connection.send([Protocol.LEAVE_ROOM]);
      } else {
        this.connection.close();
      }
    } else {
      this.onLeave.invoke(code: 4000); // "consented" code
    }
  }

  send(data) {
    this.connection.send([Protocol.ROOM_DATA, data]);
  }

  get state {
    return this.serializer.getState();
  }

  removeAllListeners() {
    if (this.serializer != null) {
      this.serializer.teardown();
    }
    this.onJoin.clear();
    this.onStateChange.clear();
    this.onMessage.clear();
    this.onError.clear();
    this.onLeave.clear();
  }

  onMessageCallback(var event) {
    if (this.previousCode == null) {
      const view = new DataView(event.data);
      const code = view.getUint8(0);

      if (code == Protocol.JOIN_ROOM) {
        var offset = 1;

        this.serializerId = utf8Read(view, offset);
        offset += utf8Length(this.serializerId);

      // get serializer implementation
        var serializer = getSerializer(this.serializerId);
        if (!serializer) {
          throw new Error();
        }

        if (view.buffer.byteLength > offset && this.serializer.handshake) {
          const bytes = Array.from(new Uint8Array(view.buffer.slice(offset)));
          this.serializer.handshake(bytes);
        }

        this.onJoin.invoke();
      } else if (code == Protocol.JOIN_ERROR) {
        this.onError.invoke(utf8Read(view, 1));
      } else if (code == Protocol.LEAVE_ROOM) {
        this.leave();
      } else {
        this.previousCode = code;
      }
    } else {
      if (this.previousCode === Protocol.ROOM_STATE) {
// TODO: improve here!
        this.setState(Array.from(new Uint8Array(event.data)));
      } else if (this.previousCode === Protocol.ROOM_STATE_PATCH) {
        this.patch(Array.from(new Uint8Array(event.data)));
      } else if (this.previousCode === Protocol.ROOM_DATA) {
        this.onMessage.invoke(msgpack.decode(event.data));
      }

      this.previousCode = null;
    }
  }

  setState(encodedState) {
    this.serializer.setState(encodedState);
    this.onStateChange.invoke(this.serializer.getState());
  }

  patch(binaryPatch) {
    this.serializer.patch(binaryPatch);
    this.onStateChange.invoke(this.serializer.getState());
  }
}
