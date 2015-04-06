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
		REGEX,
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
			else if (val.type() == typeof (Regex)) {
				str = "\"" + ((Regex)val).get_pattern() + "\"";
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
					if (is_regex())
						return NodeType.REGEX;
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
		
		string[] jarray_as_string_array() {
			string[] strv = new string[0];
			foreach (var n in array)
				strv += n.as_string();
			return strv;
		}

		public GLib.Value value {
			owned get {
				if (array != null) {
					if (array.is_unique == NodeType.STRING)
						return jarray_as_string_array();
					return as_array();
				}
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
			uint i = 0;
			if (val.type() == typeof (int))
				i = (uint)(int)val;
			if (val.type() == typeof (uint))
				i = (uint)val;
			if (val.type() == typeof (int64))
				i = (uint)((int64)val);
			if (val.type() == typeof (uint64))
				i = (uint)((uint64)val);
			if (val.type() == typeof (int8))
				i = (uint)((int8)val);
			if (val.type() == typeof (uint8))
				i = (uint)((uint8)val);
			if (val.type() == typeof (long))
				i = (uint)((long)val);
			if (val.type() == typeof (ulong))
				i = (uint)((ulong)val);
			if (node_type == NodeType.ARRAY && i < array.size)
				return array[i];
			if (node_type == NodeType.OBJECT) {
				if (val.type() == typeof (string) && object.has_key ((string)val))
					return object[(string)val];
				if (i < object.size)
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
		
		public Regex as_regex() {
			try {
				return new Regex (as_string());
			}
			catch {
				return new Regex ("()");
			}
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
		
		public bool is_boolean() {
			return boolean != null;
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
		public bool is_regex() {
			try {
				var regex = new Regex (as_string());
				return true;
			} catch {
				return false;
			}
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
		
		public bool is_int() {
			return integer != null;
		}
		
		public bool is_double() {
			return number_str != null;
		}
		
		public bool validate (JsonSchema.Schema schema) {
			if (schema.schema_type == JsonSchema.SchemaType.ARRAY && node_type != NodeType.ARRAY)
				return false;
			if (schema.schema_type == JsonSchema.SchemaType.OBJECT && node_type != NodeType.OBJECT)
				return false;
			if (schema.schema_type == JsonSchema.SchemaType.BOOLEAN && node_type != NodeType.BOOLEAN)
				return false;
			if (schema.schema_type == JsonSchema.SchemaType.INTEGER && node_type != NodeType.INTEGER)
				return false;
			if (schema.schema_type == JsonSchema.SchemaType.NUMBER && node_type != NodeType.DOUBLE)
				return false;
			if (schema.schema_type == JsonSchema.SchemaType.STRING && str == null)
				return false;
			if (node_type == NodeType.OBJECT)
				return object.validate (schema);
			if (node_type == NodeType.ARRAY)
				return array.validate (schema);
			if (node_type == NodeType.INTEGER) {
				JsonSchema.SchemaInteger si = (JsonSchema.SchemaInteger)schema;
				if (si.multiple_of != null && (integer % si.multiple_of) != 0)
					return false;
				if (si.maximum != null)
					if (si.exclusive_maximum && integer >= si.maximum || !si.exclusive_maximum && integer > si.maximum)
						return false;
				if (si.minimum != null)
					if (si.exclusive_minimum && integer >= si.minimum || !si.exclusive_minimum && integer > si.minimum)
						return false;
			}
			if (node_type == NodeType.DOUBLE) {
				JsonSchema.SchemaNumber sn = (JsonSchema.SchemaNumber)schema;
				double d = as_double();
				if (sn.multiple_of != null && (d % sn.multiple_of) != 0)
					return false;
				if (sn.maximum != null)
					if (sn.exclusive_maximum && d >= sn.maximum || !sn.exclusive_maximum && d > sn.maximum)
						return false;
				if (sn.minimum != null)
					if (sn.exclusive_minimum && d >= sn.minimum || !sn.exclusive_minimum && d > sn.minimum)
						return false;
			}
			if (str != null) {
				JsonSchema.SchemaString s = (JsonSchema.SchemaString)schema;
				if (s.max_length != null && str.length > s.max_length)
					return false;
				if (s.min_length != null && str.length < s.min_length)
					return false;
				if (s.pattern != null && !s.pattern.match (str))
					return false;
			}
			return true;
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
