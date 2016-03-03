namespace JsonSchema {
	public enum SchemaType {
		NULL,
		ARRAY,
		BOOLEAN,
		INTEGER,
		NUMBER,
		OBJECT,
		STRING;
		
		public string to_string() {
			var strv = new string[]{"null", "array", "boolean", "integer", "number", "object", "string"};
			return strv[(int)this];
		}
	}
	
	public class Schema : GLib.Object {
		string _title;
		string _description;
		
		public string description {
			owned get {
				return _description;
			}
			set {
				_description = Json.is_valid_string (value) ? value : null;
			}
		}
		
		public string title {
			owned get {
				return _title;
			}
			set {
				_title = Json.is_valid_string (value) ? value : null;
			}
		}
		
		public Set @enum { get; set; }
	
		public SchemaType schema_type { get; set construct; }
	
		[Version (experimental = true, experimental_until = "1.6")]
		public static Schema parse (string data) throws GLib.Error {
			var object = Json.Object.parse (data);
			Schema schema = parse_schema (object);
			if (object.has_key ("title") && object["title"].is_string())
				schema.title = object["title"].as_string();
			if (object.has_key ("description") && object["description"].is_string())
				schema.description = object["description"].as_string();
			return schema;
		}
		
		static Schema parse_schema (Json.Object object) throws GLib.Error {
			Schema schema = null;
			if (object["type"] != null) {
				if (object["type"].as_string() == "array")
					schema = parse_array (object);
				else if (object["type"].as_string() == "object")
					schema = parse_object (object);
				else if (object["type"].as_string() == "boolean")
					schema = parse_boolean (object);
				else if (object["type"].as_string() == "integer")
					schema = parse_integer (object);
				else if (object["type"].as_string() == "number")
					schema = parse_number (object);
				else if (object["type"].as_string() == "string")
					schema = parse_string (object);
				else
					throw new SchemaError.INVALID ("invalid object type (%s).".printf (object["type"].as_string()));
			}
			if (object["enum"] != null) {
				
			}
			return schema;
		}
		
		static Schema parse_number (Json.Object object) throws GLib.Error {
			var schema = new SchemaNumber();
			if (object.has_key ("multipleOf")) {
				if (!object["multipleOf"].is_double())
					throw new SchemaError.INVALID ("invalid type for 'multipleOf'.");
				schema.multiple_of = object["multipleOf"].as_double();
			}
			if (object.has_key ("maximum")) {
				if (!object["maximum"].is_double())
					throw new SchemaError.INVALID ("invalid type for 'maximum'.");
				schema.maximum = object["maximum"].as_double();
			}
			if (object.has_key ("exclusiveMaximum")) {
				if (!object["exclusiveMaximum"].is_boolean())
					throw new SchemaError.INVALID ("invalid type for 'exclusiveMaximum'.");
				schema.exclusive_maximum = object["exclusiveMaximum"].as_boolean();
			}
			if (object.has_key ("minimum")) {
				if (!object["minimum"].is_double())
					throw new SchemaError.INVALID ("invalid type for 'minimum'.");
				schema.minimum = object["minimum"].as_double();
			}
			if (object.has_key ("exclusiveMinimum")) {
				if (!object["exclusiveMinimum"].is_boolean())
					throw new SchemaError.INVALID ("invalid type for 'exclusiveMinimum'.");
				schema.exclusive_minimum = object["exclusiveMinimum"].as_boolean();
			}
			return schema;
		}
		
		static Schema parse_integer (Json.Object object) throws GLib.Error {
			var schema = new SchemaInteger();
			if (object.has_key ("multipleOf")) {
				if (!object["multipleOf"].is_integer())
					throw new SchemaError.INVALID ("invalid type for 'multipleOf'.");
				schema.multiple_of = object["multipleOf"].as_integer();
			}
			if (object.has_key ("maximum")) {
				if (!object["maximum"].is_integer())
					throw new SchemaError.INVALID ("invalid type for 'maximum'.");
				schema.maximum = object["maximum"].as_integer();
			}
			if (object.has_key ("exclusiveMaximum")) {
				if (!object["exclusiveMaximum"].is_boolean())
					throw new SchemaError.INVALID ("invalid type for 'exclusiveMaximum'.");
				schema.exclusive_maximum = object["exclusiveMaximum"].as_boolean();
			}
			if (object.has_key ("minimum")) {
				if (!object["minimum"].is_integer())
					throw new SchemaError.INVALID ("invalid type for 'minimum'.");
				schema.minimum = object["minimum"].as_integer();
			}
			if (object.has_key ("exclusiveMinimum")) {
				if (!object["exclusiveMinimum"].is_boolean())
					throw new SchemaError.INVALID ("invalid type for 'exclusiveMinimum'.");
				schema.exclusive_minimum = object["exclusiveMinimum"].as_boolean();
			}
			return schema;
		}
		
		static Schema parse_string (Json.Object object) throws GLib.Error {
			var schema = new SchemaString();
			if (object.has_key ("maxLength")) {
				if (!object["maxLength"].is_integer())
					throw new SchemaError.INVALID ("invalid type for 'maxLength'.");
				schema.max_length = (uint64)object["maxLength"].as_integer();
			}
			if (object.has_key ("minLength")) {
				if (!object["minLength"].is_integer())
					throw new SchemaError.INVALID ("invalid type for 'minLength'.");
				schema.min_length = (uint64)object["minLength"].as_integer();
			}
			if (object.has_key ("pattern")) {
				if (!object["pattern"].is_string())
					throw new SchemaError.INVALID ("invalid type for 'minLength'.");
				schema.pattern = new Regex (object["pattern"].as_string());
			}
			return schema;
		}
		
		static Schema parse_boolean (Json.Object object) {
			return new SchemaBoolean();
		}
		
		static SchemaArray parse_array (Json.Object object) throws GLib.Error {
			var schema = new SchemaArray();
			if (!object.has_key ("items"))
				throw new SchemaError.INVALID ("can't find items object.");
			if (object["items"].is_object())
				schema.items = parse_schema (object["items"].as_object());
			if (object["items"].is_array()) {
				var slist = new SchemaList();
				object["items"].as_array().foreach (node => {
					if (!node.is_object())
						throw new SchemaError.INVALID ("current node is invalid.");
					slist.add (parse_schema (node.as_object()));
				});
				schema.items = slist;
			}
			if (object.has_key ("additionalItems")) {
				if (object["additionalItems"].is_boolean())
					schema.additional_items = object["additionalItems"].as_boolean();
				else if (object["additionalItems"].is_object())
					schema.additional_items = parse_schema (object["additionalItems"].as_object());
				else throw new SchemaError.INVALID ("invalid type for 'additionalItems'.");
			}
			if (object.has_key ("maxItems"))
				if (!object["maxItems"].is_integer()) 
					throw new SchemaError.INVALID ("invalid type for 'maxItems'.");
				else
					schema.max_items = (uint64)object["maxItems"].as_integer();
			if (object.has_key ("minItems"))
				if (!object["minItems"].is_integer()) 
					throw new SchemaError.INVALID ("invalid type for 'minItems'.");
				else
					schema.min_items = (uint64)object["minItems"].as_integer();
			if (object.has_key ("uniqueItems"))
				if (!object["uniqueItems"].is_boolean()) 
					throw new SchemaError.INVALID ("invalid type for 'uniqueItems'.");
				else
					schema.unique_items = object["uniqueItems"].as_boolean();
			return schema;
		}
		
		static SchemaObject parse_object (Json.Object object) throws GLib.Error {
			var schema = new SchemaObject();
			if (object.has_key ("maxProperties"))
				if(!object["maxProperties"].is_integer())
					throw new SchemaError.INVALID ("invalid type for 'maxProperties'.");
				else
					schema.max_properties = (uint64)object["maxProperties"].as_integer();
			if (object.has_key ("minProperties"))
				if(!object["minProperties"].is_integer())
					throw new SchemaError.INVALID ("invalid type for 'minProperties'.");
				else
					schema.min_properties = (uint64)object["minProperties"].as_integer();
			if (object.has_key ("required")) {
				if (!object["required"].is_array())
					throw new SchemaError.INVALID ("invalid type for 'required'.");
				string[] req = new string[0];
				object["required"].as_array().foreach (node => {
					if (!node.is_string())
						throw new SchemaError.INVALID ("current node is invalid.");
					if (node.as_string() in req)
						throw new SchemaError.INVALID ("current string is already in required values.");
					req += node.as_string();
				});
				schema.required = req;
			}
			if (object.has_key ("additionalProperties")) {
				if (object["additionalProperties"].is_boolean())
					schema.additional_properties = object["additionalProperties"].as_boolean();
				else if (object["additionalProperties"].is_object())
					schema.additional_properties = parse_schema (object["additionalProperties"].as_object());
				else throw new SchemaError.INVALID ("invalid type for 'additionalProperties'.");
			}
			if (object.has_key ("properties")) {
				if (!object["properties"].is_object())
					throw new SchemaError.INVALID ("invalid type for 'properties'.");
				object["properties"].as_object().foreach_member ((name, value) => {
					if (!value.is_object())
						throw new SchemaError.INVALID ("invalid type for current property.");
					schema.properties[name] = parse_schema (value.as_object());
				});
			}
			if (object.has_key ("patternProperties")) {
				if (!object["patternProperties"].is_object())
					throw new SchemaError.INVALID ("invalid type for 'patternProperties'.");
				object["patternProperties"].as_object().foreach_member ((name, value) => {
					if (!value.is_object())
						throw new SchemaError.INVALID ("invalid type for current property.");
					schema.pattern_properties[new Regex (name)] = parse_schema (value.as_object());
				});
			}
			if (object.has_key ("dependencies")) {
				if (!object["dependencies"].is_object())
					throw new SchemaError.INVALID ("invalid type for 'dependencies'.");
				object["dependencies"].as_object().foreach_member ((name, value) => {
					if (value.is_array() && value.as_array().is_unique == Json.NodeType.STRING) {
						string[] deps = new string[0];
						value.as_array().foreach (node => {
							deps += node.as_string();
						});
						schema.dependencies[name] = deps;
					}
					else if (value.is_object())
						schema.dependencies[name] = parse_schema (value.as_object());
					else
						throw new SchemaError.INVALID ("invalid type for current dependency.");
				});
			}
			return schema;
		}
	}
	
	public errordomain SchemaError {
		NONE,
		INVALID
	}
}
