%
%function [JitterModel]=corrmodelfitspon(JitterData,disp)
%
%   FILE NAME       : CORR MODEL FIT SPON
%   DESCRIPTION     : Gaussian Function fit for Noise correlogram analysis.
%                     Computes the spike timing jitter and reliability.
%
%	JitterData      : Data containing all correlograms
%	disp            : Display: 'y' or 'n', Defualt=='n'
%
%Returned Variables
%
%       .Rnoise      : Noise Correlation - contains jitter and reliability
%       .lambdas     : Estimated spontaneous spike rate
%       .lamdad      : Estimated driven spike rate
%       .Rmodel      : Model Fitted Jitter Distribution Correlation
%       .sigmag      : Spike timing jitter - Gaussian Estimate
%       .pg          : Trial reproducibility - Gaussian Estimate
%       .phog        : Reliability of driven spikes, normal model
%       .lambdag     : Hypothetical spike rate - Gaussian Estimate
%                      (Assumesno jitter or trial reprodicibility errors)
%       .sigma       : Spike Timing Jitter - Direct Estimate
%       .p           : Trial reproducibility - Direct Estimate
%       .pho         : Reliability of driven spikes, direct estimate 
%       .lambda      : Hypothetical Spike rate - Direct Estimate
%                      (Assumes no jitter or rial reprodicibility errors)
%       .E           : Optimization error curve (e = Rnoise - Rmodel)
%                      versus lamdas
%       .dl          : Resolution for lambdas used to generate E
%
% (C) Monty A. Escabi, Jan 2011 (Last Edit Dec 2014)
%
function [JitterModel]=corrmodelfitspon(JitterData,disp)

%Input Arguments
if nargin<2
	disp='y';
end

%Converting Tau to seconds
Tau=JitterData.Tau/1000;

%Iteratively solving for lambdas and finding jitter parameters. Lambda is
%choosen so as to minimize theerror relative to normal jitter
count=1;
dl=0.25;    %Resolution for searching lambdas
lambdap=JitterData.lambdap;
for lambdas=0:dl:lambdap     %maximu lambdas corresponds to SNR=0
    
    %Driven spike rate
    lambdad=lambdap-lambdas;
    
    %Estimating Rnoise
    %Rnoise(count,:)=JitterData.Rab-JitterData.Raa+(JitterData.RaaS-JitterData.lambdap^2)/JitterData.lambdap^2*(lambdas^2+lambdas*lambdad);
    Rnoise(count,:)=JitterData.Rab-JitterData.Raa+(JitterData.RaaS-JitterData.lambdap^2)/JitterData.lambdap^2*(lambdas^2+2*lambdas*lambdad);
    
    %Fitting Gaussian Jitter Model to Rnoise
    %Constrained Optimization
    %
    %   0<pho<1
    %   0<sigma<20
    %
    i=find(abs(Tau)<.025);    %Select only values with delays < 25 msec for optimization
    [beta,RESNORM(count),RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = lsqcurvefit(@(beta,Tau) beta(1)*lambdad*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2),[0.5 .1],Tau(i),Rnoise(count,i),[0 0],[1 20]);
    %[beta,RESNORM(count),RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = lsqcurvefit(@(beta,Tau) beta(1)*lambdad*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2),[0.5 .1],Tau(i),Rnoise(count,i),[0 0],[10 20]);
    sigmag(count)=beta(2);
    phog(count)=beta(1);
    Rmodel(count,:)=beta(1)*lambdad*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2);
 
