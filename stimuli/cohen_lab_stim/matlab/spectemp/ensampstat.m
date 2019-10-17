%
%function [dBContDist,dBAmp,LinContDist,LinAmp,MeanEns,StdEns,KurtEns,Fst]=ensampstat(tracks,breakpoints)
%
%	FILE NAME 	: ENS AMP STAT
%	DESCRIPTION 	: Finds the ensemble amplitude (contrast) statistics
%			  Seraches for all *Cont.mat files in directory, 
%			  chooses those files designated by the tracks number
%			  variable, and computes the MeandB vs. StddB 
%			  ensemble histogram. Uses only sound segments 
%			  designated by the breakpoints array
%
%	traks		: File track numbers for ensemble average
%			  If 'all' averages ensemble over all *Cont* files
%			  found. Otherwise uses files designated by 'tracks'
%	breakpoints	: Designates the stimulus segments which are averaged
%			  Derived from the file: AMPDISTBREAK 
%
%RETUERNED VARIABLES
%	dBContDist	: Average dB Contrast Distribution over Entire Ensemble
%	dBAmp		: dB Amplitude Axis for dBContDist
%	LinContDist	: Average Lin Contrast Distribution over Entire Ensemble
%	LinAmp		: Lin Amplitude Axis for LinContDist
%	MeanEns		: Ensemble MeandB Trajectory
%	StdEns		: Ensemble StddB Trajectory
%	KurtEns		: Ensemble Kurtosis Trajectory
%	Fst		: Sampling rate for Trajectories
%
function [dBContDist,dBAmp,LinContDist,LinAmp,MeanEns,StdEns,KurtEns,Fst]=ensampstat(tracks,breakpoints)

%Preliminaries
more off

%Generating a File List
f=['ls *Cont*.mat' ];
[s,List]=unix(f);
List=[setstr(10) List setstr(10)];
returnindex=findstr(List,setstr(10));
for l=1:length(returnindex)-1
        for k=1:30
                if k+returnindex(l)<returnindex(l+1)
                        Lst(l,k)=List(returnindex(l)+k);
                else
                        Lst(l,k)=setstr(32);
                end
        end
end

%Finding Ensemble Distributions
StdEns=[];
MeanEns=[];
KurtEns=[];
dBContDist=[];
for k=1:size(Lst,1)
	%Finding File Name and Track Number
	index=findstr(Lst(k,:),'.mat');
	filename=[ Lst(k,1:index-1) '.mat'];
	index=findstr(Lst(k,:),'_');
	tracknumber=str2num(Lst(k,index-2:index-1));

	if exist(filename) & strcmp(tracks,'all')

		%Loading File
		f=['load ' filename]; 
		disp(f)	
		eval(f)

		%Number of Samples for 1 Seconds
		NT=2/Time(2);

		if exist('breakpoints')
			%Finding Number of Breakpoints
			NN=1/2*max(find(breakpoints(k,:)~=0 & breakpoints(k,:)~=-9999));
	
			for n=1:NN
				%Concatenating Parameter
				b1=breakpoints(k,2*n-1)+1;
				b2=breakpoints(k,2*n)-1;

				StdEns=[StdEns StddB(b1:b2)];
				MeanEns=[MeanEns MeandB(b1:b2)];
				KurtEns=[KurtEns KurtdB(b1:b2)];
				dBContDist=[dBContDist;sum(PDist(:,b1:b2)')];
			end
		else
			StdEns=[StdEns StddB(NT:length(StddB)-NT)];
			MeanEns=[MeanEns MeandB(NT:length(StddB)-NT)];
			KurtEns=[KurtEns KurtdB(NT:length(StddB)-NT)];
			dBContDist=[dBContDist;sum(PDist(:,NT:length(StddB)-NT)')];
		end

	elseif exist(filename) & ~isempty(find(tracknumber==tracks))

		%Loading File
		f=['load ' filename]; 
		disp(f)	
		eval(f)

		%Number of Samples for 1 Seconds
		NT=2/Time(2);

		if exist('breakpoints')
			%Finding Number of Breakpoints
%			NN=1/2*max(find(breakpoints(k,:)~=0));
			NN=1/2*max(find(breakpoints(k,:)~=0 & breakpoints(k,:)~=-9999));
			for n=1:NN
				%Concatenating Parameter
				b1=breakpoints(k,2*n-1)+1;
				b2=breakpoints(k,2*n)-1;

				StdEns=[StdEns StddB(b1:b2)];
				MeanEns=[MeanEns MeandB(b1:b2)];
				KurtEns=[KurtEns KurtdB(b1:b2)];
				dBContDist=[dBContDist;sum(PDist(:,b1:b2)')];
			end
		else
			StdEns=[StdEns StddB(NT:length(StddB)-NT)];
			MeanEns=[MeanEns MeandB(NT:length(StddB)-NT)];
			KurtEns=[KurtEns KurtdB(NT:length(StddB)-NT)];
			dBContDist=[dBContDist;sum(PDist(:,NT:length(StddB)-NT)')];
		end
	end
end

%Removing Mean From MeanEns
MeanEns=MeanEns-mean(MeanEns);

%Normalizing Contrast Distribution for unit Area
dBContDist=sum(dBContDist)/sum(sum(dBContDist));
dBAmp=Amp;

%Sampling Rate for Trajectories
Fst=1/(Time(2)-Time(1));

%Computing the Linear Amplitude Distribution By Transoforming the Bins of 
%dB ContDist
N=100;			%Number of Bins for Lin Distribution
count=length(dBContDist);
while dBContDist(count)==0
	count=count-1;
end
MaxSPL=dBAmp(count);
dx=(0:N)/100;
LinAmp=10.^((dBAmp-MaxSPL)/20);
for k=1:N
	i=find(dx(k)<=LinAmp & LinAmp<dx(k+1));
	LinContDist(k)=sum(dBContDist(i));
end
LinAmp=((0:N-1)+.5)/(N-1);
