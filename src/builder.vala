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
			if (!is_valid_id (name))
				return false;
			member = name;
			return true;
		}
		
		bool add (Mee.Value value)
		{
			if (levels.size == 0)
				return false;
			if (levels[levels.size - 1] == "array"){
				str += value.val+",";
				return true;
			}
			if (member == null)
				return false;
			str += """"%s":%s,""".printf(member,value.val);
			return true;
		}
		
		public bool add_boolean (bool value)
		{
			return add (new Mee.Value (value.to_string()));
		}
		
		public bool add_double (double value)
		{
			return add (new Mee.Value (((float)value).to_string()));	
		}
		
		public bool add_int (int64 value)
		{
			return add (new Mee.Value (value.to_string()));
		}
		
		public bool add_null ()
		{
			return add (new Mee.Value ("null"));
		}
		
		public bool add_string (string value)
		{
			try {
				valid_string (""""%s"""".printf(value));
				return add (new Mee.Value (""""%s"""".printf(value)));
			} catch {
				return false;
			}
		}
		
		public bool add_value (GLib.Value value)
		{
			var mval = new Mee.Value.from_gval (value);
			if (value.type() == typeof(string))
				return add_string (mval.val);
			return add (mval);
		}
		
		public bool add_node (Node value)
		{
			return add (new Mee.Value (value.to_string()));
		}
		
		public Node? root {
			owned get {
				var node = new Node (str.substring(0, str.length-1));
				if (!node.is_object() && !node.is_array())
					return null;
				return node;
			}
		}
	}
}
