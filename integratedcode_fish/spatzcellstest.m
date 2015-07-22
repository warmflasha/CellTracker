function peakdata = spatzcellstest(sr)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version dated 10/3/2013 - SOS

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% 1. Load Mask and thicken
%
%    Input:   segmentated image file path
%             radius to thicken mask
%
%    Output:  thickened mask - ThickMask
%
%--------------------------------------------------------------------------

load([sr.seg.dir sr.seg.name])
% LcFull - 2D matrix cell mask
% DAPI_mask - 3D matrix - nuclei mask


if sr.seg.multiz_mask
    z_range = 1:size(DAPI_mask,3);
    
    LcFull      = uint16(LcFull);
    T_LcFull    = uint16(zeros(size(LcFull)));
    DAPI_mask   = uint16(DAPI_mask);

    if sr.seg.thicken_radius<=0
        T_LcFull = LcFull;
    else
        T_LcFull = Thicken_Mask(LcFull, sr.seg.thicken_radius);
    end
else
    
    z_range = sr.image.zrange;
    
   
    
    LcFull      = uint16(LcFull);    
    T_LcFull    = uint16(zeros(size(LcFull)));
    DAPI_mask   = uint16(zeros(size(LcFull,1),size(LcFull,2),numel(z_range)));
    
    if sr.seg.thicken_radius<=0
        T_LcFull = LcFull;
        DAPI_mask = repmat(T_LcFull, [1,1,numel(z_range)]);
    else
        T_LcFull = Thicken_Mask(LcFull, sr.seg.thicken_radius);
        DAPI_mask = repmat(T_LcFull, [1,1,numel(z_range)]);
    end
end
    
clear InNu_mask
%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% 2. Load images and recognize maxima
%
%    Input:   image file dir and name and number
%             range of z-slices to analyze
%             channel to analyze
%             radius to gaussian filter images
%             neighborhood for local max search
%             threshold for local max
%
%    Output:  maxima
%
% Maxima mask for each z-slice
maxima     = cell(numel(z_range),1);
maxima_int = cell(numel(z_range),1);
%--------------------------------------------------------------------------

for i1 = 1:numel(z_range);
    
    fprintf(1,['z-Slice ' num2str(i1) ' out of ' num2str(numel(z_range)) '.' sprintf('\n')]);
    
    % 1. Load image
    % Format of Elements exported tiff names changes if there are
    % z-stacks and if so, how many z-slices.  Use try-catch statement to
    % accomidate all scenarios.
    try
        slice_name = [sr.image.fullname '_z' num2str(z_range(i1), '%04d') '_w' num2str(sr.image.channel, '%04d') '.tif'];
        FluorImage = imread(slice_name);
    catch ME
        try
            slice_name = [sr.image.fullname '_z' num2str(z_range(i1), '%04d') '_w' num2str(sr.image.channel, '%04d') '.tif'];
            FluorImage = imread(slice_name);
        catch ME
            slice_name = [sr.image.fullname '_z' num2str(z_range(i1), '%04d') '_w' num2str(sr.image.channel, '%04d') '.tif'];
            FluorImage = imread(slice_name);
        end
    end

    
    % 2. Use Gaussian filter to smooth raw data
    PSF = fspecial('gaussian',sr.spotrec.gf.size,sr.spotrec.gf.sigma);
    Filtered = imfilter(FluorImage,PSF,'symmetric','conv');
    
    % 2.1 Use two methods to find local maxima
    %     1) Isolate regional max - MATLAB built in function 
    %     2) Find points which correspond to max in x and y
    
    % 2.1.1 Search for local maxima and reduce those maxima to points
    fprintf(1,[sprintf('\t') 'Recognizing regional maxima...' sprintf('\n')]);
    all_maxima = imregionalmax(Filtered, sr.spotrec.peak.connectivity);
    all_maxima = bwmorph(all_maxima, 'shrink');    
    
    % 2.1.2 Screen for the maxima above a threshold value
    maxima_1 = maxima_above_threshold(Filtered, all_maxima, sr.spotrec.peak.threshold); %

    %2.2.1  recognize the maxima
    fprintf(1,[sprintf('\t') 'Recognizing "L" shapes...' sprintf('\n')]);

    [~, maxima_2D]=extrema2D(Filtered, sr.spotrec.peak.threshold); % calculate maxima and minima
    BW = bwmorph(uint16(maxima_2D),'clean');     % get rid of isolated points

    %2.2.2 Take only pixels that have a cross-like maxima (this get the spots)
    %   (structure elements are "L"'s in 4 orientations)
    E1  = imerode(BW,strel([0 0 0; 1 1 0; 0 1 0]));
    E2  = imerode(BW,strel([0 1 0; 1 1 0; 0 0 0]));
    E3  = imerode(BW,strel([0 1 0; 0 1 1; 0 0 0]));
    E4  = imerode(BW,strel([0 0 0; 0 1 1; 0 1 0]));

    maxima{i1}   = double(logical(E1 + E2 + E3 + E4));
    
    %Dmax = maxima_1 - maxima{i1};
    Smax = conv2(maxima{i1}, ones(5), 'same');
    Smax = Smax>0;
    Smax = (1-Smax).*maxima_1; % Pick out maxima recognized in maxima_1 but not maxima{i1}. Feb 6, 2012. TS.
    
    maxima{i1} = maxima{i1} + Smax; % Add maxima recognized in maxima_1 but not maxima{i1} to maxima{i1}. Feb 6, 2012. TS.
    
    maxima{i1}   = bwmorph(maxima{i1}, 'skel'); % Skeletonize the maxima... Feb 6, 2012. TS.
   maxima{i1}   = bwmorph(maxima{i1}, 'shrink'); % ... and reduce them to points. Feb 6, 2012. TS.

    
    % 2.3 Screen for the maxima within Cell Mask
    if sr.spotrec.discard_spots == true
        maxima{i1} = maxima{i1} & logical(T_LcFull);
    end
    
    % 2.4 Remove maxima next to edge of image
    maxima{i1}(1:3,:) = 0;
    maxima{i1}((end-2):end,:) = 0;
    maxima{i1}(:,1:3) = 0;
    maxima{i1}(:,(end-2):end) = 0;
    
    % 2.5 Record raw peak intensity of each maxima 
    maxima_int{i1} = zeros(size(T_LcFull));
    maxima_int{i1}(maxima{i1}) = FluorImage(maxima{i1});
       
end

clear FluorImage Filtered PSF slice_name all_maxima ME i1 i2
clear E1 E2 E3 E4 Smax maxima_2D BW maxima_1
%
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% 3. Match maxima between z-slices
%    Choose the z-slice at which to fit
%
%   Input:  2D maxima above threshold
%           x,y distance threshold for matching between slices
%           flag to check results of matching maxima
%           required_number_of_slices
% maxima;
% dist_thresh = 2.5;
% check_results = 0;
% required_number_of_slices = 3;

% % %Z STACK PEAK MATCHING
% % sr.zstack.max_spot_dist          = 2.5;                                  % maximum allowed distance (in pixels) between the peaks of two slides to consider them as the same spot
% % sr.zstack.min_slide_number       = 3;                                    % minimum number of slides where a spot needs to appear to be considered real
% % sr.zstack.check_results          = 0;                                    % whether or not check the results
% % 


%
%	Output: trajectory matrix - matrix containing the aligned maxima through z
maxima_trajectory(:,1) = find(maxima{1}); %start the trajectory with maxima in first z-slice
                                          % Each row of maxima_trajectory
                                          % corresponds to the "trajectory"
                                          % of a spot through the z-slices.
                                          % Each column corresponds to a
                                          % z-slice. Each element is the
                                          % number of the spot in a
                                          % particular z-slice. Feb 6, 2012. TS.
maxima_trajectory_int  = zeros(size(maxima_trajectory(:,1)));
maxima_trajectory_int  = maxima_int{1}(maxima_trajectory(:,1));
max_to_save_bi = [];  %logical vector of trajectories that are good to analyze 
maxnum_to_save = [];  %list of maxima numbers that are good to analyze 
%--------------------------------------------------------------------------

sr.zstack.min_slide_number = min([sr.zstack.min_slide_number length(z_range)]);


for i1 = 1:(numel(z_range)-1)
    
    %%  Compare the maxima in current z-slice to the next
    % maxima_in_slide{i1} contains the maxima in the current z-slice that
    % hava matched maxima in the next z-slice. Feb 6, 2012. TS.
    % matched maxima{i1} contains the maxima in the next z-slice that are
    % matched to maxima in the current z-slice. Feb 6, 2012. TS.
    % distance_between{i1} contains the distances between the pairs of
    % matched maxima. Feb 6, 2012. TS.
    [maxima_in_slide{i1} matched_maxima{i1} distance_between{i1}] = compare_maxima_in_z(sr.zstack.max_spot_dist, maxima{i1}, maxima{i1+1}, maxima_int{i1}, maxima_int{i1+1}, sr.zstack.check_results);
    
    %% Find the spots in this frame that matched
    % Pick out the spots in the curren z-slice that also appears in the
    % next z-slice. Feb 6, 2012. TS.
    [~, i1a_int, i1b_int] = intersect(maxima_trajectory(:,i1), maxima_in_slide{i1});
    
    %% For those spots, place the matched spots as next entry in trajectory
    % Continue the "trajectory" of the spots in this z-slice to the next
    % z-slice. Feb 6, 2012. TS.
    maxima_trajectory(i1a_int,i1+1) = matched_maxima{i1}(i1b_int);

    %% Find the spots that didn't match
    % Pick out the spots in the next z-slice that do not appear in the
    % current z-silce. Feb 6, 2012. TS.
    [c1_dif, i1a_dif] = setdiff(find(maxima{i1+1}), matched_maxima{i1}); 
    
    %% And place those spots as beginning of new trajectories
    % The spots in the next z-slice that do not appear in the
    % current z-silce serve as the biginnings of new spot "trajectories".
    % Feb 6, 2012. TS.
    maxima_trajectory((end+1):(end+length(c1_dif)), i1+1) = c1_dif;
    
    %%% Also, note raw peak intensity at each max
    maxima_trajectory_int(maxima_trajectory(:,i1+1)~=0,i1+1)  = maxima_int{i1+1}(maxima_trajectory(maxima_trajectory(:,i1+1)~=0,i1+1));
end

%% Choosing maxima to analyze
% 1) detect local maxima in z with extrema 2D
max_to_save_bi = ones(size(maxima_trajectory_int));
if numel(z_range) > 1
    for i1 = 1:size(maxima_trajectory_int,1)
        % Compare with intensity value of zero for cases where spots are in every frame
        [~, max_bi] = extrema2D([maxima_trajectory_int(i1,:) 0], sr.spotrec.peak.threshold);
        max_to_save_bi(i1,:) = max_bi(1:(end-1));
    end
