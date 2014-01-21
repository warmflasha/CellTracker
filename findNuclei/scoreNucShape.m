function [score, msg] = scoreNucShape(stats, verbose, stringency)
%
%   [score, msg] = scoreNucShape(stats, verbose, stringency)
%
% score = 0 object too small eliminate
% score = 1 plausible nuclei, keep with no further processing
% score = 2 possible composite nuclei, process further and retest.
% msg   = string with error message when score=2, also saved in userParam
% 
% verbose    = 0|1 print results of tests for score=2 nucs
% stringency = 0|1 when two parameters given for test, take the least|most stringent
%
% See regionprops() for defn of shape parameters

global userParam

msg = [];
area = stats.Area;
% if extra field not present, give it permissive value.
if ~isfield(stats, 'LocalMax')
    stats.LocalMax = 1;
end

if stringency
    nucSolidity = max(userParam.nucSolidity);
    nucAreaHi   = min(userParam.nucAreaHi);
    nucAreaLo   = max(userParam.nucAreaLo);
    nucAspectRatio = min(userParam.nucAspectRatio);
else
    nucSolidity = min(userParam.nucSolidity);
    nucAreaHi   = max(userParam.nucAreaHi);
    nucAreaLo   = min(userParam.nucAreaLo);
    nucAspectRatio = max(userParam.nucAspectRatio);
end
% break up test to allow printing of why test fails for score=2
test = [area<nucAreaHi, stats.Solidity>nucSolidity, ...
        stats.MajorAxisLength/stats.MinorAxisLength < nucAspectRatio, ...
        stats.LocalMax ==1];
% too small
if(area < nucAreaLo )
    score = 0;
    return;
% plausible nuclei
elseif(all(test) )
    score = 1;
    return
% suspect composite nuclei, try to segment
else
    score = 2;
    if(isfield(stats, 'Centroid') && verbose )
        msg = sprintf( 'nuc at %d %d, test= %s, area= %d, solidity= %3.2f, aspctR= %3.2f, locMx= %d\n',...
            round(stats.Centroid), num2str(test), area, stats.Solidity,...
            stats.MajorAxisLength/stats.MinorAxisLength, stats.LocalMax);
        userParam.errorStr = [userParam.errorStr, msg];
    end
end