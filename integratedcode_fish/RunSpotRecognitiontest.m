%% Run full spot recognition
function a = RunSpotRecognitiontest(dir1, z1, pos, sn, nch, sname)



%% 0. Initialize general experiment parameters
ip      = InitializeExptest(dir1, z1, pos, sn, sname);
channel = nch; % fluorescence channel to apply spatzcells

%% 1. Check Spot recognition parameters

%spot_folder = [ip.exp.path '/spots_quantify_t7ntch2/'];
df1             = sprintf('/spots_quantify_t7ntch%d/', nch);
spot_folder     = [ip.exp.path df1];

tic;

for n_sample = ip.exp.sampleList
    
    for n_image = ip.sample{n_sample}.idx % index of the first image of each sample
        
        % the corresponding frame number
        n_frame = ip.exp.splimg2frm(n_sample,n_image+1);
        
        % display time progression
        time = toc;
        hours = floor(time/3600);
        minutes = floor(time/60) - 60*hours;
        seconds = floor(time - 60*minutes - 3600*hours);
        
        progress_ = [... 
            sprintf('\n') 'SPOT RECOGNITION. FRAME ' num2str(n_frame,'%4d')...
            ' of ' num2str(ip.exp.totalframes,'%4d') '. Elapsed time = ' ...
            num2str(hours,'%02d') 'hr:' ...
            num2str(minutes,'%02d') 'min:' ...
            num2str(seconds,'%02d') 'sec'] ;
        fprintf(1,progress_) ;
        
        % run spatzcells and save output data
        sr       = InitializeSpotRecognitionParameterstest(ip,n_frame,channel,spot_folder, z1, pos);
        peakdata = spatzcellstest(sr);
        save([sr.output 'peakdata' num2str(n_frame,'%03d') '.mat'],'peakdata');
        
    end
end