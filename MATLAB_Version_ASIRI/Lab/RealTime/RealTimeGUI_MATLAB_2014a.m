function varargout = RealTimeGUI_MATLAB_2014a(varargin)
% REALTIMEGUI_MATLAB_2014A MATLAB code for RealTimeGUI_MATLAB_2014a.fig
%
%   This is a utility to see data in real (3-second) delay of the data that
%   comes out from the FCTD fish. This direct data feed does not read the
%   time stamp. The feed should have 112 HEX characters for each line, where 22
%   chars are designated to CTD, 40 char is designated to Micro
%   Conductivity, 36 to YEI data, 4 to Altimeter Travel Time, and 8 for
%   record counter.
%
%   Written by San Nguyen 2015 01 17
%
%      REALTIMEGUI_MATLAB_2014A, by itself, creates a new REALTIMEGUI_MATLAB_2014A or raises the existing
%      singleton*.
%
%      H = REALTIMEGUI_MATLAB_2014A returns the handle to a new REALTIMEGUI_MATLAB_2014A or the handle to
%      the existing singleton*.
%
%      REALTIMEGUI_MATLAB_2014A('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REALTIMEGUI_MATLAB_2014A.M with the given input arguments.
%
%      REALTIMEGUI_MATLAB_2014A('Property','Value',...) creates a new REALTIMEGUI_MATLAB_2014A or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RealTimeGUI_MATLAB_2014a_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RealTimeGUI_MATLAB_2014a_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RealTimeGUI_MATLAB_2014a

% Last Modified by GUIDE v2.5 18-Jan-2015 13:39:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RealTimeGUI_MATLAB_2014a_OpeningFcn, ...
                   'gui_OutputFcn',  @RealTimeGUI_MATLAB_2014a_OutputFcn, ...
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
end

% --- Executes just before RealTimeGUI_MATLAB_2014a is made visible.
function RealTimeGUI_MATLAB_2014a_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RealTimeGUI_MATLAB_2014a (see VARARGIN)

% Choose default command line output for RealTimeGUI_MATLAB_2014a
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RealTimeGUI_MATLAB_2014a wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% change the default closing function
set(hObject,'CloseRequestFcn',@(hObject,eventdata)RealTimeGUI_MATLAB_2014a('RealTimeGUI_MATLAB_2014a_ClosingFcn'));


UpdateUserOptions(handles);

global FCTD_Data_Stream_LeftOver;
global FCTD_SerialStream;
global FCTD_DataStorage;

FCTD_Data_Stream_LeftOver = '';
FCTD_DataStorage.cond = [];
FCTD_DataStorage.temp = [];
FCTD_DataStorage.uCond = [];
FCTD_DataStorage.gyro = [];
FCTD_DataStorage.acceleration = [];
FCTD_DataStorage.compass = [];
FCTD_DataStorage.altTime = [];

FCTD_SerialStream = serial('/dev/tty.usbserial-A600cfg9');
FCTD_SerialStream.BaudRate = 38400;
FCTD_SerialStream.DataBits = 8;
FCTD_SerialStream.Parity = 'none';
FCTD_SerialStream.Name = 'FCTD';
FCTD_SerialStream.StopBits = 1;
FCTD_SerialStream.OutputBufferSize = 8192;
FCTD_SerialStream.Terminator = '';
FCTD_SerialStream.Timeout = 1;
FCTD_SerialStream.InputBufferSize = 8192;
FCTD_SerialStream.BytesAvailableFcnCount = 112;
FCTD_SerialStream.BytesAvailableFcnMode = 'byte';
FCTD_SerialStream.BytesAvailableFcn = {@ReadSerial,handles};

fopen(FCTD_SerialStream);

% tic;
% ReadSerial();
% toc
% UpdatePlots(handles);
% toc;

% fopen(FCTD_SerialStream);

% delete(timerfindall('Tag','RealTimeGUI_MATLAB_2014a_Timer'));
% RealTimeGUI_MATLAB_2014a_Timer = timer();
% RealTimeGUI_MATLAB_2014a_Timer.TimerFcn = {@UpdatePlots,handles};
% RealTimeGUI_MATLAB_2014a_Timer.Period = 20;
% RealTimeGUI_MATLAB_2014a_Timer.BusyMode = 'drop';
% RealTimeGUI_MATLAB_2014a_Timer.ErrorFcn = 'disp([datestr(now,''[yyyy.mm.dd HH:MM:SS]'') ''Error Occurred in UpdatePlots function'']);';
% RealTimeGUI_MATLAB_2014a_Timer.StopFcn = '';
% RealTimeGUI_MATLAB_2014a_Timer.TasksToExecute = Inf;
% RealTimeGUI_MATLAB_2014a_Timer.Tag = 'RealTimeGUI_MATLAB_2014a_Timer';
% RealTimeGUI_MATLAB_2014a_Timer.Name = 'RealTimeGUI_MATLAB_2014a_Timer';
% 
% RealTimeGUI_MATLAB_2014a_Timer.ExecutionMode = 'fixedDelay';
% start(RealTimeGUI_MATLAB_2014a_Timer);

% delete(timerfindall('Tag','RealTimeGUI_MATLAB_2014a_Timer2'));
% RealTimeGUI_MATLAB_2014a_Timer2 = timer();
% RealTimeGUI_MATLAB_2014a_Timer2.TimerFcn = {@ReadSerial};
% RealTimeGUI_MATLAB_2014a_Timer2.Period = 20;
% RealTimeGUI_MATLAB_2014a_Timer2.BusyMode = 'drop';
% RealTimeGUI_MATLAB_2014a_Timer2.ErrorFcn = 'disp([datestr(now,''[yyyy.mm.dd HH:MM:SS]'') ''Error Occurred in ReadSerial function'']);';
% RealTimeGUI_MATLAB_2014a_Timer2.StopFcn = '';
% RealTimeGUI_MATLAB_2014a_Timer2.TasksToExecute = Inf;
% RealTimeGUI_MATLAB_2014a_Timer2.Tag = 'RealTimeGUI_MATLAB_2014a_Timer2';
% RealTimeGUI_MATLAB_2014a_Timer2.Name = 'RealTimeGUI_MATLAB_2014a_Timer2';
% 
% RealTimeGUI_MATLAB_2014a_Timer2.ExecutionMode = 'fixedDelay';
% start(RealTimeGUI_MATLAB_2014a_Timer2);

% UpdatePlots(handles);

end

% --- Executes just before RealTimeGUI_MATLAB_2014a is exited.
function RealTimeGUI_MATLAB_2014a_ClosingFcn()
global FCTD_SerialStream;
try
    fclose(FCTD_SerialStream);
    delete(FCTD_SerialStream);
catch err
    disp(err);
end
disp(datestr(now));
delete(gcf);
end


% --- Outputs from this function are returned to the command line.
function varargout = RealTimeGUI_MATLAB_2014a_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in timeAuto.
function timeAuto_Callback(hObject, eventdata, handles)
% hObject    handle to timeAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of timeAuto
if get(hObject,'value')
    set(handles.timeMin,'enable','off');
    set(handles.timeMax,'enable','off');
else
    set(handles.timeMin,'enable','on');
    set(handles.timeMax,'enable','on');
end
UpdateUserOptions(handles);
end

function timeMin_Callback(hObject, eventdata, handles)
% hObject    handle to timeMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeMin as text
%        str2double(get(hObject,'String')) returns contents of timeMin as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val >= RealTimeGUI_MATLAB_2014a_settings.timeMax
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.timeMin));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function timeMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function timeMax_Callback(hObject, eventdata, handles)
% hObject    handle to timeMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeMax as text
%        str2double(get(hObject,'String')) returns contents of timeMax as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val<= RealTimeGUI_MATLAB_2014a_settings.timeMin
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.timeMax));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function timeMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function timeWind_Callback(hObject, eventdata, handles)
% hObject    handle to timeWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeWind as text
%        str2double(get(hObject,'String')) returns contents of timeWind as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val<1
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.timeWind));
else
    set(hObject,'String',num2str(floor(val)));
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function timeWind_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeWind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in timeUnit.
function timeUnit_Callback(hObject, eventdata, handles)
% hObject    handle to timeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns timeUnit contents as cell array
%        contents{get(hObject,'Value')} returns selected item from timeUnit
UpdateUserOptions(handles);
end

