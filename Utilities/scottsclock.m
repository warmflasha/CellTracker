classdef scottsclock < handle
    % Based on Scott Frasso's scottsclock
    % Extended by Aleksander Veksler of Kongsberg Maritime to put a clock
    % on the current axes, and be updated on demand instead of by timer,
    % and by any time instead of real time.
    methods
        function o = scottsclock(x0, y0, dia, ah)
            if ~exist('x0', 'var'), x0=0; end;
            if ~exist('y0', 'var'), y0=0; end;
            if ~exist('dia', 'var'), dia=20; end;
            if ~exist('ah', 'var'), ah = gca; end;
            o.ah = ah;
            set(get(ah, 'Parent'), 'CurrentAxes', ah); % Make sure that the program works on correct axes;
            
            dia = dia/20; % In original code, clock had diameter of 20;
            
            
            %PreAllocate arrays for faster startup
            
            handles = o.handles; % Convenience
            
            HourHandData = zeros(1,4);
            MinuteHandData = zeros(1,4);
            SecondHandData = zeros(1,4);
            pDx = zeros(1,5);
            pDy = zeros(1,5);

            %Draw the perimeter of the clock and position the figure
            R=linspace(0,2*pi,1000);
            x1=9*cos(R);
            y1=9*sin(R);
            h = plot(x1*dia+x0,y1*dia+y0,'b','linewidth',5*dia,'color','k'); %Draws a thick black circle
            handles(end+1) = h;
            hold on
            %axis off
            %axis([-10 10 -10 10]) %Draws the figure with +/-10 for [Xmin Xmin Ymin Ymax]
            %axis equal
            
            % Plot the numbers 1-12 on the screen
            % --Declare variables to be used in the plotting the clock numbers
            Clk_fSize = 12;                                  % controls the font size of the numbers of the clock
            Clk_fTheta = (pi/3:-2*pi/12:-3*pi/2)';           % sets the Theta for each number position
            Clk_fRad = 7*dia;                                 % sets the Raduis for each number position
            Clk_numbas = (1:1:12)';
            Clk_nData = [Clk_fRad*cos(Clk_fTheta) Clk_fRad*sin(Clk_fTheta) Clk_numbas];
            h = text(Clk_nData(:,1)+x0,Clk_nData(:,2) + y0,num2str(Clk_nData(:,3)),...
                'horizontalAlignment','center','verticalAlignment','middle','FontSize',Clk_fSize);
            handles(end+1:end + length(h)) = h;
            
            %== Tic Marks ==
            % Define the Length of the Tic marks
            TLenStart = 8.1;    % Start of the Tick mark (distance from origin)
            TLenStop = 8.5;     % End of the Tick mark (distance from origin)
            [STX,STY,TTX,TTY] = ticMark(TLenStart,TLenStop);
            % Plot Skinny and Thick Tick marks on the clock face
            h = plot(STX*dia+x0,STY*dia+y0, 'linewidth',1,'color','k');
            handles(end+1: end + length(h)) = h;
            h= plot(TTX*dia+x0,TTY*dia+y0, 'linewidth',5,'color','k');
            handles(end+1: end + length(h)) = h;
            time = clock;
            [HpDx,HpDy,MpDx,MpDy,SpDx,SpDy] = GetPolyData(time);
            %Plot/Fill the 3 polygon hands for initial view
            o.hourhand = fill(HpDx*dia+x0,HpDy*dia+y0,'k');
            handles(end+1) = o.hourhand;
            o.minhand = fill(MpDx*dia +x0,MpDy*dia+y0,'k');
            handles(end+1) = o.minhand;
            %o.sechand = fill(SpDx*dia+x0,SpDy*dia +y0,'Color','r', 'EdgeColor', 'none');
            %handles(end+1) = o.sechand;
            hold off
            o.handles = handles;
            o.x0 = x0; o.y0=y0; o.dia = dia;
        end
        
        function updateClock(o, time)
            % time should be in format [year month day hour minute seconds]
            if ~exist('time', 'var'), time = clock; end
            
            x0 = o.x0; y0 = o.y0; dia = o.dia; % Convenience;

            [HpDx,HpDy,MpDx,MpDy,SpDx,SpDy] = GetPolyData(time);
            set(o.hourhand,'xdata',HpDx*dia+x0,'ydata',HpDy*dia + y0);
            set(o.minhand,'xdata',MpDx*dia +x0,'ydata',MpDy*dia + y0);
            set(o.sechand,'xdata',SpDx*dia +x0,'ydata',SpDy*dia + y0);
        end%end of the timerFcn
        function startRT(o)
            % Lets it run as a real-time clock, i.e. usual clock
            o.datimer = timer('timerfcn',{@updateClock, o},'period',.1,'executionmode','fixedrate');
            %start the timer
            start(o.datimer)
        end
        function hide(o)
            if o.hidden, return; end;
            for i = 1:length(o.handles)
                set(o.handles(i), 'Visible', 'off');
            end
            o.hidden = true;
        end
        function unhide(o)
            if ~o.hidden, return; end;
            for i = 1:length(o.handles)
                set(o.handles(i), 'Visible', 'on');
            end
            o.hidden = false;
        end
            
            

    end
    properties (Access = private)
        hourhand;
        minhand;
        sechand;
        datimer;
        x0;
        y0;
        dia;
        ah; %Axis handle where the clock is to be drawn
        handles = [];
        hidden = false;
        
    end
