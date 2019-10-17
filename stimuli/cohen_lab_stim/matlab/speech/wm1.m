%
%function [TP,MO]=wm1(x,Fs)
%	
%	FILE NAME 	: WM1
%	DESCRIPTION 	: Finds cycle to cycle To Milenkovic's Waveform 
%			  Matching Method
%			  Unlike WM extracts only one value of TP per cycle
%
%	x		: Input Signal
%	Fs		: Sampling Frequency
%
%	NO		: Removed data from extremities
%	TP		: Extracted Period array
%
function [TP,MO]=wm1(x,Fs)

%Finding Estimated Periods - Via Linear Interpolation 
L=10;
To=titze(x,Fs);
Tp=To(L);

%Removing first and last 10 periods
Ts=1/Fs;
Np=round(Tp/Ts);			

%Finding Downward Going ZC - Used to determine Measuremnet local
[nzd]=findzcd(x);

%Waveform Matching Period Estimation Method
i=1;
for no=nzd(L:length(nzd)-L)

	%Displaying % Done
	if no/1000==round(no/1000)
		disp(no)
	end

	%Period Length and Reference
	Np=round(Tp/Ts);

	%Finding Optimal Tp - Search range +/-10%
	Np10=floor(Np*.1);
	for l=0:2*Np10+1

		NTp	=Np-Np10+l;
		s 	=x(no-Np:no);
		sd	=x(no-Np-NTp:no-NTp);
		ss	=sum(s.*s);
		ssd	=sum(s.*sd);
		sdsd	=sum(sd.*sd);
		r	=findR(s,sd);
		k	=findK(s,sd);
		R(l+1)	=r;
		K(l+1)	=k;
		Eo(l+1)	=(-2*k*ssd+ss+k^2*sdsd)/(1+k^2);

	end

	%Finding Optimal period length 
	lo=find(min(Eo(2:2*Np10+1))==Eo);
	mo=Np - Np10 + lo -1;

	S0=Eo(lo-1);
	S1=Eo(lo);
	S2=Eo(lo+1);
	
%	Milenkovics method does not seem to work
%	dt=(S2-S0)/(S2-2*S1+S0)*Ts; %<-- Check this out - Need to confirm
%	Tp=mo*Ts+dt;

	%Finding Tp with minimum Eo by fitting to parabola - least MSE fit
	time=Ts*[mo-1 mo mo+1];
	E=[S0 S1 S2];
	Eindex=polyfit(time,E,2);
	time=Ts*(mo-1:.001:mo+1);
	Eval=Eindex(1)*time.^2 + Eindex(2)*time + Eindex(3);
	tind=find(min(Eval)==Eval);
	Tp=time(tind);
	TP(i)=Tp;
	MO(i)=mo;
	i=i+1;

end
