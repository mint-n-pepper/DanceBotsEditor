	Rectangle{
		id: root
		width: 30
		height: 40
		radius: 3
		property alias type: dragPrimitive.type
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.leftMargin: 5
		anchors.bottomMargin: 5

		MotorPrimitive{
			id: dragPrimitive
			type: MotorPrimitive.Type.eStraight
			onTypeChanged: motorPrimitive.updatePrimitive();
		}

		function updatePrimitive(){
			switch(dragPrimitive.type)
			{
				case MotorPrimitive.Type.eSpin:
					typeID.text="Spin";
					break;
				case MotorPrimitive.Type.eStraight:
					typeID.text="Drive Straight";
					break;
				default:
					typeID.text="default";
					break;
			}
		}

		Text
		{
			id: typeID
			Component.onCompleted: motorPrimitive.updatePrimitive();
			text: "Test"
		}
  }