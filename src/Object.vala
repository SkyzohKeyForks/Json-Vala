namespace Json {
	public class Property : GLib.Object {
		public Property (string key, Json.Node node) requires (is_valid_string (key)) {
			GLib.Object (key: key, node: node);
		}
		
		public string key { get; construct; }
		public Json.Node node { get; set; }
		public GLib.Value value {
			owned get {
				return node.value;
			}
		}
	}
	
	public class Object : GLib.Object {
		HashTable<string, Json.Node> table;

		construct {
			table = new HashTable<string, Json.Node> (str_hash, str_equal);
		}

		public static Object parse (string json) {
			try {
				var parser = new Json.Parser (json);
				if (parser.root.node_type == NodeType.OBJECT)
					return parser.root.object;
				return new Json.Object();
			} catch {
				return new Json.Object();
			}
		}
		
		public bool has_key (string key) {
			return key in table;
		}

		public bool equal (Json.Object object) {
			return true;
		}

		public delegate void ForeachFunc (Json.Property property);
		
		public void foreach (ForeachFunc func) {
			table.foreach ((key, val) => {
				func (new Property (key, val));
			});
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
			if (val.type() == typeof (string))
				return get_member ((string)val);
			if (i >= table.length)
				return new Json.Node();
			return table[table.get_keys().nth_data (i)];
		}

		public Json.Node get_member (string id) {
			if (table[id] == null)
				return new Json.Node();
			return table[id];
		}

		public bool get_null_member (string id) {
			return get_member (id).isnull;
		}

		public bool get_boolean_member (string id) {
			return get_member (id).as_boolean();
		}

		public double get_double_member (string id) {
			return get_member (id).as_double();
		}

		public string get_string_member (string id) {
			return get_member (id).as_string();
		}

		public int64 get_integer_member (string id) {
			return get_member (id).as_integer();
		}

		public Json.Array get_array_member (string id) {
			return get_member (id).as_array();
		}

		public Json.Object get_object_member (string id) {
			return get_member (id).as_object();
		}

		public DateTime get_datetime_member (string id) {
			return get_member (id).as_datetime();
		}

		public Regex get_regex_member (string id) {
			return get_member (id).as_regex();
		}

		public void set_member (string id, Json.Node node) {
			if (is_valid_string (id))
				table[id] = node;
		}

		public void set_boolean_member (string id, bool value) {
			set_member (id, new Json.Node (value));
		}

		public void set_double_member (string id, double value) {
			set_member (id, new Json.Node (value));
		}

		public void set_string_member (string id, string value) {
			set_member (id, new Json.Node (value));
		}

		public void set_integer_member (string id, int64 value) {
			set_member (id, new Json.Node (value));
		}

		public void set_array_member (string id, Json.Array value) {
			set_member (id, new Json.Node (value));
		}

		public void set_object_member (string id, Json.Object value) {
			set_member (id, new Json.Node (value));
		}

		public void set_datetime_member (string id, DateTime value) {
			set_member (id, new Json.Node (value));
		}

		public void set_regex_member (string id, Regex value) {
			set_member (id, new Json.Node (value));
		}

		public void set_null_member (string id) {
			set_member (id, new Json.Node());
		}

		public string to_string() {
			if (table.length == 0)
				return "{}";
			string result = "{ ";
			for (var i = 0; i < table.length - 1; i++)
				result += "\"%s\" : %s, ".printf (table.get_keys().nth_data (i), table[table.get_keys().nth_data (i)].to_string());
			result += "\"%s\" : %s }".printf (table.get_keys().nth_data (table.length - 1), table[table.get_keys().nth_data (table.length - 1)].to_string());
			return result;
		}

		public string[] keys {
			owned get {
				string[] vals = new string[0];
				foreach (string key in table.get_keys())
					vals += key;
				return vals;
			}
		}

		public Json.Node[] values {
			owned get {
				var nodes = new Json.Node[0];
				foreach (Json.Node node in table.get_values())
					nodes += node;
				return nodes;
			}
		}

		public Property[] properties {
			owned get {
				var props = new Property[0];
				table.foreach ((key, val) => {
					props += new Property (key, val);
				});
				return props;
			}
		}

		public int size {
			get {
				return (int)table.length;
			}
		}
	}
}
