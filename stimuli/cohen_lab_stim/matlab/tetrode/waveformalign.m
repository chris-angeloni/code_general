function [waveforma,shifts]=waveformalign(waveform,nSamp,option)

if nargin<3
    option=1;
end

N=size(waveform,1); % # of spikes
M=size(waveform,3); % # of samples per spike

waveforma=zeros(N,4,M-2*nSamp);
shifts=zeros(1,N);

a=squeeze(mean(waveform,1));
for n=1:N
    b=squeeze(waveform(n,:,:));
    switch option     
        case 1
            xab=xcorr2(a,b);
            [x,i]=max(max(xab));
        case 2
            [x,i]=max(sum(b.^2));    
        case 3
            [x,i]=min(min(b));
    end        
            
    shift=i-M;
    if abs(shift)<nSamp
        waveforma(n,:,:)=waveform(n,:,[nSamp+1:M-nSamp]-shift); 
        shifts(n)=shift;
    else    
        waveforma(n,:,:)=waveform(n,:,[nSamp+1:M-nSamp]);
    end    
end