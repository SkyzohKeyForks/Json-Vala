namespace Json {
	public class Object {
		Gee.HashMap<string, Json.Node> map;

		public signal void property_changed (Property property);
		
		public Object() {
			map = new Gee.HashMap<string, Json.Node>();
		}

		public static Json.Object parse (string json) throws GLib.Error {
			var parser = new Parser();
			parser.load_from_string (json);
			if (parser.root.node_type != NodeType.OBJECT)
				throw new Json.Error.TYPE ("provided data isn't an object.\n");
			return parser.root.object;
		}

		public Json.Node get (string id) throws GLib.Error {
			return map[id];
		}

		public Json.Property get_property (string id) throws GLib.Error {
			return new Property (id, map[id]);
		}

		public Json.Array get_array_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val.array == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.array;
		}

		public Json.Object get_object_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val.object == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.object;
		}

		public DateTime get_datetime_member (string id) throws GLib.Error {
			var val = this[id];
			var tv = TimeVal();
			if (val.str == null || !tv.from_iso8601 (val.str))
				throw new Json.Error.INVALID ("the element isn't a datetime.\n");
			return new DateTime.from_timeval_utc (tv);
		}

		public string get_string_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val.str == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.str;
		}

		public double get_double_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val.number == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.number;
		}

		public bool get_boolean_member (string id) throws GLib.Error {
			Json.Node val = this[id];
			if (val.boolean == null)
				throw new Json.Error.TYPE ("current member haven't correct value type\n");
			return val.boolean;
		}

		public bool remove_member (string id) {
			return map.unset (id);
		}

		public void set (string id, GLib.Value val) throws GLib.Error {
			if (!is_valid_string (id))
				throw new Json.Error.INVALID ("identifier is invalid.\n");
			var jval = new Json.Node();
			if (val.type().is_a (typeof (Json.Node)))
				jval = (Json.Node)val;
			else if (val.type().is_a (typeof (Json.Object)))
				jval.object = (Json.Object)val;
			else if (val.type().is_a (typeof (Json.Array)))
				jval.array = (Json.Array)val;
			else if (val.type() == typeof (string[])) {
				string[] strv = (string[])val;
				var jarray = new Json.Array();
				foreach (string s in strv) {
					if (!is_valid_string (s))
						throw new Json.Error.INVALID ("invalid string value.\n");
					jarray.add_string_element (s);
				}
				jval.array = jarray;
			}
			else if (val.type() == typeof (DateTime))
				jval.str = "\"" + ((DateTime)val).to_string() + "\"";
			else if (val.type() == typeof (bool))
				jval.boolean = (bool)val;
			else if (val.type() == typeof (int64))
				jval.integer = (int64)val;
			else if (val.type() == typeof (uint64))
				jval.integer = (int64)((uint64)val);
			else if (val.type() == typeof (int))
				jval.integer = (int64)((int)val);
			else if (val.type() == typeof (uint))
				jval.integer = (int64)((uint)val);
			else if (val.type() == typeof (long))
				jval.integer = (int64)((long)val);
			else if (val.type() == typeof (ulong))
				jval.integer = (int64)((long)val);
			else if (val.type() == typeof (double))
				jval.number = (double)val;
			else if (val.type() == typeof (float))
				jval.number = (double)((float)val);
			else if (val.type() == typeof (string)) {
				string str = (string)val;
				if (!is_valid_string (str))
					throw new Json.Error.INVALID ("invalid string value.\n");
				jval.str = "\"" + str + "\"";
			}
			else
				jval.isnull = true;
			map[id] = jval;
			property_changed (new Property (id, jval));
		}

		public void set_member (string id, Json.Node val) throws GLib.Error {
			if (!is_valid_string (id))
				throw new Json.Error.INVALID ("identifier is invalid.\n");
			map[id] = val;
			property_changed (new Property (id, val));
		}

		public void set_array_member (string id, Json.Array array) throws GLib.Error {
			var val = new Json.Node();
			val.array = array;
			set_member (id, val);
		}

		public void set_object_member (string id, Json.Object object) throws GLib.Error {
			var val = new Json.Node();
			val.object = object;
			set_member (id, val);
		}

		public void set_datetime_member (string id, DateTime date) throws GLib.Error {
			set_string_member (id, date.to_string());
		}

		public void set_string_member (string id, string str) throws GLib.Error {
			var val = new Json.Node();
			if (!is_valid_string (str))
				throw new Json.Error.INVALID ("invalid string.\n");
			val.str = "\"" + str + "\"";
			set_member (id, val);
		}

		public void set_double_member (string id, double number) throws GLib.Error {
			var val = new Json.Node();
			val.number = number;
			set_member (id, val);
		}

		public void set_boolean_member (string id, bool boolean) throws GLib.Error {
			var val = new Json.Node();
			val.boolean = boolean;
			set_member (id, val);
		}

		public void set_null_member (string id) throws GLib.Error {
			var val = new Json.Node();
			val.isnull = true;
			set_member (id, val);
		}

		public delegate void ForeachFunc (Json.Property property);

		public void foreach (ForeachFunc func) {
			for (var i = 0; i < size; i++)
				func (new Property(map.keys.to_array()[i], map.values.to_array()[i]));
		}

		public Json.Property[] properties {
			owned get {
				var list = new Gee.ArrayList<Property>();
				this.foreach (prop => {
					list.add (prop);
				});
				return list.to_array();
			}
		}

		public int size {
			get {
				return map.size;
			}
		}

		public string to_string() {
			if (size == 0)
				return "{}";
			string s = "{";
			for (var i = 0; i < size - 1; i++)
				s += ("\"" + map.keys.to_array()[i] + "\" : " + map.values.to_array()[i].to_string() + ", ");
			s += ("\"" + map.keys.to_array()[size - 1] + "\" : " + map.values.to_array()[size - 1].to_string() + "}");
			return s;
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
				sb.append ("\"" + map.keys.to_array()[i] + "\" : ");
				sb.append (map.values.to_array()[i].to_data (indent + 1, indent_char, pretty));
				sb.append (",\n");
			}
			for (var j = 0; j < indent; j++)
				sb.append_c (indent_char);
			sb.append ("\"" + map.keys.to_array()[size - 1] + "\" : ");
			sb.append (map.values.to_array()[size - 1].to_data (indent + 1, indent_char, pretty) + "\n");
			for (var j = 0; j < indent - 1; j++)
				sb.append_c (indent_char);
			sb.append ("}");
			return sb.str;
		}
	}
}
