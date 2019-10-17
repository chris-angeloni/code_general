function [MTFJ] = mtfjittergenerate2(RASTER,FMAxis)

[RASbrk,Nbrk]=rasterbrk(RASTER(count,:),FMAxis,4,1341,0.5);
Norg = 10;
%Number of Trials and Stimulus Conditions
N=length(FMAxis);           %Number of stimulus conditions
NTrial=Nbrk*Norg;    %Number of trials per stimulus

%Generating Jitter Correlation Functions at each FM
for k=1:length(FMAxis)
    MaxTau = 4*1000/(2*FMAxis(k));   % in msec, half of one period
    % MaxTau = 100;
    Fsd = 50*FMAxis(k);  % relative Fsd
    % Fsd = 2000;
    
    if k==1
       RASk = RASbrk(1:Ntrial(k));
    else
       RASk = RASbrk(sum(Ntrial(1:(k-1))) + (1:Ntrial(k)));
    end
    
    %Expand rastergram into matrix format
    T=RASTER(1).T;
    [RAS,Fs]=rasterexpand(RASk,Fsd,T);
    
    L=size(RAS,2);
    M=size(RAS,1);
    
    PSTH=sum(RAS,1);
    F=fft(PSTH);
    R=real(ifft(F.*conj(F)))/Fsd/T;
    F=fft(RAS,[],2);
    Rdiag=real(ifft(F.*conj(F),[],2)/Fsd/T);
    Rshuf=(R-sum(Rdiag)) / (M*(M-1));
    
    [Tau,Raa,Rab,Rpp,Rmodel,sigmag,pg,lambdag,sigma,p,lambda]=jitterrastercorrfit(RAS,Fsd,MaxTau,'y');
    pause(1)

    %Appending to jitter MTF data structure
    MTFJ(k).FMAxis = FMAxis(k);
    MTFJ(k).p=p; P(k)=p;
    MTFJ(k).sigma=sigma;  
    MTFJ(k).lambda=lambda; 
    MTFJ(k).pg=pg;  Pg(k)=pg;
    MTFJ(k).sigmag=sigmag;  
    MTFJ(k).lambdag=lambdag;  
    MTFJ(k).Corr.Tau=Tau;  
    MTFJ(k).Corr.Raa=Raa;
    MTFJ(k).Corr.Rab=Rab;
    MTFJ(k).Corr.Rpp=Rpp;
    MTFJ(k).Corr.Rmodel=Rmodel;

end

for k=1:length(FMAxis)
     P(k) = MTFJ(k).p;
     Sigma(k) = (MTFJ(k).sigma)^2;
     Pg(k) = MTFJ(k).pg;
     Sigmag(k) = MTFJ(k).sigmag;
end

figure
subplot(221)
semilogx(FMAxis,P,'.b-');
axis([1 2000 0 1])
subplot(223)
semilogx(FMAxis,Sigma,'.b-');
axis([1 2000 0 150])
subplot(222)
semilogx(FMAxis,Pg,'.g-');
axis([1 2000 0 1])
subplot(224)
semilogx(FMAxis,Sigmag,'.g-');
axis([1 2000 0 1])