% --- Executes during object creation, after setting all properties.
function timeUnit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeUnit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in uCondFFTxScale.
function uCondFFTxScale_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTxScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of uCondFFTxScale

if get(hObject,'value')
    set(handles.uCondFFTxMin,'enable','off');
    set(handles.uCondFFTxMax,'enable','off');
else
    set(handles.uCondFFTxMin,'enable','on');
    set(handles.uCondFFTxMax,'enable','on');
end
UpdateUserOptions(handles);

end

% --- Executes on button press in uCondFFTyScale.
function uCondFFTyScale_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTyScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of uCondFFTyScale

if get(hObject,'value')
    set(handles.uCondFFTyMin,'enable','off');
    set(handles.uCondFFTyMax,'enable','off');
else
    set(handles.uCondFFTyMin,'enable','on');
    set(handles.uCondFFTyMax,'enable','on');
end
UpdateUserOptions(handles);

end

function uCondFFTxMin_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTxMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uCondFFTxMin as text
%        str2double(get(hObject,'String')) returns contents of uCondFFTxMin as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val >= RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMax
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMin));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function uCondFFTxMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uCondFFTxMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function uCondFFTxMax_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTxMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uCondFFTxMax as text
%        str2double(get(hObject,'String')) returns contents of uCondFFTxMax as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val <= RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMin
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMax));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function uCondFFTxMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uCondFFTxMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function uCondFFTyMin_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTyMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uCondFFTyMin as text
%        str2double(get(hObject,'String')) returns contents of uCondFFTyMin as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val >= RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMax
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMin));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function uCondFFTyMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uCondFFTyMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function uCondFFTyMax_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTyMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uCondFFTyMax as text
%        str2double(get(hObject,'String')) returns contents of uCondFFTyMax as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val <= RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMin
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMax));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function uCondFFTyMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uCondFFTyMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in uCondFFTreset.
function uCondFFTreset_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTreset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global RealTimeGUI_MATLAB_2014a_uCondFFT;
RealTimeGUI_MATLAB_2014a_uCondFFT = NaN(size(RealTimeGUI_MATLAB_2014a_uCondFFT));
end

