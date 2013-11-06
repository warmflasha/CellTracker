function handles = UpdatePlotDisplay(hObject,handles)

if handles.OKdatatrack
    global DataIF dataTrack
    
    if ~handles.showSingleCell
        
        cells = dataTrack.allCells;
        feedings = dataTrack.feedings;
        pictimes = dataTrack.pictimes;
        
        
        axes(handles.FigurePlot); cla; hold on;
        curseurFluor1=[]; avgreturn=[];
        if handles.showFluor1Plot
            if handles.useRatioForPlot==1
                [avgreturn,curseurFluor1] = averagePlot2(cells,pictimes,[2],'PlotStyle','g.-','frameNb',handles.currentImageIndex);
            elseif handles.useRatioForPlot==2
                [avgreturn,curseurFluor1] = averagePlot2(cells,pictimes,[2 1],'PlotStyle','g.-','frameNb',handles.currentImageIndex);
            elseif handles.useRatioForPlot==3
                [avgreturn,curseurFluor1] = averagePlot2(cells,pictimes,[2 3],'PlotStyle','g.-','frameNb',handles.currentImageIndex);
            end
        end
        
        handles.What2plot = 'average';
        handles.plotCursorFluor1 =  curseurFluor1;
        handles.avgreturnFluor1 = avgreturn;
        
        curseurNuc=[];
        if handles.showNucPlot
            if handles.useRatioForPlot==1
                [avgreturn,curseurNuc] = averagePlot2(cells,pictimes,[1],'PlotStyle','r.-','frameNb',handles.currentImageIndex);
            elseif handles.useRatioForPlot==2 || handles.useRatioForPlot==3
                [avgreturn,curseurNuc] = averagePlot2(cells,pictimes,[1 1],'PlotStyle','r.-','frameNb',handles.currentImageIndex);
            end
        end
        handles.plotCursorNuc=curseurNuc;
        handles.avgreturnNuc=avgreturn;
        set(handles.text_plot,'String','average plot');
        
        
        hold off;
        % Update handles structure et plots
        guidata(hObject, handles);
        
    else
        
        cells = dataTrack.FilteredCells;
        feedings = dataTrack.feedings;
        pictimes = dataTrack.pictimes;
        paxes = handles.FigurePlot;
        ii = handles.cell2display;
        try
            births = dataTrack.births;
        catch
            births=[];
        end
        %     look in the births array for the current cell
        if ~isempty(births)
            birthIndex = find([births.cellN]==cells(ii).cellID);
        else
            birthIndex = [];
        end
        
        if isfield(cells,'merge')
            set(handles.text_plot,'String',['index in the cell2array (cell ID) : ' int2str(cells(ii).cellID) '  ||   merge : ' int2str(cells(ii).merge)]);
        else
            set(handles.text_plot,'String',['index in the cell2array (cell ID) : ' int2str(cells(ii).cellID)]);
        end
        set(handles.textplot2,'String',['no divisions detected here']);
        
        if ~isempty(birthIndex)
            CurrentCellBirthTime = [births(birthIndex).time];
            
            for abc = 1:length(birthIndex)
                siblingID(abc) = births(birthIndex(abc)).sibling.cellN;
            end
            set(handles.textplot2,'String',['division(s) at frame : ' int2str(CurrentCellBirthTime) '  ||   sibbling(s) : ' int2str(siblingID)]);
        end
        
        % plot single cell trace in figurePlot window
        axes(handles.FigurePlot); cla; hold on;
        
        if cells(ii).good
            plotspline=1;
            currentCellData.timePoints = pictimes(cells(ii).onframes);
            currentCellData.nucSpline = cells(ii).sdata(:,1)/cells(ii).fdata(1,1);
            currentCellData.nucPoints = cells(ii).fdata(:,1)/cells(ii).fdata(1,1);
            currentCellData.smadPoint = cells(ii).fdata(:,2)./cells(ii).fdata(:,3);
            currentCellData.smadSpline = cells(ii).sdata(:,2)./cells(ii).sdata(:,3);
        else
            plotspline=0;
        end
        
        avgreturn=[]; curseur=[];
        if handles.showNucPlot
            if handles.useRatioForPlot==2 || handles.useRatioForPlot==3
                [avgreturn curseur]=singleCellPlot2(cells(ii),pictimes,1,'NormToStart',1,'plotspline',plotspline,'PlotStyle','r.',...
                    'frameNb',handles.currentImageIndex); hold on;
            else
                [avgreturn curseur]=singleCellPlot2(cells(ii),pictimes,1,'NormToStart',0,'plotspline',plotspline,'PlotStyle','r.',...
                    'frameNb',handles.currentImageIndex); hold on;
            end
        end
        handles.plotCursorNuc=curseur;
        handles.avgreturnNuc=avgreturn;
        
        avgreturn=[]; curseur=[];
        if handles.showFluor1Plot
            if handles.useRatioForPlot==2
                [avgreturn curseur]=singleCellPlot2(cells(ii),pictimes,[2 1],'plotspline',plotspline,'PlotStyle','g.',...
                    'frameNb',handles.currentImageIndex); hold on;
            elseif handles.useRatioForPlot==1
                [avgreturn curseur]=singleCellPlot2(cells(ii),pictimes,2,'plotspline',plotspline,'PlotStyle','g.',...
                    'frameNb',handles.currentImageIndex); hold on;
            elseif handles.useRatioForPlot==3
                [avgreturn curseur]=singleCellPlot2(cells(ii),pictimes,[2 3],'plotspline',plotspline,'PlotStyle','g.',...
                    'frameNb',handles.currentImageIndex); hold on;
            end
        end
        handles.plotCursorFluor1=curseur;
        handles.avgreturnFluor1=avgreturn;
        
        if handles.showFluor2Plot
            if handles.useRatioForPlot==3
                singleCellPlot2(cells(ii),pictimes,[4 5],'plotspline',plotspline); hold on;
            elseif handles.useRatioForPlot==1
                singleCellPlot2(cells(ii),pictimes,4,'plotspline',plotspline); hold on;
            elseif handles.useRatioForPlot==2
                singleCellPlot2(cells(ii),pictimes,[4 1],'plotspline',plotspline); hold on;
            end
        end
        
        
        
        if handles.CCCexpt
            currentCellData.fmedianum=[feedings.medianum];
            currentCellData.ftimes=[feedings.time];
        end
        
        
        hold off;
        
        
        
        %
        % % % % return data in the workspace
        assignin('base','currentCell',cells(ii));
        handles.plotCursor = curseur;
    end
    
    ymax=maxnoinf([handles.avgreturnFluor1; handles.avgreturnNuc]);
    ymin=min([handles.avgreturnFluor1; handles.avgreturnNuc]);
    ylim([0.9*ymin ymax*1.1]);
    if handles.CCCexpt
        hold on;
        drawFeedingLines(feedings);
        hold off;
    end
    if handles.showSingleCell
        xmin=pictimes(cells(ii).onframes(1)); xmax=pictimes(cells(ii).onframes(end));
    else
        xmin=min(pictimes); xmax=max(pictimes);
    end

    xlim([0.9*xmin 1.1*xmax]);
    % UpdateImageDisplay(hObject,handles)
    
end