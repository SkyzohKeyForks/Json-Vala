namespace MeeJson {
	public interface Item : GLib.Object {
		public abstract MeeJson.Node get (GLib.Value val);
		public abstract void foreach (Func<Item> func);
		
		public abstract GLib.Value value { owned get; }
	}
	
	public class Property : GLib.Object, Item {
		public Property (string id, MeeJson.Node val) {
			this.identifier = id;
			this.node_value = val;
		}
		
		public void foreach (Func<Item> func) {
			node_value.foreach (func);
		}
		
		public MeeJson.Node get (GLib.Value val) {
			return node_value[val];
		}

		public string identifier { get; private set; }
		public MeeJson.Node node_value { get; private set; }
		public GLib.Value value {
			owned get {
				return node_value.value;
			}
		}
		public MeeJson.NodeType node_type {
			get {
				return node_value.node_type;
			}
		}
	}
}
