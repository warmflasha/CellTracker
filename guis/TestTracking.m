function varargout = TestTracking(varargin)
% TESTTRACKING MATLAB code for TestTracking.fig
%      TESTTRACKING, by itself, creates a new TESTTRACKING or raises the existing
%      singleton*.
%
%      H = TESTTRACKING returns the handle to a new TESTTRACKING or the handle to
%      the existing singleton*.
%
%      TESTTRACKING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTTRACKING.M with the given input arguments.
%
%      TESTTRACKING('Property','Value',...) creates a new TESTTRACKING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TestTracking_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TestTracking_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TestTracking

% Last Modified by GUIDE v2.5 06-Apr-2011 14:30:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TestTracking_OpeningFcn, ...
    'gui_OutputFcn',  @TestTracking_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TestTracking is made visible.
function TestTracking_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TestTracking (see VARARGIN)

% Choose default command line output for TestTracking
handles.output = hObject;

handles.shownuc=[0 0];
handles.showsmad=[0 0];
handles.showcyto=[0 0];
handles.showcenters = [0 0];

handles.nucloaded=[0 0];
handles.smadloaded=[0 0];
handles.ploaded=0;
handles.tracked=[0 0];
handles.matched=0;
handles.faxes=[handles.axes1 handles.axes2];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TestTracking wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TestTracking_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Nuc1.
function Nuc1_Callback(hObject, eventdata, handles)
% hObject    handle to Nuc1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

fs={'*.jpg;*.tif;*.png;*.gif;*.TIF', 'Image Files'};
[ftoopen ptoopen] = uigetfile(fs);

if ftoopen==0
    return;
end

nf1=imread([ptoopen ftoopen]);
handles.nucloaded(1)=1;
handles.images(1).nuc=nf1;
handles.tracked(1)=0;
handles.matched=0;
handles.outdat{1}=[];

handles.impath=ptoopen;
set(handles.n1file,'String',ftoopen);

updateDisplay(handles,1);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in segmentimage1.
function segmentimage1_Callback(hObject, eventdata, handles)
% hObject    handle to segmentimage1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.ploaded
    if handles.nucloaded(1) && handles.smadloaded(1)
        [outdat cmask]=segmentImage(handles,1);
        handles.outdat{1}=outdat;
        handles.cmask{1}=cmask;
        handles.tracked(1)=1;
        updateDisplay(handles,1);
    end
    if handles.nucloaded(2) && handles.smadloaded(2)
        [outdat cmask]=segmentImage(handles,2);
        handles.outdat{2}=outdat;
        handles.cmask{2}=cmask;
        handles.tracked(2)=1;
        updateDisplay(handles,2);
    end
else
    display('Please load a parameter file before segmenting');
end
% Update handles structure
guidata(hObject, handles);

function [outdat cmask]=segmentImage(handles,index)
%segment the current image and store the data in handles.outdat

r=handles.images(index).nuc;
g=handles.images(index).smad;

figure;
[maskC statsN]=segmentCells(r,g);
[cmask statsN]=addCellAvr2Stats(maskC,g,statsN);
outdat=outputData4AWTracker(statsN,r);




function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in S1button.
function S1button_Callback(hObject, eventdata, handles)
% hObject    handle to S1button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


fs={'*.jpg;*.tif;*.png;*.gif;*.TIF', 'Image Files'};
[ftoopen ptoopen] = uigetfile(fs);

if ftoopen==0
    return;
end

nf1=imread([ptoopen ftoopen]);
handles.images(1).smad=nf1;
set(handles.s1file,'String',ftoopen);

handles.smadloaded(1)=1;

% Update handles structure
guidata(hObject, handles);

function updateDisplay(handles,index)

axes(handles.faxes(index));
hold on;

if handles.nucloaded(index)
    
    si=size(handles.images(index).nuc);
    
    if handles.shownuc(index) && handles.nucloaded(index)
        r=im2double(handles.images(index).nuc);
        r=imadjust(r,stretchlim(r,[0.1 0.999]));
    else
        r=zeros(si);
    end
    if handles.showsmad(index) && handles.smadloaded(index)
        g=im2double(handles.images(index).smad);
        g=imadjust(g,stretchlim(g));
    else
        g=zeros(si);
    end
    if handles.showcyto(index) && handles.tracked(index)
        b=handles.cmask{index};
    else
        b=zeros(si);
    end
    overlay=cat(3,r,g,b);
    imshow(overlay);
end;
if handles.tracked(index) && handles.showcenters(index)
    plot(handles.outdat{index}(:,1),handles.outdat{index}(:,2),'m.');
end
if handles.matched && handles.showcenters(index)
    px=handles.outdat{index}(:,1); py=handles.outdat{index}(:,2);
    if index==1
        for ii=1:length(px)
            text(px(ii)+5,py(ii)+5,num2str(ii),'Color','m');
        end
        nomatch=find(handles.outdat{1}(:,4)==-1);
        plot(px(nomatch),py(nomatch),'c.');
    elseif index==2
        nomatch=[];
        for ii=1:length(px)
            indsold=find(handles.outdat{1}(:,4)==ii);
            if ~isempty(indsold)
                text(px(ii)+5,py(ii)+5,num2str(indsold),'Color','m');
            else
                nomatch=[nomatch ii];
            end
        end
        plot(px(nomatch),py(nomatch),'c.');
    end
