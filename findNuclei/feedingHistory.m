function feedingHistory(feedings, time)
% 
% feedingHistory(feedings, time)
%
%   Input a struct feedings produced by getFeedings(), and time in matlab
% datenum format.  Return nicely printed list of prior feedings. If time is
% beyond last feeding time, prints a nice list of feeding times starting from
% first
%
% TODO make varargout, test on nargout if 0 print if 2 return lists of
% times and what's fed

if isempty(feedings) || isempty(time)
    return
end

if time > feedings(end).datenum
    t0 = feedings(1).datenum;  % feeding time relative to first one
    fprintf(1, 'feedings beginning from %s\n', datestr(t0) );
else
    t0 = time;  % print feeding time relative to time input
end

for i = 1:length(feedings)
    tf = feedings(i).datenum;
    if tf > time
        break
    end
    hrsago = round(100*24*(tf - t0))/100;
    fprintf(1, '%6.2f hrs fed %s, %d cycles\n',...
        hrsago, feedings(i).medianame, feedings(i).cycles);
end