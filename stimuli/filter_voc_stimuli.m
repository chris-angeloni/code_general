function filter_voc_stimuli(Dir)

addpath(genpath(Dir.cal));

filt_files = {'F104.mat' 'F105.mat'};

stim = dir([Dir.out 'vocs_in_noise*']);

for i = 1:length(stim)
    stim_in = [Dir.out stim(i).name];
    
    for j = 1:2
        load(filt_files{j});
        fn = sprintf('%sC%03d%s.wav',Dir.out,i,filt_files{j}(1:end-4));
        filterStim(filt,stim_in,fn);
    end
end
        

