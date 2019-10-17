function attributevalue=get(attributenum)

ui_handles = get (gcf, 'userdata');
save_button = ui_handles(22);
attributes = get(save_button, 'userdata');
file_name = get(ui_handles(23), 'userdata');
file_index = get_file_index(file_name);

[row, n] = find (attributes(:, 1) == file_index);
if isempty(row) == 1
	attributevalue=0;
else
	attributevalue=attributes(row, attributenum);
end