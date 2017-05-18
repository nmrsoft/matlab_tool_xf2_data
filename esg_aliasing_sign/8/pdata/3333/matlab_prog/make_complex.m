function out=make_complex(xf2data_work)
% transform real data by pairs into complexe data in first dimension of
% input
out=zeros(size(xf2data_work,1)/2,size(xf2data_work,2));
for lo=1:size(out,1)
   out(lo,:)=xf2data_work((lo-1)*2+1,:)+1i*xf2data_work((lo-1)*2+2,:);
end
end