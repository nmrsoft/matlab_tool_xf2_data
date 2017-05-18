function xf2data_work=phase_correct(xf2data_work,phc0,phc1,dimen)
%warning('WARNING... not fully implemented - only zero order is applied');
%disp(['Applied phase correction : phc0=' num2str(phc0) ' testing  phc1']);
%disp(['Applied phase correction : phc0=' num2str(phc0) ' phc1=' num2str(phc1)]);
% phases=0*xf2data_work(:,1);%initializes
phases=zeros(size(xf2data_work,dimen),1);
phases=phases+phc0;%zero order

zero_to_one=(((1:size(xf2data_work,dimen))-1)/(size(xf2data_work,dimen)-1))';
%zero_to_one=zero_to_one-0.5;
zero_to_one=1-zero_to_one;
phases=phases+(zero_to_one)*phc1;
phases=phases*pi/180;

if dimen==1
    for loop=1:size(xf2data_work,3-dimen)
        xf2data_work(:,loop)=xf2data_work(:,loop).*exp(1i*phases);
    end
else
    for loop=1:size(xf2data_work,3-dimen)
        xf2data_work(loop,:)=xf2data_work(loop,:).*exp(1i*phases');
    end
end