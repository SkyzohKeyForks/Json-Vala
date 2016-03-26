namespace Json {
	public static string string_compress (string s) {
			string str = s.replace ("\\u", "\\\\u").compress();
			var sb = new StringBuilder();
			int i = 0;
			unichar u;
			while (str.get_next_char (ref i, out u)) {
				if (u == '\\') {
					unichar v;
					if (!str.get_next_char (ref i, out v)) {
						sb.append_unichar (u);
						return sb.str;
					}
					if (v == 'u') {
						string unicode = "0x";
						unichar a, b, c, d;
						if (!str.get_next_char (ref i, out a)) {
							sb.append_unichar ('u');
							return sb.str;
						}
						unicode += a.to_string();
						if (!str.get_next_char (ref i, out b)) {
							sb.append_unichar ('u');
							sb.append_unichar (a);
							return sb.str;
						}
						unicode += b.to_string();
						if (!str.get_next_char (ref i, out c)) {
							sb.append_unichar ('u');
							sb.append_unichar (a);
							sb.append_unichar (b);
							return sb.str;
						}
						unicode += c.to_string();
						if (!str.get_next_char (ref i, out d)) {
							sb.append_unichar ('u');
							sb.append_unichar (a);
							sb.append_unichar (b);
							sb.append_unichar (c);
							return sb.str;
						}
						unicode += d.to_string();
						int64 n;
						if (!int64.try_parse (unicode, out n)) {
							sb.append_unichar ('u');
							sb.append_unichar (a);
							sb.append_unichar (b);
							sb.append_unichar (c);
							sb.append_unichar (d);
						}
						else
							sb.append_unichar ((unichar)n);
					}
					else
						sb.append_unichar (v);
				}
				else
					sb.append_unichar (u);
			}
			return sb.str;
		}
	
	static void bytes_to_byte_array (Value src_value, ref Value dest_value) {
		var bytes = (Bytes)src_value;
		var array = new ByteArray.take (bytes.get_data());
		dest_value.set_boxed (array);
	}

	static void byte_array_to_bytes (Value src_value, ref Value dest_value) {
		var array = (ByteArray)src_value;
		var bytes = new Bytes (array.data);
		dest_value.set_boxed (bytes);
	}

	static void string_to_regex (Value src_value, ref Value dest_value) {
		string str = (string)src_value;
		Regex? regex = null;
		try {
			regex = new Regex (str);
		} catch {
			regex = new Regex ("");
		}
		dest_value.set_boxed (regex);
	}

	static void regex_to_string (Value src_value, ref Value dest_value) {
		Regex regex = (Regex)src_value;
		dest_value.set_string (regex.get_pattern());
	}

	static void datetime_to_string (Value src_value, ref Value dest_value) {
		DateTime dt = (DateTime)src_value;
		dest_value.set_string (dt.to_string());
	}

	static void string_to_datetime (Value src_value, ref Value dest_value) {
		string str = (string)src_value;
		TimeVal tv = TimeVal();
		if (tv.from_iso8601 (str))
			dest_value.set_boxed (new DateTime.from_timeval_local (tv));
		else
			dest_value.set_boxed (new DateTime.now_local());
	}

	static void string_to_bytes (Value src_value, ref Value dest_value) {
		string str = (string)src_value;
		Bytes bytes = new Bytes (Base64.decode (str));
		dest_value.set_boxed (bytes);
	}

	static void bytes_to_string (Value src_value, ref Value dest_value) {
		Bytes bytes = (Bytes)src_value;
		string str = Base64.encode (bytes.get_data());
		dest_value.set_string (str);
	}

	static void string_to_byte_array (Value src_value, ref Value dest_value) {
		string str = (string)src_value;
		ByteArray array = new ByteArray.take (Base64.decode (str));
		dest_value.set_boxed (array);
	}

	static void byte_array_to_string (Value src_value, ref Value dest_value) {
		ByteArray array = (ByteArray)src_value;
		string str = Base64.encode (array.data);
		dest_value.set_string (str);
	}

	static void value_init() {
		Value.register_transform_func (typeof (Bytes), typeof (ByteArray), bytes_to_byte_array);
		Value.register_transform_func (typeof (ByteArray), typeof (Bytes), byte_array_to_bytes);
		Value.register_transform_func (typeof (string), typeof (Regex), string_to_regex);
		Value.register_transform_func (typeof (Regex), typeof (string), regex_to_string);
		Value.register_transform_func (typeof (string), typeof (DateTime), string_to_datetime);
		Value.register_transform_func (typeof (DateTime), typeof (string), datetime_to_string);
		Value.register_transform_func (typeof (string), typeof (Bytes), string_to_bytes);
		Value.register_transform_func (typeof (Bytes), typeof (string), bytes_to_string);
		Value.register_transform_func (typeof (string), typeof (ByteArray), string_to_byte_array);
		Value.register_transform_func (typeof (ByteArray), typeof (string), byte_array_to_string);
	}
	
	public enum NodeType {
		NULL,
		INTEGER,
		BOOLEAN,
		NUMBER,
		STRING,
		ARRAY,
		OBJECT,
		REGEX,
		DATETIME,
		BINARY
	}
	
	public class Node : GLib.Object {
		internal Bytes? binary;
		internal Regex? regex;
		internal DateTime? datetime;
		internal Json.Object? object;
		internal Json.Array? array;
		internal string? str;
		internal string? number_str;
		internal bool? boolean;
		internal int64? integer;
		internal bool isn;
		
		public Node (GLib.Value? value = null) {
			this.value = value;
		}
		
		public bool equal (Json.Node node) {
			bool b = binary == null ? node.binary == null : binary.compare (node.binary) == 0;
			bool o = object == null ? node.object == null : object.equal (node.object);
			bool d = datetime == null ? node.datetime == null : datetime.compare (node.datetime) == 0;
			bool r = regex == null ? node.regex == null : regex.get_pattern() == node.regex.get_pattern();
			bool a = array == null ? node.array == null : array.equal (node.array);
			return (b && r && o && d && a && str == node.str && number_str == node.number_str && boolean == node.boolean && 
				integer == node.integer && isn == node.isn);
		}
		
		public string to_string() {
			var gen = new Generator();
			gen.root = this;
			return gen.to_string();
		}
		
		public Json.Object as_object() {
			if (object != null)
				return object;
			return new Json.Object();
		}
		
		public Json.Array as_array() {
			if (array != null)
				return array;
			return new Json.Array();
		}
		
		public string as_string() {
			if (str != null)
				return str;
				//return string_from_string (str);
			return "";
		}
		
		public bool as_boolean() {
			return boolean == true;
		}
		
		public DateTime as_datetime() {
			if (datetime != null)
				return datetime;
			TimeVal tv = TimeVal();
			if (!tv.from_iso8601 (as_string()))
				return new DateTime.now_local();
			return new DateTime.from_timeval_local (tv);
		}
		
		public double as_double() {
			if (number_str != null)
				return double.parse (number_str);
			return 0;
		}
		
		public int64 as_int() {
			if (integer != null)
				return integer;
			return 0;
		}
		
		public Regex as_regex() {
			if (regex == null) {
				try {
					return new Regex (as_string());
				}
				catch {
					return new Regex ("");
				}
			}
			return regex;
		}
		
		public Bytes as_binary() {
			if (binary != null)
				return binary;
			return new Bytes (Base64.decode (as_string()));
		}
		
		public bool is_null() {
			return isn;
		}
		
		public new Json.Node get (GLib.Value index) {
			if (object != null)
				return object[index];
			if (array == null)
				return new Json.Node();
			int64 i = -1;
			if (index.type() == typeof (int))
				i = (int64)(int)index;
			else if (index.type() == typeof (uint))
				i = (int64)(uint)index;
			else if (index.type() == typeof (int64))
				i = (int64)index;
			else if (index.type() == typeof (uint64))
				i = (int64)(uint64)index;
			else if (index.type() == typeof (long))
				i = (int64)(long)index;
			else if (index.type() == typeof (ulong))
				i = (int64)(ulong)index;
			else return new Json.Node();
			if (i < 0 || i >= array.size)
				return new Json.Node();
			return array[(int)i];
		}
		
		static string char_to_string (unichar u) {
			if (u < 20) {
				string s = "\\u";
				s += "%04X".printf (u);
				return s;
			}
			return u.to_string();
		}
		
		static string string_to_string (string s) {
			string str = "";
			int i = 0;
			unichar u;
			while (s.get_next_char (ref i, out u))
				str += char_to_string (u);
			return str;
		}
		
		public NodeType node_type {
			get {
				if (isn)
					return NodeType.NULL;
				if (integer != null)
					return NodeType.INTEGER;
				if (number_str != null)
					return NodeType.NUMBER;
				if (boolean != null)
					return NodeType.BOOLEAN;
				if (str != null)
					return NodeType.STRING;
				if (array != null)
					return NodeType.ARRAY;
				if (object != null)
					return NodeType.OBJECT;
				if (regex != null)
					return NodeType.REGEX;
				if (datetime != null)
					return NodeType.DATETIME;
				if (binary != null)
					return NodeType.BINARY;
				return NodeType.NULL;
			}
		}
		
		static bool is_init;
		
		public GLib.Value? value {
			owned get {
				if (binary != null)
					return binary;
				if (datetime != null)
					return datetime;
				if (regex != null)
					return regex;
				if (object != null)
					return object;
				if (array != null)
					return array;
				if (str != null)
					return str;
					//return string_from_string (str);
				if (boolean != null)
					return boolean;
				if (number_str != null)
					return double.parse (number_str);
				if (integer != null)
					return integer;
				return null;
			}
			set {
				if (!is_init) {
					value_init();
					is_init = true;
				}
				if (value == null)
					isn = true;
				else if (value.type().is_a (typeof (Json.Node))) {
					var node = (Json.Node)value;
					datetime = node.datetime;
					regex = node.regex;
					binary = node.binary;
					object = node.object;
					array = node.array;
					boolean = node.boolean;
					str = node.str;
					number_str = node.number_str;
					integer = node.integer;
					isn = node.isn;
				}
				else if (value.type().is_a (typeof (Json.Object)))
					object = (Json.Object)value;
				else if (value.type().is_a (typeof (Json.Array)))
					array = (Json.Array)value;
				else if (value.type() == typeof (bool))
					boolean = (bool)value;
				else if (value.type() == typeof (string))
					str = (string)value;
				else if (value.type() == typeof (double))
					number_str = "%g".printf ((double)value);
				else if (value.type() == typeof (float))
					number_str = "%g".printf ((float)value);
				else if (value.type() == typeof (int))
					integer = (int)value;
				else if (value.type() == typeof (uint))
					integer = (uint)value;
				else if (value.type() == typeof (int64))
					integer = (int64)value;
				else if (value.type() == typeof (uint64))
					integer = (int64)(uint64)value;
				else if (value.type() == typeof (long))
					integer = (long)value;
				else if (value.type() == typeof (ulong))
					integer = (ulong)value;
				else if (value.type() == typeof (uchar))
					integer = (uchar)value;
				else if (value.type() == typeof (char))
					str = char_to_string ((unichar)((char)value));
				else if (value.type() == typeof (DateTime))
					datetime = (DateTime)value;
				else if (value.type() == typeof (Regex))
					regex = (Regex)value;
				else if (value.type() == typeof (Bytes)) {
					Bytes bin = (Bytes)value;
					str = Base64.encode (bin.get_data());
				}
				else if (value.type() == typeof (ByteArray)) {
					ByteArray bin = (ByteArray)value;
					str = Base64.encode (bin.data);
				}
				else
					isn = true;
			}
		}
	}
}
