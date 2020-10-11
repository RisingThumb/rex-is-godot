extends Node2D

func _ready():
	var rex = readOffXPData("res://XPFiles/TEST!.xp")
	print(rex.get("layerCount"))

func readOffXPData(fileName):
	var decompressedFileName = "res://decompressFile.xp"
	var file = File.new()

	# Read the compressed xp file for its buffer
	# This is a workaround as open_compressed doesn't work with .xp files
	file.open(fileName, file.READ)
	var length = file.get_len()
	var buffer = file.get_buffer(length)
	var newbuffer = PoolByteArray()
	var filled = true
	file.close()

	# Perform decompression and save it to a temporary file
	file.open(decompressedFileName, file.WRITE_READ)

	# We don't know the decompressed file size so we iterate towards it with a multiplier
	var i = 4
	while (newbuffer.size() <= 0):
		newbuffer = buffer.decompress(length*i, File.COMPRESSION_GZIP)
		i*=2
	
	file.store_buffer(newbuffer)
	file.close()

	# Open the file normally
	file.open(decompressedFileName, file.READ)
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
	var dir = Directory.new()
	dir.remove(decompressedFileName)
	return rexImage
