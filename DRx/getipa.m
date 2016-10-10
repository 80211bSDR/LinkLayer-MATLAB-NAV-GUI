function ipa = getipa()
ipa = uint8(0); %#ok<NASGU>
[r,hst] = system('hostname');
if (r)
    if (ispc), hst=getenv('COMPUTERNAME');
    else hst=getenv('HOSTNAME'); end
end % END IF ~R
if strncmpi(hst,'bdroz-OptiPlex',14)
    ipa = uint8(103);
elseif strncmpi(hst,'bdroz-Precision',15)
    ipa = uint8(202);
elseif strncmpi(hst,'bdroz-Vostro',12)
    ipa = uint8(102);
elseif strncmpi(hst,'curie',5)
    ipa = uint8(202);
else
    f = findsdru;
    ipa = uint8(str2double(strrep(f.IPAddress(end-4:end),'.','')));
end % END IF STRCMPI(hst,'')
return;
end % END FUNCTION GETIPA