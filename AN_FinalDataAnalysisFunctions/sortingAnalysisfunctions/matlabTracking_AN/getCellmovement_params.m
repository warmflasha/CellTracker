function [msd,slope_estimate,D,diff_coeff,mean_disp,total_disp,mean_speed,validTracks,MD,mspeed,TP,fit_out] = getCellmovement_params(coordintime,pxtomicron,delta_t,shortesttrack,tr_1,tr_end,x1)

 close all
 colormap2 = jet;
 
 fit_out = struct;
 msd = struct;
 slope_estimate= struct;
 D = struct;
 all_displ2 = struct;
 mean_disp = struct;
 velocity = struct;
 mean_speed= struct;
 s = struct;
 total_disp = struct;
 counter = 0;
 clear displacement2
 if isempty(tr_end)
    tr_end = size(coordintime,2);
 end
 TP = struct;
 for totrack = 1:size(coordintime,2)%tr_1:tr_end 1:size(coordintime,2) % need to loop over tracks of a  given colony
     % find the number of usable time points(continuous) in given track
     txy = [];
    
     % coordintime(totrack).dat;
     if ~isempty(coordintime(totrack).dat)
         [tmp3,~]=find(coordintime(totrack).dat(:,3) == 0); % see if there are breaks in the track (zero coordinate)
         if isempty(tmp3)
            % disp('continuous track')
             good_tp = size(coordintime(totrack).dat,1);
         end
         if ~isempty(tmp3)
             %disp('non-continuous track')
             good_tp = tmp3(1)-1;
         end
         %disp(good_tp);
         v = [];
         dispacement = [];
         trace_lengths = [];
         if (good_tp>=shortesttrack)
             counter = counter+1;             
             txy = cat(2,(1:good_tp)',coordintime(totrack).dat(1:good_tp,1:2));
             for ii=1:(good_tp-1) %lagtimes %
                 dispacement2 = [];
                 for jj=1:(good_tp-ii)% loop over all pairs separated by lagtimes
                     % if use jj=1:ii:(good_tp-ii) then the
                     % averaging will be over only independent pairs of points separated by lagtimes
                     tp1 =jj;
                     tp2 = jj+ii;
                     dx=(txy(tp2,2)-txy(tp1,2))*pxtomicron;
                     dy = (txy(tp2,3)-txy(tp1,3))*pxtomicron;
                     % distance traveled by cell celnter in time from tp1 to tp2
                     d0 = power((power(dx,2)+power(dy,2)),0.5);% columns 2:3 are xy
                     % squared dispalcement traveled by cell celnter in time from tp1 to tp2
                     d2 = ((power(dx,2)+power(dy,2)));%                     
                     dt = ((tp2-tp1))*(delta_t/60);% time interval in hours
                     TP(ii).times(jj,1:3) = [tp1 tp2 dt];
                     v(jj,1:2) = [txy(jj,1)*(delta_t/60);  d0/dt];% in micons/hour
                     dispacement(jj,1:2) = [txy(jj,1)*(delta_t/60);  d0];% in micons
                     dispacement2(jj,1:2) = [jj;  d2];% in micons
                 end
                 % disp(size(dispacement2(:,2),1));
                 n_lags = (good_tp-ii);%size(dispacement2(:,2),1);
                 %disp(((size(nonzeros(dispacement2(:,2)),1)*delta_t)/60))
                 msd(totrack).dat(ii,1) = sum((dispacement2(:,2)))/n_lags; %*delta_t)/60  [microns^2/hour] lag time = delta_t;
                 % average over number of time steps at each lag time
                 msd(totrack).dat(ii,2) = ii; % how many delta_t intervals taken as the lag time
                 msd(totrack).trace_lengths = (good_tp);
                 if ii == 1
                    mean_disp(totrack).dat = mean(dispacement(:,2));
                    velocity(totrack).v = v;
                    mean_speed(totrack).v = mean(v(:,2));
                    s(totrack).dat= dispacement;
                    total_disp(totrack).dat = (dispacement(end,2)-dispacement(1,2));%/size(dispacement,1)
               end
             end
             % for 2D trajectory, MSD = 4Dt;
             %estimate the slope from dy/(dx*delta_t/60) for each track, get
             %D=slope/4 [um^2/hour]             
ytofit = msd(totrack).dat(1:x1,1);
xtofit = (1:x1)'*delta_t/60;
cfit = fit(xtofit,ytofit,'poly1');
fit_out(totrack).dat = cfit;
% plot(xtofit,ytofit,'p');hold on
% plot(cfit);

