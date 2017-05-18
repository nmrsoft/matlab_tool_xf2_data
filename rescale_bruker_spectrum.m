function  [out, new_nc_proc, min_out, max_out]=rescale_bruker_spectrum(out)
%% rescale bruker data so taht max is between 2^28 and 2^29
min_out=min(min(min(real(out))));if min_out>0, min_out=0;end
max_out=max(max(max(real(out))));if max_out<0, max_out=0;end
r=power(2,28);
nc_change_pos= (log( max_out)-log(r))/log(2);
nc_change_neg= (log(-min_out)-log(r))/log(2);
nc_change_neg=round(max(max([nc_change_pos nc_change_neg]))-0.5);
new_nc_proc=nc_change_neg;
if nc_change_neg~=0
    out=out/power(2,nc_change_neg);
    min_out=min_out/power(2,nc_change_neg);
    max_out=max_out/power(2,nc_change_neg);
end

end
