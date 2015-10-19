function optionalInput(x,y)

if ~exist('y','var')
    y = 1;
end

disp(x);
disp(y);    