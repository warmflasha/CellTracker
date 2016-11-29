
function getZprojectionsFucci2(direc,direc2,w)
% direc = ('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/12_FUCCI_cells/fuccimovie_fullconstruct_20160820_55115 PM');
% direc2 =('/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/12_FUCCI_cells/fuccimovie_fullconstruct_20160820_55115 PM/Zprojections');

ff = readAndorDirectory(direc);

for pos = 0:14;% positions (0:14)
    for time = 2:81
        z = [];
        % w = 0:2
        filename = getAndorFileName(ff,pos,time,z,w);
        for m=1:3
            inuc(:,:,m) = imread(filename,m);
        end
        % get max projection from each z
        max_img = zeros(1024,1024);
        
        for ii=1:3
            img_now = inuc(:,:,ii);
            if ii==1
                max_img=img_now;
            else
                max_img=max(img_now,max_img);
            end
        end
        
        %figure, imshow(max_img,[]);
        
        if pos < 10
            imwrite(max_img,[direc2 'Maxprojection_f000' num2str(pos) '_t000' num2str((time)) '_w000' num2str(ff.w(w+1)) '.tif'],'writemode','append','Compression','none');%
        end
        if pos >= 10
            imwrite(max_img,[direc2 'Maxprojection_f00' num2str(pos) '_t000' num2str((time)) '_w000' num2str(ff.w(w+1)) '.tif'],'writemode','append','Compression','none');%
        end
    end
end
end
