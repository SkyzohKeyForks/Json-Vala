namespace Json {
	public class Reader : GLib.Object
	{
		Node root;
		int pos;
		
		construct {
			pos = 0;
		}
		
		public bool is_array ()
		{
			if (root == null || !root.is_array ())
				return false;
			return true;
		}
		
		public bool is_object ()
		{
			if (root == null || !root.is_object ())
				return false;
			return true;
		}
		
		public bool is_value ()
		{
			return is_array() == false && is_object() == false;
		}
		
		public void set_root (Node node)
		{
			root = node;
		}
		
		public bool read_element (int position)
		{
			if (is_value())
				return false;
			if (is_array())
				if (position < 0 || position >= root.as_array().size)
					return false;
			if (position < 0 || position >= root.as_object().get_keys().size)
				return false;
			pos = position;
			return true;
		}
		
		public bool read_member (string name)
		{
			if (!is_object())
				return false;
			var member = root.as_object().get_member (name);
			if (member == null)
				return false;
			for (var i = 0; i < root.as_object().get_keys().size; i++)
				if (root.as_object().get_keys().to_array()[i] == name)
					pos = i;
			return true;
		}
		
		public string[] list_members()
		{
			if (!is_object())
				return null;
			return root.as_object().get_keys().to_array();
		}
		
		public string get_member_name ()
		{
			if (!is_object())
				return null;
			return list_members()[pos];
		}
		
		public Node get_value ()
		{
			if (is_object())
				return root.as_object().get_members().to_array()[pos];
			if (is_array())
				return root.as_array()[pos];
			return root;
		}
		
		public string get_string_value()
		{
			return get_value().as_string();
		}
		
		public bool get_null_value()
		{
			return get_value().is_null();
		}
		
		public int64 get_int_value ()
		{
			return get_value().as_int();
		}
		
		public double get_double_value()
		{
			return get_value().as_double();
		}
		
		public bool get_boolean_value()
		{
			return get_value().as_bool();
		}
	}
}
