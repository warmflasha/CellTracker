function outdata = Data4AWTracker_AN(statsN, imgR,nImages)
%
%   outdata = outputStats4AWTracker(statsN, imgR)
%
%   Routine to take EDS statsN struct and output outdata(cells, properties) array
% of data for tracking following format in FCalcFluorCellsForTracker(). imgR is
% the 'red' nuclear label, whose average over nuclei is one column of outdata
%   The other array output by FCalcFluorCellsForTracker()is computed in addCellAvr2Stats
% It is called maskNonNuc and is the region over which the nonnuclear fluor is computed, which
% can be either entire cytoplasm, or a donut around nuc, depending on userParam.
%   This routine must be called after addCellAvr2Stats().
%   Columns in outdata array are
%
% [x, y, nuclear_area, ones(place holder), nuc_marker_avr, nuc_smad_avr, non_nuc_smad_avr]
% If there is more than one fluor image to be quantified, two columns per
% channel are added to the end -- nuclear fluor intensities in columns
% 8,10, etc, cyto fluor intensities in columns 9,11, etc.

global userParam

ncells = length(statsN);
xy = stats2xy(statsN);
nuc_avr  = [statsN.NuclearAvr];
nuc_area  = [statsN.NuclearArea];

nuc_marker_avr = zeros(ncells, 1);
for i = 1:ncells
    data = imgR(statsN(i).PixelIdxList);
    nuc_marker_avr = round(mean(data) );
    datacell=[xy(i,1) xy(i,2) nuc_area(i) -1 nuc_marker_avr];
    for xx=1:nImages
        if userParam.donutRadiusMax > 0
            datacell=[datacell statsN(i).NuclearAvr(xx) statsN(i).DonutAvr(xx)];
        else
            datacell=[datacell statsN(i).NuclearAvr(xx) statsN(i).CytoplasmAvr(xx)];
        end
        
    end
    outdata(i,:)=datacell; 
end
return