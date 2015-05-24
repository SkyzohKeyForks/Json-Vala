namespace MeeJson {
	public class Object {
		HashTable<string, MeeJson.Node> map;

		public signal void property_changed (Property property);
		public signal void property_removed (Property property);
		
		public Object() {
			map = new HashTable<string, MeeJson.Node> (str_hash, str_equal);
		}

		public static MeeJson.Object parse (string json) throws GLib.Error {
			var parser = new Parser();
			parser.load_from_string (json);
			if (parser.root.node_type != NodeType.OBJECT)
				throw new MeeJson.Error.TYPE ("provided data isn't an object.\n");
			return parser.root.object;
		}
		
		public bool has_key (string key) {
			return map.contains (key);
		}

		public MeeJson.Node? get (string id) {
			if (has_key (id))
				return map[id];
			return null;
		}

		public MeeJson.Property get_property (string id) {
			return new Property (id, map[id]);
		}

		public MeeJson.Array get_array_member (string id) throws GLib.Error {
			MeeJson.Node val = this[id];
			if (val == null || val.array == null)
				throw new MeeJson.Error.TYPE ("current member haven't correct value type\n");
			return val.array;
		}

		public MeeJson.Object get_object_member (string id) throws GLib.Error {
			MeeJson.Node val = this[id];
			if (val == null || val.object == null)
				throw new MeeJson.Error.TYPE ("current member haven't correct value type\n");
			return val.object;
		}
		
		public uint8[] get_binary_member (string id) throws GLib.Error {
			var str = get_string_member (id);
			var data = Base64.decode (str);
			if (data.length == 0)
				throw new MeeJson.Error.INVALID ("the member isn't a valid binary data");
			return data;
		}

		public DateTime get_datetime_member (string id) throws GLib.Error {
			var str = get_string_member (id);
			var tv = TimeVal();
			if (!tv.from_iso8601 (str))
				throw new MeeJson.Error.INVALID ("the member isn't a datetime.\n");
			return new DateTime.from_timeval_utc (tv);
		}
		
		public Mee.Guid get_guid_member (string id) throws GLib.Error {
			var str = get_string_member (id);
			if (!Mee.Guid.try_parse (str))
				throw new MeeJson.Error.INVALID ("current member isn't a valid guid.\n");
			return Mee.Guid.parse (str);
		}
		
		public Mee.TimeSpan get_timespan_member (string id) throws GLib.Error {
			var str = get_string_member (id);
			if (!Mee.TimeSpan.try_parse (str))
				throw new MeeJson.Error.INVALID ("current member isn't a timespan.\n");
			return Mee.TimeSpan.parse (str);
		}
		
		public Regex get_regex_member (string id) throws GLib.Error {
			var val = this[id];
			if (val == null || val.regex == null)
				throw new MeeJson.Error.INVALID ("current member isn't a regular expression\n");
			return val.regex;
		}

		public string get_string_member (string id) throws GLib.Error {
			MeeJson.Node val = this[id];
			if (val == null || val.str == null)
				throw new MeeJson.Error.TYPE ("current member haven't correct value type\n");
			return val.str.substring (1, val.str.length - 2);
		}

		public double get_double_member (string id) throws GLib.Error {
			MeeJson.Node val = this[id];
			if (val == null || val.number_str == null)
				throw new MeeJson.Error.TYPE ("current member haven't correct value type\n");
			return val.as_double();
		}

		public bool get_boolean_member (string id) throws GLib.Error {
			MeeJson.Node val = this[id];
			if (val.boolean == null)
				throw new MeeJson.Error.TYPE ("current member haven't correct value type\n");
			return val.boolean;
		}
		
		public int64 get_integer_member (string id) throws GLib.Error {
			MeeJson.Node val = this[id];
			if (val == null || val.integer == null)
				throw new MeeJson.Error.TYPE ("current member haven't correct value type\n");
			return val.integer;
		}
		
		public void clear() {
			map = new HashTable<string, MeeJson.Node> (str_hash, str_equal);
		}
		
		public bool has (string id, MeeJson.Node node) {
			if (!map.contains (id))
				return false;
			if (!node.equals (map[id]))
				return false;
			return true;
		}
		
		public bool has_all (MeeJson.Object object) {
			for (var i = 0; i < size; i++)
				if (!has_property (object.properties[i]))
					return false;
			return true;
		}
		
		public bool has_property (MeeJson.Property property) {
			return has (property.identifier, property.node_value);
		}
		
		public bool remove_all (MeeJson.Object object) {
			bool res = true;
			for (var i = 0; i < size; i++)
				if (!remove_property (object.properties[i]))
					return false;
			return true;
		}
		
		public bool remove_property (MeeJson.Property property) {
			if (!has_property (property))
				return false;
			return map.remove (property.identifier);
		}

		public bool remove_member (string id, out MeeJson.Node? node = null) {
			node = map[id];
			bool res = map.remove (id);
			if (true)
				property_removed (new Property (id, node));
			return res;
		}

		public void set (string id, GLib.Value val) throws GLib.Error {
			if (!is_valid_string (id))
				throw new MeeJson.Error.INVALID ("identifier is invalid.\n");
			map[id] = new MeeJson.Node (val);
			property_changed (new Property (id, map[id]));
		}

		public void set_member (string id, MeeJson.Node val) throws GLib.Error {
			if (!is_valid_string (id))
				throw new MeeJson.Error.INVALID ("identifier is invalid.\n");
			map[id] = val;
			property_changed (new Property (id, val));
		}

		public void set_array_member (string id, MeeJson.Array array) throws GLib.Error {
			var val = new MeeJson.Node (array);
			set_member (id, val);
		}

		public void set_object_member (string id, MeeJson.Object object) throws GLib.Error {
			var val = new MeeJson.Node (object);
			set_member (id, val);
		}
		
		public void set_binary_member (string id, uint8[] data) throws GLib.Error {
			set_string_member (id, Base64.encode (data));
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
		
		public void set_regex_member (string id, Regex regex) throws GLib.Error {
			set_member (id, new MeeJson.Node (regex));
		}

		public void set_string_member (string id, string str) throws GLib.Error {
			set_member (id, new MeeJson.Node (str));
		}

		public void set_double_member (string id, double number) throws GLib.Error {
			var val = new MeeJson.Node (number);
			set_member (id, val);
		}

		public void set_boolean_member (string id, bool boolean) throws GLib.Error {
			var val = new MeeJson.Node (boolean);
			set_member (id, val);
		}
		
		public void set_integer_member (string id, int64 integer) throws GLib.Error {
			var val = new MeeJson.Node (integer);
			set_member (id, val);
		}

		public void set_null_member (string id) throws GLib.Error {
			var val = new MeeJson.Node();
			set_member (id, val);
		}

		public void foreach (Func<Property> func) {
			map.foreach ((name, value) => {
				func (new Property (name, value));
			});
		}
		
		public bool validate (MeeJsonSchema.Schema schema) {
			if (schema.schema_type != MeeJsonSchema.SchemaType.OBJECT)
				return false;
			MeeJsonSchema.SchemaObject so = (MeeJsonSchema.SchemaObject)schema;
			if (so.max_properties != null)
				if (size > so.max_properties)
					return false;
			if (so.min_properties != null)
				if (size < so.min_properties)
					return false;
			foreach (string str in so.required)
				if (!map.contains (str))
					return false;
			bool res = true;
			var sset = new GenericSet<string>(str_hash, str_equal);
			map.get_keys().foreach (str => { sset.add (str); });
			so.properties.foreach ((name, val) => {
				if (map.contains (name)) {
					sset.remove (name);
					if (map[name].validate (val) == false)
						res = false;
				}
			});
			if (res == false)
				return false;
			res = true;
			so.pattern_properties.foreach ((regex, val) => {
				var sres = true;
				sset.foreach (str => {
					if (regex.match (str))
						if (map[str].validate (val) == false)
							sres = false;
				});
				if (sres == false)
					res = false;
			});
			if (res == false)	
				return false;
			if (so.additional_properties.type() == typeof (bool)) {
				bool ap = (bool)so.additional_properties;
				if (sset.length > 0 && ap == false)
					return false;
			}
			if (so.additional_properties.type().is_a (typeof (MeeJsonSchema.Schema))) {
				res = true;
				var sschema = (MeeJsonSchema.Schema)so.additional_properties;
				sset.foreach (str => {
					if (map[str].validate (sschema) == false)
						res = false;
				});
				if (res == false)
					return false;
			}
			return true;
		}
		
		public string[] keys {
			owned get {
				var list = new GenericArray<string>();
				this.foreach (prop => { list.add (prop.identifier); });
				return list.data;
			}
		}
		
		public MeeJson.Node[] values {
			owned get {
				var list = new GenericArray<MeeJson.Node>();
				this.foreach (prop => { list.add (prop.node_value); });
				return list.data;
			}
		}

		public MeeJson.Property[] properties {
			owned get {
				var list = new GenericArray<Property>();
				this.foreach (prop => { list.add (prop); });
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
		
		public bool equals (MeeJson.Object object) {
			if (object.size != size)
				return false;
			bool res = true;
			this.foreach (prop => {
				if (!object.has_key (prop.identifier)) {
					res = false;
				}
				if (!prop.node_value.equals (object[prop.identifier])) {
					res = false;
				}
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
