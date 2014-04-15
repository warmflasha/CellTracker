function [dims, wavenames]=getDimsFromLogFile(direc)
%[dims wavenames]=getDimsFromLogFile(direc)
%-----------------------------------------------
%Function to find dimensions of the tiling and
%the names of the wavelengths from the .dv.log file outputted by
%deltavision
%direc = output directory containing the .dv.log file
%   assumes only one .dv.log file in that directory.
%dims = 2 component vector containing dimension
%wavenames = cell array containing wavelength names

verbose = 0;

fnames=dir([direc filesep '*log']);
scanfile=[direc filesep fnames(1).name];
ff=fopen(scanfile);

strtofind1='DO ';
strtofind2='CHANNEL';
strtofind3='Stage coordinates:';
strtofind4='Image ';

tline=fgetl(ff);
q=1;
Y=1;

while ischar(tline)
    
    k1=strfind(tline,strtofind1);
    k2=strfind(tline,strtofind2);
    k4=strfind(tline,strtofind3);
    n=strfind(tline,strtofind4);
    
    if k1
        if verbose
            disp(tline);
        end
        panels=str2double(tline(k1+3:end));
    end
    
    if k2
        if verbose
            disp(tline);
        end
        
        k3=strfind(tline,',');
        wavenames{q}=tline(k3(1)+1:k3(2)-1);
        q=q+1;
    end
    
    if n
        n1=strfind(tline,'.');
        imageNum=str2double(tline(n+6:n1-1));
    end
    
    if k4
        if verbose
            disp(tline);
        end
        
        k5=strfind(tline,',');
        y=str2double(tline(k5(1)+1:k5(2)-1));
        
        if Y==1
            y1=y;
            Y=2;
        end
        
        if Y==2 && y~=y1
            cols = (imageNum-1)./length(wavenames);
            Y=3;
        end
        
    end
    
    tline=fgetl(ff);
    
end

rows = floor(panels./cols);

dims = [rows,cols];
