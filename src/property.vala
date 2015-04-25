namespace MeeJson {
	public class Property {
		public Property (string id, MeeJson.Node val) {
			this.identifier = id;
			this.value = val;
		}

		public string identifier { get; private set; }
		public MeeJson.Node value { get; private set; }
		public MeeJson.NodeType node_type {
			get {
				return this.value.node_type;
			}
		}
	}
}