end

% 2) count number of peaks and length of trajectories
num_max_in_trajectory = sum(max_to_save_bi,2);
length_trajectory = sum(logical(maxima_trajectory_int),2);

% 3) for trajectories that contain multiple peaks, move additional peaks to new trajectories
i_to_add = size(maxima_trajectory_int,1) + 1;
for i1 = 1:size(maxima_trajectory_int,1)
    if num_max_in_trajectory(i1) > 1
        i_max_ = find(max_to_save_bi(i1,:));
        for i2 = i_max_(2:end)
            length_trajectory(i_to_add)         = length_trajectory(i1);
            maxima_trajectory(i_to_add,i2)      = maxima_trajectory(i1, i2);
            maxima_trajectory_int(i_to_add, i2) = maxima_trajectory_int(i1, i2);
            max_to_save_bi(i_to_add,i2)         = max_to_save_bi(i1,i2);
            i_to_add = i_to_add + 1;
        end
        maxima_trajectory(i1, i_max_(2:end))     = 0;
        maxima_trajectory_int(i1, i_max_(2:end)) = 0;
        max_to_save_bi(i1, i_max_(2:end))        = 0;
    end
end

% 4) screen for trajectories that last for more than x num of slices
max_to_save_bi(length_trajectory < sr.zstack.min_slide_number, :) = zeros(size(max_to_save_bi(length_trajectory < sr.zstack.min_slide_number, :)));

% 5) Final list of spots that will be fitted and saved.
maxnum_to_save = find(sum(max_to_save_bi,2)~=0);


clear i1a_int i1b_int c1_dif i1a_dif maxima_in_slide matched_maxima distance_between
clear maxima num_max_in_trajectory length_trajectory maxima_int i_to_add i_max_
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%--------------------------------------------------------------------------
% 4.  Fit all maxima to gaussians larger than diffraction limit
%
%   Input: Trajectories of local maxima and lists of ones to analyze
%          Flag to save image of z-slices with recognized maxima
%          Flag to display fit to neighborhood of maxima
%          Radius of (box) neighboorhood for fitting
%          Lambda, NA, pixel size (for diffraction limit)


maxima_trajectory;
max_to_save_bi;
maxnum_to_save;
sr.fit.save.maxima_image;
sr.fit.save.maxima_fit;
% lambda = 600;
% NA = 1.4;
% pixel_size = 130; %in nm
%
%   Output: 
peakdata = zeros(length(maxnum_to_save),21);
%--------------------------------------------------------------------------

R = .61*sr.fit.lambda/sr.fit.NA ;  %% .61*lambda/NA = resolution in nm (R)
r_dif_lim = R/sr.fit.pixel_size/2; %% radius of PSF in pixels, R/(length/px) gets pixels.



gau2_gen = @(n) ['p(' num2str(1+6*(n-1)) ').*', ... %%% 2D single-gaussian model function text generator
                 'exp(', ...                      %%% exp(-( a(x-x0)^2 + b(y-y0)^2 + 2c(x-x0)(y-y0) ))
                 '-(', ...
                 '(p(' num2str(4+6*(n-1)) ')).*(x(:,1)-p(' num2str(2+6*(n-1)) ')).^2+', ...
                 '(p(' num2str(5+6*(n-1)) ')).*(x(:,2)-p(' num2str(3+6*(n-1)) ')).^2+', ...
               '2*(p(' num2str(6+6*(n-1)) ')).*(x(:,1)-p(' num2str(2+6*(n-1)) ')).*(x(:,2)-p(' num2str(3+6*(n-1)) '))', ...
                 '))'];   

bg_gen   = @(n) ['p(' num2str(6*n+1) ')+(x(:,1)-p(' num2str(6*n+4) ')).*p(' num2str(6*n+2) ')+(x(:,2)-p(' num2str(6*n+5) ')).*p(' num2str(6*n+3) ')'];




