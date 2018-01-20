function [msd,slope_estimate,D,diff_coeff,mean_disp,total_disp,mean_speed,validTracks,MD,mspeed,TP,fit_out] = getCellmovement_params_IlastikTrack(coordintime,delta_t,trackID,x1,paramfile,local_neighbors,toplot2)
run(paramfile)
global userParam

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
TP = struct;
for totrack = trackID%
    good_tp= size(coordintime(totrack).dat,1);
    shortesttrack = good_tp;
    txy = [];
    if ~isempty(coordintime(totrack).dat)
        v = [];
        dispacement = [];
        trace_lengths = [];
        counter = counter+1;
        txy = cat(2,(1:good_tp)',coordintime(totrack).dat(1:good_tp,1:2));
        for ii=1:(good_tp-1) %lagtimes %
            dispacement2 = [];
            for jj=1:(good_tp-ii)% loop over all pairs separated by lagtimes
                % if use jj=1:ii:(good_tp-ii) then the
                % averaging will be over only independent pairs of points separated by lagtimes
                tp1 =jj;
                tp2 = jj+ii;
                dx=(txy(tp2,2)-txy(tp1,2))*userParam.pxtomicron;
                dy = (txy(tp2,3)-txy(tp1,3))*userParam.pxtomicron;
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
        % get the slope from the fit
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
       diff_coeff = cat(1,D.coeff);% estimated diffusion coefficients for each individual track 
         if toplot2 == 1
            if isempty(local_neighbors)
                hold on;figure(1),plot(msd(totrack).dat(:,2),msd(totrack).dat(:,1),'-.','MarkerFaceCOlor',colormap2(xx,:),'Markersize',14,'LineWidth',2); box on

                str1 = "Estimated D = " + num2str(diff_coeff) + " um^2/hr";
                titlestr = str1 + "\n" + " MSD calculated for all pairs of points per t_l_a_g";
                titlestr = compose(titlestr);
                title(titlestr);
                h  = figure(1);
                h.CurrentAxes.LineWidth = 2;
                h.CurrentAxes.FontSize = 10;
                h.CurrentAxes.XTick = 1:7:good_tp;
                h.CurrentAxes.XTickLabel = (1:7:good_tp)*delta_t/60;
                xlabel('Time,hours');%
                ylabel('Mean Squared Displacement, um^2')%/hour
                tmp4 = cat(1,msd.dat);
                ylim([0 round(max(tmp4(:,1)))+10]);%round(max(tmp4(:,1)))
            end
            if ~isempty(local_neighbors)
                hold on;figure(1),scatter(msd(totrack).dat(:,2),msd(totrack).dat(:,1),[],local_neighbors(1:size(msd(totrack).dat),1),'filled','Marker','p'); box on
                str2 = "Color: Fraction of other type neighbors within " + num2str((userParam.local_sz*userParam.pxtomicron))+"um neighborhood";
                str1 = "Estimated D = " + num2str(diff_coeff) + " um^2/hr";
                titlestr = str1 + "\n" + " MSD calculated for all pairs of points per t_l_a_g"+ "\n" + str2;
                titlestr = compose(titlestr);
                title(titlestr);
                h  = figure(1);
                h.CurrentAxes.LineWidth = 2;
                h.CurrentAxes.FontSize = 10;
                h.CurrentAxes.XTick = 1:7:good_tp;
                h.CurrentAxes.XTickLabel = (1:7:good_tp)*delta_t/60;
                xlabel('Time,hours');%
                ylabel('Mean Squared Displacement, um^2')%/hour
                h.Colormap = jet;
                caxis([0 1]);
                colorbar
                tmp4 = cat(1,msd.dat);
                ylim([0 round(max(tmp4(:,1)))+10]);%round(max(tmp4(:,1)))
            end
        end
    end
    if isempty(coordintime(totrack).dat)
        disp('this track is empty')
    end
end
validTracks = counter;
MD  = cat(1,mean_disp.dat);
mspeed = cat(1,mean_speed.v);
totalD = cat(1,total_disp.dat);


end