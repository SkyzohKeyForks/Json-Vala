namespace Json {
	/**
	 * An object which collect nodes
	 */
	public class Array : GLib.Object
	{
		Gee.ArrayList<Node> list;

		construct {
			list = new Gee.ArrayList<Node>();
		}

		/**
		 * Constructs a new Json Array , fed with an array of {@link GLib.Value}
		 */
		public Array.wrap (Value[] values)
		{
			this();
			add_all (values);
		}

		internal Array.from_nodes (Node[] nodes)
		{
			list = new Gee.ArrayList<Node>.wrap(nodes);
		}

		/**
		 * Add an anonymous {@link GLib.Value} to this array.
		 * @param val a {@link GLib.Value} to be put into array
		 */
		public void add (Value val)
		{
			if (val.type().is_a(typeof(Node)))	
				add_element ((Node)val.get_object());
			else if (val.type().is_a(typeof(Object)))
				add_object_element ((Object)val.get_object());
			else if (val.type().is_a(typeof(Array)))
				add_array_element ((Array)val.get_object());
			else if (val.type() == typeof(DateTime))
				add_datetime_element ((DateTime)val.get_boxed());
			else if (val.type() == typeof(bool))
				add_boolean_element (val.get_boolean());
			else if (val.type() == typeof(double))
				add_double_element (val.get_double());
			else if (val.type() == typeof(int64))
				add_int_element (val.get_int64());
			else if (val.type() == typeof(uint64))
				add_int_element ((int64)val.get_uint64());
			else if (val.type() == typeof(long))
				add_int_element ((int64)val.get_long());
			else if (val.type() == typeof(ulong))
				add_int_element ((int64)val.get_ulong());
			else if (val.type() == typeof(int))
				add_int_element ((int64)val.get_int());
			else if (val.type() == typeof(uint))
				add_int_element ((int64)val.get_uint());
			else if (val.type() == typeof(string))
				add_string_element (val.get_string());
			else
				add_null_element ();
		}

		/**
		 * Add an array of {@link GLib.Value} to this array.
		 * @param values an array of {@link GLib.Value} to be put into array
		 */
		public void add_all (Value[] values)
		{
			foreach (var gval in values)
				add (gval);
		}

		/**
		 * Add an {@link Array} to this array.
		 * @param val an {@link Array} to be put into array
		 */
		public void add_array_element (Array val)
		{
			add_element (new Node (val.to_string()));
		}

		/**
		 * Add a {@link bool} to this array. 
		 * @param val a {@link bool} to be put into array
		 */
		public void add_boolean_element (bool val)
		{
			add_element (new Node (val.to_string()));
		}

		/**
		 * Add a {@link GLib.DateTime} to this array.
		 * @param val a {@link GLib.DateTime} to be put into array
		 */
		public void add_datetime_element (DateTime val)
		{
			TimeVal tv;
			val.to_timeval (out tv);
			add_string_element (tv.to_iso8601());
		}

		/**
		 * Add a {@link double} to this array.
		 * @param val a {@link double} to be put into array
		 */
		public void add_double_element (double val)
		{
			add_element (new Node (val.to_string()));
		}
		
		/**
		 * Add an {@link int64} to this array.
		 * @param val an {@link int64} to be put into array
		 */
		public void add_int_element (int64 val)
		{
			var n = new Node (val.to_string());
			add_element (n);
		}

		/**
		 * Add a {@link Node} to this array.
		 * @param node a {@link Node} to be put into array
		 */
		public void add_element (Node node)
		{
			list.add (node);
		}
		/**
		 * Add a null element to this array.
		 */
		public void add_null_element ()
		{
			add_element (new Node ("null"));
		}
		/**
		 * Add an {@link Object} to this array.
		 * @param val an {@link Object} to be put into array
		 */
		public void add_object_element (Object val)
		{
			add_element (new Node (val.to_string()));
		}
		/**
		 * Add a {@link string} to this array.
		 * @param val a {@link string} to be put into array
		 */
		public void add_string_element (string val)
		{
			try {
				get_valid_id ("\""+val+"\"");
				add_element (new Node ("\""+val+"\""));
			} catch {

			}
		}
		/**
		 * pretty print of current array.
		 * @param indent level of indentation.
		 * 
		 * @return the string representation of current array.
		 */
		public string dump(int indent = 0){
			if(list.size == 0)
				return "[]";
			string ind = "";
			for(var i = 0; i < indent; i++)
				ind += "\t";
			string s = "["+ind+"\n";
			for (var i = 0; i < list.size - 1; i++)
				s += ind+"\t"+list[i].dump (indent+1) + " ,\n";
			s += ind+"\t"+list[list.size - 1].dump (indent+1)+"\n";
			s += ind+"]";
			return s;
		}

		public new Node get (int index)
		{
			if (index < 0 || index >= list.size)
				return new Node("null");
			return list[index];
		}

		public Array? get_array_element (int index)
		{
			var node = get_element (index);
			if (node == null)
				return null;
			return node.as_array();
		}

		public bool get_boolean_element (int index)
		{
			var node = get_element (index);
			if (node == null)
				return false;
			return node.as_boolean();
		}

		public DateTime? get_datetime_element (int index)
		{
			var node = get_element (index);
			if (node == null)
				return null;
			return node.as_datetime();
		}

		public double get_double_element (int index)
		{
			var node = get_element (index);
			if (node == null)
				return -1;
			return node.as_double();
		}

		public Node? get_element (int index)
		{
			return this[index];
		}

		public int64 get_int_element (int index)
		{
			var node = get_element (index);
			if (node == null)
				return -1;
			return node.as_int();
		}

		public bool get_null_element (int index)
		{
			var node = get_element (index);
			if (node == null)
				return false;
			return node.is_null();
		}

		public Object? get_object_element (int index)
		{
			var node = get_element (index);
			if (node == null)
				return null;
			return node.as_object();
		}

		public string? get_string_element (int index)
		{
			var node = get_element (index);
			if (node == null)
				return null;
			return node.as_string();
		}

		public void remove_at (int index)
		{
			list.remove_at (index);
		}

		public new void set (int index, Value val)
		{
			if (val.type().is_a(typeof(Node)))	
				set_element (index, (Node)val.get_object());
			else if (val.type().is_a(typeof(Object)))
				set_object_element (index, (Object)val.get_object());
			else if (val.type().is_a(typeof(Array)))
				set_array_element (index, (Array)val.get_object());
			else if (val.type() == typeof(DateTime))
				set_datetime_element (index, (DateTime)val.get_boxed());
			else if (val.type() == typeof(bool))
				set_boolean_element (index, val.get_boolean());
			else if (val.type() == typeof(double))
				set_double_element (index, val.get_double());
			else if (val.type() == typeof(int64))
				set_int_element (index, val.get_int64());
			else if (val.type() == typeof(uint64))
				set_int_element (index, (int64)val.get_uint64());
			else if (val.type() == typeof(long))
				set_int_element (index, (int64)val.get_long());
			else if (val.type() == typeof(ulong))
				set_int_element (index, (int64)val.get_ulong());
			else if (val.type() == typeof(int))
				set_int_element (index, (int64)val.get_int());
			else if (val.type() == typeof(uint))
				set_int_element (index, (int64)val.get_uint());
			else if (val.type() == typeof(string))
				set_string_element (index, val.get_string());
			else
				set_null_element (index);
		}

		public void set_array_element (int index, Array val)
		{
			set_element (index, new Node (val.to_string()));
		}

		public void set_boolean_element (int index, bool val)
		{
			set_element (index, new Node (val.to_string()));
		}

		public void set_datetime_element (int index, DateTime val)
		{
			TimeVal tv;
			val.to_timeval (out tv);
			set_string_element (index, tv.to_iso8601());
		}

		public void set_double_element (int index, double val)
		{
			set_element (index, new Node (val.to_string()));
		}

		public void set_element (int index, Node node)
		{
			if (index < 0 || index >= list.size)
				return;
			list[index] = node;
		}

		public void set_int_element (int index, int64 val)
		{
			set_element (index, new Node (val.to_string()));
		}

		public void set_null_element (int index)
		{
			set_element (index, new Node ("null"));
		}

		public void set_object_element (int index, Object val)
		{
			set_element (index, new Node (val.to_string()));
		}

		public void set_string_element (int index, string val)
		{
			try {
				get_valid_id ("\""+val+"\"");
				set_element (index, new Node (val.to_string()));
			} catch {}
		}

		public Array slice (int start, int stop)
		{
			var array = new Array();
			foreach (Node node in list.slice (start, stop))
				array.add_element (node);
			return array;
		}
		
		public string to_string()
		{
			if (list.size == 0)
				return "[]";
			string s = "[ ";
			for (var i = 0; i < list.size - 1; i++)
				s += list[i].to_string()+", ";
			s += list[list.size - 1].to_string()+" ]";
			return s;
		}

		public int size {
			get {
				return list.size;
			}
		}

		public static Array parse (string data) throws GLib.Error
		{
			int pos = 0;
			return parse_internal (data, ref pos);
		}

		internal static Array parse_internal (string str, ref int position) throws GLib.Error
		{
			var array = new Array();
			while (str[position].isspace())
				position++;
			if (str[position] != '[')
				throw new JsonError.NOT_FOUND ("'[' character can't be found.");
			position++;
			while (str[position].isspace())
				position++;
			if (str[position] == ']')
			{
				position++;
				while (str[position].isspace())
					position++;
				return array;
			}
			while (position < str.length)
			{
				if (str[position] == '[')
					array.add (new Node (Array.parse_internal (str, ref position).to_string ()));
				else if (str[position] == '{')
					array.add (new Node (Object.parse_internal (str, ref position).to_string ()));
				else if (str[position] == '"' || str[position] == '\'')
				{
					var id = get_valid_id (str, position);
					position += id.length + 2;
					while (str[position].isspace())
						position++;
					array.add (new Node ("\"%s\"".printf (id)));
				}
				else
				{
					int a = str.index_of ("]", position);
					int b = str.index_of (",", position);
					int c = b < a && b != -1 ? b : a;
					if(c == -1)
						throw new JsonError.NOT_FOUND ("end of element not found");
					while (str[position].isspace())
						position++;
					var val = str.substring (position, c - position);
					position += val.length;
					while (val[val.length - 1].isspace())
						val = val.substring (0, val.length - 1);
					if(val != "false" && val != "true" && val != "null"){
						double d = -1;
						if(double.try_parse (val,out d) == false){
							print ("pos: %lld / %lld\n", position, str.length);
							throw new JsonError.TYPE ("invalid value (%s)".printf (str.substring (position)));
						}
					}
					array.add(new Node (val));
					while (str[position].isspace())
						position++;
				}
				if(str[position] != ',' && str[position] != ']')
					throw new JsonError.TYPE ("invalid end of element : "+str);
					bool end = (str[position] == ']') ? true : false;
					position ++;
					while (str[position].isspace())
						position++;
					if (end)
						break;
			}
			return array;
		}
	}
}
