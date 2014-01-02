namespace Json {
	public class Builder : GLib.Object
	{
		string str;
		string? member;
		Gee.ArrayList<string> levels;
		
		construct {
			str = "";
			levels = new Gee.ArrayList<string>();
		}
		
		public Json.Node? root {
			owned get {
				var parser = new Parser();
				try {
					parser.load_from_data (str);
					return parser.root;
				} catch {
					return null;
				}
			}
		}
		
		public void begin_array ()
		{
			if (levels.size > 0 && levels[levels.size - 1] == "object")
			{
				if (member == null)
					return;
				str += """"%s":""".printf(member);
			}
			str += "[";
			levels.add ("array");
		}
		
		public void end_array ()
		{
			if (levels.size == 0 || levels[levels.size - 1] != "array")
				return;
			if (str[str.length-1] == ',')
				str = str.substring (0, str.length - 1);
			str += "],";
			levels.remove_at (levels.size - 1);
		}
		
		public void begin_object ()
		{
			if (levels.size > 0 && levels[levels.size - 1] == "object")
			{
				if (member == null)
					return;
				str += """"%s":""".printf(member);
			}
			str += "{";
			levels.add ("object");
		}
		
		public void end_object ()
		{
			if (levels.size == 0 || levels[levels.size - 1] != "object")
				return;
			if (str[str.length-1] == ',')
				str = str.substring (0, str.length - 1);
			str += "},";
			levels.remove_at (levels.size - 1);
		}
		
		public bool set_member_name (string name)
		{
			try {
				var id = get_valid_id (new Mee.Text.String(name));
				member = id;
				return true;
			}
			catch {
				return false;
			}
		}
		
		public bool add (Value val)
		{
			if (val.type().is_a(typeof(Node)))	
				return add_node ((Node)val.get_object());
			if (val.type().is_a(typeof(Object)))
				return add_object ((Object)val.get_object());
			if (val.type().is_a(typeof(Array)))
				return add_array ((Array)val.get_object());
			if (val.type() == typeof(bool))
				return add_boolean (val.get_boolean());
			if (val.type() == typeof(double))
				return add_double (val.get_double());
			if (val.type() == typeof(int64))
				return add_int (val.get_int64());
			if (val.type() == typeof(uint64))
				return add_int ((int64)val.get_uint64());
			if (val.type() == typeof(long))
				return add_int ((int64)val.get_long());
			if (val.type() == typeof(ulong))
				return add_int ((int64)val.get_ulong());
			if (val.type() == typeof(int))
				return add_int ((int64)val.get_int());
			if (val.type() == typeof(uint))
				return add_int ((int64)val.get_uint());
			if (val.type() == typeof(string))
				return add_string (val.get_string());
			return add_null ();
		}

		public bool add_node (Node node)
		{
			if (levels.size == 0)
				return false;
			if (levels[levels.size - 1] == "array"){
				str += node.to_string()+",";
				return true;
			}
			if (member == null)
				return false;
			str += @"'$member' : '$node',";
			return true;
		}

		public bool add_array (Array array)
		{
			return add_node ( new Node (@"$array"));
		}

		public bool add_object (Object object)
		{
			return add_node ( new Node (@"$object"));
		}

		public bool add_boolean (bool val)
		{
			return add_node ( new Node (@"$val"));
		}

		public bool add_double (double val)
		{
			return add_node ( new Node (@"$((float)val)"));
		}

		public bool add_int (int64 val)
		{
			return add_node ( new Node (@"$val"));
		}

		public bool add_null ()
		{
			return add_node ( new Node ("null"));
		}

		public bool add_string (string val)
		{
			return add_node ( new Node (@"$val"));
		}
	}
}
