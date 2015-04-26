namespace MeeJson.Bson {
	public class Writer : MeeJson.Writer {
		OutputStream output_stream;
		
		public Writer (OutputStream stream) {
			output_stream = stream;
		}
		
		public override void write_array (MeeJson.Array array) {
			output_stream.write (write_array2 (array).data);
		}
		
		public override void write_object (MeeJson.Object object) {
			output_stream.write (write_object2 (object).data);
		}
		
		internal ByteArray write_array2 (MeeJson.Array array) {
			var barray = new ByteArray();
			for (var j = 0; j < array.size; j++) {
				var node = array[j];
				if (node.node_type == NodeType.NULL)
					barray.append ({ElementType.NULL});
				if (node.node_type == NodeType.ARRAY)
					barray.append ({ElementType.ARRAY});
				if (node.node_type == NodeType.OBJECT)
					barray.append ({ElementType.DOCUMENT});
				if (node.node_type == NodeType.DATETIME)
					barray.append ({ElementType.DATETIME});
				if (node.node_type == NodeType.DOUBLE)
					barray.append ({ElementType.DOUBLE});
				if (node.node_type == NodeType.INTEGER)
					barray.append ({ElementType.INT64});
				if (node.node_type == NodeType.REGEX)
					barray.append ({ElementType.REGEX});
				if (node.node_type == NodeType.BOOLEAN)
					barray.append ({ElementType.BOOLEAN});
				if (node.node_type == NodeType.STRING)
					barray.append ({ElementType.STRING});
				string str = j.to_string();
				uint8[] data = new uint8[str.length + 1];
				for (var i = 0; i < str.length; i++)
					data[i] = str.data[i];
				barray.append (data);
				if (node.node_type == NodeType.ARRAY)
					barray.append (write_array2 (node.array).data);
				if (node.node_type == NodeType.OBJECT)
					barray.append (write_object2 (node.object).data);
				if (node.node_type == NodeType.DATETIME) {
					TimeVal tv;
					var datetime = node.as_datetime();
					datetime.to_timeval (out tv);
					int64 msec = tv.tv_sec * 1000 + tv.tv_usec / 1000;
					data = new uint8[8];
					for (var i = 0; i < data.length; i++)
						data[i] = (uint8)(&msec)[i];
					barray.append (data);
				}
				if (node.node_type == NodeType.DOUBLE) {
					double val = node.as_double();
					barray.append (Mee.BitConverter.get_bytes<double?> (val));
				}
				if (node.node_type == NodeType.INTEGER) {
					data = new uint8[8];
					int64 val = node.as_int();
					for (var i = 0; i < data.length; i++)
						data[i] = (uint8)(&val)[i];
					barray.append (data);
				}
				if (node.node_type == NodeType.STRING) {
					data = new uint8[4];
					int val = node.as_string().length + 1;
					for (var i = 0; i < data.length; i++)
						data[i] = (uint8)(&val)[i];
					barray.append (data);
					data = new uint8[node.as_string().length + 1];
					for (var i = 0; i < node.as_string().length; i++)
						data[i] = node.as_string().data[i];
					barray.append (data);
				}
				if (node.node_type == NodeType.REGEX) {
					data = new uint8[4];
					Regex r = (Regex)node.value;
					int val = r.get_pattern().length + 1;
					for (var i = 0; i < data.length; i++)
						data[i] = (uint8)(&val)[i];
					barray.append (data);
					data = new uint8[r.get_pattern().length + 1];
					for (var i = 0; i < r.get_pattern().length; i++)
						data[i] = r.get_pattern().data[i];
					barray.append (data);
				}
				if (node.node_type == NodeType.BOOLEAN) {
					data = new uint8[1];
					data[0] = node.as_boolean() == true ? 1 : 0;
					barray.append (data);
				}
			}
			barray.append ({0});
			int size = 4 + barray.data.length;
			barray.prepend (Mee.BitConverter.get_bytes<int> (size));
			return barray;
		}
	
	
		internal ByteArray write_object2 (MeeJson.Object object) {
			var barray = new ByteArray();
			object.foreach (prop => {
				if (prop.node_type == NodeType.NULL)
					barray.append ({ElementType.NULL});
				if (prop.node_type == NodeType.ARRAY)
					barray.append ({ElementType.ARRAY});
				if (prop.node_type == NodeType.OBJECT)
					barray.append ({ElementType.DOCUMENT});
				if (prop.node_type == NodeType.DATETIME)
					barray.append ({ElementType.DATETIME});
				if (prop.node_type == NodeType.DOUBLE)
					barray.append ({ElementType.DOUBLE});
				if (prop.node_type == NodeType.INTEGER)
					barray.append ({ElementType.INT64});
				if (prop.node_type == NodeType.REGEX)
					barray.append ({ElementType.REGEX});
				if (prop.node_type == NodeType.BOOLEAN)
					barray.append ({ElementType.BOOLEAN});
				if (prop.node_type == NodeType.STRING)
					barray.append ({ElementType.STRING});
				uint8[] data = new uint8[prop.identifier.length + 1];
				for (var i = 0; i < prop.identifier.length; i++)
					data[i] = prop.identifier.data[i];
				barray.append (data);
				if (prop.node_type == NodeType.ARRAY)
					barray.append (write_array2 (prop.value.array).data);
				if (prop.node_type == NodeType.OBJECT)
					barray.append (write_object2 (prop.value.object).data);
				if (prop.node_type == NodeType.DATETIME) {
					TimeVal tv;
					var datetime = prop.value.as_datetime();
					datetime.to_timeval (out tv);
					int64 msec = tv.tv_sec * 1000 + tv.tv_usec / 1000;
					data = new uint8[8];;
					for (var i = 0; i < data.length; i++)
						data[i] = (uint8)(&msec)[i];
					barray.append (data);
				}
				if (prop.node_type == NodeType.DOUBLE) {
					double val = prop.value.as_double();
					barray.append (Mee.BitConverter.get_bytes<double?> (val));
				}
				if (prop.node_type == NodeType.INTEGER) {
					data = new uint8[8];
					int64 val = prop.value.as_int();
					for (var i = 0; i < data.length; i++)
						data[i] = (uint8)(&val)[i];
					barray.append (data);
				}
				if (prop.node_type == NodeType.STRING) {
					data = new uint8[4];
					int val = prop.value.as_string().length + 1;
					for (var i = 0; i < data.length; i++)
						data[i] = (uint8)(&val)[i];
					barray.append (data);
					data = new uint8[prop.value.as_string().length + 1];
					for (var i = 0; i < prop.value.as_string().length; i++)
						data[i] = prop.value.as_string().data[i];
					barray.append (data);
				}
				if (prop.node_type == NodeType.REGEX) {
					data = new uint8[4];
					Regex r = (Regex)prop.value;
					int val = r.get_pattern().length + 1;
					for (var i = 0; i < data.length; i++)
						data[i] = (uint8)(&val)[i];
					barray.append (data);
					data = new uint8[r.get_pattern().length + 1];
					for (var i = 0; i < r.get_pattern().length; i++)
						data[i] = r.get_pattern().data[i];
					barray.append (data);
				}
				if (prop.node_type == NodeType.BOOLEAN) {
					data = new uint8[1];
					data[0] = prop.value.as_boolean() == true ? 1 : 0;
					barray.append (data);
				}
			});
			barray.append ({0});
			int size = 4 + barray.data.length;
			barray.prepend (Mee.BitConverter.get_bytes<int> (size));
			return barray;
		}
	
	}
}
