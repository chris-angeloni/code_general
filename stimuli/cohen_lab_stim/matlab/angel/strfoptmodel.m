%function [Nsig,Tau,SNR,Tref,Err,Y1]=strfoptmodel(sprfile,datafile,Nsig0,Tau0,Tref0,SNR0,L,Options);  
%
% Function 
%                Looking for best Nsig, Tau, SNR and Tref for integrate fire neuron
%
% Input  
%          sprfile        sound filename
%          datafile       dB.mat file including STRF
%          Nsig0          initial normalized threshold
%          Tau0           initial time constant
%          Tref0          initial refrectory period
%          SNR0           initial signal to noise ratio
%          L              number of blocks
%          Options        binaural or monaural neuron
%                         STRF1 and STRF2  Options=0
%                         only STRF2       Options=2
%                         only STRF1       Options=1
% Output
%          Nsig           best threshold
%          Tau            best time constant
%          Tref           best refrectory period
%          SNR            best signal to noise ratio
%          Err            mean square error
%          Y1              injected current
%
% ANQI QIU
% 05/27/2002


function [Nsig,Tau,SNR,Tref,Err,Y1]=strfoptmodel(sprfile,datafile,Nsig0,Tau0,Tref0,SNR0,L,Options);

if nargin<7
	L=inf;
end;

if nargin<8
	Options=1;
end;

%load file
f=['load ' datafile];
eval(f);

%initial parameters
N=size(STRF1s,2);
STRF1=STRF1s(:,1:4:N);
STRF2=STRF2s(:,1:4:N);
taxis=taxis(1:4:N);
if strcmp(Sound,'MR')
	k=1:1706;
	L1=1706;
else
	k=1:1500;
	L1=1500;
end;

%initial parameters for integratefire neuron
Vtresh=-50;
Vrest=-65;
Fs=44100/44;
Fsd=24000;
Trig=round(((k-1)*728+1)/Fs*Fsd);

%prediction of injected current
[T,Y,Y1,Y2]=strfsprpre(sprfile,taxis,faxis,STRF1,STRF2,MdB,L1);

if L~=inf
	Y=Y(1:L*728+99);
end;
clear STRF1s STRF2s T Y1 Y2 k taxis faxis L1;


%option = optimset('fsolve');
%option=optimset(option,'LargeScale','on','DiffMaxChange',2,'DiffMinChange',.1,'Diagnostics','on','TolX',.1,'TolFun',.05,'Display','iter')    
%[beta,Err]=lsqcurvefit('strfoptmodelfit',beta0,xdata,0,[],[],option,Y,sprfile,STRF1,STRF2,PP,Vtresh,Vrest,Fs,Fsd,Trig,MdB,ModType,SModType,Sound,Options,Tref,SNR,Tau);
%[beta,Err]=fsolve('strfoptmodelfit',beta0,[],Y,sprfile,STRF1,STRF2,PP,Vtresh,Vrest,Fs,Fsd,Trig,MdB,ModType,SModType,Sound,Options,Wo1,Wo2);

option=optimset('fminsearch'); 
option=optimset(option,'DiffMaxChange',2,'DiffMinChange',.1,'TolX',.01,'TolFun',.02,'Display','iter');
[beta,Err]=fminsearch('strfoptmodelfit',[Nsig0 SNR0 Tau0 Tref0],option,Y,sprfile,STRF1,STRF2,PP,Vtresh,Vrest,Fs,Fsd,Trig,MdB,ModType,SModType,Sound,Options,Wo1,Wo2);        

Nsig=beta(1);
SNR=beta(2);
Tau=beta(3);
Tref=beta(4);
Err=sqrt(Err);
Y1(2:length(Y))=diff(Y)*Fs*Tau/R+Y(2:length(Y))/R;
Y1(1)=Y(1)*(Tau*Fs+1)/R;     