MaxP = zeros(size(T_LcFull)); % Maximum intensity projection of all z-slices.

  
%% Fit each z-slice at a time, only the maxs that were chosen above
fprintf(1,['Fitting Gaussain to spots...' sprintf('\n')]) ;
for i1 = 1:numel(z_range);
    
    progress_1 = [sprintf('\t') 'z-slice ' num2str(z_range(i1),'%3d') ' of ' num2str(z_range(end),'%3d') ', '] ;
    fprintf(1,progress_1) ;
        
    %% Load image to fit
    try
        slice_name = [sr.image.fullname '_z' num2str(z_range(i1), '%04d') '_w' num2str(sr.image.channel, '%04d') '.tif'];
        FluorImage = imread(slice_name);
    catch ME
        try
            slice_name = [sr.image.fullname '_z' num2str(z_range(i1), '%04d') '_w' num2str(sr.image.channel, '%04d') '.tif'];
            FluorImage = imread(slice_name);
        catch ME
            slice_name = [sr.image.fullname '_w' num2str(sr.image.channel, '%04d') '.tif'];
            FluorImage = imread(slice_name);
        end
    end

        
    %% Define lists of maxima locations
    all_maxnum_in_slice     = find(maxima_trajectory(:,i1)~=0);
    maxnum_to_save_in_slice = find(maxima_trajectory(:,i1)~=0 & max_to_save_bi(:,i1));
    [coord_i coord_j]       = ind2sub(size(T_LcFull), maxima_trajectory(:,i1));
    [j_map, i_map]          = meshgrid( 1:size(T_LcFull,2), 1:size(T_LcFull,1) );
    
    maxnum_left_to_save = maxnum_to_save_in_slice;
    
    %% Define list of assigned cells
    assigned_cell_num   = maxima_trajectory(:,i1);
    assigned_cell_num(maxima_trajectory(:,i1)~=0) = T_LcFull(maxima_trajectory(maxima_trajectory(:,i1)~=0,i1));
    
    %% Define list of assigned nuclei
    DAPI_mask_slice = DAPI_mask(:,:,i1);
    assigned_nucl_num   = maxima_trajectory(:,i1);
    assigned_nucl_num(maxima_trajectory(:,i1)~=0) = DAPI_mask_slice(maxima_trajectory(maxima_trajectory(:,i1)~=0,i1));
    
    %% Make SpotMask for fitting
    %%  Include all maxima in the neighborhood
    MaximaMask = zeros(size(T_LcFull));
    MaximaMask(nonzeros(maxima_trajectory(:,i1))) = all_maxnum_in_slice;
    
    %% Make BG mask to calc background
    BGMaskP  = bwpack(MaximaMask~=0);
    BGMaskPD = imdilate(BGMaskP, strel('disk', 5), 'ispacked');
    BGMaskD  = bwunpack(BGMaskPD, size(T_LcFull,1));
    

    %% For each maxima, fit all maxima around to gaussians.
    options = optimset('Display', 'off');
    progress_2 = [];
    if size(maxnum_left_to_save,1)==0
        fprintf(1,'no spots. ') ;
    end
    while ~isempty(nonzeros(maxnum_left_to_save))

       center_maxnum_fitted = maxnum_left_to_save(find(maxnum_left_to_save~=0,1));

       for d_=1:1:size(progress_2,2) ; fprintf(1,'\b') ; end
       progress_2 = ['spot ' num2str(find(maxnum_left_to_save==center_maxnum_fitted),'%5d') ' of ' num2str(length(maxnum_left_to_save),'%5d') '. '] ;
       fprintf(1,progress_2) ;

       %% Fit.
       try
           window_adjustment = 0;
           maxnum_to_exclude = [];
           [J, I, Z, f, p0, lb, ub, maxnum_in_hood, maxnum_to_save_from_fit] = generate_fitting_data(window_adjustment, T_LcFull, sr, FluorImage, MaximaMask, BGMaskD, coord_i, coord_j, i_map, j_map, center_maxnum_fitted, gau2_gen, bg_gen, r_dif_lim, maxnum_to_save_in_slice, maxnum_to_exclude);
           [p, resnorm, ~, exitflag] = lsqcurvefit(f, p0, [J I], Z, lb, ub, options);
           
           a = p([4:6:(end-5)]);
           b = p([5:6:(end-5)]);
           c = p([6:6:(end-5)]);
           i_peak = find(imag(sqrt(a.*b-c.^2)));
           if ismember(center_maxnum_fitted,maxnum_in_hood(i_peak))
               error('Center peak is fitted poorly.')
           elseif ~isempty(i_peak)
               maxnum_to_exclude = maxnum_in_hood(i_peak);
               [J, I, Z, f, p0, lb, ub, maxnum_in_hood, maxnum_to_save_from_fit] = generate_fitting_data(window_adjustment, T_LcFull, sr, FluorImage, MaximaMask, BGMaskD, coord_i, coord_j, i_map, j_map, center_maxnum_fitted, gau2_gen, bg_gen, r_dif_lim, maxnum_to_save_in_slice, maxnum_to_exclude);
               [p, resnorm, ~, exitflag] = lsqcurvefit(f, p0, [J I], Z, lb, ub, options);
           end
           
       catch ME 
           %% If fitting generates an error, adjust fitting window size,
           %% first larger, then larger still.
           %% If fitting doesn't go error-free on third try, save NaN's.
           try
               window_adjustment = +2;
               [J, I, Z, f, p0, lb, ub, maxnum_in_hood, maxnum_to_save_from_fit] = generate_fitting_data(window_adjustment, T_LcFull, sr, FluorImage, MaximaMask, BGMaskD, coord_i, coord_j, i_map, j_map, center_maxnum_fitted, gau2_gen, bg_gen, r_dif_lim, maxnum_to_save_in_slice, maxnum_to_exclude);
               [p, resnorm, ~, exitflag] = lsqcurvefit(f, p0, [J I], Z, lb, ub, options);
               
               a = p([4:6:(end-5)]);
               b = p([5:6:(end-5)]);
               c = p([6:6:(end-5)]);
               i_peak = find(imag(sqrt(a.*b-c.^2)));
               if ismember(center_maxnum_fitted,maxnum_in_hood(i_peak))
                   error('Center peak is fitted poorly.')
               elseif ~isempty(i_peak)
                   maxnum_to_exclude = maxnum_in_hood(i_peak);
                   [J, I, Z, f, p0, lb, ub, maxnum_in_hood, maxnum_to_save_from_fit] = generate_fitting_data(window_adjustment, T_LcFull, sr, FluorImage, MaximaMask, BGMaskD, coord_i, coord_j, i_map, j_map, center_maxnum_fitted, gau2_gen, bg_gen, r_dif_lim, maxnum_to_save_in_slice, maxnum_to_exclude);
                   [p, resnorm, ~, exitflag] = lsqcurvefit(f, p0, [J I], Z, lb, ub, options);
               end
                     
           catch ME
               try
                   window_adjustment = +3;
                   [J, I, Z, f, p0, lb, ub, maxnum_in_hood, maxnum_to_save_from_fit] = generate_fitting_data(window_adjustment, T_LcFull, sr, FluorImage, MaximaMask, BGMaskD, coord_i, coord_j, i_map, j_map, center_maxnum_fitted, gau2_gen, bg_gen, r_dif_lim, maxnum_to_save_in_slice, maxnum_to_exclude);
                   [p, resnorm, ~, exitflag] = lsqcurvefit(f, p0, [J I], Z, lb, ub, options);
                   
                   a = p([4:6:(end-5)]);
                   b = p([5:6:(end-5)]);
                   c = p([6:6:(end-5)]);
                   i_peak = find(imag(sqrt(a.*b-c.^2)));
                   if ismember(center_maxnum_fitted,maxnum_in_hood(i_peak))
                       error('Center peak is fitted poorly.')
                   elseif ~isempty(i_peak)
                       maxnum_to_exclude = maxnum_in_hood(i_peak);
                       [J, I, Z, f, p0, lb, ub, maxnum_in_hood, maxnum_to_save_from_fit] = generate_fitting_data(window_adjustment, T_LcFull, sr, FluorImage, MaximaMask, BGMaskD, coord_i, coord_j, i_map, j_map, center_maxnum_fitted, gau2_gen, bg_gen, r_dif_lim, maxnum_to_save_in_slice, maxnum_to_exclude);
                       [p, resnorm, ~, exitflag] = lsqcurvefit(f, p0, [J I], Z, lb, ub, options);
                   end
           
               
               catch ME
                   p = NaN*ones(size(p0));
                   resnorm = NaN;
                   exitflag = NaN;
                   maxnum_in_hood = center_maxnum_fitted;
                   maxnum_to_save_from_fit = center_maxnum_fitted;
                   fitresult.a0011 = NaN;
                   fitresult.a0012 = coord_j(center_maxnum_fitted);
                   fitresult.a0013 = coord_i(center_maxnum_fitted);
                   fitresult.a0014 = NaN;
                   fitresult.a0015 = NaN;
                   fitresult.a0016 = NaN;
                   fitresult.b1 = NaN;
                   fitresult.b2 = NaN;
                   fitresult.b3 = NaN;
                   fitresult.b4 = NaN;
                   fitresult.b5 = NaN;
                   gof.sse = NaN;
                   gof.rsquare = NaN;
                   gof.adjrsquare = NaN;
                   gof.rmse = NaN;
               end
           end
       end

       
       
       %% Save peaks of interest
       for i4 = maxnum_to_save_from_fit'

            %% Saving fitted parameters to the peakdata matrix
            
            i_for_max_to_save = find(maxnum_in_hood==i4);
            i_to_save_max     = find(maxnum_to_save==i4);

