
%function [STRFm,STRFam,STRFbm,x0,w,sf0,spectrop,t0,c,tf0,q,k,belta,Tpeak,Fpeak,SIs,SIt,SI,Errs,alpha_d]
%         =strfmodel_ic(STRF,STRFs,taxis,faxis,PP,Tresh,display);
%
%
%Function
%            Using Gabor function to fit STRF
%Input
%          STRF       the STRF that want to be fitted
%          STRFs      the significant STRFs that is relative to STRF
%          taxis      time sequence
%          faxis      frequency sequence
%          PP         Power level that is used to calculate energy
%          Tresh     Threshold that comes from wstrfstat.m
%          display    'y'  display the result
%                     'n'  do not show figures
%                     default is 'y'
%Output  
%          STRFm      the fitting STRF
%          STRFam     the fitting STRF coming from the first eigen value
%          STRFbm     the fitting STRF coming from the second eigen value
%          x0         the central position of the spectral evenlope
%          w          the width of the spectral evenlope
%          sf0        the best ripple density
%          spectrop   spectral phase
%          t0         the central position of the temporal evenlope
%          c          the width of the temporal evenlope
%          tf0        the best modulation frequency in strfmodel_ic.m
%                     the line along which the temporal frequency changes with time in strfmodel_ctx.m
%          q          the temporal phase
%          belta      the skewness of temporal evenlope. 
%                     In strfmodel_ic, the function is 2*actan(belta*taxis)
%                     In strfmodel_ctx, belta is the array in order to map taxis to a new time axis.
%          k          the absolute peak value of STRFm
%          Fpeak      At this point the temporal profile has the maximal area
%          Tpeak      At this point the spectral profile has the maximal area
%          SIs        the similarity index between modeling spectral profile and measured spectral profile
%          SIt        the similarity index between modeling temporal profile and measured temporal profile 
%          SI         the similarity index between STRFm and STRFs
%          Errs       the error between fitting STRF and STRFm
%          alpha_d    the relative power of the first and second eigen values.  alpha_d=(S(1,1)/(S(1,1)+S(2,2));
%
%Definition
%      a and b correspond to the first and second eigen value,respectively.
%      E* expresses energy
%      *m  describes the fitting result
%      Elp* the evenlope
%
%
%   ANQI QIU
%   11/12/2001



function [STRFm,STRFam,STRFbm,x0,w,sf0,spectrop,t0,c,tf0,q,k,belta,Tpeak,Fpeak,SIs,SIt,SI,Errs,alpha_d]=strfmodel_ic(STRF,STRFs,taxis,faxis,PP,Tresh,display);

if nargin<7
   display='y';
end;
%to initialize parameters
STRFam=0;
STRFbm=0;
STRFm=zeros(size(STRF));
x0=0;
w=0;
sf0=0;
spectrop=0;
t0=0;
c=0;
tf0=0;
q=0;
k=0;
belta=0;
Tpeak=find(sum(abs(STRF))==max(sum(abs(STRF))));
Fpeak=find(sum(abs(STRF'))==max(sum(abs(STRF'))));
SI=0;
SIs=0;
SIt=0;
Errs=0;
alpha_d=0;
%Define Zero-Valued STRF
STRF0=zeros(size(STRF));
%Define Temporal Sampling Rate
Fst=1/(taxis(2)-taxis(1));
xaxis=log2(faxis/500);
taxis=taxis+abs(taxis(1));

if STRF==0
   return;
end

%singular value decomposition
try
   [U,S,V]=svd(STRF);
catch
   return;
end
S1=zeros(size(STRF));
S2=zeros(size(STRF));
S1(1,1)=S(1,1);
S2(2,2)=S(2,2);
STRFa=U*S1*V';
STRFb=U*S2*V';

%the energy of the second eigen value STRF
Eb=strfstd(STRFb,STRF0,PP,Fst)
Ea=strfstd(STRFa,STRF0,PP,Fst)
%to calculate 
Enoise=Tresh/3.1            
%to calculate and alpha_d
alpha_d=S(1,1)/(S(1,1)+S(2,2));
clear U V S1 S2 S;
%*************************************************************************************
%                                 The First Eigenvalue
%*************************************************************************************
%step1:Extraxtion of parameters for the first part STRF1

