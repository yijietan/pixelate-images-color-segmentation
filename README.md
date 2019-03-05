# pixelate-images-color-segmentation
This MATLAB script pixelates an image by taking the mean RGB values of neighboring pixels to obtain the desired number of rows while maintaining aspect ratio. Then, the pixelated image is segmented based on a specified number of colors in RGB space via K-Means clustering. 

A .csv file is produced where each cell corresponds to the color of the pixel in HEX code. This can be useful for general crafting purposes, such as for cross-stich or pixel art. A text file is generated with the list of colors used in HEX code. In addition, an image with a 10x10 pixel grid is also generated for reference purposes. 

The main file is pixelate_images.m and requires cell2csv.m (by Rob Kohr) and rgb2hex.m (by Chad Greene) to run. Both files were obtained from MATLAB central. 

For users without MATLAB, there is a web installer (pixelate_images_web.exe) to install the main executable and the relevant MATLAB compiler runtime.
