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
	
	public enum NodeType {
		NULL,
		INTEGER,
		BOOLEAN,
		NUMBER,
		STRING,
		ARRAY,
		OBJECT
	}
	
	public class Node : GLib.Object {
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
			bool o = object == null ? node.object == null : object.equal (node.object);
			bool a = array == null ? node.array == null : array.equal (node.array);
			return (o && a && str == node.str && number_str == node.number_str && boolean == node.boolean && integer == node.integer &&
				isn == node.isn);
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
				return NodeType.NULL;
			}
		}
		
		public GLib.Value? value {
			owned get {
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
				if (value == null)
					isn = true;
				else if (value.type().is_a (typeof (Json.Node))) {
					var node = (Json.Node)value;
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
				else
					isn = true;
			}
		}
	}
}
