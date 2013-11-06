function thresh = thresh2PeakHist(img, prior)
%
%   thresh = thresh2PeakHist(img)
%
% For a histogram with 2 peaks and a dip in between locate the local minimum by
% fitting a + b*i + c*i^2 to +- band of points and finding best fit to local min
%   Lower and upper bounds on the fractional weight in the lower peak are given
% in the array prior eg = [0.02, 0.10].
%   NB do not add spurious far out of range points to image, since will collapse
% resolution of histogram around physical intensities.

% min/max allowed area of low intensity peak
prob1 = prior(1);   prob2 = prior(2);

% bins in histogram from min to max intensity.
nbin = 256;

% compute a second deriv by fitting 2*band+1 bins of histogram
band = 2; 

maxI = max(img(:));
scl = floor((2^16-1)/maxI );
[cts, bins] = imhist(scl*img, nbin);

wt = sum(cts(1:band));
totwt = numel(img);
minerr = totwt;
thresh = [];
for ii = (1+band):(nbin-band)
    wt = wt + cts(ii);
    if( wt/totwt < prob1 )
        continue
    end
    if( wt/totwt > prob2 )
        break
    end
    data = cts((ii-band):(ii+band));
    data = data - min(data);
    pts = -band:band;
    [poly, struct] = polyfit(pts', data,2);
    error = struct.normr;
    % more elaborate tests here might decide if no local min, ie test linear
    % term in fit.
    if(error < minerr && poly(1) > 0 )
        thresh = round(bins(ii)/scl);
        minerr = error;
    end
    % fprintf(1, 'ii= %d, frac wt= %d, poly= %d %d %d, error= %d\n',ii, wt/totwt, poly, error);
end

return
%% k means does not work
% ctr1 = bins(i2);  ctr2 = bins(i2);
% for iter = 1:100
%     mid = round( (ctr1 + ctr2)/(2*bins2int) );
%     ctr1 = dot( bins(1:mid), cts(1:mid) )/sum(cts(1:mid));
%     ctr2 = dot( bins((mid+1):end), cts((mid+1):end) )/sum(cts((mid+1):end));
%     [ctr1, ctr2]
%     [sum(cts(1:mid)), sum(cts((mid+1):end))]/prod(size(img))
% end
% return