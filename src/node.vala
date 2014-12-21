namespace Json {
	public enum NodeType {
		NULL,
		ARRAY,
		BOOLEAN,
		DATETIME,
		DOUBLE,
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
		internal double? number;
		internal bool? boolean;
		internal bool isnull;
		
		internal Node() {

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
					return NodeType.STRING;
				}
				if (integer != null)
					return NodeType.INTEGER;
				if (number != null)
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
				if (str != null) {
					if (is_datetime())
						return as_datetime();
					if (is_timespan())
						return as_timespan();
					return as_string();
				}
				if (integer != null)
					return as_int();
				if (number != null) {
					double d = as_double();
					return d;
				}
				if (boolean != null)
					return as_boolean();
				return 0;
			}
		}

		public Json.Node? get (GLib.Value val) {
			int i = -1;
			if (val.type() == typeof (int))
				i = (int)val;
			if (val.type() == typeof (uint))
				i = (int)((uint)val);
			if (val.type() == typeof (int64))
				i = (int)((int64)val);
			if (val.type() == typeof (uint64))
				i = (int)((uint64)val);
			if (val.type() == typeof (long))
				i = (int)((long)val);
			if (val.type() == typeof (ulong))
				i = (int)((ulong)val);
			if (node_type == NodeType.ARRAY)
				return array[i];
			if (node_type == NodeType.OBJECT) {
				if (val.type() == typeof (string))
					return object[(string)val];
				if (i >= object.size)
					i = object.size - 1;
				if (i != -1)
					return object.properties[i].value;
			}
			return null;
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
			return (number == null) ? 0 : number;
		}

		public bool as_boolean() {
			return (boolean == null) ? false : boolean;
		}
		
		public bool equals (Json.Node node) {
				return node.str == str &&
					   node.isnull == isnull &&
					   node.boolean == boolean &&
					   node.number == number &&
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
			if (number != null)
				return number.to_string();
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
			if (number != null)
				return number.to_string();
			if (boolean != null)
				return boolean.to_string();
			return "null";
		}
	}
}