function uCondFFTn_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uCondFFTn as text
%        str2double(get(hObject,'String')) returns contents of uCondFFTn as a double
global RealTimeGUI_MATLAB_2014a_settings;
global RealTimeGUI_MATLAB_2014a_uCondFFT;
val = str2double(get(hObject,'String'));

if isnan(val)
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondFFTn));
else
    if val == RealTimeGUI_MATLAB_2014a_settings.uCondFFTn
        RealTimeGUI_MATLAB_2014a_uCondFFT = NaN(size(RealTimeGUI_MATLAB_2014a_uCondFFT));
    end
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function uCondFFTn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uCondFFTn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in uCondFFTlogScale.
function uCondFFTlogScale_Callback(hObject, eventdata, handles)
% hObject    handle to uCondFFTlogScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of uCondFFTlogScale
UpdateUserOptions(handles);
end

% --- Executes on button press in uCondAuto.
function uCondAuto_Callback(hObject, eventdata, handles)
% hObject    handle to uCondAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of uCondAuto
if get(hObject,'value')
    set(handles.uCondMin,'enable','off');
    set(handles.uCondMax,'enable','off');
else
    set(handles.uCondMin,'enable','on');
    set(handles.uCondMax,'enable','on');
end
UpdateUserOptions(handles);
end

function uCondMin_Callback(hObject, eventdata, handles)
% hObject    handle to uCondMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uCondMin as text
%        str2double(get(hObject,'String')) returns contents of uCondMin as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val >= RealTimeGUI_MATLAB_2014a_settings.uCondMax
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondMin));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function uCondMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uCondMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function uCondMax_Callback(hObject, eventdata, handles)
% hObject    handle to uCondMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of uCondMax as text
%        str2double(get(hObject,'String')) returns contents of uCondMax as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val <= RealTimeGUI_MATLAB_2014a_settings.uCondMin
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondMax));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function uCondMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uCondMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in condAuto.
function condAuto_Callback(hObject, eventdata, handles)
% hObject    handle to condAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of condAuto
if get(hObject,'value')
    set(handles.condMin,'enable','off');
    set(handles.condMax,'enable','off');
else
    set(handles.condMin,'enable','on');
    set(handles.condMax,'enable','on');
end
UpdateUserOptions(handles);
end

function condMin_Callback(hObject, eventdata, handles)
% hObject    handle to condMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of condMin as text
%        str2double(get(hObject,'String')) returns contents of condMin as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val >= RealTimeGUI_MATLAB_2014a_settings.condMax
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.condMin));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function condMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to condMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function condMax_Callback(hObject, eventdata, handles)
% hObject    handle to condMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of condMax as text
%        str2double(get(hObject,'String')) returns contents of condMax as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val <= RealTimeGUI_MATLAB_2014a_settings.condMin
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.condMax));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function condMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to condMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in tempAuto.
function tempAuto_Callback(hObject, eventdata, handles)
% hObject    handle to tempAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tempAuto
if get(hObject,'value')
    set(handles.tempMin,'enable','off');
    set(handles.tempMax,'enable','off');
else
    set(handles.tempMin,'enable','on');
    set(handles.tempMax,'enable','on');
end
UpdateUserOptions(handles);
end

