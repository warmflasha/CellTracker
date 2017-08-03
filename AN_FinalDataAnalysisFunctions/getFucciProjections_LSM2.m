%% read the laser scanning data and get max projections
% save max projections
for xx =7:12 % 2:16;
    direc = ['/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-04-04FUCCIlive/Fucci_20170403/FV10__20170403timegroup1/Track000' num2str(xx) '/'];
    if xx>=10
        direc = ['/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-04-04FUCCIlive/Fucci_20170403/FV10__20170403timegroup1/Track00' num2str(xx) '/'];
    end
    %time group2 ( only for when the same dataset is split into two
    %sepatare datasets
    direcTG2 = ['/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-04-04FUCCIlive/Fucci_20170403/FV10__20170404timegroup2/Track000' num2str(xx) '/'];
    if xx>=10
        direcTG2 = ['/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-04-04FUCCIlive/Fucci_20170403/FV10__20170404timegroup2/Track00' num2str(xx) '/'];
    end
    direc2save = '/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-05-12-liveSorting';
    %separate rfp chanel data (Cdt1)
    direcSeparate = ['/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-04-04FUCCIlive/Fucci_20170403/FV10__20170403timegroup1/Track00' num2str(xx+12) '/'];
    direcSeparate2 = ['/Users/warmflashlab/Desktop/A_NEMASHKALO_Data_and_stuff/9_LiveCllImaging/2017-04-04FUCCIlive/Fucci_20170403/FV10__20170404timegroup2/Track00' num2str(xx+12) '/'];
    % double check this value
    tpts1 =37;
    tpts2 =15;
    q = 0;    
    tpnameall = cell(1,tpts1+tpts2);
    for chan = 1:2
        clear tpname
        if (xx <=5) && (xx>1)
        q = 1;
        end
        
        if (xx >=6)
            q = 2;
        end
        fnstr1 = '_0';
        fnstr2 = '_';
        time = 1;
        %max_img = bfMaxIntensity(reader,time,chan,bitdepth);
        multitp_nuc = [];
        for k=1:(tpts1+tpts2)
            if (k >=10)
                fnstr1 = fnstr2;
            end            
            tpname = [direc 'Image000' num2str(xx+q) fnstr1 num2str(k) '.oif'];
            if (xx>=8)
                tpname = [direc 'Image00' num2str(xx+q) fnstr1 num2str(k) '.oif'];
            end
            if (k >tpts1)
                disp('here')
                fnstr1 = '_0';
                if ((k-tpts1) >=10)
                fnstr1 = fnstr2;
                end 
                %direc = direcTG2;
                tpname = [direcTG2 'Image000' num2str(xx+q) fnstr1 num2str(k-tpts1) '.oif'];
                if (xx>=8)
                    tpname = [direcTG2 'Image00' num2str(xx+q) fnstr1 num2str(k-tpts1) '.oif'];
                end
            end
            tpnameall{k} = tpname;
            reader = bfGetReader(tpname);
            multitp_nuc = bfMaxIntensity(reader,time,chan);
            disp(['populated position point' num2str(xx+q)]);
            if (xx-1)<10
                imwrite(multitp_nuc,[direc2save '/' 'FucciMIP_f000' num2str(xx-1) '_w000' num2str(chan) '.tif'],'writemode','append');
            end
            if (xx-1)>=10
                imwrite(multitp_nuc,[direc2save '/' 'FucciMIP_f00' num2str(xx-1) '_w000' num2str(chan) '.tif'],'writemode','append');
            end
        end
        disp('done')
    end
    %%%%%%% separate channel (cdt1)need to analyze them separately, since
    %%%%%%% they were taken with the delay (merge rfp and nuclear marker
    %%%%%%% for analysis
    tpts1 =37;
    tpts2 =15;
    q = 0;
    tpnameallrfp = cell(1,tpts1+tpts2);
    for chan = 1
         clear tpname
        if (xx+12) >=6
            q = 2;
        end
        fnstr1 = '_0';
        fnstr2 = '_';
        time = 1;
        %max_img = bfMaxIntensity(reader,time,chan,bitdepth);
        multitp_nuc = [];
        for k=1:(tpts1+tpts2)
            if (k >=10)
                fnstr1 = fnstr2;
            end            
            tpname = [direcSeparate 'Image00' num2str(xx+12+q) fnstr1 num2str(k) '.oif'];
%             if xx>=8
%                 tpname = [direcSeparate 'Image00' num2str(xx+12+q) fnstr1 num2str(k) '.oif'];
%             end
            if (k >tpts1)
                disp('here')
                fnstr1 = '_0';
                if ((k-tpts1) >=10)
                fnstr1 = fnstr2;
                end 
                tpname = [direcSeparate2 'Image00' num2str(xx+12+q) fnstr1 num2str(k-tpts1) '.oif'];
%                 if xx>=8
%                     tpname = [direcSeparate2 'Image00' num2str(xx+12+q) fnstr1 num2str(k-tpts1) '.oif'];
%                 end
            end
            tpnameallrfp{k} = tpname;
            reader = bfGetReader(tpname);
            multitp_nuc = bfMaxIntensity(reader,time,chan);
            disp(['populated position point' num2str(xx+12+q)]);
            if (xx-1)<10
                imwrite(multitp_nuc,[direc2save '/' 'FucciMIP_f000' num2str(xx-1) '_w000' num2str(chan+2) '.tif'],'writemode','append');
            end
            if (xx-1)>=10
                imwrite(multitp_nuc,[direc2save '/' 'FucciMIP_f00' num2str(xx-1) '_w000' num2str(chan+2) '.tif'],'writemode','append');
            end
        end
        disp('done')
    end
end
%%%%%%