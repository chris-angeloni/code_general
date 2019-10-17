function plotwaveform(waveform,N,color,channelnumber)

if nargin<4
    channelnumber=1:size(waveform,2);
end    
if nargin<3
    color='b';
end    
if nargin<2
    N=100;
end    

m=size(waveform,1);
disp(['Number of Spikes: ' int2str(m)]);
MX=max(max(max(waveform)));
MN=min(min(min(waveform)));

figure%('Units','normalized','Position',[.1 .4 .13 .8])

for n=1:length(channelnumber)
    subplot(1,length(channelnumber),n)
    if size(waveform,1)>N
         i=randsample(size(waveform,1),N);
         plot(squeeze(waveform(i,channelnumber(n),:))','Color',color);
         hold on
         plot(mean(squeeze(waveform(i,channelnumber(n),:))),'k','LineWidth',2); 
    else
         plot(squeeze(waveform(:,channelnumber(n),:))','Color',color);    
         hold on
         plot(mean(squeeze(waveform(:,channelnumber(n),:))),'k','LineWidth',2);
    end 
    xlim([1 size(waveform,3)]);
    MIN=min(-400,MN);
    MAX=max(MX,400);
    ylim([MIN MAX]);
    hold off
    set(gca,'visible','off')
end    