function tempMin_Callback(hObject, eventdata, handles)
% hObject    handle to tempMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tempMin as text
%        str2double(get(hObject,'String')) returns contents of tempMin as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val >= RealTimeGUI_MATLAB_2014a_settings.tempMax
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.tempMin));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function tempMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tempMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function tempMax_Callback(hObject, eventdata, handles)
% hObject    handle to tempMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tempMax as text
%        str2double(get(hObject,'String')) returns contents of tempMax as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val <= RealTimeGUI_MATLAB_2014a_settings.tempMin
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.tempMax));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function tempMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tempMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in altiAuto.
function altiAuto_Callback(hObject, eventdata, handles)
% hObject    handle to altiAuto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of altiAuto
if get(hObject,'value')
    set(handles.altiMin,'enable','off');
    set(handles.altiMax,'enable','off');
else
    set(handles.altiMin,'enable','on');
    set(handles.altiMax,'enable','on');
end
UpdateUserOptions(handles);
end

function altiMin_Callback(hObject, eventdata, handles)
% hObject    handle to altiMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of altiMin as text
%        str2double(get(hObject,'String')) returns contents of altiMin as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val >= RealTimeGUI_MATLAB_2014a_settings.altiMax
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.altiMin));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function altiMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to altiMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function altiMax_Callback(hObject, eventdata, handles)
% hObject    handle to altiMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of altiMax as text
%        str2double(get(hObject,'String')) returns contents of altiMax as a double
global RealTimeGUI_MATLAB_2014a_settings;
val = str2double(get(hObject,'String'));

if isnan(val) || val <= RealTimeGUI_MATLAB_2014a_settings.altiMin
    set(hObject,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.altiMax));
else
    UpdateUserOptions(handles);
end
end

% --- Executes during object creation, after setting all properties.
function altiMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to altiMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function UpdateUserOptions(handles)
global RealTimeGUI_MATLAB_2014a_settings;
if exist('RealTimeGUI_MATLAB_2014a_settings.mat','file')
    load('RealTimeGUI_MATLAB_2014a_settings.mat');
