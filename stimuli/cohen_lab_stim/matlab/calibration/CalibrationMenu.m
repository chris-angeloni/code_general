function varargout = CalibrationMenu(varargin)
% CALIBRATIONMENU M-file for CalibrationMenu.fig
% Interface for running Monty Escabi's speaker calibration package.
% Calls function CALIBFIR.M in calibrate mode
% Still needs the functions for running verify mode and tone test mode.

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CalibrationMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @CalibrationMenu_OutputFcn, ...
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


% --- Executes just before CalibrationMenu is made visible.
function CalibrationMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to CalibrationMenu (see VARARGIN)

% Choose default command line output for CalibrationMenu
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

%load last values 
load calibparams.mat
try set(handles.tdtdir, 'String', parameters.TDTDirectory); catch end
try set(handles.param1, 'String', parameters.f1); catch end
try set(handles.param2, 'String', parameters.f2); catch end
try set(handles.param3, 'String', parameters.ATT); catch end
try set(handles.param4, 'String', parameters.L); catch end
    
 
    

   
   


% UIWAIT makes CalibrationMenu wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = CalibrationMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function action_Callback(hObject, eventdata, handles)

calibmode = get(handles.calibmode, 'Value');
verifymode = get(handles.verifymode, 'Value');
tonemode = get(handles.tonemode, 'Value');
togglespeaker = get(handles.togglespeaker, 'Value')
f1 = str2num(get(handles.param1, 'String'));
f2 = str2num(get(handles.param2, 'String'));
ATT = str2num(get(handles.param3, 'String'));
L = str2num(get(handles.param4, 'String'));
tdtdir = get(handles.tdtdir, 'String');
Disp = 'y';
% try load 'Data.mat'; catch end
load 'calibparams.mat'
if calibmode                
    [Datatemp] = calibacquire(parameters.MicGain, parameters.NB, parameters.Interface, ...
                          parameters.Device, parameters.DeviceNum, parameters.NoiseSelect, 0);  %0 triggers initial acquire mode  
    
                      
    pause(0.1)
    set(handles.messagebox, 'String', ['Calibration Data Successfully Acquired. SPL = ' num2str(Datatemp.SPL, '%5.2f') 'dB'])     
    set(handles.teUncalibrated, 'String', ['Uncalibrated SPL: ' num2str(Datatemp.SPL, '%5.2f') 'dB'])
    
    [h] = calibfir(Datatemp, f1, f2, L, ATT, Disp);

    try load Data.mat; catch end     
    if ~togglespeaker                
        Data.XR = Datatemp.X;
        Data.YR = Datatemp.Y;  
        Data.hR = h.hk;
    else
        Data.XL = Datatemp.X;
        Data.YL = Datatemp.Y;
        Data.hL = h.hk;        
    end
    save('Data', 'Data', '-append')
        
    if ~togglespeaker
        %save this in local directory and TDT directory.
        tdtpath = [tdtdir '\spchan1.f32']; 
        fid = fopen(tdtpath, 'wb');
        fwrite(fid, h.hk, 'float32');
        fclose(fid);
        
        %save it generically in the local path so you don't have to modify the circuit when swapping speakers.
        fid = fopen('C:\escabi\matlab\calibration\spchan.f32', 'wb'); 
        fwrite(fid, h.hk, 'float32');
        fclose(fid);        
    else
        tdtpath = [tdtdir '\spchan2.f32']; 
        fid = fopen(tdtpath, 'wb');
        fwrite(fid, h.hk, 'float32');
        fclose(fid);
        
        fid = fopen('C:\escabi\matlab\calibration\spchan.f32', 'wb'); 
        fwrite(fid, h.hk, 'float32');
        fclose(fid);     
    end      
    set(handles.messagebox, 'String', 'Calibration Filter and Data Successfully Saved') 
elseif verifymode  
    [Datatemp] = calibacquire(parameters.MicGain, parameters.NB, parameters.Interface, ...
                          parameters.Device, parameters.DeviceNum, parameters.NoiseSelect, 1); %1 triggers verification mode
                      
    pause(0.1)
    set(handles.messagebox, 'String', ['Verification Data Successfully Acquired. SPL = ' num2str(Datatemp.SPL) 'dB']) 
    set(handles.teCalibrated, 'String', ['Calibrated SPL: ' num2str(Datatemp.SPL, '%5.2f') 'dB'])
    
    [h] = calibfir(Datatemp, f1, f2, L, ATT, Disp);
    try load Data.mat; catch end 
    if ~togglespeaker                                
        Data.XRc = Datatemp.X;
        Data.YRc = Datatemp.Y;  
    else        
        Data.XLc = Datatemp.X;
        Data.YLc = Datatemp.Y;     
    end
    save('Data', 'Data')
    set(handles.messagebox, 'String', 'Verification Complete. Verification Data Successfully Saved') 
    
