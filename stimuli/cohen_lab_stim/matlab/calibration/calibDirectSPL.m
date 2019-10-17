
%
%function [Data]=calibDirectSPL(X,t1,t2,MicGain,PA5ATT,NB,Interface,Device,DeviceNum,AcquireSelect,SpeakerSelect,MicSensitivity,MicSerialNumber)
% 	
%   FILE NAME   : CALIB DIRECT SPL
% 	DESCRIPTION : Measures the SPL for a specified input (X) in the time
%                 window from t1 to t2
%
%   X               : Input signal provided by user (in volts)
%   t1              : Start time to measure SPL (sec)
%   t2              : End time to measure SPL (sec)
%   MicGain         : Microphone Amplifier Gain (dB) (Default=60)
%   PA5ATT          : PA5 Attenuation Setting (dB). PA5 channel is selected by
%                     SpeakerSelect (Default==40 dB, for safety).
%   PA5ATT          : PA5 Attenuation Setting (dB). PA5 channel is selected by
%                     SpeakerSelect (Default==40 dB, for safety).
%   NB              : Number of white noise samples for measurement (Default,
%                     NB=970000, i.e. 10 sec at 97kHz)
%   Interface       : TDT Interface (Default, Interface='GB')
%   Device          : TDT Device for acquiring calibration data ('RX6' or
%                     'RP2'; Default, 'RX6')
%   DeviceNum       : Device Number - Designated in zBUSMon (Default,
%                     DeviceNum=1)
%   AcquireSelect   : Selects between calibration mode (direct input) and
%                     validation mode (uses FIR filter to calibrate input).
%                     0 = calibration mode
%                     1 = validation mode
%                     (Default == 0)
%   SpeakerSelect   : Selects speaker channels
%                     1 = Spekaer channel 1 (TDT 1)
%                     2 = Speaker channel 2 (TDT 2)
%                     (Default == 1)
%   MicSensitivity  : Microphone sensititivity from data sheet (mV/Pa)
%                     Note:  1 Pa = 1 N/m^2
%                            1 Pa = 10 micro bar
%                      (Default==1.3)
%   MicSerialNumber : Serial number from data sheet (Default == 652315)
%
%RETURNED VARIABLES
%
%   Data        : Data structure containing calibration data
%                 .X                - Input white noise signal
%                 .Y                - Recorded speaker output signal
%                 .Fs               - sampling rate (Hz)
%                 .MicGain          - B&K Amplifier Gain (dB)
%                 .PA5ATT           - PA5 Attenuition Setting (dB)
%                 .SPL              - RMS SPL (dB re 2.2E-5 Pa)
%                 .SPLmax           - Maximum SPL (dB re 2.2E-5 Pa)
%                 .MicSerialNumber  - Serial number from spec sheet
%
%                 .DateTime         - Date and time that data was acuired 
%                                     (see 'clock' command for format)
%
% (C) Monty A. Escabi, April 13, 2015
%
function [SPLData]=calibDirectSPL(X,t1,t2,MicGain,PA5ATT,NB,Interface,Device,DeviceNum,AcquireSelect,SpeakerSelect,MicSensitivity,MicSerialNumber)

if nargin<4  | isempty(MicGain)
    MicGain=60;
end
if nargin<5  | isempty(PA5ATT)
    PA5ATT=40;
end
if nargin<6  | isempty(NB)
    NB=970000;
end
if nargin<7  | isempty(Interface)
    Interface='GB';
end
if nargin<8 | isempty(Device)
    Device='RZ6';
end
if nargin<9 | isempty(DeviceNum)
    DeviceNum=1;
end
if nargin<10 | isempty(AcquireSelect)
    AcquireSelect=0;
end
if nargin<11 | isempty(SpeakerSelect)
    SpeakerSelect=1;
end
if nargin<12 | isempty(MicSensitivity)
    MicSensitivity=1.3;   
end
if nargin<13 | isempty(MicSerialNumber)
    MicSerialNumber=652315;
end

%Delivering Sounds and Acquiring output
[Data]=calibacquiredirectinput(X,MicGain,PA5ATT,NB,Interface,Device,DeviceNum,AcquireSelect,SpeakerSelect,MicSensitivity,MicSerialNumber);

%Convert output recording to pascals and measuring SPL
ND=17711;               %System Delay before sound is initiated
N1=round(t1*Data.Fs)+ND;
N2=round(t2*Data.Fs)+ND;
Y=Data.Y.*1000./10^(Data.MicGain/20)/Data.MicSensitivity;
Y=Y-mean(Y);
SPLData.SPL= 20*log10(std(Y(N1:N2)/2.2E-5));
SPLData.MaxSPL=20*log10(max(Y(N1:N2)/2.2E-5));
SPLData.Y=Data.Y;