end
% saving settings
if ~exist('RealTimeGUI_MATLAB_2014a_settings','var') || isempty(RealTimeGUI_MATLAB_2014a_settings)
      
    RealTimeGUI_MATLAB_2014a_settings.timeAuto = get(handles.timeAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.timeWind = str2double(get(handles.timeWind,'string'));
    RealTimeGUI_MATLAB_2014a_settings.timeUnit = get(handles.timeUnit,'value');
    RealTimeGUI_MATLAB_2014a_settings.timeMin = NaN;
    RealTimeGUI_MATLAB_2014a_settings.timeMax = NaN;
    
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTxScale = get(handles.uCondFFTxScale,'value');
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTyScale = get(handles.uCondFFTyScale,'value');
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMin = NaN;
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMax = NaN;
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMin = NaN;
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMax = NaN;
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTn = str2double(get(handles.uCondFFTn,'String'));
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTlogScale = get(handles.uCondFFTlogScale,'value');
    
    RealTimeGUI_MATLAB_2014a_settings.uCondAuto = get(handles.uCondAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.uCondMin = NaN;
    RealTimeGUI_MATLAB_2014a_settings.uCondMax = NaN;
    
    RealTimeGUI_MATLAB_2014a_settings.condAuto = get(handles.condAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.condMin = NaN;
    RealTimeGUI_MATLAB_2014a_settings.condMax = NaN;
    
    RealTimeGUI_MATLAB_2014a_settings.tempAuto = get(handles.tempAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.tempMin = NaN;
    RealTimeGUI_MATLAB_2014a_settings.tempMax = NaN;
    
    RealTimeGUI_MATLAB_2014a_settings.altiAuto = get(handles.altiAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.altiMin = NaN;
    RealTimeGUI_MATLAB_2014a_settings.altiMax = NaN;
    save('RealTimeGUI_MATLAB_2014a_settings.mat','RealTimeGUI_MATLAB_2014a_settings');
else
    RealTimeGUI_MATLAB_2014a_settings.timeAuto = get(handles.timeAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.timeWind = str2double(get(handles.timeWind,'string'));
    RealTimeGUI_MATLAB_2014a_settings.timeUnit = get(handles.timeUnit,'value');
    RealTimeGUI_MATLAB_2014a_settings.timeMin = str2double(get(handles.timeMin,'string'));
    RealTimeGUI_MATLAB_2014a_settings.timeMax = str2double(get(handles.timeMax,'string'));
    
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTxScale = get(handles.uCondFFTxScale,'value');
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTyScale = get(handles.uCondFFTyScale,'value');
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMin = str2double(get(handles.uCondFFTxMin,'string'));
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMax = str2double(get(handles.uCondFFTxMax,'string'));
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMin = str2double(get(handles.uCondFFTyMin,'string'));
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMax = str2double(get(handles.uCondFFTyMax,'string'));
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTn = str2double(get(handles.uCondFFTn,'String'));
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTlogScale = get(handles.uCondFFTlogScale,'value');
    
    
    RealTimeGUI_MATLAB_2014a_settings.uCondAuto = get(handles.uCondAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.uCondMin = str2double(get(handles.uCondMin,'string'));
    RealTimeGUI_MATLAB_2014a_settings.uCondMax = str2double(get(handles.uCondMax,'string'));
    
    RealTimeGUI_MATLAB_2014a_settings.condAuto = get(handles.condAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.condMin = str2double(get(handles.condMin,'string'));
    RealTimeGUI_MATLAB_2014a_settings.condMax = str2double(get(handles.condMax,'string'));
    
    RealTimeGUI_MATLAB_2014a_settings.tempAuto = get(handles.tempAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.tempMin = str2double(get(handles.tempMin,'string'));
    RealTimeGUI_MATLAB_2014a_settings.tempMax = str2double(get(handles.tempMax,'string'));
    
    RealTimeGUI_MATLAB_2014a_settings.altiAuto = get(handles.altiAuto,'value');
    RealTimeGUI_MATLAB_2014a_settings.altiMin = str2double(get(handles.altiMin,'string'));
    RealTimeGUI_MATLAB_2014a_settings.altiMax = str2double(get(handles.altiMax,'string'));
    save('RealTimeGUI_MATLAB_2014a_settings.mat','RealTimeGUI_MATLAB_2014a_settings');
end
end

% update plots with data converted
function UpdatePlots(handles)
global RealTimeGUI_MATLAB_2014a_settings;
global RealTimeGUI_MATLAB_2014a_uCondFFT;
global RealTimeGUI_MATLAB_2014a_uCondFFT_N;
global FCTD_DataStorage;
if isempty(FCTD_DataStorage)
    return;
end
if isempty(RealTimeGUI_MATLAB_2014a_uCondFFT_N) || sum(isnan(RealTimeGUI_MATLAB_2014a_uCondFFT))>0
    RealTimeGUI_MATLAB_2014a_uCondFFT_N = 0;
end
    
    
timeMultiplier = NaN;
switch RealTimeGUI_MATLAB_2014a_settings.timeUnit
    case 1
        timeMultiplier = 3600*16;
    case 2
        timeMultiplier = 60*16;
    case 3
        timeMultiplier = 16;
end
Npts = RealTimeGUI_MATLAB_2014a_settings.timeWind*timeMultiplier;
Npts0 = Npts;
if numel(FCTD_DataStorage.altTime)<Npts
    Npts = numel(FCTD_DataStorage.altTime);
end

N_pts = Npts*10;

plot(handles.uCond,1:N_pts,FCTD_DataStorage.uCond(end-N_pts+1:end));
plot(handles.cond,1:Npts,FCTD_DataStorage.cond(end-Npts+1:end));
plot(handles.temp,1:Npts,FCTD_DataStorage.temp(end-Npts+1:end));
plot(handles.alti,1:Npts,FCTD_DataStorage.altTime(end-Npts+1:end));


dt = 1/160;
f_sam = 1/dt; % sampling frequency
f_Ny = f_sam/2; % Nyquist frequency
df = f_Ny/floor(N_pts/2);
if mod(N_pts,2) == 0
    f = -floor(N_pts/2):floor((N_pts-1)/2);
else
    f = -floor(N_pts/2):floor(N_pts/2);
end
f = f*df;

data = FCTD_DataStorage.uCond(end-N_pts+1:end);

DATA = abs(fftshift(fft(detrend(data)))/N_pts*2);

if Npts==Npts0
    if numel(RealTimeGUI_MATLAB_2014a_uCondFFT) == N_pts && sum(isnan(RealTimeGUI_MATLAB_2014a_uCondFFT))==0 && RealTimeGUI_MATLAB_2014a_uCondFFT_N >0
        DATA = RealTimeGUI_MATLAB_2014a_uCondFFT*RealTimeGUI_MATLAB_2014a_uCondFFT_N + DATA;
    end
    RealTimeGUI_MATLAB_2014a_uCondFFT_N = RealTimeGUI_MATLAB_2014a_uCondFFT_N + 1;
    DATA = DATA/RealTimeGUI_MATLAB_2014a_uCondFFT_N;
    RealTimeGUI_MATLAB_2014a_uCondFFT = DATA;
    
    % save only Npts0 data points
    FCTD_DataStorage.uCond = FCTD_DataStorage.uCond(end-N_pts+1:end);
    FCTD_DataStorage.cond = FCTD_DataStorage.cond(end-Npts+1:end);
    FCTD_DataStorage.temp = FCTD_DataStorage.temp(end-Npts+1:end);
    FCTD_DataStorage.gyro = FCTD_DataStorage.gyro(end-Npts+1:end,:);
    FCTD_DataStorage.acceleration = FCTD_DataStorage.acceleration(end-Npts+1:end,:);
    FCTD_DataStorage.compass = FCTD_DataStorage.compass(end-Npts+1:end,:);
    FCTD_DataStorage.altTime = FCTD_DataStorage.altTime(end-Npts+1:end);
    
else
    RealTimeGUI_MATLAB_2014a_uCondFFT_N = 0;
end

plot(handles.uCOND,f(f>0),abs(DATA(f>0)));

UpdatePlotSettings(handles,Npts,N_pts,f_Ny);

end

function UpdatePlotSettings(handles,Npts,N_pts,f_Ny)
global RealTimeGUI_MATLAB_2014a_settings;


if RealTimeGUI_MATLAB_2014a_settings.uCondFFTlogScale
    set(handles.uCOND,'yscale','log','xscale','log');
else
    set(handles.uCOND,'yscale','linear','xscale','linear');
end

if RealTimeGUI_MATLAB_2014a_settings.uCondFFTxScale
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMin = 0;
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMax = f_Ny;
    set(handles.uCondFFTxMin,'String',num2str(0));
    set(handles.uCondFFTxMax,'String',num2str(f_Ny));
    xlim(handles.uCOND,[0, f_Ny]);
else
    xlim(handles.uCOND,[RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMin, RealTimeGUI_MATLAB_2014a_settings.uCondFFTxMax]);
end


if RealTimeGUI_MATLAB_2014a_settings.uCondFFTyScale
    set(handles.uCOND,'yLimMode','auto');
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMin = min(ylim(handles.uCOND));
    RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMax = max(ylim(handles.uCOND));
    set(handles.uCondFFTyMin,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMin));
    set(handles.uCondFFTyMax,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMax));
else
    ylim(handles.uCOND,[RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMin, RealTimeGUI_MATLAB_2014a_settings.uCondFFTyMax]);
end

if RealTimeGUI_MATLAB_2014a_settings.timeAuto
    RealTimeGUI_MATLAB_2014a_settings.timeMin = 1;
    RealTimeGUI_MATLAB_2014a_settings.timeMax = Npts;
    set(handles.timeMin,'String',num2str(1));
    set(handles.timeMax,'String',num2str(Npts));
    xlim(handles.uCond,[1, N_pts]);
    xlim(handles.cond,[1, Npts]);
    xlim(handles.temp,[1, Npts]);
    xlim(handles.alti,[1, Npts]);
else
    xlim(handles.uCond,[(RealTimeGUI_MATLAB_2014a_settings.timeMin-1)*10+1, RealTimeGUI_MATLAB_2014a_settings.timeMax*10]);
    xlim(handles.cond,[RealTimeGUI_MATLAB_2014a_settings.timeMin, RealTimeGUI_MATLAB_2014a_settings.timeMax]);
    xlim(handles.temp,[RealTimeGUI_MATLAB_2014a_settings.timeMin, RealTimeGUI_MATLAB_2014a_settings.timeMax]);
    xlim(handles.alti,[RealTimeGUI_MATLAB_2014a_settings.timeMin, RealTimeGUI_MATLAB_2014a_settings.timeMax]);
end

if RealTimeGUI_MATLAB_2014a_settings.uCondAuto
    set(handles.uCond,'yLimMode','auto');
    RealTimeGUI_MATLAB_2014a_settings.uCondMin = min(ylim(handles.uCond));
    RealTimeGUI_MATLAB_2014a_settings.uCondMax = max(ylim(handles.uCond));
    set(handles.uCondMin,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondMin));
    set(handles.uCondMax,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.uCondMax));
else
    ylim(handles.uCond,[RealTimeGUI_MATLAB_2014a_settings.uCondMin, RealTimeGUI_MATLAB_2014a_settings.uCondMax]);
end

if RealTimeGUI_MATLAB_2014a_settings.condAuto
    set(handles.cond,'yLimMode','auto');
    RealTimeGUI_MATLAB_2014a_settings.condMin = min(ylim(handles.cond));
    RealTimeGUI_MATLAB_2014a_settings.condMax = max(ylim(handles.cond));
    set(handles.condMin,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.condMin));
    set(handles.condMax,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.condMax));
else
    ylim(handles.cond,[RealTimeGUI_MATLAB_2014a_settings.condMin, RealTimeGUI_MATLAB_2014a_settings.condMax]);
end

if RealTimeGUI_MATLAB_2014a_settings.tempAuto
    set(handles.temp,'yLimMode','auto');
    RealTimeGUI_MATLAB_2014a_settings.tempMin = min(ylim(handles.temp));
    RealTimeGUI_MATLAB_2014a_settings.tempMax = max(ylim(handles.temp));
    set(handles.tempMin,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.tempMin));
    set(handles.tempMax,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.tempMax));
else
    ylim(handles.temp,[RealTimeGUI_MATLAB_2014a_settings.tempMin, RealTimeGUI_MATLAB_2014a_settings.tempMax]);
end

if RealTimeGUI_MATLAB_2014a_settings.altiAuto
    set(handles.alti,'yLimMode','auto');
    RealTimeGUI_MATLAB_2014a_settings.altiMin = min(ylim(handles.alti));
    RealTimeGUI_MATLAB_2014a_settings.altiMax = max(ylim(handles.alti));
    set(handles.altiMin,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.altiMin));
    set(handles.altiMax,'String',num2str(RealTimeGUI_MATLAB_2014a_settings.altiMax));
