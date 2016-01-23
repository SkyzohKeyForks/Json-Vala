namespace Json {
	public class Array : GLib.Object {
		GenericArray<Json.Node> list;

		construct {
			list = new GenericArray<Json.Node>();
		}
		
		public static Array from_values (GLib.Value[] values) {
			var array = new Array();
			foreach (var value in values)
				array.add (value);
			return array;
		}
		
		public static Array from_strv (string[] strv) {
			var array = new Array();
			foreach (var value in strv)
				array.add (value);
			return array;
		}

		public static Array parse (string json) {
			try {
				var parser = new Json.Parser();
				parser.load_from_data (json);
				if (parser.root.node_type == NodeType.ARRAY)
					return parser.root.array;
				return new Json.Array();
			} catch {
				return new Json.Array();
			}
		}
		
		public void add (GLib.Value value) {
			list.add (new Json.Node (value));
		}

		public void add_element (Json.Node node) {
			list.add (node);
		}

		public void add_boolean_element (bool value) {
			list.add (new Json.Node (value));
		}

		public void add_integer_element (int64 value) {
			list.add (new Json.Node (value));
		}

		public void add_double_element (double value) {
			list.add (new Json.Node (value));
		}

		public void add_string_element (string value) {
			list.add (new Json.Node (value));
		}

		public void add_array_element (Json.Array value) {
			list.add (new Json.Node (value));
		}

		public void add_object_element (Json.Object value) {
			list.add (new Json.Node (value));
		}
		
		public void add_datetime_element (DateTime value) {
			list.add (new Json.Node (value));
		}
		
		public void add_regex_element (Regex value) {
			list.add (new Json.Node (value));
		}

		public void add_null_element() {
			list.add (new Json.Node());
		}
		
		public bool contains (GLib.Value value) {
			return index_of (value) >= 0;
		}
		
		public int index_of (GLib.Value value) {
			var node = new Json.Node (value);
			for (var i = 0; i < size; i++)
				if (list[i].equal (node))
					return i;
			return -1;
		}

		public bool equal (Json.Array array) {
			if (size != array.size)
				return false;
			for (var i = 0; i < size; i++)
				if (!list[i].equal (array.get_element (i)))
					return false;
			return true;
		}
		
		public delegate void ForeachFunc (Json.Node node);
		
		public void foreach (ForeachFunc func) {
			list.foreach (data => {
				func ((Json.Node)data);
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
			if (i >= list.length)
				return new Json.Node();
			return list[i];
		}

		public new Json.Node get_element (int index) {
			if (index < 0 || index >= list.length)
				return new Json.Node();
			return list[index];
		}

		public bool get_boolean_element (int index) {
			return get_element (index).as_boolean();
		}

		public double get_double_element (int index) {
			return get_element (index).as_double();
		}

		public int64 get_integer_element (int index) {
			return get_element (index).as_integer();
		}

		public string get_string_element (int index) {
			return get_element (index).as_string();
		}

		public Json.Array get_array_element (int index) {
			return get_element (index).as_array();
		}

		public Json.Object get_object_element (int index) {
			return get_element (index).as_object();
		}

		public DateTime get_datetime_element (int index) {
			return get_element (index).as_datetime();
		}

		public Regex get_regex_element (int index) {
			return get_element (index).as_regex();
		}

		public bool get_null_element (int index) {
			return get_element (index).isnull;
		}

		public void set_element (int index, Json.Node node) {
			if (index >= 0 && index < list.length)
				list[index] = node;
		}

		public void set_boolean_element (int index, bool value) {
			set_element (index, new Json.Node (value));
		}

		public void set_double_element (int index, double value) {
			set_element (index, new Json.Node (value));
		}

		public void set_string_element (int index, string value) {
			set_element (index, new Json.Node (value));
		}

		public void set_integer_element (int index, int64 value) {
			set_element (index, new Json.Node (value));
		}

		public void set_null_element (int index) {
			set_element (index, new Json.Node ());
		}

		public void set_object_element (int index, Json.Object value) {
			set_element (index, new Json.Node (value));
		}

		public void set_array_element (int index, Json.Array value) {
			set_element (index, new Json.Node (value));
		}

		public void set_datetime_element (int index, DateTime value) {
			set_element (index, new Json.Node (value));
		}

		public void set_regex_element (int index, Regex value) {
			set_element (index, new Json.Node (value));
		}

		public string to_string() {
			if (list.length == 0)
				return "[]";
			string result = "[ ";
			for (var i = 0; i < list.length - 1; i++)
				result += list[i].to_string() + ", ";
			result += list[list.length - 1].to_string() + " ]";
			return result;
		}

		public int size {
			get {
				return list.length;
			}
		}
		
		public NodeType is_unique {
			get {
				if (list.length == 0)	
					return NodeType.NULL;
				var nt = list[0].node_type;
				for (var i = 1; i < list.length; i++)
					if (list[i].node_type != nt)
						return NodeType.NULL;
				return nt;
			}
		}
	}
}
