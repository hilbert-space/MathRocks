function L = promote(L)

L.oparray = oparray(@(u) chebfun(1,domain(u))*L.oparray(u));
L.varmat = varmat(@(N) myones(N)*feval(L.varmat,N));
L.isdiag = 0;

end

function I = myones(n)
    breaks = [];  numints = 1; %map = [];
    if iscell(n)
%         if numel(n) > 1, map = n{2}; end
        if numel(n) > 2, breaks = n{3}; end
        if isa(breaks,'domain'), breaks = breaks.endsandbreaks; end
        n = n{1};
    end
    if ~isempty(breaks)
        numints = numel(breaks)-1;
    end
    if numel(n) == 1, n = repmat(n,1,numints); end
    if numel(n) ~= numints
        error('LINOP:promote:numints','Vector N does not match domain D.');
    end
    I = ones(sum(n),1);
end
