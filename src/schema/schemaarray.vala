namespace MeeJsonSchema {
	public class SchemaArray : Schema {
		public SchemaArray() {
			GLib.Object (schema_type: SchemaType.ARRAY);
		}
		
		public GLib.Value additional_items { get; set; }
		public GLib.Value items { get; set; }
		public uint64? max_items { get; set; }
		public uint64? min_items { get; set; }
		public bool unique_items { get; set; }
	}
	
	public class Set : MeeJson.Array {
		GLib.Type value_type;
		
		public new void add (GLib.Value val) {
			if (value_type != val.type())
				return;
			if (val in this)
				return;
			value_type = val.type();
			base.add (val);
		}
	}
	
	public class SchemaList : GLib.Object {
		GenericArray<Schema> schemas;
		
		construct {
			schemas = new GenericArray<Schema>();
		}
		
		public void add (Schema schema) {
			schemas.add (schema);
		}
		
		public void clear() {
			schemas = new GenericArray<Schema>();
		}
		
		public new Schema get (uint index) {
			return schemas[index];
		}
		
		public uint size {
			get {
				return schemas.length;
			}
		}
	}
}
