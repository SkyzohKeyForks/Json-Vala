namespace Json {
	public class Array {
		internal Gee.ArrayList<Json.Node> list;

		public signal void list_changed (int index, int size, Json.Node val);

		public Array() {
			list = new Gee.ArrayList<Json.Node>();
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

		public void add_element (Json.Node val) {
			list.add (val);
			list_changed (size - 1, size, val);
		}
		
		public void add (GLib.Value val) throws GLib.Error {
			var jval = new Json.Node();
			if (val.type() == typeof (bool))
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
			else if (val.type() == typeof (DateTime)) {
				jval.str = "\"" + ((DateTime)val).to_string() + "\"";
			}
			else if (val.type().is_a (typeof (Mee.TimeSpan)))
				jval.str = "\"" + ((Mee.TimeSpan)val).to_string() + "\"";
			else if (val.type().is_a (typeof (Json.Node)))
				jval = (Json.Node)val;
			else if (val.type().is_a (typeof (Json.Object)))
				jval.object = (Json.Object)val;
			else if (val.type().is_a (typeof (Json.Array)))
				jval.array = (Json.Array)val;
			else if (val.type() == typeof (string)) {
				string str = (string)val;
				if (!is_valid_string (str))
					throw new Json.Error.INVALID ("invalid string value.\n");
				jval.str = "\"" + str + "\"";
			}
			else
				jval.isnull = true;
			list.add (jval);
			list_changed (size - 1, size, jval);
		}

		public void add_values (GLib.Value[] values) throws GLib.Error {
			foreach (GLib.Value val in values)
				add (val);
		}

		public void add_datetime_element (DateTime date) throws GLib.Error {
			add_string_element (date.to_string());
		}
		
		public void add_timespan_element (Mee.TimeSpan timespan) throws GLib.Error {
			add_string_element (timespan.to_string());
		}
		
		public void add_string_element (string str) throws GLib.Error {
			if (!is_valid_string (str))
				throw new Json.Error.INVALID ("current string isn't valid.\n");
			var val = new Json.Node();
			val.str = "\"%s\"".printf (str);
			add_element (val);
		}

		public void add_array_element (Json.Array array) {
			var val = new Json.Node();
			val.array = array;
			add_element (val);
		}

		public void add_object_element (Json.Object object) {
			var val = new Json.Node();
			val.object = object;
			add_element (val);
		}

		public void add_double_element (double number) {
			var val = new Json.Node();
			val.number = number;
			add_element (val);
		}

		public void add_boolean_element (bool boolean) {
			var val = new Json.Node();
			val.boolean = boolean;
			add_element (val);
		}

		public void add_null_element() {
			var val = new Json.Node();
			val.isnull = true;
			add_element (val);
		}
		
		public void clear() {
			list = new Gee.ArrayList<Json.Node>();
		}

		public delegate void ForeachFunc (Json.Node val);

		public void foreach(ForeachFunc func) {
			for (var i = 0; i < size; i++)
				func (list[i]);
		}
		
		public bool contains (Json.Node node) {
			return index_of (node) != -1;
		}

		public int index_of (Json.Node val) {
			for (var i = 0; i < size; i++)
				if (val.equals (this[i]))
					return i;
			return -1;
		}

		public void insert (int index, Json.Node val) {
			list.insert (index, val);
			list_changed (index, size, val);
		}

		public Json.Node get (int index) throws GLib.Error {
			if (index < 0 || index >= size)
				throw new Json.Error.INVALID ("index is out of bounds.\n");
			return list[index];
		}

		public Json.Array get_array_element (int index) throws GLib.Error {
			var val = this[index];
			if (val.array == null)
				throw new Json.Error.INVALID ("the element isn't an array.\n");
			return val.array;
		}

		public Json.Object get_object_element (int index) throws GLib.Error {
			var val = this[index];
			if (val.object == null)
				throw new Json.Error.INVALID ("the element isn't an object.\n");
			return val.object;
		}

		public double get_double_element (int index) throws GLib.Error {
			var val = this[index];
			if (val.number == null)
				throw new Json.Error.INVALID ("the element isn't a double.\n");
			return val.number;
		}

		public bool get_boolean_element (int index) throws GLib.Error {
			var val = this[index];
			if (val.boolean == null)
				throw new Json.Error.INVALID ("the element isn't a boolean.\n");
			return val.boolean;
		}

		public DateTime get_datetime_element (int index) throws GLib.Error {
			var val = this[index];
			var tv = TimeVal();
			if (val.str == null || !tv.from_iso8601 (val.str))
				throw new Json.Error.INVALID ("the element isn't a datetime.\n");
			return new DateTime.from_timeval_utc (tv);
		}
		
		public Mee.TimeSpan get_timespan_element (int index) throws GLib.Error {
			var val = this[index];
			if (val.str == null || Mee.TimeSpan.try_parse (val.str))
				throw new Json.Error.INVALID ("the element isn't a timespan.\n");
			return Mee.TimeSpan.parse (val.str);
		}

		public string get_string_element (int index) throws GLib.Error {
			var val = this[index];
			if (val.str == null)
				throw new Json.Error.INVALID ("the element isn't a string.\n");
			return val.str;
		}

		public bool get_null_element (int index) throws GLib.Error {
			var val = this[index];
			if (val.isnull != true)
				throw new Json.Error.INVALID ("the element isn't null.\n");
			return true;
		}
		
		public bool remove (Json.Node node) {
			for (var i = 0; i < size; i++)
				if (node.equals (this[i])) {
					list.remove_at (i);
					return true;
				}
			return false;		
		}

		public void remove_element (int index) {
			var val = list.remove_at (index);
			list_changed (index, size, val);
		}

		public void set_element (int index, Json.Node val) throws GLib.Error {
			if (index < 0 || index >= size)
				throw new Json.Error.INVALID ("index is out of bounds.\n");
			list[index] = val;
			list_changed (index, size, val);
		}

		public void set_object_element (int index, Json.Object object) throws GLib.Error {
			var val = new Json.Node();
			val.object = object;
			set_element (index, val);
		}

		public void set_array_element (int index, Json.Array array) throws GLib.Error {
			var val = new Json.Node();
			val.array = array;
			set_element (index, val);
		}
		
		public void set_string_element (int index, string str) throws GLib.Error {
			var val = new Json.Node();
			if (!is_valid_string (str))
				throw new Json.Error.INVALID ("string is invalid.\n");
			val.str = "\"" + str + "\"";
			set_element (index, val);
		}

		public void set_datetime_element (int index, DateTime date) throws GLib.Error {
			set_string_element (index, date.to_string());
		}
		
		public void set_timespan_element (int index, Mee.TimeSpan timespan) throws GLib.Error {
			set_string_element (index, timespan.to_string());
		}

		public void set_double_element (int index, double number) throws GLib.Error {
			var val = new Json.Node();
			val.number = number;
			set_element (index, val);
		}

		public void set_integer_element (int index, int64 integer) throws GLib.Error {
			var val = new Json.Node();
			val.integer = integer;
			set_element (index, val);
		}

		public void set_boolean_element (int index, bool boolean) throws GLib.Error {
			var val = new Json.Node();
			val.boolean = boolean;
			set_element (index, val);
		}

		public void set_null_element (int index) throws GLib.Error {
			var val = new Json.Node();
			val.isnull = true;
			set_element (index, val);
		}
		
		public Json.Array slice (int start, int stop) {
			var array = new Json.Array();
			array.list.add_all (list.slice (start, stop));
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

		public int size {
			get {
				return list.size;
			}
		}
	}
}
