namespace Json {
	
	public static GLib.Object deserialize_object (Type object_type, string data) throws GLib.Error
	{
		var o = Object.parse (data);
		var object = GLib.Object.new (object_type);
		var klass = (ObjectClass)object_type.class_ref ();
		for (var index = 0; index < o.size; index++){
			string key = o.keys[index];
			Node node = o.values[index];
			var spec = klass.find_property (key);
			var oval = Value (spec.value_type);
			if (spec == null)
				throw new JsonError.NOT_FOUND ("property wasn't found for required object.");
			if (node.is_object())
				object.set_property (key, deserialize_object(spec.value_type, node.to_string()));
			if (node.is_array())
			{
				var array = node.as_array();
				if (spec.value_type == typeof (string[]))
				{
					string[] str_array = new string[array.size];
					for (var i = 0; i < array.size; i++)
						str_array[i] = array[i].as_string();
					oval.set_boxed (str_array);
				}
				else if (spec.value_type.is_a (typeof (Gee.ArrayList)))
				{
					
				}
				object.set_property (key, oval);
			}
			if (node.is_int())
				object.set_property (key, node.as_int());
			if (node.is_double())
				object.set_property (key, node.as_double());
			if (node.is_datetime())
				object.set_property (key, node.as_datetime());
			if (node.is_boolean())
				object.set_property (key, node.as_boolean());
			if (node.is_string())
				object.set_property (key, node.as_string());
		};

		return object;
	}

	
	public static string serialize (GLib.Object object)
	{
		var klass = (ObjectClass)object.get_type().class_ref();
		var o = new Json.Object();
		foreach (ParamSpec spec in klass.list_properties())
		{
			GLib.Value val = GLib.Value(spec.value_type);
			object.get_property (spec.name, ref val);
			if (spec.value_type.is_a (typeof(Gee.Iterable)))
			{
				var iterable = (Gee.Iterable)val.get_object();
				o[spec.name] = new Node(serialize_array (iterable));
			}
			else if (spec.value_type.is_object())
				o[spec.name] = new Json.Node (serialize (val.get_object()));
			else if (spec.value_type == typeof(string[]))
			{
				string[] array = (string[])val.get_boxed();
				var jarray = new Json.Array();
				foreach (string str in array)
					jarray.add (str);
				o[spec.name] = jarray;
			}
			else o[spec.name] = val;
		}
		return o.dump();
	}

	public static string serialize_array (Gee.Iterable t)
	{
		string s = "[";
		if (t.element_type.is_a (typeof(DateTime)))
			foreach (var dt in (t as Gee.Iterable<DateTime>))
				s += dt.to_string() + ", ";
		if (t.element_type.is_a (typeof(Json.Object)))
			foreach (var o in (t as Gee.Iterable<Json.Object>))
				s += o.to_string() + ", ";
		if (t.element_type.is_a (typeof(Json.Array)))
			foreach (var a in (t as Gee.Iterable<Json.Array>))
				s += a.to_string() + ", ";
		if (t.element_type.is_a (typeof(Json.Node)))
			foreach (var n in (t as Gee.Iterable<Json.Node>))
				s += n.to_string() + ", ";
		if (t.element_type == typeof (bool))
			foreach (bool b in (t as Gee.Iterable<bool>))
				s += b.to_string() + ", ";
		if (t.element_type == typeof (string))
			foreach (string str in (t as Gee.Iterable<string>))
			{
				try {
					get_valid_id ("'"+str+"'");
					s += "'"+str+"'" + ", ";
				} catch {
					s += "null, ";
				}
			}
		if (t.element_type == typeof (int) || t.element_type == typeof (uint))
			foreach (int i in (t as Gee.Iterable<int>))
				s += i.to_string() + ", ";
		if (t.element_type == typeof (int64) || t.element_type == typeof (uint64))
			foreach (int64? i in (t as Gee.Iterable<int64?>))
				s += i.to_string() + ", ";
		if (t.element_type == typeof (long) || t.element_type == typeof (ulong))
			foreach (long l in (t as Gee.Iterable<long>))
				s += l.to_string() + ", ";
		if (t.element_type == typeof (double) || t.element_type == typeof (float))
			foreach (double? d in (t as Gee.Iterable<double?>))
				s += d.to_string()+", ";
		return s.substring (0, s.length - 2) + "]";
	}
}
