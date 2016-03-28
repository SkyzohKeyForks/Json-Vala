namespace Json {
	public static Json.Node serialize (GLib.Value value) {
		if (value.type().is_a (typeof (Gee.Map))) {
			var map = (Gee.Map)value;
			return new Json.Node (serialize_map (map));
		}
		if (value.type().is_a (typeof (Gee.Traversable))) {
			var t = (Gee.Traversable)value;
			return new Json.Node (serialize_traversable (t));
		}
		if (value.type().is_object())
			return new Json.Node (gobject_to_object ((GLib.Object)value));
		if (value.type() == typeof (string[])) {
			string[] strv = (string[])value;
			var array = new Json.Array();
			foreach (string str in strv)
				array.add (str);
			return new Json.Node (array);
		}
		return new Json.Node();
	}
	
	static Json.Object serialize_map (Gee.Map map) {
		var ktype = map.keys.element_type;
		var vtype = map.values.element_type;
		var object = new Json.Object();
		if (ktype != typeof (string))
			return object;
		map.foreach (entry => {
			string key = (string)entry.key;
			if (vtype == typeof (bool)) {
				object.set (key, (bool)entry.value);
			} else if (vtype == typeof (char)) {
				object.set (key, (char)entry.value);
			} else if (vtype == typeof (uchar)) {
				object.set (key, (uchar)entry.value);
			} else if (vtype == typeof (int)) {
				object.set (key, (int)entry.value);
			} else if (vtype == typeof (uint)) {
				object.set (key, (uint)entry.value);
			} else if (vtype == typeof (int64)) {
				object.set (key, (int64)entry.value);
			} else if (vtype == typeof (uint64)) {
				object.set (key, (uint64)entry.value);
			} else if (vtype == typeof (long)) {
				object.set (key, (long)entry.value);
			} else if (vtype == typeof (ulong)) {
				object.set (key, (ulong)entry.value);
			} else if (vtype == typeof (float)) {
				float? f = (float?)entry.value;
				if (f != null)
					object.set (key, (float)f);
			} else if (vtype == typeof (double)) {
				double? d = (double?)entry.value;
				if (d != null)
					object.set (key, (double)d);
			} else if (vtype.is_a (typeof (Json.Object))) {
				object.set (key, (Json.Object)entry.value);
			} else if (vtype.is_a (typeof (Json.Array))) {
				object.set (key, (Json.Array)entry.value);
			} else if (vtype.is_a (typeof (Json.Node))) {
				object.set (key, (Json.Node)entry.value);
			} else if (vtype == typeof (Regex)) {
				object.set (key, (Regex)entry.value);
			} else if (vtype == typeof (DateTime)) {
				object.set (key, (DateTime)entry.value);
			} else if (vtype == typeof (Bytes)) {
				object.set (key, (Bytes)entry.value);
			} else if (vtype == typeof (ByteArray)) {
				object.set (key, (ByteArray)entry.value);
			} else if (vtype.is_object()) {
				object.set (key, serialize ((GLib.Object)entry.value));
			} else
				object.set (key, new Json.Node());
			return true;
		});
		return object;
	}
	
	static Json.Array serialize_traversable (Gee.Traversable<void*> traversable) {
		var t = traversable.element_type;
		var array = new Json.Array();
		traversable.foreach (data => {
			if (t == typeof (bool)) {
				array.add ((bool)data);
			} else if (t == typeof (char)) {
				array.add ((char)data);
			} else if (t == typeof (uchar)) {
				array.add ((uchar)data);
			} else if (t == typeof (int)) {
				array.add ((int)data);
			} else if (t == typeof (uint)) {
				array.add ((uint)data);
			} else if (t == typeof (int64)) {
				array.add ((int64)data);
			} else if (t == typeof (uint64)) {
				array.add ((uint64)data);
			} else if (t == typeof (long)) {
				array.add ((long)data);
			} else if (t == typeof (ulong)) {
				array.add ((ulong)data);
			} else if (t == typeof (float)) {
				float? f = (float?)data;
				if (f != null)
					array.add ((float)f);
			} else if (t == typeof (double)) {
				double? d = (double?)data;
				if (d != null)
					array.add ((double)d);
			} else if (t.is_a (typeof (Json.Object))) {
				array.add ((Json.Object)data);
			} else if (t.is_a (typeof (Json.Array))) {
				array.add ((Json.Array)data);
			} else if (t.is_a (typeof (Json.Node))) {
				array.add ((Json.Node)data);
			} else if (t == typeof (Regex)) {
				array.add ((Regex)data);
			} else if (t == typeof (DateTime)) {
				array.add ((DateTime)data);
			} else if (t == typeof (Bytes)) {
				array.add ((Bytes)data);
			} else if (t == typeof (ByteArray)) {
				array.add ((ByteArray)data);
			} else if (t.is_object()) {
				array.add (serialize ((GLib.Object)data));
			} else
				array.add (new Json.Node());
			return true;
		});
		return array;
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
