function feedings=getfeedings(logfile,chnum,t0)
%function feedings=getfeedings(logfile,chnum,t0)
%--------------------------------------------
%function to get feeding schedule for chamber chnum
%from a cellculturechip logfile. feeding times are given in
%hours relative to t0 which should be given in datenum format.


if ~exist(logfile,'file')
    error('log file does not exist');
end

ff=fopen(logfile);

strtofind=['Feeding chamber ' int2str(chnum) ':'];
strtofind2=['Replacing medium with flush in chamber ' int2str(chnum) ':'];

tline=fgetl(ff);
q=1;
feedings(1)=struct('time',0,'medianum',1,'medianame','dmem','cycles',30);
while ischar(tline)
    %disp(tline);
    k=findstr(tline,strtofind);
    %disp('here')
    if k
        disp(tline);
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
    
    k2 = findstr(tline,strtofind2);
    
        if k2
        disp(tline);
        feedings(q).time=(datenum(tline(1:k2-1))-t0)*24;
        jj=findstr(tline,'input =');
        jj2=findstr(tline,' (');
        feedings(q).medianum=str2num(tline(jj+8:jj2-1));
        jj3=findstr(tline,')');
        feedings(q).medianame=tline(jj2+2:jj3-1);
%         jj4=findstr(tline,'cycles =');
%         jj5=findstr(tline,', pmp');
%         feedings(q).cycles=str2num(tline(jj4+9:jj5-1));
        feedings(q).cycles = -1;
        q=q+1;    
        end
    
    tline=fgetl(ff);
end
disp(int2str(q));
fclose(ff);