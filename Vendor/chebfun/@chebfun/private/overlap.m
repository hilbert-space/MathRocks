function [f,g] = overlap(f,g)
% OVERLAP chebfuns
%
% [fout,gout] = OVERLAP(f,g) returns two chebfuns such that
% fout.ends==gout.ends 

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if ( ~isa(f, 'chebfun') )
    [g, f] = overlap(g, f);
    return
end

if isnumeric(g) && numel(g) == 1
    g = 0*f + g;
    return
end

if isa(g,'domain') || isnumeric(g)
    g = chebfun(1,g);
end

if f.trans ~= g.trans
    error('CHEBFUN:overlap:trans','The .trans field of the two chebfuns must agree')
end

fends=f.ends; gends=g.ends;
frows=size(f.imps,1); grows=size(g.imps,1); maxrows=max(frows,grows);
fimps=f.imps; gimps=g.imps;
if length(fends)==length(gends) && all(fends==gends)

    f.imps=[fimps; zeros(maxrows-frows,length(fends))];
    g.imps=[gimps; zeros(maxrows-grows,length(fends))];    

else
    
    hs = hscale(f);
    if norm([fends(1)-gends(1), fends(end)-gends(end)],inf) > 1e-15*hs
       error('CHEBFUN:overlap:domains','Inconsitent domains, domain(f) ~= domain(g)')
    end
    ends=union(fends,gends);
    
    % If ends(i) is too close to ends(i+1), merge them: ------------------
    if min(diff(ends))<1e-13*hs   % LNT has changed this from 1e-15
        for k=1:length(fends)
            [delta,ind]=min(abs(gends-fends(k)));
            if delta < 1e-13*hs   % LNT has changed this from 1e-15
                fends(k)=gends(ind);
                % Also need to ajust ends in funs:
                if k==1
                    f.funs(1).map.par(1) = fends(1);
                elseif k <= f.nfuns
                    f.funs(k-1).map.par(2) = fends(k);
                    f.funs(k).map.par(1) = fends(k);
                else
                    f.funs(f.nfuns).map.par(2) = fends(k);
                end
            end
        end
        f.ends = fends;
        
       % replacing with this
       ends = union(fends,gends);
       
    end
    % --------------------------------------------------------------------
    
    fk=1; gk=1;
    foutfuns=[];
    goutfuns=[];

    for k=1:length(ends)-1
        a=ends(k); b=ends(k+1);
        gfun=g.funs(gk); ffun=f.funs(fk);
        if fends(fk)==a && fends(fk+1)==b
           fk=fk+1;
        else
            if fends(fk+1)<b, fk=fk+1; ffun=f.funs(fk); end
            ffun=restrict(ffun,[a,b]);
        end
        if  gends(gk)==a && gends(gk+1)==b
            gk=gk+1; 
        else
            if gends(gk+1)<b, gk=gk+1; gfun=g.funs(gk); end
            gfun=restrict(gfun,[a,b]);
        end
        foutfuns=[foutfuns ffun];  goutfuns=[goutfuns gfun];
    end
    
    foutimps = zeros(maxrows,length(ends));      
    [trash,findex,foutind]=intersect(fends,ends);
    foutimps(2:frows,foutind)=fimps(2:frows,findex);
    idx = abs(foutimps(2:end,:)) > 100*eps;
    % indices with deltas
    idx = sum(idx,1)~=0;
    % compute the average for delta indices
    if(any(idx))
        foutimps(1,idx) = 1/2*(feval(f,ends(idx), 'left')+feval(f,ends(idx),'right'));
    end
    % otherwise compute the normal function values
    if(any(~idx))
        foutimps(1,~idx)=feval(f,ends(~idx));
    end
    
    goutimps = zeros(maxrows,length(ends)); 
    [trash,gindex,goutind]=intersect(gends,ends);
    goutimps(2:grows,goutind)=gimps(2:grows,gindex);
    idx = abs(goutimps(2:end,:)) > 100*eps;
    % indices with deltas
    idx = sum(idx,1)~=0;
    % compute the average for delta indices
    if(any(idx))
        goutimps(1,idx) = 1/2*(feval(g,ends(idx), 'left')+feval(g,ends(idx),'right'));
    end
    % otherwise compute the normal function values
    if(any(~idx))
        goutimps(1,~idx)=feval(g,ends(~idx));
    end
    
    f.funs = foutfuns; f.ends = ends; f.imps = foutimps; f.nfuns = length(ends)-1;
    g.funs = goutfuns; g.ends = ends; g.imps = goutimps; g.nfuns = f.nfuns;   

end
