extends Node2D


func _ready():
	print(File.COMPRESSION_DEFLATE)
	print(File.COMPRESSION_FASTLZ)
	print(File.COMPRESSION_GZIP)
	print(File.COMPRESSION_ZSTD)
	var rex = readOffXPData("res://XPFiles/TEST!.xp")
	print(rex.get("versionInfo"))

func fixHeader(fileName):
	var file = File.new()
	file.open(fileName, File.READ)
	var length = file.get_len()
	var buffer = file.get_buffer(length)
	file.close()
	file.open(fileName+".rex", File.WRITE_READ)
	file.store_32(0x46504347)
	# FastLZ = 0
	# Deflate = 1
	# ZSTD = 2
	# Gzip = 3
	file.store_32(0x00000003) # compression method
	file.store_32(0x00001000)
	file.store_32(length*16)
	file.store_32(length)
	file.store_buffer(buffer)
	file.store_32(0x00000000)
	file.store_32(0x46504347)
	file.close()
	pass

func readOffXPData(fileName):
	fixHeader(fileName)
	var file = File.new()
	#file.open(fileName, File.READ)
	file.open_compressed(fileName+".rex", File.READ, File.COMPRESSION_GZIP)
	var rexImage = {}
	var versionInfo = file.get_32()
	rexImage["versionInfo"] = versionInfo
	var numberOfLayers = file.get_32()
	rexImage["layerCount"] = numberOfLayers
	rexImage["layers"] = []
	while !file.eof_reached():
		var height = file.get_32()
		var width = file.get_32()
		var layerData = {	"height": height,
							"width": width,
							"image": []}
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
				fgC.a = 1
				bgC.a = 1
				if bgC.r8 == 255 and bgC.g8 == 0 and bgC.b8 == 255: # Undrawn cell, background of 255, 0, 255 means transparent
					bgC.a = 0
				var characterData = {"ascii": asciicode,
									"foregroundColour": fgC,
									"backgroundColour": bgC}
				layerData.get("image").append(characterData)
	file.close()
	return rexImage
