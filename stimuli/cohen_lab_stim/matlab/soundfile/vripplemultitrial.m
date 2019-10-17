%
%function []=vripplemultitrial(outfile,f1,f2,Fm1,Fm2,FM,RD,M,Fs,NS,RP,L,Tpause,BP,alpha,calib)
%
%	FILE NAME 	: V RIPPLE MULTI TRIAL
%	DESCRIPTION : Multi Trial Binaural Virtual Ripple Sound for
%                 CAT Experiments. Used VRIPPLEBINSQRSQR
%
%			  DISCRETE CORRELATION MAP
%			  DISCRETE TEMPORAL MODULATIONS
%
%	outfile	: Output File Name - No Extension
%	f1		: Minimum Carrier Frequency
%	f2		: Maximum Carrier Frequency
%	Fm1		: Minimum temporal modulation rate
%	Fm2		: Maximum temporal modulation rate
%	FM		: Ripple temporal modulation rate
%	RD		: Ripple density
%   M       : Number of Samples
%   Fs      : Sampling Rate
%	NS		: Number of sinusoid carriers
%	RP		: Ripple Phase [0,2*pi]
%			  Default : Choosen randomly
%   L       : Number of Trials
%   Tpause  : Silent Pause in Between Presentations (sec)
%	BP		: Binaural/interaural Carrier Phase
%			  Random ('R') or Fixed ('F')
%			  Note: for 'R' produces no percept / carriers
%			  have to be alligned for left/right ear
%             (Default=='F')
%	alpha   : Window onset ratio 
%			  rt=alpha*dt
%			  rt==rise time
%			  dt==window half width
%			  OPTIONAL: Default=0.25
%	calib	: Speaker calibration data structure (Optional)
%
function []=vripplemultitrial(outfile,f1,f2,Fm1,Fm2,FM,RD,M,Fs,NS,RP,L,Tpause,BP,alpha,calib)

%Input Arguments
if nargin<14
	BP='F';	
end
if nargin<15
	alpha=0.25;
end


%Generating Randomized Modulation Rate Sequence - blocked randomized
Fm=FM;
Rd=RD;
FM=[];
RD=[];
FMb=[];         %Blocked
RDb=[];         %Blocked
for l=1:length(Fm)
    for m=1:length(Rd)
        
        FMb=[FMb Fm];
        RDb=[RDb ones(size(Fm))*Rd(m)];
           
    end
end
rand('state',0);
for k=1:L
    index=randperm(length(FMb));
    FM=[FM FMb(index)];
    RD=[RD RDb(index)];
end

%Opening Output File
fidout=fopen([outfile '.raw'],'w')
TempFile2=[outfile 'Trig.raw'];
fidtemp2=fopen(TempFile2,'wb');

%Pause Segment
Xpause=zeros(1,round(Fs*Tpause));

%Generating Sounds
for k=1:length(FM)
 
    %Generating VRipple for Lth Trial
    if nargin<16
        [X1,X2]=vripplebinsqrsqr('',f1,f2,Fm1,Fm2,FM(k),RD(k),M,Fs,NS,RP,BP,alpha,k,k+10*L);
    else
        [X1,X2]=vripplebinsqrsqr('',f1,f2,Fm1,Fm2,FM(k),RD(k),M,Fs,NS,RP,BP,alpha,k,k+10*L,calib);
    end
    
    %Generating Window For onset - 10 msec RT
    if k==1
        [W]=windowm(Fs,3,length(X1),10);
    end
    
    %Generating Audio Channels
    Y1=[X1.*W Xpause];
    Y2=[X2.*W Xpause];
    
    %Generating Trigger Signal
	if k==1
		Trig=[zeros(1,length(Y1))];
		Trig(1:2000)=round(2^31*ones(1,2000));
    end
    
    %Interleaving All Channels - Amplifying Channels for Int32
    Y(1:2:length(Y1)*2)=round(Y1*2^27); 
    Y(2:2:length(Y1)*2)=round(Y2*2^27);
    
    %Saving To File
    fwrite(fidout,Y,'int32');
    fwrite(fidtemp2,Trig,'int32');
end

%Saving Parameters
f=['save ' outfile '_param FM RD f1 f2 Fm1 Fm2 M Fs NS RP L Tpause BP alpha'];
eval(f)

%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 4 -l -s ' outfile '.raw -l ' outfile '.wav' ];
eval(f)


%Using SOX to convert to WAV File
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 2 -4 -s ' outfile '.raw  -4 -f ' outfile '.wav' ];
eval(f);
f=['!/usr/local/bin/sox -r ' int2str(Fs) ' -c 1 -4 -s ' TempFile2 '  -4 -f ' outfile '_Trig.wav' ];
eval(f);



%Closeing Files
fclose all