function h = plotSTA(x,y,STA,kwidth,lims)

% function h = plotSTA(x,y,STA,kwidth,lims)
% 
% Plots an STRF using x frequency bins, y time bins and intensity
% values in 2D matrix STA
% [optional]: Gaussian smoothing with kwidth kernel and limit on
% plot magnitudes between two numbers in lims


if ~exist('kwidth','var')
    kwidth = 0;
end
smoothSTA = imgaussfilt(STA,kwidth);

if ~exist('lims','var')
    lims = [min(smoothSTA(:)) max(smoothSTA(:))];
end

%kernel = fspecial('gaussian',kwidth,1);
%smoothSTA = imfilter(STA,kernel,'replicate');

h = imagesc(x,y,smoothSTA,lims);
set(gca,'ydir','normal');
%set(gca,'yscale','log');
xlabel('Time (ms)');
ylabel('Frequency (kHz)');
%xlim([-100 0]);
colormap(jet);