else
    ylim(handles.alti,[RealTimeGUI_MATLAB_2014a_settings.altiMin, RealTimeGUI_MATLAB_2014a_settings.altiMax]);
end

grid(handles.uCOND,'on');
grid(handles.uCond,'on');
grid(handles.cond,'on');
grid(handles.temp,'on');
grid(handles.alti,'on');
% set(handles.uCOND,'xticklabel',{});
set(handles.uCond,'xticklabel',{});
set(handles.cond,'xticklabel',{});
set(handles.temp,'xticklabel',{});
% grid(handles.alti,'on');

ylabel(handles.uCOND,'$\mu$Cond FFT');
ylabel(handles.uCond,'$\mu$Cond');
ylabel(handles.cond,'conductivity');
ylabel(handles.temp,'temperature');
ylabel(handles.alti,'altimeter');
end

% read serial data and convert to matlab data
function ReadSerial(hObject, eventdata,handles)
global FCTD_Data_Stream_LeftOver;
global FCTD_SerialStream;
global FCTD_DataStorage;
persistent DataLineCount;

if isempty(DataLineCount)
    DataLineCount = 0;
end

s = '';
if FCTD_SerialStream.BytesAvailable > 0
    try
        s = char(fread(FCTD_SerialStream,FCTD_SerialStream.BytesAvailable,'char'));
    catch err
        s = '';
    end