slope_estimate(totrack).slope =  cfit.p1; 
D(totrack).coeff = slope_estimate(totrack).slope/4;
xx = randi(60);
hold on;figure(1),plot(msd(totrack).dat(:,2),msd(totrack).dat(:,1),'-.','MarkerFaceCOlor',colormap2(xx,:),'Markersize',14,'LineWidth',2); box on
             
         end

     end
     if isempty(coordintime(totrack).dat)
         disp('this track is empty')
     end
 end 
 validTracks = counter;
 h  = figure(1);
 h.CurrentAxes.LineWidth = 2;
 h.CurrentAxes.FontSize = 10;
%  h.CurrentAxes.XTick = (1:3:lagtimes);
%  h.CurrentAxes.XTickLabel = (1:3:lagtimes)*delta_t/60;

 xlabel('Time,hours');%Lag time in multiples of imaging step, x 0.25 hr
 ylabel('Mean Squared Displacement, um^2')%/hour
 % title(['Track#' num2str(totrack) '; d^2/n , all pairs of points per lag time; no tracks <= ' num2str() 'hrs']);
 title(['Continuous tracks >= ' num2str(shortesttrack*delta_t/60) 'hrs;Total ' num2str(counter) ' Tracks;d^2/all pairs of points per t_l_a_g']);
 %xlim([0 lagtimes+1]);
 tmp4 = cat(1,msd.dat);
 ylim([0 round(max(tmp4(:,1)))+10]);%round(max(tmp4(:,1)))

 diff_coeff = cat(1,D.coeff);% estimated diffusion coefficients for each individual track that was long enough
 figure(2), histogram(diff_coeff,'binwidth',2,'normalization','probability','FaceColor','r');%
 h  = figure(2);
 h.CurrentAxes.LineWidth = 2;
 h.CurrentAxes.FontSize = 11;
 xlabel('Diffusion coefficient estimated from MSD vs lagtime slope, um^2/hr');
 ylabel('Probability')%
 title(['Continuous tracks >= ' num2str(shortesttrack*delta_t/60) 'hrs;Total ' num2str(counter) 'tracks']);
 ylim([0 1]);%
 xlim([0 round(max(diff_coeff))+1])
 % still need to determine the direction of movement of each cell

 MD  = cat(1,mean_disp.dat);
 figure(3), histogram(MD,'binwidth',0.2,'normalization','probability','FaceColor','c','LineWidth',2);hold on;
 %plot(MD,'kp','Markersize',15,'MarkerFaceColor','c','LineWidth',2);hold on;
 h  = figure(3);
 h.CurrentAxes.LineWidth = 2;
 h.CurrentAxes.FontSize = 11;
 ylabel('Probability');
 xlabel('Mean Displacement per dt, um')%
 title(['Continuous tracks >= ' num2str(shortesttrack*delta_t/60) 'hrs;Total ' num2str(counter) 'tracks']);
 ylim([0 1]);%
 xlim([0 round(max(MD))+0.5]);
 
 mspeed = cat(1,mean_speed.v);
 figure(4),histogram(mspeed,'binwidth',1,'normalization','probability','FaceColor','m','LineWidth',2); box on%plot(mspeed,'kp','Markersize',15,'MarkerFaceColor','m','LineWidth',2);
 h  = figure(4);
 h.CurrentAxes.LineWidth = 2;
 h.CurrentAxes.FontSize = 11;
 ylabel('Probability');
 xlabel('Mean Speed per dt, um/hr')%;
 ylim([0 1]);
 title(['Continuous tracks >= ' num2str(shortesttrack*delta_t/60) 'hrs;Total ' num2str(counter) 'tracks']);
 xlim([0 round(max(mspeed))+3]);
 
 totalD = cat(1,total_disp.dat); 
 figure(5),histogram(totalD,'binwidth',1,'normalization','probability','FaceColor','b','LineWidth',2); box on%plot(mspeed,'kp','Markersize',15,'MarkerFaceColor','m','LineWidth',2);
 h  = figure(5);
 h.CurrentAxes.LineWidth = 2;
 h.CurrentAxes.FontSize = 11;
 
 ylabel('Probability');
 xlabel('Total Cell Displacement, um');
 ylim([0 1]);
 title(['Continuous tracks >= ' num2str(shortesttrack*delta_t/60) 'hrs;Total ' num2str(counter) 'tracks']);
 %xlim([0 round(max(totalD))+3]);
 
 
end