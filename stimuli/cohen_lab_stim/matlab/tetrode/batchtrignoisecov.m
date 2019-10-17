for i=1:length(List) i
    load(List(i).name)
    [Cn]=tetrodecov(Tetrode,10,300,5000,1);
    save ([List(i).name(1:end-4) 'NoiseCov.mat'],'Cn');
    Trig=Tetrode(1).Trig;
    Fs=Tetrode(1).Fs;
    save ([List(i).name(1:end-4) 'Trig.mat'],'Trig','Fs');
end