function ClusterInf = RunBatch(image_folder, VALIDATE)
%image_folder is folder containing your image(s), dont put file name at the
%end (ex: 'C:/Users/user/my_images')
%VALIDATE is a boolean flag for displaying plots that look pretty and or
%are useful for debugging
if ~isdir(image_folder)
    errorMessage = sprintf('Error: The following folder does not exist:\n%s',...
        image_folder);
    uiwait(warndlg(errorMessage));
    return;
end

batch_dir = dir(image_folder); %directory struct with images
batch_dir = batch_dir(~ismember({batch_dir.name},{'.','..'})); %remove these non-file entries
num_images = size(batch_dir,1); %number of images contained in folder (assuming nothing else stored here)

%bands = cell(1,num_images); %will later store row and column of pixel we identify in each picture as our pixel of interest
%heights = zeros(1, num_images); %will later store conversion of pixel location to height in lab frame
%MAX = zeros(1, num_images);

positions = cell(1, num_images); %for each image there will be a set of objects resulting from the segmentation and labelling for which positions will be stored
LabeledImages = cell(1,num_images); %store labelled in images in cell array
NumObjects = zeros(1,num_images); %for each image we will store the number of objects identified by segmentation and labelling
for i = 1:num_images
    fname = batch_dir(i).name; %name of current frame
    fname = strcat(image_folder,'\',fname); %constructing fullpath
    I = imread(fname); %get pixel data for current frame

    if i==1
        figure;
        title('Crop out graduated cylinder ensuring bottom is bottom of cylinder');
        hold on;
        [J,rect] = imcrop(I); %on first iteration will open an interactive cropping tool
        hold off;
    else
        J = imcrop(I,rect); %on subsequent iterations will apply cropping region defined on first iteration
    end
    %below is a few lines of code for separating color channels for
    %potential analysis later to determine fraction of floating cells that
    %are expressing gas vesicles (the will be expressing blue chromophore
    %AND RFP)
    Jr = J(:,:,1);  
    Jg = J(:,:,2);
    Jb = J(:,:,3);
    
    G = rgb2gray(J); %convert to gray scale
    level = graythresh(G); %determine threshold level using Otsu's method
    BW = imbinarize(G,level); %convert to binary image
    %BW = imcomplement(BW);
    
    [L,n] = bwlabeln(BW, 18); %labelling objects
    NumObjects(i) = n; %count objects
    Lrgb = label2rgb(L,'jet','w','shuffle'); %converts labelling matrix to an RGB map so that different objects can more easily be identified graphically
    
    Lfilt = medfilt2(L, [5 5]); %apply simple median filter on image to remove noise
    %TODO fine tune region size (i.e. [5 5]) when we get real images
    
    Lfiltrgb = label2rgb(Lfilt,'jet','w','shuffle');
    LabeledImages{i} = Lfiltrgb; %store ith (current) rgb label matrix
    
    s = regionprops(BW, 'Centroid'); %perform centroiding get ordered pairs (y,z), z height along cylinder principle axis
    %y increases to right and is zero at left cylinder egdge
    
    num_obj = numel(s); %count object (this should be the same as n above and is probably redundant)
    centroids = zeros(num_obj,2); %store ordered pairs in array centroids(k,:) returns [y z] for the kth object
    for k = 1 : num_obj
        centroids(k,:) = [s(k).Centroid(1), s(k).Centroid(2)];
    end
    positions{i} = centroids; %store these matrices of arbitrary size for each frame in cell array
    
    %these are just some useful plots for verifying code is performing as
    %expected
    if VALIDATE
        figure;
        imshow(BW);
        hold on;
        title('Segmented, binarized image');
        hold off;
        
        figure;
        imshow(Lfiltrgb);
        hold on;
        numObj = numel(s);
        for k = 1 : numObj
            plot(s(k).Centroid(1), s(k).Centroid(2), 'r*');
        end
        title('Filtered Labeled Image with Centroids')
        hold off;
        
        figure;
        imshow(Lfiltrgb);
        hold on;
        numObj = numel(s);
        for k = 1 : numObj
            plot(s(k).Centroid(1), s(k).Centroid(2), 'r*');
        end
        title('Filtered Labeled Image with Centroids')
        hold off;
        
        figure;
        imshow(Lfiltrgb);
        hold on;
        numObj = numel(s);
        for k = 1 : numObj
            plot(s(k).Centroid(1), s(k).Centroid(2), 'r*');
        end
        title('Filtered Labeled Image with Centroids')
        hold off;
        
        figure;
        imshow(Lrgb);
        hold on;
        title('Unfiltered Labeled Image');
        hold off
        
        figure;
        imshow(Lfiltrgb);
        hold on;
        title('Filtered Labeled Image');
        hold off;
    end
    
    %{
    %I initialized this loop through row indices to try to find row with
    %highest mean pixel value (i.e. largest number of non-zero pixels since
    %the image has been binarized at this point). The algorith your looking
    %into may be a better way to replace this very simple approach
    num_rows = size(BW,1); %this should be the same for all of the imgages since the camera and its zoom and aspect ratio settings will be constant for each batch
    means = zeros(1,num_rows);%will store the mean pixel value for each row in the pixel data matrix
    for j=1:num_rows
        Ic = imcomplement(BW); %black appears to correspond to pixel value=0, which is the dye, so imcomp flips this to find the row with most red cells
        row = Ic(j,:);
        mn = mean(row);
        means(j) = mn;
    end
    [M,ind] = max(means); %M is whatever the max mean is in means, and ind is the index
    %the intention here is that ind represents the height of the biomass in
    %pixel space, and then based on the scale on cylinder convert to a
    %useful unit
    line([0 200], [ind ind]); %a line corresponding to the row with the greatest mean pixel value
    hold off;
    MAXs(i) = M; %might be useful to see how the max mean row value changes as a function of time to infer some sort of time dependent distribution
end
    %}
end

%Temporal Tracking

ClusterInf = cell(num_images,1); %for each image, there will exist and info struct and we will store them all here
info = struct; %instantiate struct object to input info for first frame

for i=2:num_images
    current_posns = positions{i}; %load positions of all objects in current frame as num current objects x 2 array
    previous_posns = positions{i-1}; %load positions of all objects from previous frame as num previous objects x 2 array
    num_current_obj = size(current_posns,1); %num objects in current frame
    num_prev_obj = size(previous_posns,1); %num objects from previous frame
    
    info = struct; %instantiate struct to input info for the (i+1)th frame
    
    %inds = zeros(num_current_obj,1);
    %norms = zeros(num_current_obj,1);
    %cents = cell(num_current_obj,1);
    %cents_prev = cell(num_current_obj,1);
    
    %temporal clustering relies on mapping all labels in current frame to
    %the closest object in the previous frame and assinging labels
    %accordingly (note: multiple objects in frame (i+1) can be mapped to
    %the same object in the ith frame. This corresponds to and object
    %splitting into multiple)
    for k = 1:num_current_obj
        dists = zeros(num_prev_obj,1); %store euclidean distance between the kth object in the current frame and each object in the previous frame
        for l = 1:num_prev_obj
            d = EuclideanNorm2D(current_posns{k}, previous_posns{l}); %distance between kth object in (i+1)th frame and lth object in ith frame
            dists(l) = d;
        end
        [d, ind] = min(dists); %we care about the object in the previous frame that is closest to the kth object in the current fram so we minimize and get index
        %inds(k) = ind;
        %norms(k) = d;
        %cents{k} = current_posns{k};
        %cents_prev{k} = previous_posns{ind};
        
        y = round(previous_posns{ind}(1)); %round to convert from floating point spatial values to integer pixel coordinates
        x = round(previous_posns{ind}(2));
        
        info(k).centroid_current = current_posns(k,:); %store the ordered pair for the kth object in the (i+1)th frame
        info(k).centroid_previous = previous_posns(ind,:);  %store the ordered pair for the closest object in the ith frame to the kth object in the current frame
        info(k).distance = d; %store the distance between the kth object in current frame and the object we map it to in previous frame
        info(k).previous_frame_index = ind; %this might be not be needed, but might as well store too much info than too little
        oldLabel = LabeledImages{i-1}(x,y); %this is the label of the object in the previous frame that is closest to the kth object in the current frame
        info(k).previous_frame_label = old_label; %store label from previous frame
        
        if num_current_obj == num_prev_obj
            newLabel = oldLabel; %in the case that there exists the same number of objects, there is no need to update label
        else
            newLabel = 'temp'; %store a placeholder until re-labelling algorithm... mostly unecessessary, but is useful for debugging
        end
        
        info(k).new_label = newLabel;
    end
    %re-labelling algorithm:
    if num_current_obj > num_prev_obj 
        
        delta = num_current_obj - num_prev_obj;
        inds = zeros(delta,2);
        cnt = 0;
        
        prev_X = zeros(1,num_current_obj);
        prev_Y = zeros(1,num_current_obj);
        for k=1:num_current_obj
            prev_X(k) = info(k).centroid_previous(1);
            prev_Y(k) = info(k).centroid_previous(2);
            
            X = info(k).centroid_previous(1);
            Y = info(k).centroid_previous(2);
            %indx = find(ismember(prev_X, X));
            %indy = find(ismember(prev_Y, Y));
            indx = ismember(prev_X, X);
            indy = ismember(prev_Y, Y);
            not_zero = indx(ismember(indx,1));
            if isequal(indx,indy) && numel(not_zero)>1 && cnt<=delta
                cnt = cnt+1;
                ind = find(indx); %this is an array of indexes of the objects that share a common label in previous frame
                inds(k,:) = ind;
            end
            if cnt==delta
               break 
            end
        end
        %inds = inds(~ismember(inds,0)); %remove zeros
        %inds = unique(inds,'rows'); %remove dupicate rows... found better
        %way to ensure no zeros or duplicates
        
        %{
        [nx, binx] = histc(prev_X, unique(prev_Y));
        multiple_x = find(nx>1);
        indx = find(ismember(binx, multiple_x));
        [ny, biny] = histc(prev_Y, unique(prev_Y));
        multiple_y = find(ny>1);
        indy = find(ismember(biny, multiple_y));
        %}
        for k=1:size(inds,1)
           for l=1:size(inds,2)
               if l == 1
                   info(inds(k,l)).new_Label = info(inds(k,l)).previous_Label;
               else
                  info(inds(k,l)).new_Label = num_prev_obj + (k-1);
               end
           end
        end
    end
    ClusterInf{i} = info;
end
end