function max_img =andorMaxIntensity(files,pos,time,chan)
    
    for ii=1:length(files.z)
        filename = getAndorFileName(files,pos,time,files.z(ii),chan);
        img_now = imread(filename);
        if ii==1
            max_img=img_now;
        else
            max_img=max(img_now,max_img);
        end
    end