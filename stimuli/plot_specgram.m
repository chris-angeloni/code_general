function h = plot_specgram(S, t, f, varargin)
% Plots a spectrogram while cutting off sounds more quiet than one
% deviation below average noise. To plot with a legend, execute
% 'colorbar' immediately after calling.

sss = 10*log10(S);

if nargin == 3
    avgVol = mean(mean(sss));
    minDB = avgVol - 1 * mean(std(sss));
else
    minDB = varargin{1};
end

sss(sss < minDB) = minDB;
% surfc(t, f, sss); % surfc is not working well for me,
% % and surf not working at all.
% shading flat;
% view(2);

h = imagesc(t,f/1000,sss);
% To set the color legend, execute 'colorbar' after calling this function.
set(gca, 'YDir', 'normal');
%xlabel('Time (s)');
%ylabel('Frequency (kHz)');