namespace Json {
	
	internal static Json.Object serialize_object (GLib.Object object) throws GLib.Error {
		var jobject = new Json.Object();
		var klass = (ObjectClass)object.get_type().class_ref();
		foreach (var spec in klass.list_properties()) {
			GLib.Value val = GLib.Value (spec.value_type);
			object.get_property (spec.name, ref val);
			if (val.type().is_a (typeof (GLib.Object)))
				jobject.set_object_member (spec.name, serialize_object ((GLib.Object)val));
			else
				jobject.set_member (spec.name, new Json.Node (val));
		}
		return jobject;
	}
	
	public static string serialize (GLib.Object object, bool pretty = false) throws GLib.Error {
		return serialize_object (object).to_data (1, '\t', pretty);
	}

	public static T deserialize<T> (string json) throws GLib.Error {
		if (typeof (T).is_object())
			return deserialize_object (typeof (T), json);
		if (typeof (T) == typeof (string[])) {
			var array = Json.Array.parse (json);
			string[] str_array = new string[array.size];
			for (var i = 0; i < array.size; i++)
				str_array[i] = (string)array[i].value;
			return str_array;
		}
		return null;
	}

	public static GLib.Object deserialize_object (Type object_type, string json) throws GLib.Error {
		var jobject = Json.Object.parse (json);
		var object = GLib.Object.new (object_type);
		var klass = (ObjectClass)object_type.class_ref ();
		for (var i = 0; i < jobject.size; i++) {
			var prop = jobject.properties[i];
			var spec = klass.find_property (prop.identifier);
			if (spec == null)
				throw new Json.Error.NOT_FOUND ("property wasn't found for required object.\n");
			if (prop.node_type == NodeType.OBJECT)
				object.set_property (spec.name, deserialize_object (spec.value_type, prop.value.to_string()));
			else if (prop.node_type == NodeType.ARRAY) {
				if (spec.value_type == typeof (string[])) {
					string[] strv = new string[0];
					prop.value.as_array().foreach (anode => {
						strv += anode.as_string();
					});
					object.set_property (spec.name, strv);
				}
					
			}
			else if (prop.node_type == NodeType.INTEGER)
				object.set_property (spec.name, prop.value.as_int());
			else if (prop.node_type == NodeType.DOUBLE)
				object.set_property (spec.name, prop.value.as_double());
			else if (prop.node_type == NodeType.DATETIME)
				object.set_property (spec.name, prop.value.as_datetime());
			else if (prop.node_type == NodeType.TIMESPAN)
				object.set_property (spec.name, prop.value.as_timespan());
			else if (prop.node_type == NodeType.GUID)
				object.set_property (spec.name, prop.value.as_guid());
			else if (prop.node_type == NodeType.BOOLEAN)
				object.set_property (spec.name, prop.value.as_boolean());
			else if (prop.node_type == NodeType.STRING)
				object.set_property (spec.name, prop.value.as_string());
		}
		return object;
	}
}
