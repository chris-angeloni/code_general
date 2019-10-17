%
%function []=electricalstimulationplaydir(StimDir,MaxAmp,Ec,Betac,ChanMask,Lp)
%
%       FILE NAME       : ELECTRICAL STIMULATION PLAY DIR
%       DESCRIPTION     : Delivers a spatio temporal electrical stimulation pattern
%                         across N channels. Signals are obtained from a
%                         desired directory and sent the IZ2 
%
%       StimDir         : Directory conataining electrical stimulation
%                         files
%       MaxAmp          : Maximum stimulation current (micro Amp) or 
%                         voltage (Volts) amplitude.
%                         Need to verify stimulation mode in TDT. 
%       Ec              : Commmodulation Envelope for electrical
%                         stimulation signal. The vector length should 
%                         match up the length of the electrical stimulation
%                         signal, S. This parameter is optional, if it is
%                         not provided a value of 1 (for all time points)
%                         is used. If not desired use Bc=[].
%       Betac           : Modulation index for Ec (0 < Betac < 1)
%       ChanMask        : Vector mask to turn on or off channels. The
%                         vector length  should be the same as the number
%                         of channels in the envelope (i.e., 16). 1
%                         indicates that the channel is on 0 indicates that
%                         the channel is off. If ChanMask=[] then all
%                         channels are turned on.
%       Lp              : Number of buffer blocks to play back. Needs to be
%                         an integer multiple of 2 (Default all blocks)
%
% (C) Monty A. Escabi, July 2011
%
function []=electricalstimulationplaydir(StimDir,MaxAmp,Ec,Betac,ChanMask,Lp)

%File List
List=dir([StimDir '\*_Block*.mat']);

%Loading Stimulus Parameters
f=['load ' List(1).name];
eval(f);
S=full(S);
S=S/ParamList.MaxAmp*MaxAmp;

%Input Arguments
if isempty(Ec)
    Ec=ones(1,length(S)*length(List));
end
if isempty(ChanMask)
    ChanMask=ones(1,size(S,1));
end

%Buffer size and other Parameters
Fs=ParamList.Fs;        %Sampling Rate
NB=ParamList.NB;        %Buffer size
N=NB/2;                 %Half the buffer size
Ec=Ec/max(Ec);          %Normalize for maximum value of 1, this way maximum current is determined by MaxAmp
if exist('Lp')          %Number of buffer blocks to deliver
    L=Lp;
else
   L=length(List);
end

%Open A Dummy Figure
figure, set(gcf,'visible','off');
DA = actxcontrol('TDevAcc.X');
DA.ConnectServer('Local');
if DA.CheckServerConnection==0
    clc
    display('Client application not connect to server')
else
    clc
    display('Client application connected to server')
end

%Initialize
DA.SetTargetVal('Amp1.CMode',0);        %Stimulation Control Mode - no feedback
DA.SetTargetVal('Amp1.Kplant',1);
DA.SetTargetVal('Amp1.RWEnable',0);
DA.SetTargetVal('Amp1.RWReset',1);
DA.SetTargetVal('Amp1.RWReset',0);

%Sending Electrical Stimulation Pattern
for k=1:L
    
    %Loading Stimulus
    f=['load ' List(k).name];
    eval(f)
    S=full(S);
    S=S/ParamList.MaxAmp*MaxAmp;
    
    %Loading 16 channel stimulation pattern into buffer
    if k/2==floor(k/2)
        Offset=N;
    else
        Offset=0;
    end
    for l=1:16
        %Writing input to each channel
        ChannelString=['Amp1.InChan' int2str(l)];
        DA.WriteTargetVEX(ChannelString,Offset,'F32',ChanMask(l)*S(l,:).*(Ec((k-1)*N+(1:N))*Betac+(1-Betac)));    %Sending electrical stimulation for each channel
    end
    plot(S(l,:).*(Ec((1-1)*N+(1:N))*Betac+(1-Betac))),pause(1)
    
    %display(['            Stimulation pattern loaded to buffer block: ' int2str(k)])
   
    %Begin playing the buffer only for k==1
    if k==1
       DA.SetTargetVal('Amp1.RWEnable',1);
       tic
       display('Begin Stimulus Delivery')
    end

    %Pause until previous buffer half is delivered
    if k>1
        if k/2==floor(k/2)
            Nmin=0;
            Nmax=NB/2;
        else
            Nmin=NB/2;
            Nmax=NB;
        end
        index=DA.GetTargetVal('Amp1.Index16');
        while (index<Nmax & index>Nmin)
                index=DA.GetTargetVal('Amp1.Index16');
        end
        %time=toc;
       % display(['                                Elapsed Time: ' num2str(time,4) ' sec'])
    end
    
    display(['                        Delivering buffer block: ' int2str(k)])
   
end

%Deliver Last Block
Nmax=NB;
Nmin=NB/2;
index=DA.GetTargetVal('Amp1.Index16');
while (index<Nmax & index>Nmin)
        index=DA.GetTargetVal('Amp1.Index16');
end
%time=toc;
%display(['                                Elapsed Time: ' num2str(time,4) ' sec'])
        
%Stop Delivery
DA.SetTargetVal('Amp1.RWEnable',0);
%DA.SetTargetVal('Amp1.RWReset',1);     %seems to give problems
display('Stop Stimulus Delivery')


% %Stimulating
% DA.SetTargetVal('Amp1.RWEnable',1);
% while (DA.GetTargetVal('Amp1.Index16')<10000)
% end
% DA.SetTargetVal('Amp1.RWEnable',0);






% 
% 
% DA.GetTargetVal('Amp1.Index16')
% 
% 
% 
% %Set system to Preview mode (0=idle; 1=standby; 2=preview; 3=record)
% Mode=DA.GetSysMode;
% DA.SetSysMode(2);
% 
% 