elseif tonemode
    set(handles.messagebox, 'String', 'This feature has not yet been implemented.') 
    %to be added later.
else
    set(handles.messagebox, 'String', 'Please select one of the three options on the left', 'ForegroundColor', 'r') 
end
   


function togglespeaker_Callback(hObject, eventdata, handles)

a = get(handles.togglespeaker, 'Value');
if a
    set(handles.togglespeaker, 'String', 'Speaker 2 (Left)')
else
    set(handles.togglespeaker, 'String', 'Speaker 1 (Right)')
end

%call one of the function buttons that will toggle all the other names and
%shit.


function param1_Callback(hObject, eventdata, handles)




function param1_CreateFcn(hObject, eventdata, handles)



% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function param2_Callback(hObject, eventdata, handles)


function param2_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function param3_Callback(hObject, eventdata, handles)


function param3_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function param4_Callback(hObject, eventdata, handles)


function param4_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function calibmode_Callback(hObject, eventdata, handles)
%this is the main function for renaming objects.
calibmode = get(handles.calibmode, 'Value');
verifymode = get(handles.verifymode, 'Value');
tonemode = get(handles.tonemode, 'Value');

if calibmode
    set(handles.text1, 'String', 'Lower Cutoff (Hz)')
    set(handles.text2, 'String', 'Upper Cutoff (Hz)')
    set(handles.text3, 'String', 'Attenuation Factor (dB)')
    set(handles.text4, 'String', 'Number of Filter Points')
elseif verifymode
elseif tonemode
    %need octave and linear mode, start, step, end... anything else?
end

function verifymode_Callback(hObject, eventdata, handles)
calibmode_Callback(hObject, eventdata, handles)

function tonemode_Callback(hObject, eventdata, handles)
calibmode_Callback(hObject, eventdata, handles)



function setparams_Callback(hObject, eventdata, handles)
load 'calibparams.mat'
device = parameters.Device;
%parameters.MicGain,NB,Interface,Device,DeviceNum,NoiseSelect 
prompt = {'Enter Device Type:','Enter Device Number:', 'Enter Interface', ...
          'Enter Noise Length in Samples', 'Enter Noise Selection(0 = Guassian, 1 = From File)', 'Enter Mic Gain'};
dlg_title = 'Input Parameters';
num_lines = 1;
def = {parameters.Device, num2str(parameters.DeviceNum), parameters.Interface, ...
       num2str(parameters.NB), num2str(parameters.NoiseSelect), num2str(parameters.MicGain)};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if ~isempty(answer)
    parameters.Device = answer{1}; parameters.DeviceNum = str2num(answer{2}); parameters.Interface = answer{3}; 
    parameters.NB = str2num(answer{4}); parameters.NoiseSelect = str2num(answer{5}); parameters.MicGain = str2num(answer{6});
end

save('calibparams', 'parameters', '-append')

if ~strcmp(parameters.Device, device)
    set(handles.messagebox, 'String', ['Open "SpeakerCAL onlineRX6.rcx" in RPvdsEx. Under the "Interface => Device Setup" menu change "Type" to: ' parameters.Device])
end

function restoredefaults_Callback(hObject, eventdata, handles)
parameters.MicGain = 40; parameters.NB = 970000; parameters.Interface = 'GB';
parameters.Device = 'RX6'; parameters.DeviceNum = 1; parameters.NoiseSelect = 0;
save 'calibparams.mat' 'parameters'

function optionmenu_Callback(hObject, eventdata, handles)




function tdtdir_Callback(hObject, eventdata, handles)


function tdtdir_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function figure1_DeleteFcn(hObject, eventdata, handles)
load 'calibparams.mat'
parameters.TDTDirectory = get(handles.tdtdir, 'String');
parameters.f1 = str2num(get(handles.param1, 'String'));
parameters.f2 = str2num(get(handles.param2, 'String'));
parameters.ATT = str2num(get(handles.param3, 'String'));
parameters.L = str2num(get(handles.param4, 'String'));
save 'calibparams.mat' 'parameters'



