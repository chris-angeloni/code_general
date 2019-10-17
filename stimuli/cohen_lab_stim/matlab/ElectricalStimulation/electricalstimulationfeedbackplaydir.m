%
%function []=electricalstimulationfeedbackplaydir(StimDir,MaxAmp,Ec,Betac,ChanMask,ECoGRef,ECoGRMSDC,Tau,Kplant,MaxGain,Lp)
%
%       FILE NAME       : ELECTRICAL STIMULATION FEEDBACK PLAY DIR
%       DESCRIPTION     : Delivers a spatio temporal electrical stimulation pattern
%                         across N channels. Signals are obtained from a
%                         desired directory and sent the IZ2. Uses cortical
%                         feedback to dynamically control the stimulation
%                         signal so as to match the reference cortical
%                         response pattern.
%
%                         Typically there are two control strategies that
%                         can be used. 
%
%                         1) In the first strategy, one can make the
%                         commodulation envelope, Ec, time varying while
%                         the Reference cotrical output, ECoGRef, is fixed.
%                         In this strategy, one provides a time varying
%                         electrical signal and the goal is to make the
%                         output response pattern constant (ECoGRef
%                         typically will be equal to ECoGRMSDC).
%
%                         2) An alternateive strategy is to make the input
%                         constant amplitude (i.e., Ec=1 for all time
%                         points) and make the reference cortical pattern
%                         time varying (ECoGRef). For this scenario, the
%                         goal is to track and replicate a desired cortical
%                         pattern.
%
%
%       StimDir         : Directory conataining electrical stimulation
%                         files
%       MaxAmp          : Maximum stimulation current (micro Amp) or 
%                         voltage (Volts) amplitude.
%                         Need to verify stimulation mode in TDT.
%       Ec              : Commmodulation Envelope for electrical
%                         stimulation signal. The vector length should 
%                         match up the length of the electrical stimulation
%                         signal, S. If not desired use Bc=[].
%       Betac           : Modulation index for Ec (0 < Betac < 1)
%       ChanMask        : Vector mask to turn on or off channels. The
%                         vector length  should be the same as the number
%                         of channels in the envelope (i.e., 16). 1
%                         indicates that the channel is on 0 indicates that
%                         the channel is off. If ChanMask=[] then all
%                         channels are turned on.
%       ECoGRef         : Vecotor containing the Reference ECoG control 
%                         signal. The vector length should match up the
%                         length of the electrical stimulation signal, S.
%                         Typically we will use ECoGRMSDC=ECoGRef so that
%                         the control strategy attempts to produce a
%                         baseline response at the operating point.
%       ECoGRMSDC       : DC Operating Point for control.
%       Tau             : Time constant for feedback RMS signal (msec).
%       Kplant          : Plant Gain. This gain can be derive from a rate-
%                         level function using the electrical stimulator.
%                         The input will be the RMS current while the
%                         output is the RMS ECoG voltage. The gain is
%                         defined as 
%
%                               Kplant= (RMS ECoG Voltage in Volts) / (RMS Current in micro A)
%
%
%                         In practice, we can arbitrarily choose this gain
%                         as a slightly smaller or larger value than the
%                         true system gain. This will decrease or increase
%                         the response time of the controller by providing
%                         less or more control signal. The units for the
%                         gain are in micro Volts / micro Amps
%       MaxGain         : Max controller gain during feedback experiment.
%                         Used as a safety to make sure we dont overdrive
%                         the brain tissue.
%       Lp              : Number of buffer blocks to play back. Needs to be
%                         an integer multiple of 2 (Default all blocks)
%
% (C) Monty A. Escabi, Dec 2011
%
function []=electricalstimulationfeedbackplaydir(StimDir,MaxAmp,Ec,Betac,ChanMask,ECoGRef,ECoGRMSDC,Tau,Kplant,MaxGain,Lp)

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
DA.SetTargetVal('Amp1.CMode',1);                %Stimulation Control Mode - feedback active
DA.SetTargetVal('Amp1.RWEnable',0);
DA.SetTargetVal('Amp1.RWReset',1);
DA.SetTargetVal('Amp1.RWReset',0);
DA.SetTargetVal('Amp1.Kplant',Kplant);          %Plant Gain 
DA.SetTargetVal('Amp1.ECoGRMSDC',ECoGRMSDC);    %ECoG Operating Point
DA.SetTargetVal('Amp1.Tau',Tau);                %Time Constant for measuring RMS
DA.SetTargetVal('Amp1.MaxGain',MaxGain);        %Maximum stimulator gain - safety!

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
    DA.WriteTargetVEX('Amp1.ECoGRef',Offset,'F32',ECoGRef((k-1)*N+(1:N)));          %Sending reference control signal
   
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
        time=toc;
        display(['                                Elapsed Time: ' num2str(time,4) ' sec'])
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
time=toc;
display(['                                Elapsed Time: ' num2str(time,4) ' sec'])
        
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
