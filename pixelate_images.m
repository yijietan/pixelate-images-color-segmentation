clear all; close all; clc;

[baseName, folder] = uigetfile({'*.jpg;*.png'});
file = fullfile(folder, baseName);
[pathstr,inImgname,ext] = fileparts(file);
img = imread(file);
imshow(img);


numRows = size(img,1);
numCols = size(img,2);

col2rol_ratio = numCols / numRows;

ratio = numRows/ numCols;
% Separate to RGB channel
redChannel = img(:,:,1);
greenChannel = img(:,:,2);
blueChannel = img(:,:,3);

prompt = {'Number of rows in pixels', 'Number of colors'};
title = 'User preferences';
dims = [1 50; 1 50];
definput = {'200', '20'};
answer = inputdlg(prompt,title,dims,definput);

numRows_desired = str2num(answer{1});
noOfColors = str2num(answer{2});
numCols_desired = ceil(col2rol_ratio * numRows_desired);


numRows_ratio = numRows / numRows_desired;
numCols_ratio = numCols / numCols_desired;


img_pixelate = zeros(round(numRows_desired * numRows_ratio), round(numCols_desired * numCols_ratio), 3, 'uint8');
img_spreadsheet = cell(numRows_desired, numCols_desired);


for i = 1:numRows_desired
    for j = 1:numCols_desired
        
        row_idx = floor((i-1)*numRows_ratio) + 1 : floor(i*numRows_ratio);
        
        
        col_idx = floor((j-1)*numCols_ratio) + 1 : floor(j*numCols_ratio);
        
        
        redMean = mean2(redChannel(row_idx,col_idx));
        greenMean = mean2(greenChannel(row_idx,col_idx));
        blueMean = mean2(blueChannel(row_idx,col_idx));
        
        img_pixelate(row_idx,col_idx,1) = redMean;
        
        img_pixelate(row_idx,col_idx,2) = greenMean;
        
        img_pixelate(row_idx,col_idx,3) = blueMean;
        
    end
end

r = img_pixelate(:,:,1);
g = img_pixelate(:,:,2);
b = img_pixelate(:,:,3);
inputImg = zeros((numRows * numCols), 3);
inputImg(:,1) = r(:);
inputImg(:,2) = g(:);
inputImg(:,3) = b(:);
inputImg = double(inputImg);


[idx, C] = kmeans(inputImg, noOfColors, 'EmptyAction', 'singleton');

palette = round(C);
palette_hex = rgb2hex(palette);
palette_hex = cellstr(palette_hex);

%Color Mapping
idx = uint8(idx);
outImg = zeros(numRows,numCols,3);
temp = reshape(idx, [numRows numCols]);
for i = 1 : numRows
    for j = 1 : numCols
        outImg(i,j,:) = palette(temp(i,j),:);
    end
end

for i = 1:numRows_desired
    for j = 1:numCols_desired
        row_idx = floor((i-1)*numRows_ratio) + 1;
        col_idx = floor((j-1)*numCols_ratio) + 1;
        r = outImg(row_idx, col_idx,1);
        g = outImg(row_idx, col_idx,2);
        b = outImg(row_idx, col_idx,3);
        outImg_actual(i,j,:) = [r g b];
        img_spreadsheet{i,j} = rgb2hex([r g b]);
    end
end

colorPercentage = zeros(noOfColors, 1);
for i = 1:noOfColors
    colorPercentage(i) = (nnz(strcmp(img_spreadsheet,palette_hex{i})) / (numRows_desired * numCols_desired)) * 100;
    palette_hex{i,2} = colorPercentage(i);
end
labels = {'Color (hex code)', 'Percentage of pixels'};
palette_hex = [labels;palette_hex];


csv_out_filename = [inImgname, '_', int2str(noOfColors), '_pattern.csv'];
cell2csv(csv_out_filename, cellstr(img_spreadsheet));

outFilename = [inImgname, '_', int2str(noOfColors), '_scaled.bmp'];
imwrite(uint8(outImg), outFilename);
figure;
imshow(uint8(outImg));


paletteText_filename = [inImgname, '_', int2str(noOfColors), '_palette.csv'];
cell2csv(paletteText_filename, palette_hex);

outImg_actual_filename = [inImgname, '_', int2str(noOfColors), '_actual.bmp'];
imwrite(uint8(outImg_actual), outImg_actual_filename);

new_directory_name = [inImgname, '_', int2str(noOfColors)];

status1 = mkdir(new_directory_name);
status2 = movefile(outFilename, new_directory_name);
status3 = movefile(csv_out_filename, new_directory_name);
status4 = movefile(paletteText_filename, new_directory_name);
status5 = movefile(outImg_actual_filename, new_directory_name);