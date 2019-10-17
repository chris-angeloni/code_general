%function  batchstrfoptmodel(namestruct1,namestruct2,sprfile,Nsig0,Tau0,Tref0,SNR0,L,Options,Y)
%
% Function     
%                 batch optimization of intracellular mechanism and resimulation of STRFs for DR and RN
%
% Input:
%                 namestruct1             struct with field 'name for DR'
%                                         namestruct=struct('name',{filename})
%                 namestruct2             struct with field 'name for RN'
%                 sprfile                 movingripple sound file
%                 Nsig0                   initail normalized threshold
%                 Tau0                    initial time constant
%                 Tref0                   initial refrectory period
%                 SNR0                    initial signal to noise ratio
%                 L                       number of blocks  (1706)
%                 Options                 binaural or monaural neuron
%                         		  STRF1 and STRF2  Options=0
%                         		  only STRF2       Options=2
%                         		  only STRF1       Options=1
%                 Y                       output of strfsprpre.m
%
% ANQI QIU
% 5/30/2002



function  batchstrfoptmodel(namestruct1,namestruct2,sprfile,Nsig0,Tau0,Tref0,SNR0,L,Options,Y);

M=size(namestruct1,2)

if nargin<8
	Options=ones(1,M);
end;

for n=1:M,
	filename=namestruct1(n).name;
	[Nsig,Tau,SNR,Tref,Err,Y1]=strfoptmodel(sprfile,filename,Y,Nsig0,Tau0,Tref0,SNR0,L,Options(n));
	f=['load ' filename ';'];
        eval(f);
	%resimulation of STRF for DR
	[timeaxis,freqaxis,STRF1mr,STRF2mr,STRF1smr,STRF2smr,PP,Wo1mr,Wo2mr,No1mr,No2mr,SPLN,FSImr,FSIemr,FSIimr,SImr,SIHistmr,SIHistrmr,SIHistemr,SIHistermr,SIHistimr,SIHistirmr]=strfsimulate2(sprfile,Y1,MdB,'dB','MR',Nsig,SNR,Tau,Tref,L,0.1);
	i=find(filename=='.');
        f=['save ' filename(1:i-1) '_o.mat Nsig Tau SNR Tref Err timeaxis freqaxis STRF1mr STRF2mr STRF1smr STRF2smr PP Wo1mr Wo2mr No1mr No2mr SPLN FSImr FSIemr FSIimr SImr SIHistmr SIHistrmr SIHistemr SIHistermr SIHistimr SIHistirmr;'];
        eval(f);   
	clear timeaxis freqaxis STRF1mr STRF2mr STRF1smr STRF2smr PP Wo1mr Wo2mr No1mr No2mr SPLN FSImr FSIemr FSIimr SImr SIHistmr SIHistrmr SIHistemr SIHistermr SIHistimr SIHistirmr filename;

	%resimualtion of STRF for RN
	filename=namestruct2(n).name;
	f=['load ' filename ';'];
    	eval(f); 
	N=size(STRF1s,2);
	taxis=taxis(1:4:N);
	STRF1=STRF1s(:,1:4:N);
	STRF2=STRF2s(:,1:4:N);
	clear STRF1s STRF2s
	[T,Yrn,Y1,Y2]=strfsprpre('ripplenoise.spr',taxis,faxis,STRF1,STRF2,MdB,1500);
        clear Y1 Y2;
        R=100E6;
        Fs=1/(taxis(2)-taxis(1));
        Y1(2:length(Yrn))=diff(Yrn)*Fs*Tau/R+Yrn(2:length(Yrn))/R;
        Y1(1)=Yrn(1)*(Tau*Fs+1)/R;
	[timeaxis,freqaxis,STRF1rn,STRF2rn,STRF1srn,STRF2srn,PP,Wo1rn,Wo2rn,No1rn,No2rn,SPLN,FSIrn,FSIern,FSIirn,SIrn,SIHistrn,SIHistrrn,SIHistern,SIHisterrn,SIHistirn,SIHistirrn]=strfsimulate2('ripplenoise.spr',Y1,MdB,'dB','RN',Nsig,SNR,Tau,Tref,1500,0.1);        	
	i=find(filename=='.');
	f=['save ' filename(1:i-1) '_o.mat Nsig Tau SNR Tref Err timeaxis freqaxis STRF1rn STRF2rn STRF1srn STRF2srn PP Wo1rn Wo2rn No1rn No2rn SPLN FSIrn FSIern FSIirn SIrn SIHistrn SIHistrrn SIHistern SIHisterrn SIHistirn SIHistirrn;'];
	eval(f);
	clear  Nsig Tau SNR Tref Err timeaxis freqaxis STRF1rn STRF2rn STRF1srn STRF2srn PP Wo1rn Wo2rn No1rn No2rn SPLN FSIrn FSIern FSIirn SIrn SIHistrn SIHistrrn SIHistern SIHisterrn SIHistirn SIHistirrn filename;
end;
	
 