%   Output: Peakdata matrix
%           1) Peak intensity (fit over BG)
%           2) X position
%           3) Y position
%           4) fit a
%           5) fit b
%           6) fit c
%           7) Background
%           8) fit resnorm: the squared 2-norm of the residual at X: sum{(FUN(X,XDATA)-YDATA).^2}
%           9) fit exitflag: see help lsqcurvefit
%          10) ~
%          11) Assigned nucleus number
%          12) Assigned cell number
%          13) Z-Slice
%          14) Integrated spot intensity
%          15) Minor axis
%          16) Major axis
%          17) Frame number
%          (18-21: continued below)


            eval(['peakdata(i_to_save_max,1) = p(' num2str( 1+6*(i_for_max_to_save-1) ) ');']);
            eval(['peakdata(i_to_save_max,2) = p(' num2str( 2+6*(i_for_max_to_save-1) ) ');']);
            eval(['peakdata(i_to_save_max,3) = p(' num2str( 3+6*(i_for_max_to_save-1) ) ');']);
            eval(['peakdata(i_to_save_max,4) = p(' num2str( 4+6*(i_for_max_to_save-1) ) ');']);
            eval(['peakdata(i_to_save_max,5) = p(' num2str( 5+6*(i_for_max_to_save-1) ) ');']);
            eval(['peakdata(i_to_save_max,6) = p(' num2str( 6+6*(i_for_max_to_save-1) ) ');']);

            eval(['peakdata(i_to_save_max,7) = p(' num2str(6*length(maxnum_in_hood)+1) ') + ', ...
                '(p(' num2str( 2+6*(i_for_max_to_save-1) ) ') - p(' num2str(6*length(maxnum_in_hood)+4) ')).*p(' num2str(6*length(maxnum_in_hood)+2) ') + ', ...
                '(p(' num2str( 3+6*(i_for_max_to_save-1) ) ') - p(' num2str(6*length(maxnum_in_hood)+5) ')).*p(' num2str(6*length(maxnum_in_hood)+3) ');']);

            peakdata(i_to_save_max,8) = resnorm;
            peakdata(i_to_save_max,9) = exitflag;
            peakdata(i_to_save_max,11) = assigned_nucl_num(i4);
            peakdata(i_to_save_max,12) = assigned_cell_num(i4);

            peakdata(i_to_save_max,13) = z_range(i1);

            peakdata(i_to_save_max,14) = peakdata(i_to_save_max,1).*pi./sqrt(peakdata(i_to_save_max,4).*peakdata(i_to_save_max,5)-peakdata(i_to_save_max,6).^2);

            peakdata(i_to_save_max,15) = 1./sqrt( peakdata(i_to_save_max,4) + peakdata(i_to_save_max,5) + ... %% Defined by '+'
                    sqrt( (peakdata(i_to_save_max,4)-peakdata(i_to_save_max,5)).^2 + 4*peakdata(i_to_save_max,6).^2));  %% Minor axis

            peakdata(i_to_save_max,16) = 1./sqrt( peakdata(i_to_save_max,4) + peakdata(i_to_save_max,5) - ... %% Defined by '-'
                    sqrt( (peakdata(i_to_save_max,4)-peakdata(i_to_save_max,5)).^2 + 4*peakdata(i_to_save_max,6).^2));  %% Major axis

            peakdata(i_to_save_max,17) = sr.image.frame;
            
            
            
            % Save data that was fit and the fit result
            % for future reference.
            if sr.fit.save.maxima_fit
                save_dir = [sr.fit.output 'Frame' num2str(sr.image.frame, '%03d') '/'];
                if ~exist(save_dir,'dir'), mkdir(save_dir); end
                
                save_name = [save_dir 'peakfit' num2str(i_to_save_max, '%04d') '.mat'];
                save(save_name, 'p0', 'J', 'I', 'Z', 'lb', 'ub', 'options', 'p', 'resnorm', 'exitflag');
            end
            

       end

       %% Cross all max off list.
       maxnum_left_to_save(ismember(maxnum_left_to_save, maxnum_to_save_from_fit)) = 0;

    end
    
    
    % Save the image of all maxima for this z-slice?
    if sr.fit.save.maxima_image==true
        fprintf(1,'Saving image...');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % 
        % Begin. Feb 6, 2012. TS.
        % Extract cell perimeters in a slightly diffrerent way.
        % 
        cellPerim = zeros(size(LcFull)) ;
        for iCell = 1:1:max(LcFull(:))
            cellPerim = cellPerim + bwperim(LcFull==iCell) ;
        end
        % 
        % End. Feb 6, 2012. TS.
        % 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        [all_maxima_y all_maxima_x] = ind2sub(size(T_LcFull), nonzeros(maxima_trajectory(:,i1)));
        save_name = [sr.spotrec.output 'frame' num2str(sr.image.frame, '%03d') 'c' num2str(sr.image.channel) 'z' num2str(i1, '%03d') '.fig'];
        save_maxima_image(FluorImage, cellPerim, all_maxima_x, all_maxima_y, peakdata(peakdata(:,13)==i1,:), sr, save_name)
        MaxP = max( cat(3, MaxP, FluorImage), [], 3);
    end
    
    fprintf(1,sprintf('\n'));
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Begin. Feb 6, 2012. TS.
% Calculate positions of spots relative to the cell axes. Algorithm same as
% the one in the previous generation of spot recognition codes.
% 
%   Output: Peakdata matrix
%          18) position of spot along the cell axis (between -1 and +1, 0 being the center)
%          19) position of spot perpendicular to the cell axis (between -1 and +1, 0 being the center)
%          20) position of spot along the cell axis (actual pixels)
%          21) position of spot perpendicular to the cell axis (actual pixels)
fprintf(1,['Calculating positions of spots relative to cell axes...' sprintf('\n')]);
for iCell=unique(peakdata(:,12))' % Do the calculations cell-by-cell.
    
    if iCell==0 | sr.fit.cell_info==false
        
        peakdata(peakdata(:,12)==iCell,18:21) = NaN * ones(sum(peakdata(:,12)==iCell),4) ;
        
    else
        
        % Pick out the spots in this cell.
        subPeakdata = peakdata(peakdata(:,12)==iCell,:) ;
        
        % Obtain properties of this cell.
        CellStats = regionprops(double(LcFull==iCell),...
            'Orientation','Centroid','MajorAxisLength','MinorAxisLength','PixelList') ;
        alpha = -CellStats.Orientation ; % Angle between x-axis and cell
                                         % axis in degrees (-90 to 90)
                                         % (- sign because y-axis is reversed).
        CellXY = CellStats.Centroid ; % Cell centroid.
        CellPixels = CellStats.PixelList ; % List of pixels covered by this cell.
        CellAxisL = [CellStats.MajorAxisLength;CellStats.MinorAxisLength] ; % Cell axes lengths (This is not accurate. A more accurate value is calculated below.).
        
        % List of pixels covered by a line through the cell centroid with
        % same orientation as cell.
        axis_line1 = [ CellXY(1)+[-CellAxisL(1):1:CellAxisL(1)]*cosd(alpha) ; ...
            CellXY(2)+[-CellAxisL(1):1:CellAxisL(1)]*sind(alpha) ] ;
        % List of pixels covered by a line through cell centroid
        % perpendicular to cell.
        axis_line2 = [ CellXY(1)-[-CellAxisL(2):1:CellAxisL(2)]*sind(alpha) ; ...
            CellXY(2)+[-CellAxisL(2):1:CellAxisL(2)]*cosd(alpha) ] ;
        
        % Throw away points in axis_line1 that are outside the cell.
        for i2 = size(axis_line1,2):-1:1
            % D is a vector containing distances from all cell pixels to a
            % point in axis_line1.
            D = sqrt( (axis_line1(1,i2)-CellPixels(:,1)).^2 + (axis_line1(2,i2)-CellPixels(:,2)).^2 ) ;
            if min(D)>=1
                axis_line1(:,i2) = [] ;
            end
        end
        % Throw away points in axis_line2 that are outside the cell.
        for i2 = size(axis_line2,2):-1:1
            % D is a vector containing distances from all cell pixels to a
            % point in axis_line2.
            D = sqrt( (axis_line2(1,i2)-CellPixels(:,1)).^2 + (axis_line2(2,i2)-CellPixels(:,2)).^2 ) ; % vector containing distances from all cell pixels to a point in axis_line2
            if min(D)>=1
                axis_line2(:,i2) = [] ;
            end
        end
        
        % Lengths of cell axes.
        CellAxisL = sqrt( (axis_line1(1,1)-axis_line1(1,end))^2 + (axis_line1(2,1)-axis_line1(2,end))^2 ) ;
        CellAxisW = sqrt( (axis_line2(1,1)-axis_line2(1,end))^2 + (axis_line2(2,1)-axis_line2(2,end))^2 ) ;
        
        % Calculate positions of spots relative to the cell axes.
        for iSpot=1:size(subPeakdata,1)
            
            % Spot centroid.
            SpotXY = subPeakdata(iSpot,2:3) ;
            
            % Angle between x-axis and the line joining the spot and the
            % cell centroid in degrees (-90 to 90).
            beta = atan((SpotXY(2)-CellXY(2))/(SpotXY(1)-CellXY(1))) * 180 / pi ;
            
            % Angle between x-axis and the line joining the spot and the
            % cell centroid in degrees (-90 to 270).
            beta = beta + ((SpotXY(1)-CellXY(1))<0)*180 ;
            
            % Angle between x-axis and the line joining the spot and the
            % cell centroid in degrees (0 to 360).
            beta = beta + (beta<0)*360 ;
            
            % Angle between the cell axis and the line joining the spot
            % and the cell centroid in degrees.
            theta = beta - alpha ;
            
            % Distance between the spot and the cell centroid in pixels.
            lll = sqrt((SpotXY(1)-CellXY(1))^2 + (SpotXY(2)-CellXY(2))^2) ;
            
            % Projection of lll onto the cell axis and perpendicular axis
            % (in pixels).
            ddd = lll * [cosd(theta) sind(theta)] ;
            
            % Position of the spot along the cell axis and perpendicular
            % axis (between -1 and +1, 0 being the center).
            SpotAxisPos = ddd./[0.5*CellAxisL 0.5*CellAxisW] ;
            
            subPeakdata(iSpot,18:21) = [SpotAxisPos ddd] ;
            
        end
        
        peakdata(peakdata(:,12)==iCell,:) = subPeakdata ;
    
    end
    
