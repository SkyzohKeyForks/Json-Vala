namespace Json {
	public class Array {
		GenericArray<Json.Node> list;

		public signal void list_changed (uint index, uint size, Json.Node val);

		public Array() {
			list = new GenericArray<Json.Node>();
		}
		
		public static Array parse (string json) throws GLib.Error {
			var parser = new Parser();
			parser.load_from_string (json);
			if (parser.root.node_type != NodeType.ARRAY)
				throw new Json.Error.TYPE ("provided data isn't an array.\n");
			return parser.root.array;
		}
		
		public static Array from_values (GLib.Value[] values) throws GLib.Error {
			var array = new Array();
			array.add_values (values);
			return array;
		}
		
		public static Array from_strv (string[] array) throws GLib.Error {
			var jarray = new Array();
			foreach (string str in array)
				jarray.add_string_element (str);
			return jarray;
		}

		public void add_element (Json.Node val) {
			list.add (val);
			list_changed (size - 1, size, val);
		}
		
		public void add (GLib.Value val) throws GLib.Error {
			var node = new Json.Node (val);
			list.add (node);
			list_changed (size - 1, size, node);
		}

		public void add_values (GLib.Value[] values) throws GLib.Error {
			foreach (GLib.Value val in values)
				add (val);
		}

		public void add_datetime_element (DateTime date) throws GLib.Error {
			add_string_element (date.to_string());
		}
		
		public void add_guid_element (Mee.Guid guid) throws GLib.Error {
			add_string_element (guid.to_string());
		}
		
		public void add_timespan_element (Mee.TimeSpan timespan) throws GLib.Error {
			add_string_element (timespan.to_string());
		}
		
		public void add_regex_element (Regex regex) throws GLib.Error {
			add_string_element (regex.get_pattern());
		}
		
		public void add_string_element (string str) throws GLib.Error {
			var val = new Json.Node (str);
			add_element (val);
		}

		public void add_array_element (Json.Array array) {
			var val = new Json.Node (array);
			add_element (val);
		}

		public void add_object_element (Json.Object object) {
			var val = new Json.Node (object);
			add_element (val);
		}

		public void add_double_element (double number) {
			var val = new Json.Node (number);
			add_element (val);
		}

		public void add_boolean_element (bool boolean) {
			var val = new Json.Node (boolean);
			add_element (val);
		}
		
		public void add_integer_element (int64 integer) {
			add_element (new Json.Node (integer));
		}

		public void add_null_element() {
			add_element (new Json.Node());
		}
		
		public void clear() {
			list = new GenericArray<Json.Node>();
		}

		public void foreach (GLib.Func<Json.Node> func) {
			list.foreach (func);
		}
		
		public bool contains (GLib.Value val) {
			return index_of (val) != -1;
		}

		public int index_of (GLib.Value val) {
			var node = new Json.Node (val);
			for (var i = 0; i < size; i++)
				if (node.equals (this[i]))
					return i;
			return -1;
		}

		public void insert (int index, GLib.Value val) {
			list.insert (index, new Json.Node (val));
			list_changed (index, size, new Json.Node (val));
		}

		public Json.Node get (uint index) throws GLib.Error {
			return list[index];
		}

		public Json.Array get_array_element (uint index) throws GLib.Error {
			var val = this[index];
			if (val.array == null)
				throw new Json.Error.INVALID ("the element isn't an array.\n");
			return val.array;
		}

		public Json.Object get_object_element (uint index) throws GLib.Error {
			var val = this[index];
			if (val.object == null)
				throw new Json.Error.INVALID ("the element isn't an object.\n");
			return val.object;
		}

		public double get_double_element (uint index) throws GLib.Error {
			var val = this[index];
			if (val.number_str == null)
				throw new Json.Error.INVALID ("the element isn't a double.\n");
			return val.as_double();
		}

		public bool get_boolean_element (uint index) throws GLib.Error {
			var val = this[index];
			if (val.boolean == null)
				throw new Json.Error.INVALID ("the element isn't a boolean.\n");
			return val.boolean;
		}

		public DateTime get_datetime_element (uint index) throws GLib.Error {
			var str = get_string_element (index);
			var tv = TimeVal();
			if (!tv.from_iso8601 (str))
				throw new Json.Error.INVALID ("the element isn't a datetime.\n");
			return new DateTime.from_timeval_utc (tv);
		}
		
		public Mee.Guid get_guid_element (uint index) throws GLib.Error {
			var str = get_string_element (index);
			if (!Mee.Guid.try_parse (str))
				throw new Json.Error.INVALID ("the element isn't a valid guid.\n");
			return Mee.Guid.parse (str);
		}
		
		public Mee.TimeSpan get_timespan_element (uint index) throws GLib.Error {
			var str = get_string_element (index);
			if (!Mee.TimeSpan.try_parse (str))
				throw new Json.Error.INVALID ("the element isn't a timespan.\n");
			return Mee.TimeSpan.parse (str);
		}
		
		public Regex get_regex_element (uint index) throws GLib.Error {
			var str = get_string_element (index);
			try {
				return new Regex (str);
			} catch (RegexError re) {
				throw new Json.Error.INVALID ("the element isn't a regular expression : %s.\n".printf (re.message));
			}
		}

		public string get_string_element (uint index) throws GLib.Error {
			var val = this[index];
			if (val.str == null)
				throw new Json.Error.INVALID ("the element isn't a string.\n");
			return val.str;
		}
		
		public int64 get_integer_element (uint index) throws GLib.Error {
			var val = this[index];
			if (val.integer == null)
				throw new Json.Error.INVALID ("the element isn't an integer.\n");
			return val.integer;
		}

		public bool get_null_element (uint index) throws GLib.Error {
			var val = this[index];
			if (val.isnull != true)
				throw new Json.Error.INVALID ("the element isn't null.\n");
			return true;
		}
		
		public bool remove (GLib.Value val) {
			var node = new Json.Node (val);
			for (var i = 0; i < size; i++)
				if (node.equals (this[i])) {
					list.remove_index (i);
					return true;
				}
			return false;		
		}

		public void remove_element (uint index) {
			var val = list[index];
			list.remove_index (index);
			list_changed (index, size, val);
		}
		
		public new void set (uint index, GLib.Value val) {
			set_element (index, new Json.Node (val));
		}

		public void set_element (uint index, Json.Node val) {
			list[index] = val;
			list_changed (index, size, val);
		}

		public void set_object_element (uint index, Json.Object object) {
			var val = new Json.Node (object);
			set_element (index, val);
		}

		public void set_array_element (uint index, Json.Array array) {
			var val = new Json.Node (array);
			set_element (index, val);
		}
		
		public void set_string_element (uint index, string str) {
			set_element (index, new Json.Node (str));
		}

		public void set_datetime_element (uint index, DateTime date) {
			set_string_element (index, date.to_string());
		}
		
		public void set_guid_element (uint index, Mee.Guid guid) {
			set_string_element (index, guid.to_string());
		}
		
		public void set_timespan_element (uint index, Mee.TimeSpan timespan) {
			set_string_element (index, timespan.to_string());
		}
		
		public void set_regex_element (uint index, Regex regex) {
			set_string_element (index, regex.get_pattern());
		}

		public void set_double_element (uint index, double number) {
			var val = new Json.Node (number);
			set_element (index, val);
		}

		public void set_integer_element (uint index, int64 integer) {
			var val = new Json.Node (integer);
			set_element (index, val);
		}

		public void set_boolean_element (uint index, bool boolean) {
			var val = new Json.Node (boolean);
			set_element (index, val);
		}

		public void set_null_element (uint index) {
			var val = new Json.Node();
			set_element (index, val);
		}
		
		public Json.Array slice (int start, int stop) {
			var array = new Json.Array();
			for (uint u = start; u < stop; u++)
				array.add (this[u]);
			return array;
		}

		public string to_string() {
			if (size == 0)
				return "[]";
			string s = "[";
			for (var i = 0; i < size - 1; i++)
				s += list[i].to_string() + ",";
			s += list[size - 1].to_string() + "]";
			return s;
		}

		public bool equals (Json.Array array) {
			if (array.size != size)
				return false;
			for (var i = 0; i < size; i++)
				if (!array[i].equals (this[i]))
					return false;
			return true;
		}
		
		public bool validate (JsonSchema.Schema schema) {
			if (schema.enum != null) {
				
			}
			if (schema.schema_type != JsonSchema.SchemaType.ARRAY)
				return false;
			var sa = (JsonSchema.SchemaArray)schema;
			if (sa.max_items != null && sa.max_items < size)
				return false;
			if (sa.min_items != null && sa.min_items > size)
				return false;
			if (sa.unique_items == true) {
				for (var i = 0; i < size; i++)
					for (var j = 1; j < size; j++) {
						if (i == j)
							continue;
						if (this[i].equals (this[j]))
							return false;
					}
			}
			bool? ai = null;
			JsonSchema.Schema? sa2 = null;
			if (sa.additional_items.type() == typeof (bool)) {
				ai = (bool)sa.additional_items;
			}
			else if (sa.additional_items.type().is_a (typeof (JsonSchema.Schema)))
				sa2 = (JsonSchema.Schema)sa.additional_items;
			JsonSchema.Schema? _items = null;
			JsonSchema.SchemaList? sl = null;
			if (sa.items.type().is_a (typeof (JsonSchema.Schema)))
				_items = (JsonSchema.Schema)sa.items;
			else if (sa.items.type() == typeof (JsonSchema.SchemaList))
				sl = (JsonSchema.SchemaList)sa.items;
			else return false;
			if (sl != null) {
				if (ai == false && sl.size < size)
					return false;
				for (var i = 0; i < sl.size; i++)
					if (!this[i].validate (sl[i]))
						return false;
				if (sa2 != null)
					for (var i = sl.size; i < size; i++)
						if (!this[i].validate (sa2))
							return false;
			}
			if (_items != null) {
				for (var i = 0; i < size; i++)
					if (!this[i].validate (_items))
						return false;
			}
			return true;
		}

		internal string to_data (uint indent, char indent_char, bool pretty) {
			if (size == 0)
				return "[]";
			var sb = new StringBuilder("[\n");
			for (var i = 0; i < size - 1; i++) {
				for (var j = 0; j < indent; j++)
					sb.append_c (indent_char);
				sb.append (list[i].to_data (indent + 1, indent_char, pretty));
				sb.append (",\n");
			}
			for (var j = 0; j < indent; j++)
				sb.append_c (indent_char);
			sb.append (list[size - 1].to_data (indent + 1, indent_char, pretty) + "\n");
			for (var j = 0; j < indent - 1; j++)
				sb.append_c (indent_char);
			sb.append ("]");
			return sb.str;
		}
		
		public NodeType is_unique {
			get {
				if (size == 0)
					return NodeType.NULL;
				NodeType nt = list[0].node_type;
				for (var i = 1; i < list.length; i++)
					if (list[i].node_type != nt)
						return NodeType.NULL;
				return nt;
			}
		}

		public uint size {
			get {
				return list.length;
			}
		}
	}
}
