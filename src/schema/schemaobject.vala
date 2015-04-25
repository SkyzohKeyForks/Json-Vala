namespace MeeJsonSchema {
	public class SchemaObject : Schema {
		public SchemaObject() {
			GLib.Object (schema_type: SchemaType.OBJECT);
		}
		
		construct {
			props = new HashTable<string, Schema> (str_hash, str_equal);
			deps = new HashTable<string, GLib.Value?> (str_hash, str_equal);
			pattern_properties = new HashTable<Regex, Schema>(null, null);
		}
		
		public uint64? max_properties { get; set; }
		public uint64? min_properties { get; set; }
		
		public GLib.Value additional_properties { get; set; }
		
		HashTable<string, GLib.Value?> deps;
		
		public HashTable<string, GLib.Value?> dependencies {
			owned get {
				return deps;
			}
			set {
				value.foreach ((name, val) => {
					if (MeeJson.is_valid_string (name))
						deps[name] = val;
				});
			}
		}
		
		public HashTable<Regex, Schema> pattern_properties { get; set; }
		
		HashTable<string, Schema> props;
		
		public HashTable<string, Schema> properties {
			owned get {
				return props;
			}
			set {
				value.foreach ((name, val) => {
					if (MeeJson.is_valid_string (name))
						props[name] = val;
				});
			}
		}
		
		string[] req;
		
		public string[] required {
			owned get {
				return req;
			}
			set {
				req = new string[0];
				foreach (string str in value)
					if (MeeJson.is_valid_string (str))
						req += str;
			}
		}
	}
}
