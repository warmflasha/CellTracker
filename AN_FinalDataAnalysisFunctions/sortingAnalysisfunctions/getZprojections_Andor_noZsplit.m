direc = 'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\2017-07-14-Smad4sorting_maxProjections';% dt = 20 mins 0.617284 um/pxl (20X)
%direc ='E:\RICE_Research_databackup\gfpS4bmp4woSBtotal27hrs_20170117_54941 PM';%dt = 17 mins  0.325000 um/pxl (40x)
direc2save ='C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\LiveSorting_MIPgfpS4cellswithCFPdiff';
%'C:\Users\Nastya\Desktop\RiceResearch\2017-10-04-REMOTE_WORK\For_MatlabTracking\Fucci_andOtherCells_regularCulture';

ff = readAndorDirectory(direc);
pos = 0;
tgroup = [];
tpname = getAndorFileName(ff,pos,tgroup,[],chan);%chan
reader = bfGetReader(tpname);
nz=reader.getSizeZ;
nT = reader.getSizeT;
nT = 80;
multitp_nuc = [];
for time=1:nT
    chan = 1;
    for ii = 1:nz
        %time = 3;
        iPlane=reader.getIndex(ii - 1, chan -1, time - 1) + 1;
        img_now=bfGetPlane(reader,iPlane);
        %figure(ii),imshow(img_now,[]);
        if ii == 1
            max_img =  img_now;
        else
            max_img = max(max_img,img_now);
        end
        multitp_nuc = max_img;
    end
    if (pos)<10
         imwrite(multitp_nuc,[direc2save '\' ff.prefix '_80tpts_testDynamics_MIP_f000' num2str(pos) '_w000' num2str(ff.w(chan+1)) '.tif'],'writemode','append');
    end
    if (pos)>=10
         imwrite(multitp_nuc,[direc2save '\' ff.prefix '_80tpts_testDynamics_MIP_f00' num2str(pos) '_w000' num2str(ff.w(chan+1)) '.tif'],'writemode','append');
    end
          disp(['saved projection for time point' num2str(time) ' channel' num2str(ff.w(chan+1)) '  position' num2str(pos)]);

end
 