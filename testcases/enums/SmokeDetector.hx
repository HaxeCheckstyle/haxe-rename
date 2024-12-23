package enums;

enum abstract SmokeDetector(String) from String to String {
	var Staircase = "zigbee.0.0000000000000000";
	var Bedroom1 = "zigbee.1.0000000000000000";
	var Hallway1 = "zigbee.2.0000000000000000";
	var Office = "zigbee.3.0000000000000000";
	var LivingRoom = "zigbee.4.0000000000000000";

	public inline function available():String {
		return '${this}.available';
	}
}
