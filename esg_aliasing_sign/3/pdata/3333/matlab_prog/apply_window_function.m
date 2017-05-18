function xf2data_work=apply_window_function(xf2data_work,wdw,ssb,dimen)
warning('WARNING... the application of window function is not implemented!!');
%warning('WARNING... not fully implemented - only sine and sine squared');

%dimen=3-dimen;
window=ones(size(xf2data_work,dimen),1);%initializes

if dimen==1
    %   window=window+phc0;%zero order
    %  window=window*pi/180;
    for loop=1:size(xf2data_work,2)
        xf2data_work(:,loop)=xf2data_work(:,loop).*(window);
    end
    
    
elseif dimen==2
    for loop=1:size(xf2data_work,1)
        xf2data_work(loop,:)=xf2data_work(loop,:).*(window');
    end
end




end