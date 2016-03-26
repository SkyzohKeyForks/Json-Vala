namespace Json {
	public static Json.Node serialize<T> (T value) {
		if (typeof (T).is_object())
			return new Json.Node (gobject_to_object ((GLib.Object)value));
		return new Json.Node();
	}
	
	public static Json.Object gobject_to_object (GLib.Object obj) {
		Json.Object result = new Json.Object();
		var klass = (ObjectClass)obj.get_type().class_ref();
		foreach (var spec in klass.list_properties()) {
			GLib.Value value = GLib.Value (spec.value_type);
			obj.get_property (spec.name, ref value);
			if (spec.value_type.is_object())
				result[spec.name] = gobject_to_object ((GLib.Object)value);
			else
				result[spec.name] = value;
		}
		return result;
	}
	
	public errordomain SerializeError {
		NULL,
		TYPE
	}
	
	public static T deserialize<T> (Json.Object object) throws GLib.Error {
		return object_to_gobject (typeof (T), object);
	}
	
	public static GLib.Object object_to_gobject (Type type, Json.Object object) throws GLib.Error {
		if (!type.is_object())
			throw new SerializeError.TYPE ("object_to_gobject : type isn't object");
		var obj = GLib.Object.new (type);
		var klass = (ObjectClass)type.class_ref();
		foreach (var spec in klass.list_properties()) {
			var val = object[spec.name].value;
			if (spec.value_type.is_object())
				obj.set (spec.name, object_to_gobject (spec.value_type, object[spec.name].as_object()));
			else
				obj.set_property (spec.name, val);
		}
		return obj;
	}
}
