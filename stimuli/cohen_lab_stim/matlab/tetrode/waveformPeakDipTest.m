function [PeakDip,PeakDipP,PeakDipInterval,PeakDipXl,PeakDipXu]=waveformPeakDipTest(waveform)

% values distribution at midpoint (peak/valley) 
% using the 'dip' test for unimodality. 
for i=1:4
    midpt=floor(size(waveform,3)/2)+1;
    wv=squeeze(waveform(:,i,:));
    X=(wv(:,midpt));
    %X=X/max(abs(X));
    [dip, p,xl,xu] = HartigansDipSignifTest(X, 500);
    PeakDip(i)=dip;
    PeakDipP(i)=p;
    PeakDipXl(i)=xl;
    PeakDipXu(i)=xu;
end
PeakDipInterval=abs(PeakDipXl-PeakDipXu)./abs(mean([PeakDipXl;PeakDipXu]));