end

if ~isempty(s)
    FCTD_Data_Stream_LeftOver = [FCTD_Data_Stream_LeftOver; s];
    DataLineCount = DataLineCount + 1;
end

if DataLineCount<32
    return;
end

ctdlen=22;
mcrlen=40;
acclen=36;
altlen=4;
cntlen=8;

linelength = ctdlen + mcrlen + acclen + altlen + cntlen + 2;

% find first complete record and non-garbage, long line
ind = find(FCTD_Data_Stream_LeftOver==sprintf('\n'),1,'first');
if ind~=linelength
    FCTD_Data_Stream_LeftOver = FCTD_Data_Stream_LeftOver(ind+1:end);
end
ind = find(FCTD_Data_Stream_LeftOver==sprintf('\n'),1,'last');

try
% i am assuming everything in the middle is orderly without any garbage
% reshape the data into something nice
s = reshape(FCTD_Data_Stream_LeftOver(1:ind),linelength,[])';
% somehow bad stuff gets in here (non-hex??);
bad = ~ismember(s,['0':'9' 'A':'F']);
s(bad) = '0';
ctdpos = 1;


[cond, temp] = FastCTD_ReadCTD_ASCII(s(:,ctdpos+(1:ctdlen)-1));

uCond = FastCTD_ASCII_getMcr(s(:,ctdpos+ctdlen+(1:mcrlen)-1));

[gyro,acceleration,compass] = FastCTD_ASCII_getYEI(s(:,ctdpos+ctdlen+mcrlen+(1:acclen)-1));
altTime = FastCTD_ASCII_getAltimeter(s(:,ctdpos+ctdlen+mcrlen+acclen+(1:altlen)-1))*750;

uCond = uCond';

FCTD_DataStorage.gyro = [FCTD_DataStorage.gyro; gyro];
FCTD_DataStorage.acceleration = [FCTD_DataStorage.acceleration; acceleration];
FCTD_DataStorage.compass = [FCTD_DataStorage.compass; compass];
FCTD_DataStorage.altTime = [FCTD_DataStorage.altTime; altTime];

