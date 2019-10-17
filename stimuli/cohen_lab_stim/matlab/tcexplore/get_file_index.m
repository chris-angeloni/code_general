function file_index = get_file_index(file_name)

w = findstr(file_name,'.');
% convert the last five characters of file_name into a reasonable number as an index
if size(file_name,2) >= 9
	start_conversion = w - 5;
else
	start_conversion = 1;
end
if file_name(w-2)=='s'
	file_index = file_name([start_conversion-1:w-3 w-1]);
else
	file_index = file_name(start_conversion:w-1);
end

end_conversion = size(file_index,2);

% last character could be a number or a letter, convert letters to corresponding numbers	
if isempty(str2num(file_index(end_conversion))) == 1 % if its a character
	let2num = real(upper(file_index(end_conversion))) - 64; % converts A,a to 1 etc.
	if let2num < 10 % letter converted is a single digit, so convert it
		file_index(end_conversion) = num2str(let2num);
	else % all other characters converted to 0s
		file_index(end_conversion) = '0';
	end
end
% convert all other characters to 0s
for k=1:4
	if isempty(str2num(file_index(k))) == 1 % if its a character
		file_index(k) = '0';
	end
end

file_index = str2num(file_index);
