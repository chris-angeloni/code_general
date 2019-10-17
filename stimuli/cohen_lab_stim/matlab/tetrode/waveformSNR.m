function SNR=waveformSNR(wv,sigmaN)

%input waveforms: N x M (N: number of spikes, M: number of samples in each
%spike)
%sigmaN:noise variance (std). optional 

wvmean=mean(wv);
Peak=max(abs(wvmean));

if nargin<2
    wverr=zeros(size(wv));
    for i=1:size(wv,2)
        wverr(:,i)=wv(:,i)-wvmean(i);
    end
    sigmaN=mean(std(wverr));
end


SNR=(Peak/sigmaN);
    
        