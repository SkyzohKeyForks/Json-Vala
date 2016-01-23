namespace Json {
	public enum NodeType {
		NULL,
		ARRAY,
		BOOLEAN,
		DOUBLE,
		INTEGER,
		OBJECT,
		STRING,
		DATETIME
	}
	
	public class Node : GLib.Object {
		internal bool isnull;
		internal Json.Array? array;
		internal Json.Object? object;
		internal bool? boolean;
		internal string? number_str;
		internal string? str;
		internal int64? integer;

		public Node (GLib.Value? val = null) {
			set_value_internal (val);
		}

		public bool as_boolean() {
			return boolean == true;
		}

		public double as_double() {
			return double.parse (number_str == null ? "0" : number_str);
		}

		public int64 as_integer() {
			return integer == null ? 0 : integer;
		}

		public string as_string() {
			return str == null ? "" : str.substring (1, str.length - 2);
		}
		
		public DateTime as_datetime() {
			TimeVal tv = TimeVal();
			if (!tv.from_iso8601 (as_string()))
				return new DateTime.now_local();
			return new DateTime.from_timeval_local (tv);
		}
		
		public Regex as_regex() {
			try {
				var regex = new Regex (as_string());
				return regex;
			} catch {
				return new Regex ("");
			}
		}

		public Json.Array as_array() {
			return array == null ? new Json.Array() : array;
		}

		public Json.Object as_object() {
			return object == null ? new Json.Object() : object;
		}
		
		public string[] as_string_array() {
			string[] strv = new string[0];
			var a = as_array();
			foreach (var node in a)
				if (node.is_string())
					strv += node.as_string();
			return strv;
		}
		
		public bool is_boolean() {
			return boolean != null;
		}
		
		public bool is_datetime() {
			TimeVal tv = TimeVal();
			return tv.from_iso8601 (as_string());
		}
		
		public bool is_double() {
			return number_str != null;
		}
		
		public bool is_integer() {
			return integer != null;
		}
		
		public bool is_regex() {
			try {
				var regex = new Regex (as_string());
				return true;
			} catch {
				return false;
			}
		}
		
		public bool is_string() {
			return str != null;
		}
		
		public bool is_object() {
			return object != null;
		}
		
		public bool is_array() {
			return array != null;
		}
		
		public bool is_null() {
			return isnull;
		}
		
		public bool is_string_array() {
			if (!is_array())
				return false;
			foreach (var node in array)
				if (!node.is_string())
					return false;
			return true;
		}
		
		public bool equal (Json.Node node) {
			return isnull == node.isnull &&
				boolean == node.boolean &&
				str_equal (number_str, node.number_str) &&
				str_equal (str, node.str) &&
				integer == node.integer &&
				(array == null ? node.array == null : array.equal (node.array)) &&
				(object == null ? node.object == null : object.equal (node.object));
		}

		public Json.Node get (GLib.Value? val) {
			if (array != null)
				return array[val];
			if (object != null)
				return object[val];
			return new Json.Node();
		}

		public string to_string() {
			if (array != null)
				return array.to_string();
			if (object != null)
				return object.to_string();
			if (boolean != null)
				return boolean.to_string();
			if (number_str != null)
				return number_str;
			if (str != null)
				return str;
			if (integer != null)
				return integer.to_string();
			return "null";
		}

		void set_value_internal (GLib.Value? val) {
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
			else if (val.type() == typeof (string) && is_valid_string ((string)val))
				str = "\"%s\"".printf ((string)val);
			else if (val.type() == typeof (DateTime))
				str = "\"%s\"".printf (((DateTime)val).to_string());
			else if (val.type() == typeof (Regex))
				str = "\"%s\"".printf (((Regex)val).get_pattern());
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

		public NodeType node_type {
			get {
				if (boolean != null)
					return NodeType.BOOLEAN;
				if (number_str != null)
					return NodeType.DOUBLE;
				if (is_datetime())
					return NodeType.DATETIME;
				if (str != null)
					return NodeType.STRING;
				if (integer != null)
					return NodeType.INTEGER;
				if (array != null)
					return NodeType.ARRAY;
				if (object != null)
					return NodeType.OBJECT;
				return NodeType.NULL;
			}
		}

		public GLib.Value? value {
			owned get {
				if (boolean != null)
					return boolean;
				if (number_str != null)
					return double.parse (number_str);
				if (is_datetime())
					return as_datetime();
				if (str != null)
					return as_string();
				if (integer != null)
					return integer;
				if (array != null)
					return array;
				if (object != null)
					return object;
				return null;
			}
			set {
				set_value_internal (value);
			}
		}
	}
}
