function RunBatch(image_folder, VALIDATE)
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

batch_dir = dir(image_folder);
batch_dir = batch_dir(~ismember({batch_dir.name},{'.','..'}));
num_images = size(batch_dir,1);

bands = cell(1,num_images); %will later store row and column of pixel we identify in each picture as our pixel of interest
heights = zeros(1, num_images); %will later store conversion of pixel location to height in lab frame
MAX = zeros(1, num_images);
positions = cell(1, num_images);
for i = 1:num_images
    fname = batch_dir(i).name;
    fname = strcat(image_folder,'\',fname);
    I = imread(fname);
    %{
    Ir = I(:,:,1);
    Ig = I(:,:,2);
    Ib = I(:,:,3);
    
    Q = Ir-Ig-Ib;
    Q=Q>0;
    Q = double(Q);
    %}
    if i==1
        figure;
        title('Crop out graduated cylinder ensuring bottom is bottom of cylinder');
        hold on;
        [J,rect] = imcrop(I); %on first iteration will open an interactive cropping tool
        hold off;
    else
        J = imcrop(I,rect); %on subsequent iterations will apply cropping region defined on first iteration
    end
    
    Jr = J(:,:,1);  %this is just separating colour channels, will be useful later
    Jg = J(:,:,2);
    Jb = J(:,:,3);
    
    G = rgb2gray(J);
    level = graythresh(G);
    BW = imbinarize(G,level);
    %s = regionprops(BW, G, 'WeightedCentroid');
    
    L = bwlabeln(BW, 18); %labelling objects
    Lrgb = label2rgb(L,'jet','w','shuffle');
    
    Lfilt = medfilt2(L, [5 5]); %filter image to remove noise
    %TODO fine tune region size (i.e. [5 5]) when we get real images
    Lfilt = label2rgb(Lfilt,'jet','w','shuffle');
    
    s = regionprops(Lfilt, 'Centroid');
    
    num_obj = numel(s);
    centroids = cell(1, num_obj);
    for k = 1 : num_obj
        centroids{k} = [s(k).Centroid(1), s(k).Centroid(2)];
    end
    positions{i} = centroids;
    
    %these are just some useful plots for verifying code is performing as
    %expected
    if VALIDATE
        figure;
        imshow(BW);
        hold on;
        title('Segmented, binarized image');
        hold off;
        
        figure;
        imshow(Lfilt);
        hold on;
        numObj = numel(s);
        for k = 1 : numObj
            plot(s(k).Centroid(1), s(k).Centroid(2), 'r*');
        end
        title('Filtered Labeled Image with Centroids')
        hold off;
        
        figure;
        imshow(Lfilt);
        hold on;
        numObj = numel(s);
        for k = 1 : numObj
            plot(s(k).Centroid(1), s(k).Centroid(2), 'r*');
        end
        title('Filtered Labeled Image with Centroids')
        hold off;
        
        figure;
        imshow(Lfilt);
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
        imshow(Lfilt);
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

ClusterInf = cell(num_images),1);
info = struct;
ClusterInf{1} = info;

for i=2:num_images
   current_posns = positions{i};
   previous_posns = positions{i-1};
   num_current_obj = length(current_posns);
   num_prev_obj = length(previous_posns);
   
   info = struct;
   ClusterInf{i} = info;
   
   inds = zeros(num_current_obj,1);
   norms = zeros(num_current_obj,1);
   cents = cell(num_current_obj,1);
   cents_prev = cell(num_current_obj,1);
   for k = 1:num_current_obj
       dists = zeros(num_prev_obj,1);
       for l = 1:num_prev_obj
           d = EuclideanNorn2D(current_posns{k}, previous_posns{l});
           dists(l) = d;    
       end
       [d, ind] = min(dists);
       inds(k) = ind;
       norms(k) = d;
       cents{k} = current_posns{k};
       cents_prev{k} = previous_posns{ind};
       
       info(k).centroid_current = current_posns{k};
       info(k).centroid_previous = previous_posns{ind};
       info(k).distance = d;
       info(k).previous_frame_index = ind;
       info(k).previous_frame_label = 
       info(k).new_label = 
   end
end
end