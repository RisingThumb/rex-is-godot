# Rex is Godot
This is a utility project for utilising the .xp binary file format that is the output of Rexpaint.

Currently it doesn't work for .xp files out of the box. You must first unzip them via gzip before use in your project.

# Documentation

This includes a single scene with a single script and a single decompressed .xp file as an example.

The script has a function `readOffXPData`. Copy this into your project as necessary.

#### Parameters
- fileName, A string path to the XP file

#### Expected Output:
- Dictionary with following keys:
    - "versionInfo" Integer, with a value relating to the .xp versionInfo information.
    - "layerCount" Integer, with a value that is the total number of layers
    - "layers": Array of type Dict, with a value that is an array of dictionarys. Each index corresponds with a layer. Below is an example dictionary with keys.
        - "height" : Integer,  Height in cells of the layer
        - "width" : Integer, Width in cells of the layer
        - "image" : Array of type Dict, 1D array of all the characters in your array. A character's positioned is found with the formula (x*height + y). Below is an example dictionary of character's keys
            - "asciicode" : Integer, Asciicode that corresponds with your font png.
            - "foregroundColor" : Color. Corresponds with RGBA of the glyph. Alpha value will always be 1. Use an empty glyph if if you want no alpha.
            - "backgroundColor" : Color, Corresponds with RGBA of the background. Alpha value will be 0 IF the RGB value is 255 0 255, otherwise it will be 1.

#### Sample output taken from the .xp file included:
```
{layerCount:1,
layers:[
        {height:10,
        image:[{ascii:84,
                backgroundColour:0.101961,0.078431,0.05098,1,
                foregroundColour:1,0.2,0.2,1}, ... ]
        width:10}]
versionInfo: 4294967295}
```
