function [wvcon,wvSI]=waveformconsistency(waveform)

%computes the waveform consistency across four channels,
%this give us a sense of how different the mean waveforms are across the
%four channels
%used to get the "input" waveforms because they tend to have uniform
%amlitudes across the four channels
%r * mean( [ 1-var(s_k-s_l)/sqrt[ var(s_k)*var(s_l)]] ) 

wv1=mean(squeeze(waveform(:,1,:)));
wv2=mean(squeeze(waveform(:,2,:)));
wv3=mean(squeeze(waveform(:,3,:)));
wv4=mean(squeeze(waveform(:,4,:)));

wv=[wv1;wv2;wv3;wv4];   %4 by 75 

% [SNR]=waveformSNR(wv);
% j=find(SNR<1);
% wv(j,:)=[]; 

ch_var=var(wv');  %% compute energy at every channel
[MIN,j]=min(ch_var);
wv(j,:)=[]; %% ignore channel with smallest energy. this takes care when one of the electrode was probably bad

R=corrcoef(wv');
R=triu(R,1);
r=mean(mean(R(find(R)))); 

wvcon=0;
count=0;
for k=1:length(R)
    s_k=wv(k,:);
    for l=k+1:length(R)
        s_l=wv(l,:);
        con=1-var(s_k-s_l)/sqrt(var(s_k)*var(s_l));
        wvcon=wvcon+con;
        count=count+1;
    end    
end
wvcon=wvcon/count;
wvSI=r;


        
        
    
  




