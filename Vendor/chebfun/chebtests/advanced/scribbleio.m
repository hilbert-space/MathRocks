function pass = scribbleio
% Tests that scribble responds to the expected input and output
% configurations

pass = [];

%% scribble does not fail / gives a default string with no inputs
try
    f = scribble;
    pass(end+1) = isa(f,'chebfun');
catch
    pass(end+1) = false;
end

%% scribble can take a single string and return a chebfun
try
    f = scribble('l');
    pass(end+1) = isa(f,'chebfun') && all(size(f) == [Inf 1]);
catch
    pass(end+1) = false;
end

%% scribble can take a string and number and return a quasimatrix
try
    f = scribble('ll',3);
    pass(end+1) = isa(f,'chebfun') && all(size(f) == [Inf 2]);
catch
    pass(end+1) = false;
end

%% scribble can take N >= 2 strings and return a quasimatrix
try
    f = scribble('l','l');
    pass(end+1) = isa(f,'chebfun') && all(size(f) == [Inf 2]);
catch
    pass(end+1) = false;
end

%% scribble can take N >= 2 strings and return a quasimatrix
try
    f = scribble('l','l','l');
    pass(end+1) = isa(f,'chebfun') && all(size(f) == [Inf 3]);
catch
    pass(end+1) = false;
end

%% scribble can take an N-element cell array and return a quasimatrix
try
    f = scribble({'l','l','l'});
    pass(end+1) = isa(f,'chebfun') && all(size(f) == [Inf 3]);
catch
    pass(end+1) = false;
end

%% scribble can print the entire USA QWERTY keyboard with no error
try
    f = scribble(['`1234567890-=qwertyuiop[]\asdfghjkl;''zxcvbnm,./', ...
        '~!@#$%^&*()_+{}|:"<>?']);
    pass(end+1) = isa(f,'chebfun') && all(size(f) == [Inf 1]);
catch
    pass(end+1) = false;
end