end
% 
% End. Feb 6, 2012. TS.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if sr.fit.save.maxima_image==true
    
    fprintf(1,['Saving final image...' sprintf('\n')]);
    
    % cells perimeter
    MaxMask   = zeros(size(LcFull,1),size(LcFull,2));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    % Begin. Feb 6, 2012. TS.
    % Extract cell perimeters in a slightly diffrerent way.
    % 
    cellPerim = zeros(size(LcFull)) ;
    for iCell = 1:1:max(LcFull(:))
        cellPerim = cellPerim + bwperim(LcFull==iCell) ;
    end
    % 
    % End. Feb 6, 2012. TS.
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Add flag to include DAPI signal perimeters when sr.seg.multiz_mask is
    % true.
    if sr.seg.multiz_mask
        for z_i = 1:size(DAPI_mask,3)
            MaxMask = max( cat(3, MaxMask, DAPI_mask(:,:,z_i)), [], 3);
        end
        NCell=double(sort(unique(nonzeros(MaxMask(:)))));
        for index = 1:numel(NCell)
            CellNum = NCell(index);
            cellPerim = cellPerim + bwperim(MaxMask==CellNum) ;
        end
    end

    [all_maxima_y all_maxima_x] = ind2sub(size(T_LcFull), nonzeros(maxima_trajectory));

    save_name = [sr.spotrec.output 'frame' num2str(sr.image.frame, '%03d') 'c' num2str(sr.image.channel) '_MaxP.fig'];
    
    save_maxima_image(MaxP, cellPerim, all_maxima_x, all_maxima_y, peakdata, sr, save_name)
  
end

fprintf(1,['Done.' sprintf('\n')]);
fprintf(1,sprintf('\n\n'));

clear BG_estimate BG_slope_I BG_slope_J FluorImage I J NA R MaximaMask MaximaMask_hood Z all_maxnum_in_slice bg_gen
clear box coord_i coord_j fitresult ft gau2_gen gaussian_fun gof i_map i_for_max_to_save
clear i_to_save_max j_map lambda maxnum_left_to_save center_maxnum_fitted maxnum_to_save_in_slice opts output peaks_estimate pixel_size
clear r_dif_lim save_image_of_maxima maxima_hood maxnum_in_hood maxima_location i_1 i_2 j_1 j_2 n
clear maxima_trajectory maxnum_to_save max_to_save_bi ME MaxP
%--------------------------------------------------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




