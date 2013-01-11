function [fout,mpts] = merge(f, varargin)
% MERGE   Try to remove breakpoints in chebfuns.
%
% F = MERGE(F) attempts to remove unescessry breakpoints from F such that
% each smooth piece has at most SPLITDEGREE number of points, SPLITDEGREE 
% being specified in CHEBFUNPREF. In SPLITTING OFF mode instead of 
% SPLITDEGREE, the parameter MAXDEGREE in CHEBFUNPREF is used.
% 
% [F, MPTS] = MERGE(F) returns the index of the merged endpoints in MPTS.
% 
% MERGE(F, INDEX) returns an equivalent chebfun representation of F
% after attempting to eliminate the endpoints specified in INDEX. 
% INDEX = 'all' is equivalent to INDEX = [2:length(F.ends)-1].
%   
% MERGE(F, INDEX, MAXDEG) restricts each smooth piece to at most
% degree MAXDEG as it attempts to eliminate break points.
%
% MERGE(F, INDEX, MAXDEG, TOL) attempts elimination of breakpoints using 
% the relative tolerance TOL.
%
% MERGE(..., PREF) attempts elimination of breakpoints according to the
% chebfun preference structure PREF.
%
% In all cases, elimination is attempted from left to right.
%
% Impulses will prevent merging at corresponding break points.
%
% Example:
%     f = chebfun(@(x) abs(x),'splitting','on');
%     [g,ind] = merge(f.^2);
%
% See also SPLITTING, CHEBFUNPREF, SIMPLIFY.

% Copyright 2011 by The University of Oxford and The Chebfun Developers. 
% See http://www.maths.ox.ac.uk/chebfun/ for Chebfun information.

if numel(f) > 1
    error('CHEBFUN:merge:quasimatrix','MERGE does not handle chebfun quasimatrices')
end

fout = f;

% Has preference structure been provided?
if nargin>1 && isstruct(varargin{end})
    nin = nargin-1;
    pref = varargin{end};
else
    nin = nargin;
    pref = chebfunpref;
end

% Deal with input arguments:
if nin == 1;
    bkpts = 2:f.nfuns;
else % Index of endpoints was provided
    bkpts = varargin{1};
    if isempty(bkpts)
        return;
    elseif ischar(bkpts) % bkpts = 'all'
        bkpts = 2:f.nfuns;
    else
        bkpts = unique(bkpts);
        if  bkpts(1) < 1 || bkpts(end) > f.nfuns+1 || any(round(bkpts)~=bkpts)
            error('CHEBFUN:merge:bkpts','Break points must be integers between 2 and length(ends)-1')
        end
        if bkpts(1)==1, bkpts = bkpts(2:end); end
        if ~isempty(bkpts) && bkpts(end)==length(f.ends), bkpts = bkpts(1:end-1); end
    end
    if nin > 2 % Maximum degree was provided
        pref.splitting = true;
        pref.splitdegree = varargin{2};
        if nin > 3 % Tolerance was provided
            pref.eps = varargin{3};
        end
    end
end

if ~pref.splitting
    maxn = pref.maxdegree+1; 
else
    maxn = pref.splitdegree+1; 
end

pref.exps = [0 0]; % This prevents a call to FINDEXPS when merging!

scl.v = f.scl;
scl.h = hscale(f);
mpts = [];

for k = bkpts  
    
    xk = f.ends(k);
    j = find(xk == fout.ends,1,'first');
    
    % Prevent merging if there are impulses or chebfun lengths add to more
    % than maxn
    if ~any(f.imps(2:end,k),1) && length(fout.funs(j-1))+length(fout.funs(j)) < 1.2*maxn
        %v = feval(f, [xk, xk+eps(xk), xk-eps(xk)]);
        v(1) = f.imps(1,k);
        v(2) = f.funs(k-1).vals(end);
        v(3) = f.funs(k).vals(1);
        % Prevent merging if there are jumps (very loose tolerance) OR EXPONENTS
        if  norm(v(1) - v(2:3),inf) < 1e7*pref.eps*f.scl && ~(any(fout.funs(j-1).exps)||any(fout.funs(j).exps))
            [mergedfun, hpy] = getfun(@(x) feval(fout,x),  ... 
                               [fout.ends(j-1), fout.ends(j+1)], pref, scl);
            % merging successful                  
            if hpy 
                mpts = [mpts k];
                fout.funs = [fout.funs(1:j-2) mergedfun fout.funs(j+1:end)];
                fout.ends = [fout.ends(1:j-1) fout.ends(j+1:end)];
                fout.imps = [fout.imps(:,1:j-1) fout.imps(:,j+1:end)];
                fout.nfuns = fout.nfuns - 1;
            end
        end
    end
    
end