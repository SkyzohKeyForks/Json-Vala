namespace Json {
	public enum NodeType {
		NULL,
		ARRAY,
		BOOLEAN,
		DATETIME,
		DOUBLE,
		GUID,
		INTEGER,
		OBJECT,
		STRING,
		TIMESPAN
	}
	
	public class Node {
		internal Json.Array? array;
		internal Json.Object? object;
		internal string? str;
		internal int64? integer;
		internal string? number_str;
		internal bool? boolean;
		internal bool isnull;
		
		public Node (GLib.Value? val = null) {
			if (val == null)
				isnull = true;
			else if (val.type().is_a (typeof (Json.Array)))
				array = (Json.Array)val;
			else if (val.type().is_a (typeof (Json.Object)))
				object = (Json.Object)val;
			else if (val.type() == typeof (bool))
				boolean = (bool)val;
			else if (val.type() == typeof (int64))
				integer = (int64)val;
			else if (val.type() == typeof (uint64))
				integer = (int64)((uint64)val);
			else if (val.type() == typeof (int))
				integer = (int64)((int)val);
			else if (val.type() == typeof (uint))
				integer = (int64)((uint)val);
			else if (val.type() == typeof (long))
				integer = (int64)((long)val);
			else if (val.type() == typeof (ulong))
				integer = (int64)((long)val);
			else if (val.type() == typeof (double))
				number_str = "%g".printf ((double)val);
			else if (val.type() == typeof (float))
				number_str = "%g".printf ((float)val);
			else if (val.type() == typeof (string[])) {
				string[] strv = (string[])val;
				array = new Json.Array();
				foreach (string s in strv) {
					if (!is_valid_string (s))
						throw new Json.Error.INVALID ("invalid string value.\n");
					array.add_string_element (s);
				}
			}
			else if (val.type() == typeof (DateTime)) {
				str = "\"" + ((DateTime)val).to_string() + "\"";
			}
			else if (val.type() == typeof (Mee.Guid)) {
				str = "\"" + ((Mee.Guid)val).to_string() + "\"";
			}
			else if (val.type().is_a (typeof (Mee.TimeSpan)))
				str = "\"" + ((Mee.TimeSpan)val).to_string() + "\"";
			else if (val.type() == typeof (string)) {
				if (!is_valid_string ((string)val))
					throw new Json.Error.INVALID ("current string isn't valid.\n");
				str = "\"%s\"".printf ((string)val);
			}
			else if (val.type().is_a (typeof (Json.Node))) {
				var node = (Json.Node)val;
				array = node.array;
				object = node.object;
				str = node.str;
				integer = node.integer;
				number_str = node.number_str;
				boolean = node.boolean;
				isnull = node.isnull;
			}
			else isnull = true;
		}

		public Json.NodeType node_type {
			get {
				if (array != null)
					return NodeType.ARRAY;
				if (object != null)
					return NodeType.OBJECT;
				if (str != null) {
					if (is_datetime())
						return NodeType.DATETIME;
					if (is_timespan())
						return NodeType.TIMESPAN;
					if (is_guid())
						return NodeType.GUID;
					return NodeType.STRING;
				}
				if (integer != null)
					return NodeType.INTEGER;
				if (number_str != null)
					return NodeType.DOUBLE;
				if (boolean != null)
					return NodeType.BOOLEAN;
				return NodeType.NULL;
			}
		}

		public GLib.Value value {
			owned get {
				if (array != null)
					return as_array();
				if (object != null)
					return as_object();
				if (str != null)
					return as_string();
				if (integer != null)
					return as_int();
				if (number_str != null) {
					double d = 0;
					number_str.scanf ("%g", out d);
					return d;
				}
				if (boolean != null)
					return as_boolean();
				return 0;
			}
		}

		public Json.Node get (GLib.Value val) {
			int i = -1;
			if (val.type() == typeof (int))
				i = (int)val;
			if (val.type() == typeof (uint))
				i = (int)((uint)val);
			if (val.type() == typeof (int64))
				i = (int)((int64)val);
			if (val.type() == typeof (uint64))
				i = (int)((uint64)val);
			if (val.type() == typeof (int8))
				i = (int)((int8)val);
			if (val.type() == typeof (uint8))
				i = (int)((uint8)val);
			if (val.type() == typeof (long))
				i = (int)((long)val);
			if (val.type() == typeof (ulong))
				i = (int)((ulong)val);
			if (node_type == NodeType.ARRAY && i >= 0 && i < array.size)
				return array[i];
			if (node_type == NodeType.OBJECT) {
				if (val.type() == typeof (string) && object.has_key ((string)val))
					return object[(string)val];
				if (i >= object.size)
					i = object.size - 1;
				if (i != -1)
					return object.properties[i].value;
			}
			var null_node = new Node();
			null_node.isnull = true;
			return null_node;
		}

		public Json.Array as_array() {
			return (array == null) ? new Json.Array() : array;
		}

		public Json.Object as_object() {
			return (object == null) ? new Json.Object() : object;
		}

		public DateTime as_datetime() {
			TimeVal tv = TimeVal();
			var date_str = as_string();
			if (date_str == null || date_str.length == 0 || !tv.from_iso8601 (date_str))
				return new DateTime.now_local();
			return new DateTime.from_timeval_utc (tv);
		}
		
		public Mee.Guid as_guid() {
			return Mee.Guid.parse (as_string());
		}
		
		public Mee.TimeSpan as_timespan() {
			return Mee.TimeSpan.parse (as_string());
		}

		public string as_string() {
			return (str == null) ? "" : str.substring (1, str.length - 2);
		}

		public int64 as_int() {
			return (integer == null) ? 0 : integer;
		}

		public double as_double() {
			if (number_str == null)
				return 0;
			double d = 0;
			number_str.scanf ("%g", out d);
			return d;
		}

		public bool as_boolean() {
			return (boolean == null) ? false : boolean;
		}
		
		public bool equals (GLib.Value val) {
			var node = new Node (val);
			return node.str == str &&
					   node.isnull == isnull &&
					   node.boolean == boolean &&
					   node.number_str == number_str &&
					   node.integer == integer && 
					   (array == null ? array == node.array : array.equals (node.array)) &&
					   (object == null ? object == node.object : object.equals (node.object));
		}
		
		public bool is_array() {
			return array != null;
		}

		public bool is_datetime() {
			TimeVal tv = TimeVal();
			var date_str = as_string();
			return tv.from_iso8601 (date_str);
		}
		
		public bool is_guid() {
			return Mee.Guid.try_parse (as_string());
		}
		
		public bool is_timespan() {
			return Mee.TimeSpan.try_parse (as_string());
		}

		public bool is_null() {
			return isnull == true;
		}
		
		public bool is_object() {
			return object != null;
		}
		
		public bool is_string() {
			return str != null;
		}

		public string to_string() {
			if (array != null)
				return array.to_string();
			if (object != null)
				return object.to_string();
			if (str != null)
				return str;
			if (integer != null)
				return integer.to_string();
			if (number_str != null)
				return number_str;
			if (boolean != null)
				return boolean.to_string();
			return "null";
		}

		internal string to_data (uint indent, char indent_char, bool pretty) {
			if (array != null)
				return array.to_data (indent, indent_char, pretty);
			if (object != null)
				return object.to_data (indent, indent_char, pretty);
			if (str != null)
				return str;
			if (integer != null)
				return integer.to_string();
			if (number_str != null)
				return number_str;
			if (boolean != null)
				return boolean.to_string();
			return "null";
		}
	}
}
