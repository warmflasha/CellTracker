function varargout = SyringePump_GUI(varargin)
% SYRINGEPUMP_GUI MATLAB code for SyringePump_GUI.fig
%      SYRINGEPUMP_GUI, by itself, creates a new SYRINGEPUMP_GUI or raises the existing
%      singleton*.
%
%      H = SYRINGEPUMP_GUI returns the handle to a new SYRINGEPUMP_GUI or the handle to
%      the existing singleton*.
%
%      SYRINGEPUMP_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SYRINGEPUMP_GUI.M with the given input arguments.
%
%      SYRINGEPUMP_GUI('Property','Value',...) creates a new SYRINGEPUMP_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SyringePump_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SyringePump_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% % syringe diameter
% hamilton gas tight syringes
% 1705 : 50uL 1.030mm
% 1710 : 100uL 1.457 mm
% 1750 : 500uL 3.256 mm


% Edit the above text to modify the response to help SyringePump_GUI

% Last Modified by GUIDE v2.5 27-Jul-2012 16:08:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SyringePump_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SyringePump_GUI_OutputFcn, ...
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


% --- Executes just before SyringePump_GUI is made visible.
function SyringePump_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SyringePump_GUI (see VARARGIN)

% 1 - set up the serial port

s = serial('COM8');
fopen(s);
set(s,'Baudrate',19200,'Parity','none','StopBits',1);
set(s,'ReadAsyncMode','continuous');
set(s,'Terminator',3,'Timeout',0.5);
handles.serial_port = s;

s

handles.syringeDiameter = '11.99';
handles.pumpDir = 'INF';
handles.flowRate = '50'
handles.flowRateUnit = 'MH';

handles = UpdatePumpParams(handles)

% Choose default command line output for SyringePump_GUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SyringePump_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SyringePump_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run_pushbutton.
function run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = UpdatePumpParams(handles);

cmd = 'RUN';
 fprintf(handles.serial_port, '%s\r', cmd)
 answer = fscanf(handles.serial_port)
% handles
 % Update handles structure
guidata(hObject, handles);

% --- Executes on button press in stop_pushbutton.
function stop_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stop_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cmd = 'STP';
fprintf(handles.serial_port, '%s\r', cmd);
answer = fscanf(handles.serial_port)


% Update handles structure
guidata(hObject, handles);
 
function syringeDiam_edit_Callback(hObject, eventdata, handles)
% hObject    handle to syringeDiam_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.syringeDiameter = get(hObject,'String');% returns contents of syringeDiam_edit as text
% str2double(get(hObject,'String'))% returns contents of syringeDiam_edit as a double
handles = UpdatePumpParams(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function syringeDiam_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to syringeDiam_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FlowRateValue_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FlowRateValue_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.flowRate = get(hObject,'String');% returns contents of FlowRateValue_edit as text
%        str2double(get(hObject,'String')) returns contents of FlowRateValue_edit as a double

handles = UpdatePumpParams(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function FlowRateValue_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FlowRateValue_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% close the serial port before closing the figure

fclose(handles.serial_port);

% Hint: delete(hObject) closes the figure
delete(hObject);




% --- Executes on selection change in direction_popupmenu.
function direction_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to direction_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String')) %returns direction_popupmenu contents as cell array
pumpdir = contents{get(hObject,'Value')} % returns selected item from direction_popupmenu



switch pumpdir
    
    case 'infusion'
       handles. pumpDir = 'INF';
    case 'withdrawal'
       handles. pumpDir = 'WDR';
end

handles = UpdatePumpParams(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function direction_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to direction_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FlowRateUnit_popupmenu.
function FlowRateUnit_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to FlowRateUnit_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));% returns FlowRateUnit_popupmenu contents as cell array
flowRateUnit =   contents{get(hObject,'Value')};% returns selected item from FlowRateUnit_popupmenu


switch flowRateUnit
    
    case 'ul/hr'
       handles.flowRateUnit = 'UH';
    case 'ml/hr'
       handles.flowRateUnit = 'MH';
end

handles = UpdatePumpParams(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function FlowRateUnit_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FlowRateUnit_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function handles = UpdatePumpParams(handles)

% set the flow rate
cmd = ['RAT ' handles.flowRate ' ' handles.flowRateUnit]; % flowrate
fprintf(handles.serial_port, '%s\r', cmd);
answer = fscanf(handles.serial_port);
set(handles.FlowRateValue_edit,'String',handles.flowRate);

popUpContent = cellstr(get(handles.FlowRateUnit_popupmenu,'String'));%
switch handles.flowRateUnit
    
    case 'MH'
        
        for ii = 1:length(popUpContent)
        if strcmp(char(popUpContent{ii}),'ml/hr')
        inds = ii;
        end
        end
        set(handles.FlowRateUnit_popupmenu,'Value',inds)
        
    case 'UH'
        
        for ii = 1:length(popUpContent)
        if strcmp(char(popUpContent{ii}),'ul/hr')
        inds = ii;
        end
        end
        set(handles.FlowRateUnit_popupmenu,'Value',inds);
end

cmd = ['RAT']; % ask what is the flowrate
fprintf(handles.serial_port, '%s\r', cmd);
answer = fscanf(handles.serial_port);
set(handles.flowRateCtrl_text,'String',answer(1:end));


% set the syringe diameter
cmd = ['DIA ' handles.syringeDiameter];% 5ml syringe
fprintf(handles.serial_port, '%s\r', cmd);
answer = fscanf(handles.serial_port);

cmd = ['DIA']; % ask what is the syringe diameter
fprintf(handles.serial_port, '%s\r', cmd);
disp('dia')
answer = fscanf(handles.serial_port)
set(handles.SyrDiamCTRL_text,'String',answer(5:end));

% set the pumping direction to infusion
cmd = ['DIR ' handles.pumpDir];
% cmd = ['DIR WDR'];
fprintf(handles.serial_port, '%s\r', cmd);
answer = fscanf(handles.serial_port);

cmd = ['DIR']; % ask what is the syringe diameter
fprintf(handles.serial_port, '%s\r', cmd);
answer = fscanf(handles.serial_port);
set( handles.pumpDirCTRL_text,'String',answer(5:end));
