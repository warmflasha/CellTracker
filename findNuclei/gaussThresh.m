function thresh = gaussThresh(img)
% fit a Gaussian to histogram of img pixel values from
%   average < val < average + gauss_thresh_sigma*std
% Define threshold when 
%   actual counts > excess_fudge*(number from Gaussian fit) AND
%   value of bin > thresh_sigma * std_of_data
% img is assumed to be integer valued, or approx so, so that differences
% less than 1 are not meaningful. Images should be of size at least 256^2 for
% adequate counts in histogram

global userParam

verbose = 0;        % set to one for some diagnostics if crazy output
gauss_thresh_sigma = 1.5;     % fit this range of data >= mean to Gaussian
if isfield(userParam, 'gaussThreshExcess')
    gauss_thresh_excess = userParam.gaussThreshExcess;
else
    gauss_thresh_excess = 5;    % when actual hist > excess*gaussian fit -> threshold
end
if isfield(userParam, 'gaussThreshSigma')
    thresh_sigma = userParam.gaussThreshSigma;
else
    thresh_sigma = 3;
end

img2 = double(img);
avr = mean(img2(:));
sig = std(img2(:));


% compute approximate histogram so as to locate the level with max counts
mnhist = max(avr - gauss_thresh_sigma*sig, 0);
mxhist = avr + gauss_thresh_sigma*sig;
[cts, bins, nice_nbin] = adaptive_hist(img2, mnhist, mxhist);
[cmx, imx] = max(cts);

% redo histogram from value with max counts to upper end of intensities,
% using bin size adapted to region from max to several std above max.
dlt_bin = bins(2)-bins(1);
sig = dlt_bin*one_sided_std(cts(imx:end));
mnhist = bins(imx) - dlt_bin;
mxhist = bins(imx) + gauss_thresh_sigma*sig;
[cts, bins, nice_nbin] = adaptive_hist(img2, mnhist, mxhist);
nice_nbin = max(nice_nbin, 4);  % want at least 4 pts to fit to 1/2 parabola

% fit log histogram to parabola for values >= max to several std.

%AW add to prevent crash when length(cts) < nice_nbin
if nice_nbin > length(cts)
    nice_nbin=length(cts);
    if nice_nbin < 4
        disp('Warning gaussThresh: note enough pts for fit');
    end
end

data = log( cts(1:nice_nbin) + 1 ); % +1 to prevent NaN in log
len = length(data);
fit0 = ones(len, 1);
fit2 = ((0:(len-1)).^2)';
coef = [fit0, fit2] \ reshape(data, len, 1);
thresh = -1;

% starting from bin with max counts, find threshold
for i = 0:(length(bins)-1)
    fit = exp(coef(1) + coef(2)*i^2);
    if(verbose)
        [i, fit, cts(i+1)]
    end
    if(cts(i+1) > fit*gauss_thresh_excess & i*dlt_bin > thresh_sigma*sig)
        thresh = bins(i+1);
        break
    end
    % inadequate statistics, return with warning
    if(cts(i+1) < 10 )
        fprintf(1, 'WARNING gaussThresh() could not find reliable thresh, dlt_bin= %d, thresh= %d\n', dlt_bin, thresh);
        coef 
        %cts(1:100)
    end
end

if(verbose)
    test_plot(coef, cts, length(data) );
    fprintf(1,'dlt_bin= %d, thresh= %d\n', dlt_bin, thresh);
    coef 
    bins(1:10)
    %cts(1:100)
end

if(thresh < 0)
    fprintf(1, 'error in gaussThresh() see help text in file\n');
    %cts(1:100)
end

return

function [cts, bins, nice_bins] = adaptive_hist(img, imn, imx)
% compute historgram for nicely spaced bins between imn and imx. Return the
% histgram with bin 1 removed (ie cumulative cts < imn) as cts0. 
% The number of bins between imn and imx is returned as nice_bins

nbin = 128;  % mx number of bins between imn, imx should not be too large
dlt_bin = max([1, (imx-imn)/nbin]);
dlt_bin = round(dlt_bin);
nbin = 2*ceil( (imx-imn)/(2*dlt_bin) ); % actual number of bins between imn imx
mxbin = ceil((max(img(:)) - imn)/dlt_bin);
bins = imn + dlt_bin*(0:max(mxbin, nbin+2)); % +2 incase mxbin < nbin etc.
cts = hist(img(:), bins);

% drop first since has cumulative counts <= imn, and last incase lots of
% saturation.
nice_bins = nbin-1;
cts  = cts(2:(end-1));
bins = bins(2:(end-1));

function std = one_sided_std(cts)
% compute one sided second moment of density fn, 'center' is 1st element of
% input array. Keep only ~95% of prob, ie 2 sigma. Problem with a few huge
% values in img giving large i^2
nn = length(cts);
std=0;
sumc = 0;
for i = 1:nn
    std = std + cts(i)*(i-1)^2;
    sumc = sumc + cts(i);
    if( cts(i) < 0.05*sumc )
        break
    end
    % [i,std, sumc]
end
std = sqrt(std/sumc);


function test_plot(coef, cts, nbin)
% test plot for i>=0
xx = (0:nbin)';
fit2 = (0:nbin).^2;
model = coef(1) + coef(2)*fit2';
figure, plot(xx, model, xx, log(cts(1:(nbin+1))) );
title('model, log(histogram counts) vs bin number for bin >= average')
