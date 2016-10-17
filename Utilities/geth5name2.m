function h5name = geth5name2(filename, suffix)
%strip file extension and add .h5 index, also can add additional suffix
%useful for when you have multiple .h5 files as in co-cultures
inds = strfind(filename,'.');
h5name = [filename(1:(inds(end)-1)) suffix '.h5'];
