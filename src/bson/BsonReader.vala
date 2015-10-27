namespace Json.Bson {
	internal enum ElementType {
		END,
		DOUBLE,
		STRING,
		DOCUMENT,
		ARRAY,
		BINARY,
		UNDEFINED,
		OBJECT_ID,
		BOOLEAN,
		DATETIME,
		NULL,
		REGEX,
		INT32 = 0x10,
		TIMESTAMP,
		INT64
	}
	
	errordomain ReadError {
		NONE,
		INDEX,
		INVALID,
		TYPE
	}
	
	public class Reader : GLib.Object {
		DataInputStream dis;
		
		internal Reader (InputStream stream) {
			dis = new DataInputStream (stream);
			dis.byte_order = DataStreamByteOrder.LITTLE_ENDIAN;
		}
		
		string read_id() {
			uint8[] data = new uint8[0];
			while (true) {
				var byte = dis.read_byte();
				data += byte;
				if (byte == 0)
					break;
			}
			return (string)data;
		}
		
		public double read_double() {
			uint8[] data = new uint8[8];
			dis.read (data);
			double* ptr = (double*)((void*)data);
			return *ptr;
		}
		
		public string read_string() {
			int i = dis.read_int32();
			uint8[] data = new uint8[i];
			dis.read (data);
			return (string)data;
		}
		
		public int read_int32() {
			return dis.read_int32();
		}
		
		public int64 read_int64() {
			return dis.read_int64();
		}
		
		public uint8[] read_bytes() {
			int i = dis.read_int32();
			dis.read_byte(); // subtype, unused here.
			uint8[] data = new uint8[i];
			dis.read (data);
			return data;
		}
		
		public DateTime read_date_time() throws GLib.Error {
			int64 i = dis.read_int64();
			TimeVal utc = TimeVal();
			utc.tv_sec = (long)(i / 1000);
			utc.tv_usec = (long)(i % 1000);
			return new DateTime.from_timeval_utc (utc);
		}
		
		public Json.Array read_array() throws GLib.Error {
			int size = dis.read_int32();
			var array = new Json.Array();
			ElementType et = ElementType.END;
			uint64 index = 0;
			while ((et = (ElementType)dis.read_byte()) != ElementType.END) {
				uint64 i = -1;
				if (!uint64.try_parse (read_id(), out i))
					throw new ReadError.INVALID ("current index isn't a number.");
				if (i != index)
					throw new ReadError.INDEX ("invalid index for current BSON array.");
				index++;
				switch (et) {
					case ElementType.DOUBLE:
					array.add (read_double());
					break;
					case ElementType.STRING:
					array.add (read_string());
					break;
					case ElementType.ARRAY:
					array.add (read_array());
					break;
					case ElementType.DOCUMENT:
					array.add (read_object());
					break;
					case ElementType.BOOLEAN:
					array.add (dis.read_byte() == 0 ? false : true);
					break;
					case ElementType.DATETIME:
					array.add (read_date_time());
					break;
					case ElementType.NULL:
					array.add_null_element();
					break;
					case ElementType.REGEX:
					array.add (new Regex (read_string()));
					break;
					case ElementType.INT32:
					array.add (read_int32());
					break;
					case ElementType.INT64:
					array.add (read_int64());
					break;
				}
			}
			return array;
		}
		
		public Json.Object read_object() throws GLib.Error {
			int size = dis.read_int32();
			var object = new Json.Object();
			ElementType et = (ElementType)dis.read_byte();
			while (et != ElementType.END) {
				string id = read_id();
				switch (et) {
					case ElementType.DOUBLE:
					object[id] = read_double();
					break;
					case ElementType.STRING:
					object[id] = read_string();
					break;
					case ElementType.DOCUMENT:
					object[id] = read_object();
					break;
					case ElementType.ARRAY:
					object[id] = read_array();
					break;
					case ElementType.BINARY:
					object[id] = Base64.encode (read_bytes());
					break;
					case ElementType.BOOLEAN:
					object[id] = dis.read_byte() == 0 ? false : true;
					break;
					case ElementType.DATETIME:
					object[id] = read_date_time();
					break;
					case ElementType.NULL:
					object.set_null_member (id);
					break;
					case ElementType.REGEX:
					object[id] = new Regex (read_string());
					break;
					case ElementType.INT32:
					object[id] = read_int32();
					break;
					case ElementType.INT64:
					object[id] = read_int64();
					break;
				}	
				et = (ElementType)dis.read_byte();
			}
			return object;
		}
	}
}
