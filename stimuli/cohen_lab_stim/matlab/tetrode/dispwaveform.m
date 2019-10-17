function dispwaveform(waveform)

for j=1:size(waveform,1)

    plot(squeeze(waveform(j,1,:))+900);
    hold on
    plot(squeeze(waveform(j,2,:))+600);
    plot(squeeze(waveform(j,3,:))+300);
    plot(squeeze(waveform(j,4,:)));
    hold off
    pause(.6)
end