return



function ThickMask = Thicken_Mask(Mask, Radius)
NewMask = zeros(size(Mask));
for i1 = sort(nonzeros(unique(Mask(:))))'
    ErodedCell = zeros(size(Mask));
    ErodedCell(Mask==i1) = 1;
    ErodedCell = imerode(ErodedCell,strel('disk',1));
    NewMask(ErodedCell==1) = i1;
end

%% Blow up mask by radius
BWThickMask = bwmorph(NewMask, 'thicken', (Radius+1));
ThickMask = -bwlabel(BWThickMask,4);
for i1 = sort(nonzeros(unique(ThickMask(:))))'
   %[i,j] = find(ThickMask==i1);
   cellNum = nonzeros(unique(NewMask(ThickMask==i1)));
   ThickMask(ThickMask==i1) = cellNum;
end
ThickMask = abs(ThickMask);

ThickMask = uint16(ThickMask);
return

function maxima_above_thresh = maxima_above_threshold(Image, all_maxima, MaxThresh)

Screen = Image;
Screen(all_maxima==0) = 0;

Screen1 = [Image(2:end,:); Inf*ones(1,size(Image,2))];       Screen1(all_maxima==0) = 0;
Screen2 = [Image(3:end,:); Inf*ones(2,size(Image,2))];       Screen2(all_maxima==0) = 0;
Screen3 = [Image(4:end,:); Inf*ones(3,size(Image,2))];       Screen3(all_maxima==0) = 0; 

Screen4 = [Inf*ones(1,size(Image,2)); Image(1:(end-1),:)];   Screen4(all_maxima==0) = 0;
Screen5 = [Inf*ones(2,size(Image,2)); Image(1:(end-2),:)];   Screen5(all_maxima==0) = 0;
Screen6 = [Inf*ones(3,size(Image,2)); Image(1:(end-3),:)];   Screen6(all_maxima==0) = 0;

Screen7 = [Image(:,2:end) Inf*ones(size(Image,1),1)];        Screen7(all_maxima==0) = 0;
Screen8 = [Image(:,3:end) Inf*ones(size(Image,1),2)];        Screen8(all_maxima==0) = 0;
Screen9 = [Image(:,4:end) Inf*ones(size(Image,1),3)];        Screen9(all_maxima==0) = 0;

Screen10 = [Inf*ones(size(Image,1),1) Image(:,1:(end-1))];   Screen10(all_maxima==0) = 0;
Screen11 = [Inf*ones(size(Image,1),2) Image(:,1:(end-2))];   Screen11(all_maxima==0) = 0;
Screen12 = [Inf*ones(size(Image,1),3) Image(:,1:(end-3))];   Screen12(all_maxima==0) = 0;


Min_Screen = min(cat(3, Screen1, Screen2, Screen3, ...
                        Screen4, Screen5, Screen6, ...
                        Screen7, Screen8, Screen9, ...
                        Screen10, Screen11, Screen12), [], 3);
                    
DScreen = Screen - Min_Screen;

maxima_above_thresh = all_maxima;

maxima_above_thresh(DScreen<MaxThresh) = 0;

return

function [matched_spots_above matched_spots_below distance_between] = compare_maxima_in_z(dist_thresh, top_max_M, bot_max_M, top_max_int_M, bot_max_int_M, check_results) 


% top_dist_M contains the distances of the closest non-zero neighbor for
% each element.
% top_label_M contains the linear indices of the closest non-zero neighbor
% for each element.
% Feb 6, 2012. TS.
[top_dist_M, top_label_M] = bwdist(top_max_M);
% Same as above. Feb 6, 2012. TS.
[bot_dist_M, bot_label_M] = bwdist(bot_max_M);

spot_indexs_above = find(top_max_M);
spot_indexs_below = find(bot_max_M);

spot_intens_above = top_max_int_M(spot_indexs_above);
spot_intens_below = bot_max_int_M(spot_indexs_below);

close_spots_above = top_label_M(spot_indexs_below);
close_spots_below = bot_label_M(spot_indexs_above);

disttospots_above = top_dist_M(spot_indexs_below);
disttospots_below = bot_dist_M(spot_indexs_above);


%%  This spot above is close to this spot below by this distance (tie goes to brightest spot on top).
Above_to_below = [spot_indexs_above(disttospots_below <= dist_thresh), ...
                  close_spots_below(disttospots_below <= dist_thresh), ...
                  disttospots_below(disttospots_below <= dist_thresh), ...
                  spot_intens_above(disttospots_below <= dist_thresh)];
              
if size(Above_to_below,2) == 0, Above_to_below = zeros(0,4);end

%%  Sort by intensity of above spots.
% Spots are sorted by intensities so that brighter spots appear first.
% Feb 6, 2012. TS.
s_Above_to_below_1 = sort_matrix(Above_to_below, 4, 'ascend');

%%  Sort back by distance.
% Spots are sorted by distances so that nearer spots appear first.
% Feb 6, 2012. TS.
s_Above_to_below_2 = sort_matrix(s_Above_to_below_1, 3, 'descend');
              
%%  Then sort by index of target spot              
s_Above_to_below_3 = sort_matrix(s_Above_to_below_2, 2, 'ascend');

%%  Then remove repeated spots on targets. (Saving the closest)
maxima_match = remove_repeated_entries(s_Above_to_below_3, 2);

matched_spots_above = maxima_match(:,1);
matched_spots_below = maxima_match(:,2);
distance_between    = maxima_match(:,3);



if check_results == true
    
    figure
    subplot(3,2,1)
    imagesc(top_max_M)
    subplot(3,2,2)
    imagesc(bot_max_M)
    subplot(3,2,3)
    imagesc(top_label_M)
    subplot(3,2,4)
    imagesc(bot_label_M)
    subplot(3,2,5)
    imagesc(top_dist_M)
    subplot(3,2,6)
    imagesc(bot_dist_M)

    [I_Orig_A, J_Orig_A] = ind2sub(size(top_max_M), spot_indexs_above);
    [I_Orig_B, J_Orig_B] = ind2sub(size(top_max_M), spot_indexs_below);
    
    [I_A2B_A, J_A2B_A] = ind2sub(size(top_max_M), maxima_match(:,1));
    [I_A2B_B, J_A2B_B] = ind2sub(size(top_max_M), maxima_match(:,2));

    figure
    hold on
    plot(J_Orig_A, I_Orig_A, 'ob')
    plot(J_Orig_B, I_Orig_B, 'or')
    plot(J_A2B_A, I_A2B_A, '*b')
    plot(J_A2B_B, I_A2B_B, '*r')
    plot([J_A2B_A J_A2B_B]', [I_A2B_A I_A2B_B]', 'k')
    hold off
    
    
   
end


return

function sorted_matrix = sort_matrix(matrix, column, direction)

[sorted_column i_sorted_column] = sort(matrix(:,column), direction);

sorted_matrix = matrix(i_sorted_column,:);

return

function unique_entries = remove_repeated_entries(matrix, column)

if isempty(matrix)
    repeat_entries = matrix;
else
    repeat_entries = [diff(matrix(:,column),1)==0; 0];
end

unique_entries = matrix(~repeat_entries, :);

return

function display_fit_trajectories(fit_trajectories)


