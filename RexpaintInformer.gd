extends Node2D


func _ready():
	var rex = readOffXPDate("res://XPFiles/uncompressed.xp")
	print(rex.get("layers")[0].get("image")[0].get("ascii"))

func readOffXPDate(fileName):
	var file = File.new()
	file.open(fileName, File.READ)
	var rexImage = {}
	var versionInfo = file.get_32()
	rexImage["versionInfo"] = versionInfo
	var numberOfLayers = file.get_32()
	rexImage["layerCount"] = numberOfLayers
	rexImage["layers"] = []
	var layers = 0
	while !file.eof_reached():
		var height = file.get_32()
		var width = file.get_32()
		var layerData = {"height": height, "width": width, "image": []}
		rexImage["layers"].append(layerData)
		for x in width: # It's encoded vertical line by line(top to bottom then left to right)
			for y in height:
				file.endian_swap = false # little endian
				var asciicode = file.get_32()
				file.endian_swap = false
				var fgC = Color()
				fgC.r8 = file.get_8()
				fgC.g8 = file.get_8()
				fgC.b8 = file.get_8()
				var bgC = Color()
				bgC.r8 = file.get_8()
				bgC.g8 = file.get_8()
				bgC.b8 = file.get_8()
				if bgC.r8 == 255 and bgC.g8 == 0 and bgC.b8 == 255: # Undrawn cell, background of 255, 0, 255 means transparent
					fgC.a = 0
					bgC.a = 0
				else:
					fgC.a = 1
					bgC.a = 1
				var characterData = {"ascii": asciicode, "foregroundColour": fgC, "backgroundColour": bgC}
				layerData.get("image").append(characterData)
	file.close()
	return rexImage
