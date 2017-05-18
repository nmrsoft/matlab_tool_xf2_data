function exx=exist_folder_display_problem(path_exp)

if exist(path_exp,'dir')
    exx=1;
else
    exx=0;
    disp(['folder ' path_exp ' not found!' ])
    for loop=1:1000
        k = strfind(path_exp,'/');
        if size(k,2)<2
            
            break,
        end
        cut_here=k(1,end-1);
        removed=path_exp(cut_here+1:end);
        path_exp=path_exp(1:cut_here);
        
        if ~exist(path_exp,'dir')
            
            disp(['This folder does not exists : ' path_exp ]);
        else
            h = msgbox(['Folder ' removed char(10) 'not found in Folder : '  char(10) path_exp  char(10) 'ls returns: ' char(10) ls(path_exp)]);
            break
            
            
            
        end
    end
    
end

end