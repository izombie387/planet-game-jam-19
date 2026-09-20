extends Node
# http.gd (Autoload)

const DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1532828959404986578/pEKkWSNSW3wz0hhYs95U6Bpmk5wfyEFFJ0d8z913o4TGgkcXXkgt87wZxfpMeRNj_SiC"
const USER_DATA_PATH = "user://user_info.json"

@onready var http_request: HTTPRequest = HTTPRequest.new()

var user_id: String = ""

func _ready() -> void:
	add_child(http_request)
	http_request.timeout = 8.0
	user_id = load_or_create_user_id()

func load_or_create_user_id() -> String:
	if FileAccess.file_exists(USER_DATA_PATH):
		var file = FileAccess.open(USER_DATA_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		file.close()
		if data and data.has("user_id"):
			return data["user_id"]
	
	var new_id = Crypto.new().generate_random_bytes(16).hex_encode()
	save_user_id(new_id)
	return new_id

func save_user_id(id_to_save: String) -> void:
	var file : FileAccess = FileAccess.open(USER_DATA_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"user_id": id_to_save}))
	file.close()

func _process_result(result: Array) -> Error:
	match result:
		[var status, var code, var _headers, var body]:
			# Result checks if network transport worked (e.g., DNS error, no internet)
			if status != HTTPRequest.RESULT_SUCCESS:
				print("Network transport error code: ", status)
				return ERR_CANT_CONNECT

			print("HTTP Response Code: ", code)

			# 200 or 204 means Discord accepted it successfully!
			if code == 200 or code == 204:
				print("Successfully sent to Discord!")
				return OK
			else:
				# Parse Discord's exact error message
				var response_text = body.get_string_from_utf8()
				print("Discord rejected request! Error details:")
				print(response_text)
				return ERR_CANT_CONNECT
		_:
			return ERR_CANT_CONNECT
		
#func _dict_to_fields(dict: Dictionary) -> Array[Dictionary]:
	#var fields: Array[Dictionary]
	#for key in dict:
		#var value = dict[key]
		#if value is Dictionary:
			#fields.append_array(_dict_to_fields(value))
		#else:
			#var entry = {
				#"name": str(key),
				#"value": str(value) if str(value) != "" else "N/A", # Ensure non-empty string,
				#"inline": false,
			#}
			#fields.append(entry)
	#return fields

func send_feedback(feedback: Dictionary) -> Error:
	var headers = ["Content-Type: application/json"]
	
	#var fields := _dict_to_fields(feedback)
	feedback["uid"] = user_id.left(8)
	var string_dict = JSON.stringify(feedback, "\t")
	var payload = {
	  "content": string_dict,
	}
	var json_body = JSON.stringify(payload)
	var error = http_request.request(DISCORD_WEBHOOK_URL, headers, HTTPClient.METHOD_POST, json_body)
	
	if error != OK:
		print("Failed to send telemetry to Discord: ", error)
		return error
	else:
		return _process_result(await http_request.request_completed)
		
		
		