FCTD_DataStorage.cond = [FCTD_DataStorage.cond; cond];
FCTD_DataStorage.temp = [FCTD_DataStorage.temp; temp];
FCTD_DataStorage.uCond = [FCTD_DataStorage.uCond; uCond(:)];

DataLineCount = 0;

UpdatePlots(handles);
disp(FCTD_DataStorage);
disp(FCTD_Data_Stream_LeftOver);
catch err
    disp(err);
end
if ind<numel(FCTD_Data_Stream_LeftOver)
    FCTD_Data_Stream_LeftOver = FCTD_Data_Stream_LeftOver(ind+1:end);
else
    FCTD_Data_Stream_LeftOver = '';
end
end

%  reads the conductivity & temperature data
function [cond, temp] = FastCTD_ReadCTD_ASCII(ctd_ASCII)

cond = hex2dec(ctd_ASCII(:,(1:6)+6))/256/1000;
rawT = hex2dec(ctd_ASCII(:,1:6));
mv = (rawT-524288)/1.6e7;
temp = (mv*2.295e10 + 9.216e8)./(6.144e4-mv*5.3e5);
return;
end

%  reads the Micro Conductivity data
function uCond = FastCTD_ASCII_getMcr(mcr_ASCII)

try
    m = reshape(mcr_ASCII',4,[])';
catch
    m = ones(0,4);
end
mm = hex2dec(m);

try
    uCond = reshape(mm,10,[])';
catch
    uCond = ones(0,10);
end

end
%  reads the Acceleration
function [gyro,acceleration,compass] = FastCTD_ASCII_getYEI(YEI_ASCII)
try
    m = reshape(YEI_ASCII',4,[])';
catch
    m = ones(0,4);
end
mm = hex2dec(m);
mm(mm>=hex2dec('8000')) = -(2.^16-mm(mm>=hex2dec('8000')));

try
    tmp = reshape(mm,9,[])';
catch
    tmp = ones(0,9);
end
gyro = tmp(:,1:3)*pi/180*0.07;
acceleration = tmp(:,4:6)/16384;
compass = tmp(:,7:9)/1090;

% From: Yost Engineering Support <support@yostengineering.com>
% Subject: 3-Space Calibration Algorithms
% Date: July 27, 2012 9:58:12 AM GMT-10:00
% To: mgoldin@ucsd.edu
% Reply-To: support@yostengineering.com
%
% Hello,
%
% Here is how we convert the raw data from our component sensors into usable data:
%
% Gyroscope:
% 1)We add the bias components(the last 3 components) of the gyroscope
%   calibration data(command 164) each onto their respective axis.
% 2)We multiply all axes by PI/180 to convert from degrees into radians.
% 3)Depending on the dps range, we multiply all axes by:
%    Range     Multiplier
%    250dps    .00875
%    500dps    .0175
%    2000dps   .07 (default range)
% 4)We multiply the matrix components(the first 9 components) of the gyroscope
%   calibration data with the gyroscope vector.
%
% Accelerometer:
% 1)We add the bias components(the last 3 components) of the accelerometer
%   calibration data(command 163) each onto their respective axis.
% 2)We divide all axes by 16384.
% 3)Depending on the g range, we multiply all axes by:
%    Range  Multiplier
%    2g     1 (default range)
%    4g     2
%    8g     4
% 4)We multiply the matrix components(the first 9 components) of the accelerometer
%   calibration data with the accelerometer vector.
%
% Compass:
% 1)We add the bias components(the last 3 components) of the compass calibration
%   data(command 162) each onto their respective axis.
% 2)Depending on the compass range, we divide all axes by:
%    Range      Divisor
%    0.88 Ga    1370
%    1.3 Ga     1090 (default range)
%    1.9 Ga     820
%    2.5 Ga     660
%    4.0 Ga     440
%    4.7 Ga     390
%    5.6 Ga     330
%    8.1 Ga     230
% 3)We multiply the matrix components(the first 9 components) of the compass
%   calibration data with the compass vector.

return
end
%  reads the altimeter
function altTime = FastCTD_ASCII_getAltimeter(alti_ASCII)

try
    m = reshape(alti_ASCII',4,[])';
catch
    m = ones(0,4);
end
mm = hex2dec(m);

try
    % time is in count of 1/(40kHz)
    altTime = mm/4.0e4;
catch
    altTime = ones(0,1);
end


return;
end

% --- Executes on button press in saveFile.
function saveFile_Callback(hObject, eventdata, handles)
% hObject    handle to saveFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

end

function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double
end

% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