end
hold off;



% --- Executes on button press in loadnext.
function loadnext_Callback(hObject, eventdata, handles)
% hObject    handle to loadnext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

newnucfile=findnextfile(get(handles.n1file,'String'));
newsmadfile=findnextfile(get(handles.s1file,'String'));

handles.images(2).nuc=imread([handles.impath newnucfile]);
handles.nucloaded(2)=1;
handles.images(2).smad=imread([handles.impath newsmadfile]);
handles.smadloaded(2)=1;

set(handles.n2file,'String',newnucfile);
set(handles.s2file,'String',newsmadfile);

updateDisplay(handles,2);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in matchbutton.
function matchbutton_Callback(hObject, eventdata, handles)
% hObject    handle to matchbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if sum(handles.tracked)==2
handles.outdat=matchFramesEDS(handles.outdat);
handles.matched=1;
updateDisplay(handles,1);
updateDisplay(handles,2);
else
    disp('Please segment images before matching');
end
% Update handles structure
guidata(hObject, handles);



function Lbox_Callback(hObject, eventdata, handles)
% hObject    handle to Lbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Lbox as text
%        str2double(get(hObject,'String')) returns contents of Lbox as a double

global userParam;
userParam.L=str2double(get(hObject,'String'));

% --- Executes during object creation, after setting all properties.
function Lbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Lbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nextframesbutton.
function nextframesbutton_Callback(hObject, eventdata, handles)
% hObject    handle to nextframesbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.n1file,'String',get(handles.n2file,'String'));
set(handles.s1file,'String',get(handles.s2file,'String'));

handles.images(1)=handles.images(2);

if handles.tracked(2)
    handles.outdat{1}=handles.outdat{2};
end
handles.tracked(1)=handles.tracked(2);

newnucfile=findnextfile(get(handles.n1file,'String'));
newsmadfile=findnextfile(get(handles.s1file,'String'));

handles.images(2).nuc=imread([handles.impath newnucfile]);
handles.nucloaded(2)=1;
handles.images(2).smad=imread([handles.impath newsmadfile]);
handles.smadloaded(2)=1;
handles.tracked(2)=0;
handles.matched=0;

set(handles.n2file,'String',newnucfile);
set(handles.s2file,'String',newsmadfile);

updateDisplay(handles,1);
updateDisplay(handles,2);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in shownuc1.
function shownuc1_Callback(hObject, eventdata, handles)
% hObject    handle to shownuc1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shownuc1

handles.shownuc(1)=get(hObject,'Value');
updateDisplay(handles,1);
% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in showsmad1.
function showsmad1_Callback(hObject, eventdata, handles)
% hObject    handle to showsmad1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showsmad1
handles.showsmad(1)=get(hObject,'Value');
updateDisplay(handles,1);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in showcyto1.
function showcyto1_Callback(hObject, eventdata, handles)
% hObject    handle to showcyto1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showcyto1

handles.showcyto(1)=get(hObject,'Value');
updateDisplay(handles,1);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in shownuc2.
function shownuc2_Callback(hObject, eventdata, handles)
% hObject    handle to shownuc2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shownuc2
handles.shownuc(2)=get(hObject,'Value');
updateDisplay(handles,2);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in showsmad2.
function showsmad2_Callback(hObject, eventdata, handles)
% hObject    handle to showsmad2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showsmad2
handles.showsmad(2)=get(hObject,'Value');
updateDisplay(handles,2);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in showcyto2.
function showcyto2_Callback(hObject, eventdata, handles)
% hObject    handle to showcyto2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showcyto2
handles.showcyto(2)=get(hObject,'Value');
updateDisplay(handles,2);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in showcenters1.
function showcenters1_Callback(hObject, eventdata, handles)
% hObject    handle to showcenters1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showcenters1

handles.showcenters(1)=get(hObject,'Value');
updateDisplay(handles,1);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in showcenters2.
function showcenters2_Callback(hObject, eventdata, handles)
% hObject    handle to showcenters2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showcenters2

handles.showcenters(2)=get(hObject,'Value');
updateDisplay(handles,2);
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in loadpfile.
function loadpfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadpfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global userParam;

[fn pn]=uigetfile('~/Dropbox/shared matlab/findNucEDS/*Param*.m');
if fn==0
    return;
end
scriptname=strtok(fn,'.');
try
    oldd=pwd;
    cd(pn);
    if handles.nucloaded(1)
        r=handles.images(1).nuc;
        eval([scriptname '(r)']);
    else
        eval([scriptname '([672 512])']);
        warning('No image loaded. using default image size 672x512');
    end
    cd(oldd);
    set(handles.paramfile,'String',scriptname);
    handles.param_scriptname=scriptname;
    handles.param_path=pn;
    handles.ploaded=1;
catch
    warning('New paramter file not loaded');
end
% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in reloadpfile.
function reloadpfile_Callback(hObject, eventdata, handles)
% hObject    handle to reloadpfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global userParam;

scriptname=handles.param_scriptname;
pn=handles.param_path;
try
    oldd=pwd;
    cd(pn);
    if handles.nucloaded(1)
        r=handles.images(1).nuc;
        eval([scriptname '(r)']);
    else
        eval([scriptname '([672 512])']);
        warning('No image loaded. using default image size 672x512');
    end
    cd(oldd);
catch
    warning('Could not reexecute param file');
end
