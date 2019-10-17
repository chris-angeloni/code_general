function imagescwaveform(waveform,N,channelnumber)

if nargin<3
    channelnumber=1:size(waveform,2);
end    

if nargin<2
    N=size(waveform,1);
end    

m=size(waveform,1);
disp(['Number of Spikes: ' int2str(m)]);

MX=max(max(max(waveform)));
MN=min(min(min(waveform)));

%figure%('Units','normalized','Position',[.1 .4 .13 .8])

for n=1:length(channelnumber)
    subplot(1,length(channelnumber),n)
    if length(waveform)>N
         i=randsample(size(waveform,1),N);
         wv=squeeze(waveform(i,channelnumber(n),:));
    else
         wv=squeeze(waveform(:,channelnumber(n),:));
    end 
    %imagesc(1:size(wv,2),min(min(wv)):1:max(max(wv)),hist(wv,min(min(wv)):1:max(max(wv))));
    MAX=max([MX -MN 400]);
  %  MAX=300;
    MIN=-MAX;
    imagesc(1:size(wv,2),MIN:MAX,hist(wv,MIN:MAX));     
    xlim([1 size(waveform,3)]);
    ylim([MIN MAX]);
    set(gca,'YDir','Normal');
    hold off
    set(gca,'visible','off')
end    
colormap hot
