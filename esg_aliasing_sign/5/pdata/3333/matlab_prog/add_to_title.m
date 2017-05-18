function        add_to_title(path_out,title)


fileID = fopen([path_out 'title'],'a');
if fileID~=-1
    fprintf(fileID,'\n');
    fprintf(fileID,'%s\n',title);
    fclose(fileID);
    
end
end
