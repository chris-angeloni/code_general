%
%function []=caliball(MicGain,NB,Interface,Device,DeviceNum,Path)
% 	
%   FILE NAME   : TDT Calibration Routine
% 	DESCRIPTION : Acquires input-output data and calibrates the TDT system
%
%   MicGain     : Microphone Amplifier Gain (dB) (Default=40)
%   NB          : Number of white noise samples for measurement (Default,
%                 NB=97000, i.e. 10 sec at 97kHz)
%   Interface   : TDT Interface (Default, Interface='GB')
%   Device      : TDT Device for acquiring calibration data ('RX6' or
%                 'RP2'; Default, 'RX6')
%   DeviceNum   : Device Number - Designated in zBUSMon (Default, DeviceNum=1)
%   Path        : Path for storing data (Default = local directory)
%
%RETURNED VARIABLES
%
%   Data        : Data structure containing calibration data
%                 X - Input white noise signal
%                 Y - Recorder speaker output signal
%
% (C) Monty A. Escabi & F.E. Rodriguez, November 2007
%
function []=caliball(MicGain,NB,Interface,Device,DeviceNum,Path)









