namespace Json {
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
}
