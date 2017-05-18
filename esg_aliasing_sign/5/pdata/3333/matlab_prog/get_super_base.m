function [super_base user]=get_super_base(spectro,usergroup)
super_base='.';
if nargin<1
    spectro='';
end
if nargin<2
    usergroup='';
end
%super_base='/u/data/exp/stan/';%dj_mac_pro
if exist('/Volumes/lacie_case/nmr_data/nmrge500_data/data/','dir'),%for damien office
    user='djw';
    super_base=['/Volumes/lacie_case/nmr_data/nmrge500_data/data/' usergroup '/nmr/'];
     if(size(strfind(spectro,'500d'),1)~=0),%to acces direct folder
    super_base='/Volumes/lacie_case/nmr_data/nmrge500_data/data/jeannerat_direct_link/nmr/';
     end
     if(size(strfind(spectro,'500_3'),1)~=0),%to acces direct folder
    super_base=['/Volumes/lacie_case/nmr_data/nmrge500_3/data/' usergroup '/data/nmr/nmr/'];
    end
    if(size(strfind(spectro,'300'),1)~=0),
        super_base='/Volumes/lacie_case/nmr_data/nmrge300_data/data/';
    end
    if(size(strfind(spectro,'300b'),1)~=0)
        super_base='/Volumes/lacie_case/nmr_data/nmrge300b_data/data/';
        if(size(strfind(usergroup,'sistare'),1)~=0)
            super_base=[super_base usergroup '/data/nmr/nmr/'];
        end
        if(size(strfind(usergroup,'nmr'),1)~=0)
            super_base=[super_base usergroup '/data/nmr/nmr/'];
        end
    end
end
if exist('/Users/esistare/Desktop/NMR/sistare/nmr/','dir'),%for eduard /nmr/NMR500/
    user='esgw';
    super_base='/Users/esistare/Desktop/NMR/';
    if(size(strfind(spectro,'500'),1)~=0),
        super_base='/Users/esistare/Desktop/NMR/sistare/nmr/NMR500/';
    end
    if(size(strfind(spectro,'300'),1)~=0),
        super_base='/Users/esistare/Desktop/NMR/sistare/nmr/NMR300/';
    end
    if(size(strfind(spectro,'300b'),1)~=0),
        super_base='/Users/esistare/Desktop/NMR/sistare/nmr/NMR300b/';
    end
end

end

%%if exist('C:\Users\User\Desktop\NMR500/'),%for eduard /nmr/NMR500/
   