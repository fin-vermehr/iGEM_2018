%% Clearing variables and figures from previous runs

close all;
clear;
clc;

%% Selecting batch and iterating images

% Specifying the folder where the files live.
imageFolder = 'C:\Users\prans\MATLAB Drive\Image Processing\iGEM 2018\Test Images';

% Specifying the number of batches.
numBatches = 1;

% Preallocate and initialize the Batch structure.
Batch = repmat(struct('batchPattern', []), numBatches, 1);

% Error handling - check to make sure that folder actually exists.
if ~isdir(imageFolder)
  errorMessage = sprintf('Error: The following folder does not exist:\n%s',...
      imageFolder);
  uiwait(warndlg(errorMessage));
  return;
end

% Iterating through batches.
for i = 1 : numBatches
    
    % Getting a list of all image files in the folder.
    Batch(i).batchPattern = fullfile(imageFolder, '*.jpg');
    Batch(i).batchFiles = dir(Batch(i).batchPattern);
    
    %sort batch images by datenum. start from the lowest to the highest.
    
    Batch(i).imageName = extractField(Batch(i).batchFiles, 'name');
    Batch(i).fullImageName = fullfile(imageFolder, imageName);
    fprintf('Now reading %s\n', imageName);
    Batch(i).imageArray = imread(Batch(i).fullImageName);
    %originalImage = rgb2gray(originalImage);
    
    % Display image and forcing it to update immediately.
    imshow(Batch(i).imageArray);
    drawnow;

%% Ground detection

%% Color area(s) detection

%% Centroid (net displacement) calculation

%% Addition of data point to the displacement graph

%% Curve fitting

%% Reporting fitted parameters for each batch

end
%% Reporting mean of fitted parameters

%% Custom functions

% Extracting the field as an array from a struct array
function fieldArray = extractField(batchFiles, fieldName)
    fieldArray = zeros(length(batchFiles), 1);
    for i = 1 : length(batchFiles)
        fieldArray(i) = batchFiles(i).(fieldName);
    end
end