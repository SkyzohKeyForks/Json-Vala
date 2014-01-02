namespace Json {
	[Experimental]
	public class Path : GLib.Object
	{
		public signal void evaluation_started ();
		public signal void evaluation_stopped ();
		public signal void evaluation_finished ();
		
		public Path (Json.Node node)
		{
			GLib.Object (root: node);
		}
		
		public void eval (string path)
		{
			result = new Json.Array ();
			evaluation_started ();
			if (path[0] != '$')
			{
				evaluation_stopped ();
				return;
			}
			string tmp = path.substring (1);
			result = process (ref tmp, root);
			evaluation_finished ();
		}
		
		Array process (ref string query, Node node)
		{
			Array res = new Array ();
					string sub = null;
			
			if (query[0] == '.')
			{
				if (query.length > 2 && query[1] == '.')
				{
					string q = query.substring (2, query.index_of (".", 2) - 2);
					if (q.contains ("["))
					{
						q = query.substring (2, query.index_of ("[", 2) - 2);
						query = query.substring (q.length + 2);
						sub = query.substring (1, query.index_of ("]") - 1);
						query = query.substring (query.index_of ("]")+1);
					}
					var array = node.get_nodes (q);
					if (sub != null)
					{
						int64 i;
						if (int64.try_parse (sub, out i))
							res.add_element (array[(int)i]);
						else if (sub.contains (":"))
						{
							int a = (int)int64.parse (sub.split(":")[0]);
							int b = (int)int64.parse (sub.split(":")[1]);
							res = array[a:b];
						}
					}
					else
						res = array;
					if (query.length == 0)
						return res;
					string new_query = query;
					array = new Array();
					foreach (var nsub in res)
						foreach (var nnsub in process (ref new_query, nsub))
							array.add_element (nnsub);
					res = array;
				}
				else
				{
					string q = query.substring (1, query.index_of (".", 1) - 1);
					query = query.substring (q.length + 1);
					if (q.contains ("["))
					{
						q = query.substring (1, query.index_of ("[", 1) - 1);
						query = query.substring (q.length + 1);
						sub = query.substring (1, query.index_of ("]") - 1);
						query = query.substring (query.index_of ("]")+1);
					}
					var array = new Array();
					if (node.is_object ())
					{
						if (node.as_object ().get_member (q) == null)
							return new Array();
						array.add_element (node.as_object ().get_member (q));
					}
					else if (node.is_array ())
					{
						int64 i;
						if (!int64.try_parse (q, out i))
							return new Array();
						array.add_element (node.as_array ()[(int)i]);
					}
					if (sub != null)
					{
						int64 i;
						if (int64.try_parse (sub, out i) && array[0].is_array())
							res.add_element (array[0].as_array()[(int)i]);
					}
					else res = array;
					string new_query = query;
					if (query.length == 0 || res.size == 0)
						return res;
					res = process (ref new_query, res[0]);
				}
			}
			return res;
		}
		
		public Node root { private get; construct; }
		
		public Array result { get; private set; }
	}
}