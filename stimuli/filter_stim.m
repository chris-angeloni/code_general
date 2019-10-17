function out = filter_stim(in,filt_files)
    
    f = length(filt_files);
    
    out = zeros(length(in),f);
    for i = 1:f
        fprintf('\tUsing %s\n',filt_files{i});
        clear filt
        dat = load(filt_files{i});
        out(:,i) = conv(in',dat.filt,'same');
    end
    
