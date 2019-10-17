
function [CorrICCTX]=ftccorricctx(FTCic,FTCctx,Fs,Disp)

%Input Arguments
if nargin<4
    Disp='n';
end

%Computing Shuffled and Diagonal Correaltions
N=size(FTCic.data,4);
for k=1:size(FTCic.data,1)
    for l=1:size(FTCic.data,2)
        Xctx=squeeze(sum(FTCctx.Rtrial(k,l,:,:),3));
        Xic=squeeze(sum(FTCic.data(k,l,:,:),4))*Fs;
        Rpsth(:,k,l)=fftshift(real(ifft(fft(Xctx).*conj(fft(Xic)))));
    end
end
for k=1:size(FTCic.data,1)
    for l=1:size(FTCic.data,2)
        for m=1:size(FTCic.data,4)
            Xctx=squeeze(FTCctx.Rtrial(k,l,m,:));
            Xic=squeeze(FTCic.data(k,l,:,m))*Fs;
            Rdiag(:,k,l,m)=fftshift(real(ifft(fft(Xctx).*conj(fft(Xic)))));
        end
    end
end
Rdiag=sum(Rdiag,4);
Rshuf=Rpsth-Rdiag;
Rshuf=Rshuf/N/(N-1);
Rdiag=Rdiag/N;
Rdiff=Rdiag-Rshuf;
Nt=size(FTCic.data,3);
Tau=((1:Nt)-Nt/2)/Fs*1000;
Freq=FTCic.Freq;

%Correlation Data Structure 
CorrICCTX.Rdiag=Rdiag;
CorrICCTX.Rshuf=Rshuf;
CorrICCTX.Rdiff=Rdiff;
CorrICCTX.Tau=Tau;
CorrICCTX.Freq=Freq;

if strcmp(Disp,'y')
    %Plotting Rshuf versus level
    figure
    Max=max(max(max(Rshuf)));
    for k=1:8
       subplot(8,1,8-k+1)
       imagesc(log10(Freq/1000),Tau,Rshuf(:,:,k)) 
       hold on
       plot([log10(min(Freq/1000)) log10(max(Freq/1000))],[0 0],'k-.')
       caxis([-Max Max]*1.1)
    end

    %Plotting Rdiag versus level
    figure
    Max=max(max(max(Rdiag)));
    for k=1:8
       subplot(8,1,8-k+1)
       imagesc(log10(Freq/1000),Tau,Rdiag(:,:,k)) 
       hold on
       plot([log10(min(Freq/1000)) log10(max(Freq/1000))],[0 0],'k-.')
       caxis([-Max Max]*1.1)
    end

    %Plotting Rdiff=Rdiag-Rshuf versus level
    figure
    Max=max(max(max(Rdiag)));
    for k=1:8
       subplot(8,1,8-k+1)
       imagesc(log10(Freq/1000),Tau,(Rdiag(:,:,k))-Rshuf(:,:,k)) 
       hold on
       plot([log10(min(Freq/1000)) log10(max(Freq/1000))],[0 0],'k-.')
       caxis([-Max Max]*1.1)
    end

    %Plotting Average Rshuf and Rdiag vesus level
    figure
    Max=-99999;
    for k=1:8
       subplot(8,1,8-k+1)
       plot(Tau,squeeze(mean(Rshuf(:,:,k),2))','k')
       hold on
       plot(Tau,squeeze(mean(Rdiag(:,:,k),2))','r')
       Max=max([Max abs(max(squeeze(mean(Rshuf(:,:,k),2))')) abs(max(squeeze(mean(Rdiag(:,:,k),2))'))]);
       set(gca,'Box','off')
    end
    for k=1:8
        subplot(8,1,8-k+1)
        ylim([-Max Max]*1.1)
    end

    %Plotting Average Rdiff=Rdiag-Rshuf
    figure
    Max=-99999;
    Rdiff=Rdiag-Rshuf;
    for k=1:8
       subplot(8,1,8-k+1)
       plot(Tau,squeeze(mean(Rdiff(:,:,k),2))','k')
       Max=max([Max abs(max(squeeze(mean(Rdiff(:,:,k),2))'))]);
       set(gca,'Box','off')
    end
    for k=1:8
        subplot(8,1,8-k+1)
        ylim([-Max Max]*1.1)
    end
end
    