for i1 = 1:size(fit_trajectories,1)
    
    temp = cat(1,fit_trajectories{i1,:});
    
    [max_spot(i1) i_max_spot(i1)] = max(temp(:,1)+temp(:,10)); 
    [min_spot(i1) i_min_spot(i1)] = min(temp(:,1)+temp(:,10));
    
end



num_samples = 1:10;
i3 = 1;

for i1 = num_samples
    
    for i2 = 1:9
        
        if ~isempty(fit_trajectories{i1,i2})
            
            I{i2} = double(imread([image_dir image_name '0003z' num2str(i2) 'c1.tif']));
            I_norm = (I{i2}-min_spot(i1))./(max_spot(i1) - min_spot(i1));

            figure(1)
            subplot(length(num_samples),9,i3)
            imshow(I_norm)
            ylim([(fit_trajectories{i1,i2}(2)-10) (fit_trajectories{i1,i2}(2)+10)])
            xlim([(fit_trajectories{i1,i2}(3)-10) (fit_trajectories{i1,i2}(3)+10)])
            title(['Peak intensity = ' num2str(fit_trajectories{i1,i2}(1), '%3.1f')])
        end
        i3 = i3 + 1;
    end
                
                
end

return

function [minima,maxima] = extrema2D(I,minThreshold)

   minima = zeros(size(I));
   maxima = zeros(size(I));

   
   %____calculate minima and maxima for the y dimension

    mn    = Inf*ones(1,size(I,2));      mx = -Inf*ones(1,size(I,2));
    mnpos = NaN*ones(1,size(I,2));   mxpos =  NaN*ones(1,size(I,2));

    lookformax = ones(1,size(I,2));

    for i1=1:size(I,1)

        this = I(i1,:);
        
        mxpos(this > mx) = i1;
           mx(this > mx) = this(this > mx);

        mnpos(this < mn) = i1;
           mn(this < mn) = this(this < mn);

        lookformax_now = lookformax;
        mn_now = mn;
        mx_now = mx;

        mnpos(lookformax_now==1 & this<(mx_now-minThreshold)) = i1;
           mn(lookformax_now==1 & this<(mx_now-minThreshold)) = this(lookformax_now==1 & this<(mx_now-minThreshold));

        mxpos(lookformax_now==0 & this>(mn_now+minThreshold)) = i1;
           mx(lookformax_now==0 & this>(mn_now+minThreshold)) = this(lookformax_now==0 & this>(mn_now+minThreshold));
           
        lookformax(lookformax_now==1 & this<(mx_now-minThreshold)) = 0;
        lookformax(lookformax_now==0 & this>(mn_now+minThreshold)) = 1;

        maxima(sub2ind(size(maxima), mxpos(lookformax_now==1 & this<(mx_now-minThreshold)), find(lookformax_now==1 & this<(mx_now-minThreshold)))) = 1;
        minima(sub2ind(size(minima), mnpos(lookformax_now==0 & this>(mn_now+minThreshold)), find(lookformax_now==0 & this>(mn_now+minThreshold)))) = 1;

    end


   %____calculate minima and maxima for the x dimension

    mn    = Inf*ones(size(I,1),1);      mx = -Inf*ones(size(I,1),1);
    mnpos = NaN*ones(size(I,1),1);   mxpos = NaN*ones(size(I,1),1);

    lookformax = ones(size(I,1),1);

    for i1=1:size(I,2)

        this = I(:,i1);
        
        mxpos(this > mx) = i1;
           mx(this > mx) = this(this > mx);

        mnpos(this < mn) = i1;
           mn(this < mn) = this(this < mn);

        lookformax_now = lookformax;
        mn_now = mn;
        mx_now = mx;

        mnpos(lookformax_now==1 & this<(mx_now-minThreshold)) = i1;
           mn(lookformax_now==1 & this<(mx_now-minThreshold)) = this(lookformax_now==1 & this<(mx_now-minThreshold));

        mxpos(lookformax_now==0 & this>(mn_now+minThreshold)) = i1;
           mx(lookformax_now==0 & this>(mn_now+minThreshold)) = this(lookformax_now==0 & this>(mn_now+minThreshold));
           
        lookformax(lookformax_now==1 & this<(mx_now-minThreshold)) = 0;
        lookformax(lookformax_now==0 & this>(mn_now+minThreshold)) = 1;

        maxima(sub2ind(size(maxima), find(lookformax_now==1 & this<(mx_now-minThreshold)), mxpos(lookformax_now==1 & this<(mx_now-minThreshold)))) = 1;
        minima(sub2ind(size(minima), find(lookformax_now==0 & this>(mn_now+minThreshold)), mnpos(lookformax_now==0 & this>(mn_now+minThreshold)))) = 1;

    end


return

function save_maxima_image(MaxP, cellPerim, all_maxima_x, all_maxima_y, spots, sr, save_name)

if ~isempty(spots)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    % Begin. Feb 6, 2012. TS.
    % Display fluorescence image in a slightly diffrerent way.
    % 
     imshow((MaxP), [min(MaxP(:)) max(MaxP(:))],'InitialMagnification',50); hold on;  %% Back to original SOS 
%     low = double(min(MaxP(:)))/65535 ;
%     high = double(max(MaxP(:)))/65535 ;
%     imshow(imadjust(MaxP,[low,low+0.5*(high-low)],[0,1],0.8),...
%         'InitialMagnification','fit');hold on;
    % 
    % End. Feb 6, 2012. TS.
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    spy(cellPerim,'w',0.5); hold on; % cells perimeter
    plot(spots(:,2), spots(:,3), 'ko', 'MarkerFaceColor', 'b')
    plot(all_maxima_x, all_maxima_y, 'ko')
    for i3 = 1:size(spots,1)
           %% Display spot number
           text((spots(i3,2))+3*sr.seg.thicken_radius,(spots(i3,3)),num2str(i3),...
               'Color',[155 187 89]/255,...
               'FontSize',8,'FontName','Calibri','FontWeight','Bold') ;
           % Add flag to choose to display spot measurements or not.
           % Feb 6, 2012. TS.
           if sr.fit.display.maxima_data
               %% Display peak and integrated intensity
               text((spots(i3,2))+3*sr.seg.thicken_radius,(spots(i3,3))+3*sr.seg.thicken_radius, [num2str(spots(i3,1), '%3.1f') ', ' num2str(spots(i3,1).*pi./sqrt(spots(i3,4).*spots(i3,5)-spots(i3,6).^2), '%3.1f')], ...
                   'Color',[155 187 89]/255,...
                   'FontSize',8,'FontName','Calibri','FontWeight','Bold') ;
               %% Display background and area
               text((spots(i3,2))+3*sr.seg.thicken_radius,(spots(i3,3))+6*sr.seg.thicken_radius, [num2str(spots(i3,7), '%3.1f') ', ' num2str(spots(i3,15).*spots(i3,16), '%3.1f')], ...
                   'Color',[155 187 89]/255,...
                   'FontSize',8,'FontName','Calibri','FontWeight','Bold') ;
           end
    end
    hold off
    
else
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % 
    % Begin. Feb 6, 2012. TS.
    % Display fluorescence image in a slightly diffrerent way.
    % 
% % %     imshow((MaxP), [min(MaxP(:)) max(MaxP(:))],'InitialMagnification',50); hold on;
    low = double(min(MaxP(:)))/65535 ;
    high = double(max(MaxP(:)))/65535 ;
    imshow(imadjust(MaxP,[low,low+0.5*(high-low)],[0,1],0.8),...
        'InitialMagnification','fit');hold on;
    % 
    % End. Feb 6, 2012. TS.
    % 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    spy(cellPerim,'w',0.5); hold on; % cells perimeter
    plot(all_maxima_x, all_maxima_y, 'ko')
    hold off
    
