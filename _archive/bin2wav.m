function bin2wav

bin_fn = 'C:\Users\Chris\Documents\Chris_Rotation\MouseVocs\m46652_female_urine_alone_20130308_1.ch2';
wav_fn = 'C:\Users\Chris\Documents\Chris_Rotation\MouseVocs\m46652_female_urine_alone_20130308_1.wav';
fs = 450450;

% Find how many samples are in the binary file
fprintf('Counting binary samples... ');
fid = fopen(bin_fn,'r');
[~,count] = fread(fid,inf,'float32');
fprintf('%g samples\n',count);

% Calculate file chunks
chunk_size = 1e6;
n_chunks = ceil(count / chunk_size);
last_chunk = count - (chunk_size * (n_chunks - 1));

% Write to wav file
fid = []; fmt = [];
for i = 1:n_chunks
    n = chunk_size;
    switch(i)
        case 1
            w = 1; % Start write and keep file open
        case n_chunks
            w = 4; % Keep writing, but close the file after
            n = last_chunk;
        otherwise
            w = 3; % Keep writing
    end
    
    % Read binary data
    offset = i * chunk_size + 1;
    y = read_file_chunk(bin_fn,n,offset,'float32');
    
    [fid, fmt] = wavwriteStim(y, fs, 32, wav_fn, w, count, fid, fmt);
    
    clear y
    disp(i);
end