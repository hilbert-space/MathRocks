function pass = fun2_subsref
% Subsref test for fun2 objects. 
% Alex Townsend, March 2013. 

pass = 1;
f = @(x,y) cos(x); f=fun2(f);  % any fun2.
try
    % subrefs working with single reference
    subrank = f.rank;
    % get working
    getrank = get(f,'rank');
    %
    if(abs(subrank - getrank)>0)  % that's a really bad error
        pass=0; return;
    end
    % double subreferencing. 
    f.map.for;
catch
    pass = 0;
end
end