end


title({'Recognized peaks (blue) with spot numbers, peak intensity, and BG (green)',...
           ['With filter, threshold = ',num2str(sr.spotrec.peak.threshold),', radius = ',num2str(sr.seg.thicken_radius)]});

hgsave(save_name) ; close ;
    
    
return

function [J, I, Z, f, p0, lb, ub, maxnum_in_hood, maxnum_to_save_from_fit] = generate_fitting_data(window_adjustment, T_LcFull, sr, FluorImage, MaximaMask, BGMaskD, coord_i, coord_j, i_map, j_map, center_maxnum_fitted, gau2_gen, bg_gen, r_dif_lim, maxnum_to_save_in_slice, maxnum_to_exclude)

   box_size = sr.fit.box + window_adjustment;
   
   %% Get center of neighborhood for fitting-
   i_1 = max([(coord_i(center_maxnum_fitted)-box_size) 1]);
   i_2 = min([(coord_i(center_maxnum_fitted)+box_size) size(T_LcFull,1)]);
   j_1 = max([(coord_j(center_maxnum_fitted)-box_size) 1]);
   j_2 = min([(coord_j(center_maxnum_fitted)+box_size) size(T_LcFull,2)]);


   %% Make maps of x, y, z for Gaussian fit
   radius_of_inclusion = 4;
   i_3 = max([i_1-radius_of_inclusion 1]);
   i_4 = min([i_2+radius_of_inclusion size(T_LcFull,1)]);
   j_3 = max([j_1-radius_of_inclusion 1]);
   j_4 = min([j_2+radius_of_inclusion size(T_LcFull,2)]);
   
   maxima_hood             =  FluorImage( i_1:i_2, j_1:j_2 );
   BGMask_hood             = 1 - BGMaskD( i_1:i_2, j_1:j_2 );
   maxnum_close_to_center  = nonzeros(unique(MaximaMask( i_1:i_2, j_1:j_2 )));
   maxnum_close_to_center  = setdiff(maxnum_close_to_center, maxnum_to_exclude);
   maxnum_to_save_from_fit = intersect(maxnum_close_to_center, maxnum_to_save_in_slice);
   
   MaximaMask_hood   = MaximaMask( i_3:i_4, j_3:j_4 );
   maxnum_in_hood    = nonzeros(unique(MaximaMask_hood));
   maxnum_in_hood    = setdiff(maxnum_in_hood, maxnum_to_exclude);
   
   Pixels_to_analyze = zeros(size(MaximaMask));
   Pixels_to_analyze(ismember(MaximaMask, maxnum_in_hood)) = 1;
   Pixels_to_analyze = imdilate(Pixels_to_analyze, strel('disk', radius_of_inclusion));
   Pixels_to_analyze( i_1:i_2, j_1:j_2 ) = 1;

   I = double(i_map(Pixels_to_analyze==1)); %% 'Y'
   J = double(j_map(Pixels_to_analyze==1)); %% 'X'
   Z = double(FluorImage(Pixels_to_analyze==1));


   %% Estimate fitting parameters 
   maxima_location = [coord_i(maxnum_in_hood) coord_j(maxnum_in_hood)];
   BG_estimate = double(median(double(maxima_hood(BGMask_hood==1))));
   BG_slope_I = (mean(maxima_hood(end,:)) - mean(maxima_hood(1,:)))/(2*box_size+1);
   BG_slope_J = (mean(maxima_hood(:,end)) - mean(maxima_hood(:,1)))/(2*box_size+1);

   peaks_estimate = double(FluorImage(sub2ind(size(T_LcFull), maxima_location(:,1), maxima_location(:,2)))) ...
                    - BG_estimate ...
                    - (maxima_location(:,1)-coord_i(center_maxnum_fitted)).*BG_slope_I ...
                    - (maxima_location(:,2)-coord_j(center_maxnum_fitted)).*BG_slope_J ;

   %% Make fitting function based on the number of maxima in
   %% neighborhood
   gaussian_fun = [];

   for n = 1:length(maxnum_in_hood)
       gaussian_fun = [gaussian_fun gau2_gen(n) '+'];
   end

   gaussian_fun = [gaussian_fun bg_gen(n)];
   
   eval(['f = @(p,x)' gaussian_fun ';']);

   StartPoint = zeros(1, 6*length(maxnum_in_hood)+3);
   Lower      = zeros(1, 6*length(maxnum_in_hood)+3);
   Upper      = zeros(1, 6*length(maxnum_in_hood)+3);

   % a1XXX - peak height  1 + 4*n
   % a2XXX - x position   2 + 4*n
   % a3XXX - y position   3 + 4*n
   % a4XXX - a            4 + 4*n
   % a5XXX - b            5 + 4*n
   % a6XXX - c            6 + 4*n
   % b1    - BG offset    4*n
   % b2    - BG x slope
   % b3    - BG y slope
   % b4    - BG x center of field
   % b5    - BG y center of field

   for n = 1:length(maxnum_in_hood)
       StartPoint(1+6*(n-1)) = max([peaks_estimate(n) 10]);
       StartPoint(2+6*(n-1)) = maxima_location(n,2);
       StartPoint(3+6*(n-1)) = maxima_location(n,1);
       StartPoint(4+6*(n-1)) = 2*.50/(2*r_dif_lim^2);
       StartPoint(5+6*(n-1)) = 2*.50/(2*r_dif_lim^2);
       StartPoint(6+6*(n-1)) = 0;

       Lower(1+6*(n-1)) = 10;
       Lower(2+6*(n-1)) = maxima_location(n,2)-1;
       Lower(3+6*(n-1)) = maxima_location(n,1)-1;
       Lower(4+6*(n-1)) = 1E-3;
       Lower(5+6*(n-1)) = 1E-3;
       Lower(6+6*(n-1)) = -10;

       Upper(1+6*(n-1)) = 1E6;
       Upper(2+6*(n-1)) = maxima_location(n,2)+1;
       Upper(3+6*(n-1)) = maxima_location(n,1)+1;
       Upper(4+6*(n-1)) = 2/(2*r_dif_lim^2);
       Upper(5+6*(n-1)) = 2/(2*r_dif_lim^2);
       Upper(6+6*(n-1)) = 10;
   end

   StartPoint(6*n+1) = BG_estimate;
   StartPoint(6*n+2) = BG_slope_J;
   StartPoint(6*n+3) = BG_slope_I;
   StartPoint(6*n+4) = uint16(coord_j(center_maxnum_fitted));
   StartPoint(6*n+5) = uint16(coord_i(center_maxnum_fitted));
   Lower(6*n+1) = 0;
   Upper(6*n+1) = 60000;
   Lower(6*n+2) = -3000;
   Upper(6*n+2) = 3000;
   Lower(6*n+3) = -3000;
   Upper(6*n+3) = 3000;
   Lower(6*n+4) = uint16(coord_j(center_maxnum_fitted))-1;
   Upper(6*n+4) = uint16(coord_j(center_maxnum_fitted))+1;
   Lower(6*n+5) = uint16(coord_i(center_maxnum_fitted))-1;
   Upper(6*n+5) = uint16(coord_i(center_maxnum_fitted))+1;

    p0 = StartPoint;
    lb = Lower;
    ub = Upper;

return
