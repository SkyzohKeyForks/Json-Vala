namespace MeeJson {
	
	internal static MeeJson.Object serialize_jobject (GLib.Object object) throws GLib.Error {
		var jobject = new MeeJson.Object();
		var klass = (ObjectClass)object.get_type().class_ref();
		foreach (var spec in klass.list_properties()) {
			GLib.Value val = GLib.Value (spec.value_type);
			object.get_property (spec.name, ref val);
			if (val.type().is_a (typeof (GLib.Object)))
				jobject.set_object_member (spec.name, serialize_jobject ((GLib.Object)val));
			else
				jobject.set_member (spec.name, new MeeJson.Node (val));
		}
		return jobject;
	}
	
	public static void serialize_object (Writer writer, GLib.Object object) throws GLib.Error {
		writer.write_object (serialize_jobject (object));
	}
	
	public static void serialize_json (Writer writer, Object object) throws GLib.Error {
		writer.write_object (object);
	}

	public static void serialize<T> (Writer writer, T object) throws GLib.Error {
		if (typeof (T).is_object())
			serialize_object (writer, (GLib.Object)object);
	}
	
	public static T deserialize_bson<T> (uint8[] bson) throws GLib.Error {
		var mis = new MemoryInputStream.from_data (bson, null);
		var reader = new MeeJson.Bson.Reader (mis);
		return deserialize<T> (reader);
	}
	
	public static T deserialize_json<T> (string json) throws GLib.Error {
		return deserialize<T> (new TextReader (new Mee.StringReader (json)));
	}
	
	public static T deserialize<T> (Reader reader) throws GLib.Error {
		if (typeof (T).is_object())
			return deserialize_object (typeof (T), reader);
		if (typeof (T) == typeof (string[])) {
			var array = reader.read_array();
			string[] strv = new string[array.size];
			for (var i = 0; i < array.size; i++)
				strv[i] = array.get_string_element (i);
			return strv;
		}
		return null;
	}
	
	public static GLib.Object deserialize_object (Type object_type, Reader reader) throws GLib.Error {
		var jobject = reader.read_object();
		var object = GLib.Object.new (object_type);
		var klass = (ObjectClass)object_type.class_ref ();
		jobject.foreach (prop => {
			var spec = klass.find_property (prop.identifier);
			if (spec == null)
				throw new MeeJson.Error.NOT_FOUND ("property wasn't found for required object.\n");
			if (prop.node_type == NodeType.OBJECT)
				object.set_property (spec.name, deserialize_object (spec.value_type, new TextReader (new Mee.StringReader (prop.value.to_string()))));
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
		});
		return object;
	}
}
