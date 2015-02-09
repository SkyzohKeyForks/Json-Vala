namespace Json {
	public class Object {
		HashTable<string, Json.Node> map;

		public signal void property_changed (Property property);
		public signal void property_removed (Property property);
		
		public Object() {
			map = new HashTable<string, Json.Node> (str_hash, str_equal);
		}

		public static Json.Object parse (string json) throws GLib.Error {
			var parser = new Parser();
			parser.load_from_string (json);
			if (parser.root.node_type != NodeType.OBJECT)
				throw new Json.Error.TYPE ("provided data isn't an object.\n");
			return parser.root.object;
		}
		
		public bool has_key (string key) {
			return map.contains (key);
		}

		public Json.Node? get (string id) {
			if (has_key (id))
				return map[id];
			return null;
		}

		public Json.Property get_property (string id) {
			return new Property (id, map[id]);
		}

		public Json.Array get_array_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val == null || val.array == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.array;
		}

		public Json.Object get_object_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val == null || val.object == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.object;
		}

		public DateTime get_datetime_member (string id) throws GLib.Error {
			var str = get_string_member (id);
			var tv = TimeVal();
			if (!tv.from_iso8601 (str))
				throw new Json.Error.INVALID ("the element isn't a datetime.\n");
			return new DateTime.from_timeval_utc (tv);
		}
		
		public Mee.Guid get_guid_member (string id) throws GLib.Error {
			var str = get_string_member (id);
			if (!Mee.Guid.try_parse (str))
				throw new Json.Error.INVALID ("current member isn't a valid guid.\n");
			return Mee.Guid.parse (str);
		}
		
		public Mee.TimeSpan get_timespan_member (string id) throws GLib.Error {
			var str = get_string_member (id);
			if (!Mee.TimeSpan.try_parse (str))
				throw new Json.Error.INVALID ("the element isn't a timespan.\n");
			return Mee.TimeSpan.parse (str);
		}

		public string get_string_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val == null || val.str == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.str.substring (1, val.str.length - 2);
		}

		public double get_double_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val == null || val.number_str == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.as_double();
		}

		public bool get_boolean_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val.boolean == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.boolean;
		}
		
		public int64 get_integer_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val == null || val.integer == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.integer;
		}
		
		public void clear() {
			map = new HashTable<string, Json.Node> (str_hash, str_equal);
		}
		
		public bool has (string id, Json.Node node) {
			if (!map.contains (id))
				return false;
			if (!node.equals (map[id]))
				return false;
			return true;
		}
		
		public bool has_all (Json.Object object) {
			for (var i = 0; i < size; i++)
				if (!has_property (object.properties[i]))
					return false;
			return true;
		}
		
		public bool has_property (Json.Property property) {
			return has (property.identifier, property.value);
		}
		
		public bool remove_all (Json.Object object) {
			bool res = true;
			for (var i = 0; i < size; i++)
				if (!remove_property (object.properties[i]))
					return false;
			return true;
		}
		
		public bool remove_property (Json.Property property) {
			if (!has_property (property))
				return false;
			return map.remove (property.identifier);
		}

		public bool remove_member (string id, out Json.Node? node = null) {
			node = map[id];
			bool res = map.remove (id);
			if (true)
				property_removed (new Property (id, node));
			return res;
		}

		public void set (string id, GLib.Value val) throws GLib.Error {
			if (!is_valid_string (id))
				throw new Json.Error.INVALID ("identifier is invalid.\n");
			map[id] = new Json.Node (val);
			property_changed (new Property (id, map[id]));
		}

		public void set_member (string id, Json.Node val) throws GLib.Error {
			if (!is_valid_string (id))
				throw new Json.Error.INVALID ("identifier is invalid.\n");
			map[id] = val;
			property_changed (new Property (id, val));
		}

		public void set_array_member (string id, Json.Array array) throws GLib.Error {
			var val = new Json.Node (array);
			set_member (id, val);
		}

		public void set_object_member (string id, Json.Object object) throws GLib.Error {
			var val = new Json.Node (object);
			set_member (id, val);
		}

		public void set_datetime_member (string id, DateTime date) throws GLib.Error {
			set_string_member (id, date.to_string());
		}
		
		public void set_guid_member (string id, Mee.Guid guid) throws GLib.Error {
			set_string_member (id, guid.to_string());
		}
		
		public void set_timespan_member (string id, Mee.TimeSpan timespan)  throws GLib.Error {
			set_string_member (id, timespan.to_string());
		}

		public void set_string_member (string id, string str) throws GLib.Error {
			set_member (id, new Json.Node (str));
		}

		public void set_double_member (string id, double number) throws GLib.Error {
			var val = new Json.Node (number);
			set_member (id, val);
		}

		public void set_boolean_member (string id, bool boolean) throws GLib.Error {
			var val = new Json.Node (boolean);
			set_member (id, val);
		}
		
		public void set_integer_member (string id, int64 integer) throws GLib.Error {
			var val = new Json.Node (integer);
			set_member (id, val);
		}

		public void set_null_member (string id) throws GLib.Error {
			var val = new Json.Node();
			set_member (id, val);
		}

		public delegate bool ForeachFunc (Json.Property property);

		public void foreach (ForeachFunc func) {
			for (uint u = 0; u < size; u++)
				if(!func (properties[u]))
					return;
		}
		
		public string[] keys {
			owned get {
				var list = new GenericArray<string>();
				this.foreach (prop => { list.add (prop.identifier); return true; });
				return list.data;
			}
		}
		
		public Json.Node[] values {
			owned get {
				var list = new GenericArray<Json.Node>();
				this.foreach (prop => { list.add (prop.value); return true; });
				return list.data;
			}
		}

		public Json.Property[] properties {
			owned get {
				var list = new GenericArray<Property>();
				this.foreach (prop => { list.add (prop); return true; });
				return list.data;
			}
		}

		public uint size {
			get {
				return map.length;
			}
		}

		public string to_string() {
			if (size == 0)
				return "{}";
			string s = "{";
			for (var i = 0; i < size - 1; i++)
				s += ("\"" + keys[i] + "\" : " + values[i].to_string() + ", ");
			s += ("\"" + keys[size - 1] + "\" : " + values[size - 1].to_string() + "}");
			return s;
		}
		
		public bool equals (Json.Object object) {
			if (object.size != size)
				return false;
			bool res = true;
			this.foreach (prop => {
				if (!object.has_key (prop.identifier)) {
					res = false;
					return false;
				}
				if (!prop.value.equals (object[prop.identifier])) {
					res = false;
					return false;
				}
				return true;
			});
			return res;
		}

		internal string to_data (uint indent, char indent_char, bool pretty) {
			if (!pretty)
				return to_string ();
			if (size == 0)
				return "{}";
			StringBuilder sb = new StringBuilder("{\n");
			for (var i = 0; i < size - 1; i++) {
				for (var j = 0; j < indent; j++)
					sb.append_c (indent_char);
				sb.append ("\"" + keys[i] + "\" : ");
				sb.append (values[i].to_data (indent + 1, indent_char, pretty));
				sb.append (",\n");
			}
			for (var j = 0; j < indent; j++)
				sb.append_c (indent_char);
			sb.append ("\"" + keys[size - 1] + "\" : ");
			sb.append (values[size - 1].to_data (indent + 1, indent_char, pretty) + "\n");
			for (var j = 0; j < indent - 1; j++)
				sb.append_c (indent_char);
			sb.append ("}");
			return sb.str;
		}
	}
}
