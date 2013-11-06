function feedings = getFeedings(logfile, chnum, t0)
%
%   function feedings = getfeedings(filename,chnum,t0)
%
% Where filename is a logfile eg '/Volumes/DATA/110210_experiment-log.txt'.
%   chnum is the number of the chamber 
%   t0 is an time in matlab datenum() format (or 0 to skip).
%
%   Returns 
%   file_parse = [path_toDATA, yymmdd, (int) chamber] (or [] if fails) and 
%       a struct feedings with fields
%   datenum     the date num of feeding time, to compare with file creation
%               times
%   time        time in hrs after t0
%   medianum    number of line for media supplied at that time
%   medianame   name of media
%   cycles      number of pump cycles of media supplied.

verbose = 0;

ff=fopen(logfile);
if ff < 0
    fprintf(1, 'getFeedings(): can not open file= %s\n', logfile);
    feedings = [];
    return
end

strtofind=['Feeding chamber ' int2str(chnum) ':'];
tline=fgetl(ff);
q=1;
feedings(1)=struct('time',0,'medianum',1,'medianame','dmem','cycles',30,'datenum', 0);
while ischar(tline)
    %disp(tline);
    k=findstr(tline,strtofind);
    %disp('here')
    if k
        if verbose
            disp(tline);
        end
        feedings(q).datenum = datenum(tline(1:k-1));
        feedings(q).time=(datenum(tline(1:k-1))-t0)*24;
        jj=findstr(tline,'input =');
        jj2=findstr(tline,' (');
        feedings(q).medianum=str2num(tline(jj+8:jj2-1));
        jj3=findstr(tline,')');
        feedings(q).medianame=tline(jj2+2:jj3-1);
        jj4=findstr(tline,'cycles =');
        jj5=findstr(tline,', pmp');
        feedings(q).cycles=str2num(tline(jj4+9:jj5-1));
        q=q+1;    
    end
    
    tline=fgetl(ff);
end

fprintf(1, 'read %d lines of data from %s chamber= %d\n   first/last time= %s %s\n',...
    length(feedings), logfile, chnum, datestr(feedings(1).datenum), datestr(feedings(end).datenum) );
fclose(ff);
return
