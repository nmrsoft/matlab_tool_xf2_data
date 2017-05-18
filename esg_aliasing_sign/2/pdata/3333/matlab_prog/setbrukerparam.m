function [value_before]=setbrukerparam(path,param,value_param)
%% Modify or add parameters in jcamp bruker files (acqu, proc, etc.)
% Version 0.9 - This was tested by comparing files (minor differences
% remains but are expected to cause no problem to topspin/xwinnmr
% but this was not tested yet
% Also works for tables of parameters (such as "P", "D", etc.)
% Examples:
% setbrukerparam([exp_name '1/acqus'],'NS','32');
% setbrukerparam([exp_name '1/acqus'],'P 1','10.15');
%
% Ignored: 
% 1) series of more than one space (because matlab uses space/EOL as
% separator
% 2) Sometimes Bruker put lines with "$$" in the same line as previous data,
% sometimes not. This function always put lines with "$$" in new line.

number=1;%if not table 
if size(strfind(param,' ')>0) %testing if table
    pos=strfind(param,' ');
    tmpstr=param(1:pos-1);
    valuestr=param(pos+1:end);
    number=2+str2num(param(pos+1:end));
    param=tmpstr;
end

max_for_return=70;
don_t=0;
count_for_end_of_line=0;
%count to 72 and replace "space" with "enter".

value_before='';
str_in=[path  ];
str_out=[path  '_tmp'];
%read acqus
content=textread(str_in,'%s' ,'bufsize',32*1024);
%sw         = str2num(char(content(strmatch('##$SW=',content')+1)));
%pulprog    = char(content(strmatch('##$PULPROG=',content')+1));pulprog = pulprog(2:(end-1));
% this is the number of point in F2, (2 td)
look_for=['##$' param '='];
where=strmatch(look_for,content')+1;
if size(where,1)==0% found it ... read and dispay before setting new value
    %need to find where it goes
    
    if number>1
        problem_display=['Cannot add arrayed parameter "' param '" to file ' path]
        error('not_able_to_do_this2');
    end
    for loop_over_content=1:size(content,1)
        toto=content(loop_over_content);
        temp=toto{1};
        if (  strmatch('##$',temp) )
            [trasfsda,idx] = sort({temp;look_for});
            flag=idx(1,1)
            if flag>1,
                fl=flag
                si=size(content,1)
                real_pos_end=loop_over_content-1
                real_pos_st=loop_over_content
                temp
                [content(real_pos_end) ;['##$' param '='];['' value_param ''] ; content(real_pos_st)]
                break;
            end
        end
        
    end
    
    %  safas
else
    real_pos_end=where(1,1)-2;
    real_pos_st=where(1,1)+1;
    
end
if number==1
        value_before         = (char(content(where)));

content2=[content(1:real_pos_end) ;['##$' param '='];['' value_param ''] ; content(real_pos_st:end)];
else
content2=[content(1:real_pos_end) ;['##$' param '='];content(real_pos_st-1:real_pos_st+number-3);['' value_param ''] ; content(real_pos_st+number+2-3:end)];
    value_before         = (char(content(real_pos_st+number-3+1)));


end
f_out=fopen(str_out,'w');
first=1;
for loop_over_content2=1:size(content2,1)
    toto=content2(loop_over_content2);
    temp=toto{1};
    if (  strmatch('##',temp) )
        if first==1
            first=0;
        else
            fprintf(f_out,'\n');count_for_end_of_line=0;
        end
    else
        if  strmatch('$$',temp)
            % fprintf(f_out,'\n');
            
        else
            if ~don_t
                % normally put space but....
                if count_for_end_of_line>max_for_return,
                    count_for_end_of_line=0;
                    fprintf(f_out,'\n');count_for_end_of_line=0;
                else
                    fprintf(f_out,' ');
                end
            else
                don_t=0;
            end
        end
    end
    if  strmatch('$$',temp)
        fprintf(f_out,'\n');count_for_end_of_line=0;
        
    end
    %here print
    fprintf(f_out,'%s',temp);
    count_for_end_of_line=count_for_end_of_line+length(temp)+1;
    
    %here end print
    if  strmatch('(0',temp)
        fprintf(f_out,'\n');  count_for_end_of_line=0;
        don_t=1;
    end
end
fprintf(f_out,'\n');
fclose(f_out);
if ~exist([str_in '_orig'],'file')
    copyfile(str_in,[str_in '_orig']);
end
   movefile( str_out,path);
end