end

function updateClock(varargin)
    o = varargin{3};
    if ~ishandle(o.ah)
        % The user has probably closed the window, stopping timer to avoid
        % "invalid handle object" error. The try/catch has been added in case the
        % timer has never started it will just end without causing errors.
        try
            stop(o.datimer)
            delete(o.datimer)
        catch ME %#ok<NASGU>
        end
    else
        varargin{3}.updateClock();
    end
end

function [HpDx,HpDy,MpDx,MpDy,SpDx,SpDy] = GetPolyData(time)
        %GetPolyData is given the time in a vector and returns
        % the points that make up the polygons relative to the
        % time(in a vector) given to it. This angle of each 
        % polygon is calculated by the Initial angle of each hand
        % then the dimensions are specified through the _HandData
        % shown below. Finally the function PolyEngine is
        % called where it will return the data points that make up
        % the polygon. This is done to allow the polygons to be 
        % updated later without having to redifine there 
        % specifications here in GetPolyData.  
        %Initial Angle of Each Hand
        hoursTheta = (((time(4)*30)+(time(5)/2))-90)*(-pi/180);
        minsTheta = (((time(5)*6)-90)+time(6)/10)*(-pi/180);
        secsTheta= ((time(6)*6)-90)*(-pi/180);
        %Data Set for each hand
        %HandData = 'Front Length' 'Back Length' 'Front Width' 'Back Width'
        HourHandData = [5 5/3 .1 .3];
        % X     Y data for this polygon
        [HpDx,HpDy] = PolyEngine(hoursTheta,HourHandData);
        MinuteHandData  = [7 7/3 .1 .3];
        [MpDx,MpDy] = PolyEngine(minsTheta,MinuteHandData);
        SecondHandData = [7 7/3 .05 .15];
        [SpDx,SpDy] = PolyEngine(secsTheta,SecondHandData);
end %end GetPolyData

function [STX,STY,TTX,TTY] = ticMark(TLenStart,TLenStop)
            %ticMark is given the distance from center to start the tick
            % marks (TLenStart) and the distance from origin to stop the
            % tick marks (TLenStop).
            %STTTheta 60 point array going clockwise skinny ticmarks
            STTheta = pi/2:-2*pi/60:-3*pi/2;
            %Calculates X Y coordinates for all 60 skinny tick marks
            STX = [TLenStart*cos(STTheta') TLenStop*cos(STTheta')]'; 
            STY = [TLenStart*sin(STTheta') TLenStop*sin(STTheta')]';
            %TTTheta 12 point array going around clockwise thick tic marks
            TTTheta = pi/2:-2*pi/12:-3*pi/2;
            %Calculates X Y coordinates for all 12 thick tic marks
            TTX = [TLenStart*cos(TTTheta') TLenStop*cos(TTTheta')]'; 
            TTY = [TLenStart*sin(TTTheta') TLenStop*sin(TTTheta')]';
end %end ticmark function
   
function [pDx,pDy] = PolyEngine(Theta,HanData)
        %PolyEngine is given the initial angle and specifications for each
        % polygon it is to generate. It then calculates the data points
        % that will makeup the polygon and passes it back in two variables
        % making up a set of X and Y coordinates that corelate to the
        % current angle. This makes it easy to plot the points as well as
        % easy to change the polygons shape. At this time it is specified
        % with 4 data points but a 5th could be added easily with only
        % changing the data in this PolyEngine function.
    
        %-Hand Polygon Equations
        %==================================================================
        %-Calculate the length from origin to points A and B.
        oA = sqrt(HanData(1)^2+HanData(3)^2);
        %-Calculate the length from origin to points C and D.
        oB = sqrt(HanData(2)^2+HanData(4)^2);
        %-Calculate X Y coordinates of points A B C and D.
        %-Prepare the X Y data points to be easily passed back and plotted.
        pDx = [oA*cos(Theta+atan(HanData(3)/HanData(1))), ...
              (HanData(1)+HanData(3)*5)*cos(Theta),...
              oA*cos(Theta-atan(HanData(3)/HanData(1))),...
              oB*cos(Theta+atan(HanData(4)/HanData(2))+pi),...
              oB*cos(Theta-atan(HanData(4)/HanData(2))+pi)];
        pDy = [oA*sin(Theta+atan(HanData(3)/HanData(1))) (HanData(1)+HanData(3)*5)*sin(Theta) oA*sin(Theta-atan(HanData(3)/HanData(1))) oB*sin(Theta+atan(HanData(4)/HanData(2))+pi) oB*sin(Theta-atan(HanData(4)/HanData(2))+pi)];
end%end PolyEngine function
    
    