%step1_1:to find the sf0 and tf0 for the first part STRF1
[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRFa,300,4,'n');
[BestFm,BestRD]=rtfparam(Fm,RD,RTF,0.5,'n');	
if (BestFm==0) & (BestRD==0)
   return;
end;
%to find spectral envelope and create Gaussian function
Tpeak1=find(sum(abs(STRFa))==max(sum(abs(STRFa))));
Fpeak1=find(sum(abs(STRFa'))==max(sum(abs(STRFa'))));
%spectral envelope
Elpsa=abs(hilbert(STRFa(:,Tpeak1)));
%central frequency
betas0(1)=xaxis(find(Elpsa==max(Elpsa)));
%bandwidth of spectral envelope
betas0(2)=xaxis(max(find(Elpsa>=exp(-1)*max(Elpsa))))-xaxis(min(find(Elpsa>=exp(-1)*max(Elpsa))));
%to initialize ripple density and spectral phase for sinusoid wave in Gabor function
betas0(3)=abs(BestRD(1));
betas0(4)=2*pi*betas0(3)*(betas0(1)-xaxis(Fpeak1));
%the peak value
betas0(5)=max(abs(STRFa(:,Tpeak1)));    %the gain 
warning off;
ydata=STRFa(:,Tpeak1);
betas=lsqcurvefit('spectrofit',betas0,xaxis,ydata');
%to compare error from intitial parameters with that from fitting parameters
Temp_elpsa1=betas0(5)*(exp(-(2*(xaxis-betas0(1))/betas0(2)).^2).*cos(2*pi*betas0(3)*(xaxis-betas0(1))+betas0(4)));
Temp_elpsa2=betas(5)*(exp(-(2*(xaxis-betas(1))/betas(2)).^2).*cos(2*pi*betas(3)*(xaxis-betas(1))+betas(4)));
T=num2str(Temp_elpsa2);
T1=num2str(zeros(1,length(Temp_elpsa2)));
if (sum((Temp_elpsa1-STRFa(:,Tpeak1)').^2)>sum((Temp_elpsa2-STRFa(:,Tpeak1)').^2)) & (~strcmp(T,T1))
   x0(1)=betas(1);
   w(1)=betas(2);
   if betas(3)<0
      sf0(1)=-betas(3);
      spectrop(1)=-betas(4);
   else
      sf0(1)=betas(3);
      spectrop(1)=betas(4);
   end;     
   k(1,1)=betas(5);
else
   x0(1)=betas0(1);
   w(1)=betas0(2);
   if betas0(3)<0
      sf0(1)=-betas0(3);
      spectrop(1)=-betas0(4);
   else
      sf0(1)=betas0(3);
      spectrop(1)=betas0(4);
   end;     
   k(1,1)=betas0(5);
end
clear Temp_elpsa1 Temp_elpsa2 betas0 betas T T1; 
%to adjust the range of peak value and spectral phase
if k(1,1)<0
   spectrop(1)=spectrop(1)+pi;
   k(1,1)=-k(1,1);
end;
if spectrop(1)>2*pi
   spectrop(1)=spectrop(1)-2*pi*round(spectrop(1)/2/pi);
else if spectrop(1)<-2*pi
      spectrop(1)=spectrop(1)-2*pi*(round(spectrop(1)/2/pi)-1);
   end
end  

%step1_2:to find temporal envelope and create Gaussian function
Elpta=abs(hilbert(STRFa(Fpeak1,:)));
%peak latency
betat0(1)=taxis(find(Elpta==max(Elpta)));
%temporal bandwidth
betat0(2)=taxis(max(find(Elpta>=exp(-1)*max(Elpta))))-taxis(min(find(Elpta>=exp(-1)*max(Elpta))));
%to find modulation frequency and temporal phase for sinusoid wave in Gabor fuction
betat0(3)=abs(BestFm(1));
betat0(4)=2*pi*betat0(3)*(betat0(1)-taxis(Tpeak1));
%peak value
betat0(5)=max(abs(STRFa(Fpeak1,:))); 
%the skewness
betat0(6)=tan(0.5*taxis(Tpeak1))/taxis(Tpeak1);
warning off;
ydata=STRFa(Fpeak1,:);
betat=lsqcurvefit('tempofit',betat0,taxis,ydata);
%to compare error from intitial parameters with that from fitting parameters
Temp_elpta1=betat0(5)*(exp(-(2*(2*atan(betat0(6)*taxis)-betat0(1))/betat0(2)).^2).*cos(2*pi*betat0(3)*(2*atan(betat0(6)*taxis)-betat0(1))+betat0(4)));
Temp_elpta2=betat(5)*(exp(-(2*(2*atan(betat(6)*taxis)-betat(1))/betat(2)).^2).*cos(2*pi*betat(3)*(2*atan(betat(6)*taxis)-betat(1))+betat(4)));
T=num2str(Temp_elpta2);
T1=num2str(zeros(1,length(Temp_elpta2)));
if (sum((Temp_elpta1-STRFa(Fpeak1,:)).^2)>sum((Temp_elpta2-STRFa(Fpeak1,:)).^2)) & (~strcmp(T,T1))
	t0(1)=betat(1);
	c(1)=betat(2);
	tf0(1)=betat(3);
   q(1)=betat(4);
   belta(1)=betat(6);
else
	t0(1)=betat0(1);
	c(1)=betat0(2);
	tf0(1)=betat0(3);
   q(1)=betat0(4);
   belta(1)=betat0(6);
end
clear Temp_elpta1 Temp_elpta2 betat0 betat ydata T T1;
if tf0(1)<0
   tf0(1)=-tf0(1);
   q(1)=-q(1);
end;
if q(1)>2*pi
   q(1)=q(1)-2*pi*round(q(1)/2/pi);
else if q(1)<-2*pi
      q(1)=q(1)-2*pi*(round(q(1)/2/pi)-1);
   end
end

STRFam=k(1,1)*(exp(-(2*(xaxis-x0(1))/w(1)).^2).*cos(2*pi*sf0(1)*(xaxis-x0(1))+spectrop(1)))'*(exp(-(2*(2*atan(belta(1)*taxis)-t0(1))/c(1)).^2).*cos(2*pi*tf0(1)*(2*atan(belta(1)*taxis)-t0(1))+q(1)));
STRFam=STRFam/strfstd(STRFam,STRF0,PP,Fst)*strfstd(STRFa,STRF0,PP,Fst);

%****************************************************************
%                   the second eigenvalue
%****************************************************************

%step2: for the second eigenvalue
if Eb>Enoise
	%to find the sf0 and tf0 for the second part STRF2
	[Fm,RD,RTF]=strf2rtf(taxis,faxis,STRFb,300,4,'n');	
   [BestFm,BestRD]=rtfparam(Fm,RD,RTF,0.5,'n');
	%step2-1:to find spectral envelope and create Gaussian function
	Tpeak2=find(sum(abs(STRFb))==max(sum(abs(STRFb))));
	Fpeak2=find(sum(abs(STRFb'))==max(sum(abs(STRFb'))));
	Elpsb=abs(hilbert(STRFb(:,Tpeak2)));
   %central frequency
   betas0(1)=xaxis(find(Elpsb==max(Elpsb)));
   %spectral bandwidth
	betas0(2)=xaxis(max(find(Elpsb>=exp(-1)*max(Elpsb))))-xaxis(min(find(Elpsb>=exp(-1)*max(Elpsb))));
	%to find ripple density and spectral phase for sinusoid wave in Gabor function
	betas0(3)=abs(BestRD(1));
  	betas0(4)=2*pi*betas0(3)*(betas0(1)-xaxis(Fpeak2));
   %peak value  
   betas0(5)=max(abs(STRFb(:,Tpeak2)));    %the gain 
	ydata=STRFb(:,Tpeak2);
	betas=lsqcurvefit('spectrofit',betas0,xaxis,ydata');
   %to compare error from intitial parameters with that from fitting parameters
	Temp_elpsa1=betas0(5)*(exp(-(2*(xaxis-betas0(1))/betas0(2)).^2).*cos(2*pi*betas0(3)*(xaxis-betas0(1))+betas0(4)));
   Temp_elpsa2=betas(5)*(exp(-(2*(xaxis-betas(1))/betas(2)).^2).*cos(2*pi*betas(3)*(xaxis-betas(1))+betas(4)));
   T=num2str(Temp_elpsa2);
   T1=num2str(zeros(1,length(Temp_elpsa2)));
	if (sum((Temp_elpsa1-STRFb(:,Tpeak2)').^2)>sum((Temp_elpsa2-STRFb(:,Tpeak2)').^2)) & (~strcmp(T,T1))
	 	x0(2)=betas(1);
		w(2)=betas(2);
   	if betas(3)<0
         sf0(2)=-betas(3);
    		spectrop(2)=-betas(4);
   	else
         sf0(2)=betas(3);
         spectrop(2)=betas(4);
      end;     
        k(2,1)=betas(5);
   else
     	x0(2)=betas0(1);
		w(2)=betas0(2);
   	if betas(3)<0
         sf0(2)=-betas0(3);
     		spectrop(2)=-betas0(4);
   	else
         sf0(2)=betas0(3);
         spectrop(2)=betas0(4);
      end;     
      k(2,1)=betas(5);
   end;   
   clear Temp_elpsa1 Temp_elpsa2 betas0 betas ydata T T1;   
   if k(2,1)<0
   	spectrop(2)=spectrop(2)+pi;
   	k(2,1)=-k(2,1);
	end;
   if spectrop(2)>2*pi
   	spectrop(2)=spectrop(2)-2*pi*round(spectrop(2)/2/pi);
	else if spectrop(2)<-2*pi
      	spectrop(2)=spectrop(2)-2*pi*(round(spectrop(2)/2/pi)-1);
   	end
	end
	    
  	%step2_2:to find temporal envelope and create Gaussian function
   Elptb=abs(hilbert(STRFb(Fpeak2,:)));
   %peak latency  
   betat0(1)=taxis(find(Elptb==max(Elptb)));
   %duration
  	betat0(2)=taxis(max(find(Elptb>=exp(-1)*max(Elptb))))-taxis(min(find(Elptb>=exp(-1)*max(Elptb))));
  	%to find modulation frequency and temporal phase of sinusoid wave
	betat0(3)=abs(BestFm(1));
  	betat0(4)=2*pi*betat0(3)*(betat0(1)-taxis(Tpeak2));
   %peak value
   betat0(5)=max(abs(STRFb(Fpeak1,:)));				         %the gain
   %skewness
   betat0(6)=tan(0.5*taxis(Tpeak2))/taxis(Tpeak2);    %the beta for Ts=2*atan(beta*taxis);
   ydata=STRFb(Fpeak2,:);
   betat=lsqcurvefit('tempofit',betat0,taxis,ydata);
      %to compare error from intitial parameters with that from fitting parameters
	Temp_elpta1=betat0(5)*(exp(-(2*(2*atan(betat0(6)*taxis)-betat0(1))/betat0(2)).^2).*cos(2*pi*betat0(3)*(2*atan(betat0(6)*taxis)-betat0(1))+betat0(4)));
   Temp_elpta2=betat(5)*(exp(-(2*(2*atan(betat(6)*taxis)-betat(1))/betat(2)).^2).*cos(2*pi*betat(3)*(2*atan(betat(6)*taxis)-betat(1))+betat(4)));
   T=num2str(Temp_elpta2);
   T1=num2str(zeros(1,length(Temp_elpta2)));
	if (sum((Temp_elpta1-STRFb(Fpeak2,:)).^2)>sum((Temp_elpta2-STRFb(Fpeak2,:)).^2)) & (~strcmp(T,T1))
   	t0(2)=betat(1);
		c(2)=betat(2);
		tf0(2)=betat(3);
      q(2)=betat(4);
      belta(2)=betat(6);
   else
 		t0(2)=betat0(1);
		c(2)=betat0(2);
		tf0(2)=betat0(3);
      q(2)=betat0(4);
      belta(2)=betat0(6);
   end   
   clear Temp_elpta1 Temp_elpta2 betat0 betat ydata T T1;   
   if tf0(2)<0
   	tf0(2)=-tf0(2);
   	q(2)=-q(2);
	end;
   if q(2)>2*pi
       q(2)=q(2)-2*pi*round(q(2)/2/pi);
	else if q(2)<-2*pi
   	   q(2)=q(2)-2*pi*(round(q(2)/2/pi)-1);
   	end
	end

   STRFbm=k(2,1)*(exp(-(2*(xaxis-x0(2))/w(2)).^2).*cos(2*pi*sf0(2)*(xaxis-x0(2))+spectrop(2)))'*(exp(-(2*(2*atan(belta(2)*taxis)-t0(2))/c(2)).^2).*cos(2*pi*tf0(2)*(2*atan(belta(2)*taxis)-t0(2))+q(2)));
   STRFbm=STRFbm/strfstd(STRFbm,STRF0,PP,Fst)*Eb;
else
   STRFbm=zeros(size(STRF));
end
%STRF model
STRFm=STRFam+STRFbm;
%Energy Error Metric
i=find(STRFm~=0 | STRFs~=0);
Errs=sum((STRFm(i)-STRFs(i)).^2)/sum(STRFs(i).^2);
SI=strfcorrcoef(STRFs,STRFm);
a=corrcoef(STRFm(:,Tpeak),STRFs(:,Tpeak));
SIs=a(1,2);
a=corrcoef(STRFm(Fpeak,:),STRFs(Fpeak,:));
SIt=a(1,2);
clear a k;
%the peak value
k=abs(STRFm(Fpeak,Tpeak));

%to display fitting results and spectral and temporal evenlopes
if strcmp(display,'y')
	Max=max(max(abs(STRF)));
	figure;
	set(gcf,'Position',[98 28 779 660])
	subplot(3,3,1);
	imagesc(STRF,[-Max Max]), colorbar
	set(gca,'YDir','normal')
	title('Original STRF');   
	subplot(3,3,2);
	imagesc(STRFm,[-Max Max]), colorbar
	set(gca,'YDir','normal')
	title('Fit STRF');
	subplot(3,3,3);
	imagesc(STRF-STRFm,[-Max Max]), colorbar
	set(gca,'YDir','normal')
	title(['Error=' num2str(Errs)]);
	subplot(3,3,4);
	imagesc(STRFa,[-Max Max]), colorbar
	set(gca,'YDir','normal')
	title('The first eigenvalue(STRFa)');
	subplot(3,3,5);
	imagesc(STRFam,[-Max Max]), colorbar
	set(gca,'YDir','normal')
	title('Fit STRF1');
	subplot(3,3,6);
	imagesc(STRFa-STRFam,[-Max Max]), colorbar
	set(gca,'YDir','normal')
	title('Error');
	if max(max(abs(STRFbm)))~=0
  	 	subplot(3,3,7);
   	imagesc(STRFb,[-Max Max]), colorbar
   	set(gca,'YDir','normal')
   	title('The second eigenvalue(STRFb)');
   	subplot(3,3,8);
   	imagesc(STRFbm,[-Max Max]), colorbar
   	set(gca,'YDir','normal')
   	title('Fit STRF2');
   	subplot(3,3,9);
   	imagesc(STRFb-STRFbm,[-Max Max]), colorbar
   	set(gca,'YDir','normal')
   	title('Error');
	end;
	figure;
	subplot(221);
	plot(STRFa(:,Tpeak1))
	title('Spectral profile for STRFa');
	hold on
	plot(STRFam(:,Tpeak1),'r')
	subplot(222);
	plot(STRFa(Fpeak1,:))
	title('Temporal profile for STRFa');
	hold on
	plot(STRFam(Fpeak1,:),'r')
	if max(max(abs(STRFbm)))~=0
		subplot(223);
		plot(STRFb(:,Tpeak2))
		title('Spectral profile for STRFb');
		hold on
		plot(STRFbm(:,Tpeak2),'r')
		subplot(224);
		plot(STRFb(Fpeak2,:))
		title('Temporal profile for STRFb');
		hold on
		plot(STRFbm(Fpeak2,:),'r')
   end;
end;

   