%   Did some testing to see why the model is always lower than the data
%   when pho>1. Baiscally, for a fixed pho=1 increasing sigma decreases the
%   height and therefore the error gets larger.  Here is the code I used
%      if phog(count)>=1
%                  
%          [beta2,RESNORM(count),RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = lsqcurvefit(@(beta2,Tau) 1*lambdad*1/sqrt(4*pi*(beta2/1000)^2)*exp(-(Tau).^2/4/(beta2/1000)^2),[0.5],Tau(i),Rnoise(count,i),[0],[20]);
%          sigmag(count)=beta2;
%          phog(count)=1;
%          Rmodel(count,:)=phog(count)*lambdad*1/sqrt(4*pi*(sigmag(count)/1000)^2)*exp(-(Tau).^2/4/(sigmag(count)/1000)^2);
%      end
%Old code - optimizing for p and lambda as opposed to pho and lambdad
%    [beta,RESNORM(count),RESIDUAL,EXITFLAG,OUTPUT,LAMBDA,JACOBIAN] = lsqcurvefit(@(beta,Tau) beta(1)*lambdap*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2),[0.5 .1],Tau(i),Rnoise(count,i),[0 0],[1 20]);
%    pg(count)=beta(1);
%    Rmodel(count,:)=beta(1)*lambdap*1/sqrt(4*pi*(beta(2)/1000)^2)*exp(-(Tau).^2/4/(beta(2)/1000)^2);
%
%     plot(Rnoise(count,:))
%     hold on
%     plot(Rmodel(count,:),'r')
%     hold off
%     [phog(count) lambdad]
%     pause(.1)
%

    %Computing Error
    %Did a large scale simulation and the normalized error appears to
    %perform better. Will set that as the default.
    Enorm(count)=norm(Rmodel(count,i)-Rnoise(count,i))/norm(Rnoise(count,i));   %Normalized Error
    Eunorm(count)=norm(Rmodel(count,i)-Rnoise(count,i));                        %Unnormalized Error
    E(count)=Enorm(count);
    
    %Increasing counter
    count=count+1;
    
end

%Temporary Saving Rnoise/Rmodel
Rmodelt=Rmodel;
Rnoiset=Rnoise;

%Optimal Parameters
i=find(min(E)==E);
lambdas=0:dl:lambdap;
lambdas=lambdas(i);
lambdad=lambdap-lambdas;
sigmag=sigmag(i);
phog=phog(i);
Rmodel=Rmodel(i,:);
Rnoise=Rnoise(i,:);
pg=phog*lambdad/lambdap;
%pg=pg(i);   old optimization for p and lambda

% figure(1)
% clf
% plot(0:dl:lambdap,E)
% pause(.1)

%Direct Estimate of Jitter and Reliability
Fsd=1./(Tau(2)-Tau(1));
Ncenter=(length(Rnoise)-1)/2+1;
%dN=min(max(find(Rnoise>1/2*max(Rnoise)))-Ncenter,floor((Ncenter-1)/6))   %Makes sure the 1/2 duration                                                                           %does not exceed the number of samples
dN=min(ceil(sigmag/1000*Fsd),floor((Ncenter-1)/6));
if dN==0    %In case jitter is too tight
   dN=1; 
end
Rnoise2=Rnoise(Ncenter-dN*5:Ncenter+dN*5);    %Select segment 5 sigmag wide relative to center
Tau2=Tau(Ncenter-dN*5:Ncenter+dN*5);
Mean=sum(Tau2.*Rnoise2/sum(Rnoise2));
sigma=sqrt(abs(sum((Tau2-Mean).^2.*Rnoise2/sum(Rnoise2))));
sigma=sigma*1000/sqrt(2);       %Divide by sqrt(2) because correlation is sqrt(2) as wide as jitter    
p=sum(Rnoise)/Fsd/lambdap;
pho=sum(Rnoise)/Fsd/lambdad;

%Plotting Data and Model
if strcmp(disp,'y')
	hold off
	plot(Tau,Rnoise,'k')
	hold on
	plot(Tau,Rmodel)
	xlabel('Delay (msec)')
	ylabel('Crosscorrelation Amplitude')
	pause(.1)
end

%Data Structure containing Model and Parameters
JitterModel.Rnoise=Rnoise;      %Now return optimal Rnoise
JitterModel.lambdas=lambdas;
JitterModel.lambdad=lambdad;
JitterModel.Rmodel=Rmodel;
JitterModel.sigmag=sigmag;
JitterModel.pg=pg;
JitterModel.phog=phog;
JitterModel.lambdag=lambdad/JitterModel.phog;
JitterModel.sigma=sigma;
JitterModel.p=p;
JitterModel.pho=pho;
JitterModel.lambda=lambdad/JitterModel.pho;
JitterModel.E=E;
JitterModel.Enorm=Enorm;
JitterModel.Eunorm=Eunorm;
JitterModel.dl=dl;
JitterModel.Fitting.Rnoise=Rnoiset;
JitterModel.Fitting.Rmodel=Rmodelt;