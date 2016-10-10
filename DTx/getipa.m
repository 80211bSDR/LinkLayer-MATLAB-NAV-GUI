function ipa = getipa()
ipa = uint8(0); %#ok<NASGU>
[r,hst] = system('hostname');
if (r)
    if (ispc), hst=getenv('COMPUTERNAME');
    else hst=getenv('HOSTNAME'); end
end % END IF ~R
f = findsdru;
ipa = uint8(str2double(strrep(f.IPAddress(end-4:end),'.','')));
return;
end % END FUNCTION GETIPA