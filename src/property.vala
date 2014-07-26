namespace Json {
	public class Property {
		public Property (string id, Json.Node val) {
			this.identifier = id;
			this.value = val;
		}

		public string identifier { get; private set; }
		public Json.Node value { get; private set; }
		public Json.NodeType node_type {
			get {
				return this.value.node_type;
			}
		}
	}
}