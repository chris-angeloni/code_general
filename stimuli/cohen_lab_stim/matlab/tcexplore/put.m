function put(attributevalue, attributenum)
%	The Put function places values in the attribute data matrix.  
%The format to be used to enter data into the data matrix is 
%put(attributevalue, attributenumber).  The user should make sure 
%to use attribute numbers that are not used for a specific attribute 
%already.  The added attribute is added to the row in the data matrix 
%of the most recent file.
% last modified 8 nov, hwm

ui_handles = get(figure(1), 'userdata');
save_button = ui_handles(22);
file_name = get(ui_handles(23), 'userdata');
file_index = get_file_index(file_name);


attributes = get(save_button, 'userdata');
if isempty(attributes) == 1
	attributes= zeros(1, 30);
	row = 1;
else
	% for m=1:(size(attributes, 1))
	[row, n] = find (attributes(:, 1) == file_index);
	row= max(row);
	if isempty(row) == 1
		row= size(attributes, 1)+1;
	end
end

attributes(row, 1) = file_index;
attributes(row, attributenum)=attributevalue;
set(save_button, 'userdata', attributes);
